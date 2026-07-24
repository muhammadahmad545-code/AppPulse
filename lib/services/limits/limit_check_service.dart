import 'dart:convert';

import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:app_pulse/services/limits/limit_models.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:hive/hive.dart';

/// Evaluates app limits against current summaries and emits reminders.
///
/// Android does not allow third-party apps to reliably force-close other apps.
/// AppPulse notifies and reminds instead.
final class LimitCheckService {
  LimitCheckService({
    required AppDatabase database,
    required SettingsStorage settings,
    required NotificationService notifications,
    UsageStatsPlatform? platform,
    Box<dynamic>? dedupeBox,
  })  : _db = database,
        _settings = settings,
        _notifications = notifications,
        _platform = platform ?? UsageStatsPlatform(),
        _dedupe = dedupeBox;

  final AppDatabase _db;
  final SettingsStorage _settings;
  final NotificationService _notifications;
  final UsageStatsPlatform _platform;
  Box<dynamic>? _dedupe;

  static const _dedupeBoxName = 'limit_alerts_dedupe';

  Future<Box<dynamic>> _box() async {
    final existing = _dedupe;
    if (existing != null && existing.isOpen) return existing;
    _dedupe = await Hive.openBox<dynamic>(_dedupeBoxName);
    return _dedupe!;
  }

  Future<List<LimitAlert>> check({
    String? foregroundPackage,
    bool notify = true,
  }) async {
    final limits = await _db.limitsDao.getAllLimits();
    final enabled = limits.where((l) => l.isEnabled).toList();
    if (enabled.isEmpty) return const [];

    final now = DateTime.now();
    final alerts = <LimitAlert>[];
    final focusActive = await _db.focusDao.getActiveSession();
    final blocked = focusActive == null
        ? const <String>{}
        : _parsePackages(focusActive.blockedPackagesJson);

    for (final limit in enabled) {
      final type = LimitTypeStorage.fromStorage(limit.limitType);
      if (type == LimitType.custom && !_isWithinCustomWindow(limit, now)) {
        continue;
      }

      final usedMs = await _usedMs(limit, now);
      final limitMs = limit.limitDurationMs;
      if (limitMs <= 0) continue;

      final remainingMs = limitMs - usedMs;
      final app = await _db.appsDao.getByPackage(limit.packageName);
      final appName = app?.appName ?? limit.packageName;
      final action = LimitActionStorage.fromStorage(limit.actionOnReach);

      LimitAlertKind? kind;
      if (remainingMs <= 0) {
        kind = LimitAlertKind.reached;
      } else {
        final remainingMin = remainingMs / 60000;
        final primary = limit.warnAtMinutesRemaining > 0
            ? limit.warnAtMinutesRemaining
            : _settings.warnMinutesPrimary;
        final secondary = limit.secondaryWarnAtMinutesRemaining > 0
            ? limit.secondaryWarnAtMinutesRemaining
            : _settings.warnMinutesSecondary;
        if (remainingMin <= primary) {
          kind = LimitAlertKind.primaryWarn;
        } else if (remainingMin <= secondary) {
          kind = LimitAlertKind.secondaryWarn;
        }
      }
      if (kind == null) continue;

      final alert = LimitAlert(
        limitId: limit.id,
        packageName: limit.packageName,
        appName: appName,
        limitType: type,
        action: action,
        kind: kind,
        used: Duration(milliseconds: usedMs),
        limit: Duration(milliseconds: limitMs),
        remaining: Duration(milliseconds: remainingMs < 0 ? 0 : remainingMs),
      );
      alerts.add(alert);

      final inFocusSilence = focusActive != null &&
          kind != LimitAlertKind.reached &&
          !(blocked.contains(limit.packageName) &&
              foregroundPackage == limit.packageName);

      if (notify &&
          _settings.notificationsEnabled &&
          !inFocusSilence &&
          await _shouldNotify(alert, now)) {
        await _notifications.showLimitAlert(
          alert,
          fullScreen: action == LimitAction.fullScreen ||
              action == LimitAction.strict,
          silent: action == LimitAction.onlyNotify &&
              kind != LimitAlertKind.reached,
        );
        if (action == LimitAction.overlay) {
          try {
            if (await _platform.canDrawOverlays()) {
              await _platform.showLimitOverlay(
                title: alert.title,
                body: alert.body,
              );
            }
          } catch (error, stack) {
            AppLogger.w('System overlay failed', error, stack);
          }
        }
        await _markNotified(alert, now);
        AppLogger.i(
          'Limit alert: ${alert.appName} ${alert.kind.name} '
          '(${alert.used.compactLabel}/${alert.limit.compactLabel})',
        );
      }
    }

    return alerts;
  }

  bool _isWithinCustomWindow(AppLimit limit, DateTime now) {
    final start = limit.customWindowStart;
    final end = limit.customWindowEnd;
    if (start == null || end == null) return false;
    return !now.isBefore(start) && !now.isAfter(end);
  }

  Future<int> _usedMs(AppLimit limit, DateTime now) async {
    switch (LimitTypeStorage.fromStorage(limit.limitType)) {
      case LimitType.daily:
        final row =
            await _db.summariesDao.getDailyForPackage(limit.packageName, now.dayKey);
        return row?.totalDurationMs ?? 0;
      case LimitType.custom:
        final start = limit.customWindowStart ?? now.startOfDay;
        final end = limit.customWindowEnd ?? now.endOfDay;
        final sessions = await _db.sessionsDao.getSessionsInRange(
          start,
          end,
          packageName: limit.packageName,
        );
        return sessions.fold<int>(0, (s, e) => s + (e.durationMs ?? 0));
      case LimitType.weekly:
        final rows = await _db.summariesDao.getWeeklySummaries(now.weekKey);
        for (final row in rows) {
          if (row.packageName == limit.packageName) return row.totalDurationMs;
        }
        return 0;
      case LimitType.monthly:
        final rows = await _db.summariesDao.getMonthlySummaries(now.monthKey);
        for (final row in rows) {
          if (row.packageName == limit.packageName) return row.totalDurationMs;
        }
        return 0;
    }
  }

  Future<bool> _shouldNotify(LimitAlert alert, DateTime now) async {
    final box = await _box();
    final key = _dedupeKey(alert, now);
    if (box.containsKey(key)) return false;

    if (alert.kind == LimitAlertKind.reached &&
        alert.action == LimitAction.strict) {
      final last = box.get('strict_${alert.limitId}') as int?;
      if (last != null &&
          now.millisecondsSinceEpoch - last <
              const Duration(minutes: 15).inMilliseconds) {
        return false;
      }
    }

    if (alert.kind == LimitAlertKind.reached &&
        alert.action == LimitAction.delay) {
      final firstKey = 'delay_first_${alert.limitId}_${now.dayKey}';
      final first = box.get(firstKey) as int?;
      if (first == null) {
        await box.put(firstKey, now.millisecondsSinceEpoch);
        return false;
      }
      if (now.millisecondsSinceEpoch - first <
          const Duration(minutes: 2).inMilliseconds) {
        return false;
      }
    }

    return true;
  }

  Future<void> _markNotified(LimitAlert alert, DateTime now) async {
    final box = await _box();
    await box.put(_dedupeKey(alert, now), true);
    if (alert.action == LimitAction.strict &&
        alert.kind == LimitAlertKind.reached) {
      await box.put('strict_${alert.limitId}', now.millisecondsSinceEpoch);
    }
  }

  String _dedupeKey(LimitAlert alert, DateTime now) {
    final bucket = switch (alert.limitType) {
      LimitType.daily => now.dayKey,
      LimitType.custom => 'custom_${alert.limitId}',
      LimitType.weekly => now.weekKey,
      LimitType.monthly => now.monthKey,
    };
    return 'limit_${alert.limitId}_${alert.kind.name}_$bucket';
  }

  Set<String> _parsePackages(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => '$e').where((e) => e.isNotEmpty).toSet();
      }
    } catch (_) {}
    return {};
  }
}
