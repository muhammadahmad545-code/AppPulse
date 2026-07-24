import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:app_pulse/services/usage/session_reconstructor.dart';
import 'package:app_pulse/services/usage/summary_aggregator.dart';
import 'package:drift/drift.dart';

/// Pulls UsageEvents from Android and persists sessions + summaries in Drift.
final class UsageSyncService {
  UsageSyncService({
    required AppDatabase database,
    required SettingsStorage settings,
    required UsageStatsPlatform platform,
    SessionReconstructor reconstructor = const SessionReconstructor(),
    SummaryAggregator? aggregator,
  })  : _db = database,
        _settings = settings,
        _platform = platform,
        _reconstructor = reconstructor,
        _aggregator = aggregator ?? SummaryAggregator(database);

  final AppDatabase _db;
  final SettingsStorage _settings;
  final UsageStatsPlatform _platform;
  final SessionReconstructor _reconstructor;
  final SummaryAggregator _aggregator;

  bool _running = false;

  /// Syncs usage since the last checkpoint (or last 7 days on first run).
  Future<UsageSyncResult> sync({bool forceFullDay = false}) async {
    if (_running) {
      return const UsageSyncResult(skipped: true, reason: 'already_running');
    }
    _running = true;
    try {
      if (!_settings.trackingEnabled) {
        return const UsageSyncResult(skipped: true, reason: 'tracking_disabled');
      }
      if (!await _platform.hasUsagePermission()) {
        await _settings.setUsageAccessGranted(false);
        return const UsageSyncResult(
          skipped: true,
          reason: 'usage_permission_denied',
        );
      }
      await _settings.setUsageAccessGranted(true);

      final now = DateTime.now();
      await _handleCalendarEdgeCases(now);

      final lastSyncMs = _settings.lastUsageSyncMs;
      final defaultStart = now.subtract(const Duration(days: 7)).startOfDay;
      final start = forceFullDay
          ? now.startOfDay
          : (lastSyncMs == null
              ? defaultStart
              : DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
                  .subtract(const Duration(minutes: 2)));

      final events = await _platform.getUsageEvents(start: start, end: now);
      final sessions = _reconstructor.reconstruct(
        events,
        now: now,
        ownPackageName: AppConstants.packageName,
      );

      await _db.transaction(() async {
        await _db.sessionsDao.closeAllOngoing(endedAt: start);
        await _db.sessionsDao.deleteClosedSessionsInRange(start, now);

        final companions = sessions.map((session) {
          return UsageSessionsCompanion.insert(
            packageName: session.packageName,
            startedAt: session.startedAt,
            endedAt: Value(session.isOngoing ? null : session.endedAt),
            durationMs: Value(session.duration.inMilliseconds),
            dayKey: session.dayKey,
            isOngoing: Value(session.isOngoing),
          );
        }).toList(growable: false);

        await _db.sessionsDao.insertSessions(companions);
      });

      final dayKeys = <String>{
        ...sessions.map((s) => s.dayKey),
        now.dayKey,
        if (lastSyncMs != null)
          DateTime.fromMillisecondsSinceEpoch(lastSyncMs).dayKey,
      };
      await _aggregator.reaggregateDays(dayKeys);

      for (final session in sessions) {
        await _db.appsDao.updateLastOpened(
          session.packageName,
          session.endedAt,
        );
      }

      await _settings.setLastUsageSyncMs(now.millisecondsSinceEpoch);
      AppLogger.i(
        'Usage sync complete: ${events.length} events → ${sessions.length} sessions',
      );

      final foreground = await _platform.getForegroundApp();
      return UsageSyncResult(
        eventCount: events.length,
        sessionCount: sessions.length,
        foregroundPackage: foreground,
      );
    } catch (error, stack) {
      AppLogger.e('Usage sync failed', error, stack);
      return UsageSyncResult(skipped: true, reason: 'error: $error');
    } finally {
      _running = false;
    }
  }

  Future<void> _handleCalendarEdgeCases(DateTime now) async {
    final offset = now.timeZoneOffset.inMinutes;
    final previousOffset = _settings.lastKnownTimeZoneOffsetMinutes;
    if (previousOffset != null && previousOffset != offset) {
      AppLogger.i(
        'Timezone offset changed ($previousOffset → $offset); forcing day rebuild',
      );
      await _aggregator.reaggregateDays({now.dayKey});
    }
    await _settings.setLastKnownTimeZoneOffsetMinutes(offset);

    final previousDay = _settings.lastKnownDayKey;
    if (previousDay != null && previousDay != now.dayKey) {
      AppLogger.i('Day rolled over ($previousDay → ${now.dayKey})');
      await _aggregator.reaggregateDays({previousDay, now.dayKey});
    }
    await _settings.setLastKnownDayKey(now.dayKey);
  }
}

final class UsageSyncResult {
  const UsageSyncResult({
    this.skipped = false,
    this.reason,
    this.eventCount = 0,
    this.sessionCount = 0,
    this.foregroundPackage,
  });

  final bool skipped;
  final String? reason;
  final int eventCount;
  final int sessionCount;
  final String? foregroundPackage;
}
