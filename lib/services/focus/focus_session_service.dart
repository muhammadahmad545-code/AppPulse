import 'dart:convert';

import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:drift/drift.dart';

export 'package:app_pulse/database/app_database.dart' show FocusSession;

/// Starts, completes, and cancels offline focus sessions.
final class FocusSessionService {
  FocusSessionService({
    required AppDatabase database,
    required NotificationService notifications,
  })  : _db = database,
        _notifications = notifications;

  final AppDatabase _db;
  final NotificationService _notifications;

  static const presets = <Duration>[
    Duration(minutes: 15),
    Duration(minutes: 25),
    Duration(minutes: 45),
    Duration(minutes: 60),
    Duration(minutes: 90),
  ];

  Stream<FocusSession?> watchActive() => _db.focusDao.watchActiveSession();

  Future<FocusSession?> getActive() => _db.focusDao.getActiveSession();

  Future<int> start({
    required Duration planned,
    required List<String> blockedPackages,
  }) async {
    final existing = await getActive();
    if (existing != null) {
      throw StateError('A focus session is already active');
    }
    final now = DateTime.now();
    final id = await _db.focusDao.insertSession(
      FocusSessionsCompanion.insert(
        startedAt: now,
        plannedDurationMs: planned.inMilliseconds,
        blockedPackagesJson: jsonEncode(blockedPackages),
        status: const Value('active'),
        dayKey: now.dayKey,
      ),
    );
    await _notifications.showFocusAlert(
      title: 'Focus mode started',
      body: 'Stay on track for ${planned.inMinutes} minutes.',
      id: 5001,
    );
    AppLogger.i('Focus session $id started (${planned.inMinutes}m)');
    return id;
  }

  Future<void> complete(FocusSession session) async {
    final now = DateTime.now();
    final actual = now.difference(session.startedAt);
    await _db.focusDao.updateSession(
      session.copyWith(
        endedAt: Value(now),
        actualDurationMs: Value(actual.inMilliseconds),
        status: 'completed',
      ),
    );
    await _notifications.showFocusAlert(
      title: 'Focus complete',
      body: 'Nice work — ${actual.inMinutes} focused minutes.',
      id: 5002,
    );
  }

  Future<void> cancel(FocusSession session) async {
    final now = DateTime.now();
    final actual = now.difference(session.startedAt);
    await _db.focusDao.updateSession(
      session.copyWith(
        endedAt: Value(now),
        actualDurationMs: Value(actual.inMilliseconds),
        status: 'cancelled',
      ),
    );
    await _notifications.showFocusAlert(
      title: 'Focus cancelled',
      body: 'Session ended early.',
      id: 5003,
    );
  }

  Future<FocusDayStats> statsForToday() async {
    final sessions =
        await _db.focusDao.getSessionsForDay(DateTime.now().dayKey);
    var completed = 0;
    var totalMs = 0;
    for (final session in sessions) {
      if (session.status == 'completed') {
        completed += 1;
        totalMs += session.actualDurationMs ?? 0;
      }
    }
    return FocusDayStats(
      completedCount: completed,
      totalFocused: Duration(milliseconds: totalMs),
      sessions: sessions,
    );
  }

  /// If an active session's planned duration elapsed, auto-complete it.
  Future<FocusSession?> tick() async {
    final active = await getActive();
    if (active == null) return null;
    final elapsed = DateTime.now().difference(active.startedAt);
    if (elapsed.inMilliseconds >= active.plannedDurationMs) {
      await complete(active);
      return null;
    }
    return active;
  }
}

final class FocusDayStats {
  const FocusDayStats({
    required this.completedCount,
    required this.totalFocused,
    required this.sessions,
  });

  final int completedCount;
  final Duration totalFocused;
  final List<FocusSession> sessions;
}
