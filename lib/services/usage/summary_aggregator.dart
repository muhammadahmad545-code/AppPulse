import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/services/usage/session_reconstructor.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

/// Rebuilds daily / weekly / monthly / hourly aggregates from sessions.
final class SummaryAggregator {
  SummaryAggregator(this._db);

  final AppDatabase _db;

  Future<void> reaggregateDays(Set<String> dayKeys) async {
    for (final dayKey in dayKeys) {
      await _reaggregateDay(dayKey);
    }
  }

  Future<void> _reaggregateDay(String dayKey) async {
    final day = DateTime.parse(dayKey);
    final start = day.startOfDay;
    final end = day.endOfDay;

    final sessions = await _db.sessionsDao.getSessionsInRange(start, end);
    final byPackage = <String, _Bucket>{};
    final hourly = <String, Map<int, int>>{};

    for (final session in sessions) {
      if (session.durationMs == null || session.durationMs! <= 0) continue;
      final bucket = byPackage.putIfAbsent(
        session.packageName,
        _Bucket.new,
      );
      bucket.totalMs += session.durationMs!;
      bucket.launches += 1;
      bucket.longestMs = bucket.longestMs == 0
          ? session.durationMs!
          : (session.durationMs! > bucket.longestMs
              ? session.durationMs!
              : bucket.longestMs);
      bucket.shortestMs = bucket.shortestMs == 0
          ? session.durationMs!
          : (session.durationMs! < bucket.shortestMs
              ? session.durationMs!
              : bucket.shortestMs);

      _distributeHourly(
        hourly.putIfAbsent(session.packageName, () => {}),
        session.startedAt,
        session.endedAt ?? session.startedAt,
        session.durationMs!,
      );
    }

    await _db.transaction(() async {
      await (_db.delete(_db.dailySummaries)
            ..where((t) => t.dayKey.equals(dayKey)))
          .go();
      await (_db.delete(_db.hourlyUsage)
            ..where((t) => t.dayKey.equals(dayKey)))
          .go();

      for (final entry in byPackage.entries) {
        await _db.summariesDao.upsertDaily(
          DailySummariesCompanion.insert(
            packageName: entry.key,
            dayKey: dayKey,
            totalDurationMs: Value(entry.value.totalMs),
            launchCount: Value(entry.value.launches),
            longestSessionMs: Value(entry.value.longestMs),
            shortestSessionMs: Value(entry.value.shortestMs),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      for (final packageEntry in hourly.entries) {
        for (final hourEntry in packageEntry.value.entries) {
          await _db.summariesDao.upsertHourly(
            HourlyUsageCompanion.insert(
              packageName: packageEntry.key,
              dayKey: dayKey,
              hour: hourEntry.key,
              durationMs: Value(hourEntry.value),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    });

    await _reaggregateWeek(day);
    await _reaggregateMonth(day);
  }

  Future<void> _reaggregateWeek(DateTime day) async {
    final weekKey = _weekKey(day);
    final start = day.startOfWeek;
    final end = day.endOfWeek;
    final sessions = await _db.sessionsDao.getSessionsInRange(start, end);
    final totals = <String, ({int ms, int launches})>{};

    for (final session in sessions) {
      if (session.durationMs == null) continue;
      final current = totals[session.packageName] ?? (ms: 0, launches: 0);
      totals[session.packageName] = (
        ms: current.ms + session.durationMs!,
        launches: current.launches + 1,
      );
    }

    await (_db.delete(_db.weeklySummaries)
          ..where((t) => t.weekKey.equals(weekKey)))
        .go();

    for (final entry in totals.entries) {
      await _db.summariesDao.upsertWeekly(
        WeeklySummariesCompanion.insert(
          packageName: entry.key,
          weekKey: weekKey,
          totalDurationMs: Value(entry.value.ms),
          launchCount: Value(entry.value.launches),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _reaggregateMonth(DateTime day) async {
    final monthKey = DateFormat('yyyy-MM').format(day);
    final start = day.startOfMonth;
    final end = day.endOfMonth;
    final sessions = await _db.sessionsDao.getSessionsInRange(start, end);
    final totals = <String, ({int ms, int launches})>{};

    for (final session in sessions) {
      if (session.durationMs == null) continue;
      final current = totals[session.packageName] ?? (ms: 0, launches: 0);
      totals[session.packageName] = (
        ms: current.ms + session.durationMs!,
        launches: current.launches + 1,
      );
    }

    await (_db.delete(_db.monthlySummaries)
          ..where((t) => t.monthKey.equals(monthKey)))
        .go();

    for (final entry in totals.entries) {
      await _db.summariesDao.upsertMonthly(
        MonthlySummariesCompanion.insert(
          packageName: entry.key,
          monthKey: monthKey,
          totalDurationMs: Value(entry.value.ms),
          launchCount: Value(entry.value.launches),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  void _distributeHourly(
    Map<int, int> hours,
    DateTime start,
    DateTime end,
    int totalMs,
  ) {
    if (totalMs <= 0 || !end.isAfter(start)) {
      hours[start.hour] = (hours[start.hour] ?? 0) + totalMs;
      return;
    }

    var cursor = start;
    var remaining = totalMs;
    while (cursor.isBefore(end) && remaining > 0) {
      final hourEnd = DateTime(
        cursor.year,
        cursor.month,
        cursor.day,
        cursor.hour,
      ).add(const Duration(hours: 1));
      final sliceEnd = hourEnd.isBefore(end) ? hourEnd : end;
      final sliceMs = sliceEnd.difference(cursor).inMilliseconds;
      final applied = sliceMs.clamp(0, remaining);
      hours[cursor.hour] = (hours[cursor.hour] ?? 0) + applied;
      remaining -= applied;
      cursor = sliceEnd;
    }
  }

  String _weekKey(DateTime day) => day.weekKey;

  /// Convenience for regenerating from an in-memory session list's day keys.
  Future<void> reaggregateFromSessions(List<ReconstructedSession> sessions) {
    final keys = sessions.map((s) => s.dayKey).toSet();
    return reaggregateDays(keys);
  }
}

class _Bucket {
  int totalMs = 0;
  int launches = 0;
  int longestMs = 0;
  int shortestMs = 0;
}
