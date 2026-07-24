import 'package:app_pulse/core/constants/app_categories.dart';
import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/features/reports/domain/usage_report.dart';
import 'package:intl/intl.dart';

/// Builds offline usage reports from Drift sessions + app catalog.
final class ReportBuilder {
  ReportBuilder(this._db);

  final AppDatabase _db;

  Future<UsageReport> build(ReportPeriod period, {DateTime? anchor}) async {
    final now = anchor ?? DateTime.now();
    final (start, end, title) = _rangeFor(period, now);

    final sessions = await _db.sessionsDao.getSessionsInRange(start, end);
    final apps = await _db.appsDao.getAllApps(includeHidden: true);
    final appByPackage = {for (final app in apps) app.packageName: app};

    final usageByPackage = <String, int>{};
    final launchesByPackage = <String, int>{};
    final categoryMs = <String, int>{};
    final dailyTotals = <String, int>{};
    var totalMs = 0;
    var longest = 0;

    for (final session in sessions) {
      final ms = session.durationMs ?? 0;
      if (ms <= 0) continue;
      totalMs += ms;
      if (ms > longest) longest = ms;
      usageByPackage[session.packageName] =
          (usageByPackage[session.packageName] ?? 0) + ms;
      launchesByPackage[session.packageName] =
          (launchesByPackage[session.packageName] ?? 0) + 1;
      dailyTotals[session.dayKey] = (dailyTotals[session.dayKey] ?? 0) + ms;

      final category = appByPackage[session.packageName]?.category ?? 'other';
      categoryMs[category] = (categoryMs[category] ?? 0) + ms;
    }

    final appRows = usageByPackage.entries.map((entry) {
      final app = appByPackage[entry.key];
      return ReportAppRow(
        packageName: entry.key,
        appName: app?.appName ?? entry.key,
        category: AppCategory.fromStorage(app?.category).label,
        durationMs: entry.value,
        launchCount: launchesByPackage[entry.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.durationMs.compareTo(a.durationMs));

    final categoryRows = categoryMs.entries.map((entry) {
      final percent = totalMs == 0 ? 0.0 : (entry.value / totalMs) * 100;
      return ReportCategoryRow(
        category: AppCategory.fromStorage(entry.key).label,
        durationMs: entry.value,
        percent: percent,
      );
    }).toList()
      ..sort((a, b) => b.durationMs.compareTo(a.durationMs));

    final sessionCount = sessions.where((s) => (s.durationMs ?? 0) > 0).length;
    final launchCount =
        launchesByPackage.values.fold<int>(0, (s, v) => s + v);

    return UsageReport(
      period: period,
      title: title,
      generatedAt: DateTime.now(),
      rangeStart: start,
      rangeEnd: end,
      totalDurationMs: totalMs,
      sessionCount: sessionCount,
      launchCount: launchCount,
      averageSessionMs: sessionCount == 0 ? 0 : totalMs ~/ sessionCount,
      longestSessionMs: longest,
      appRows: appRows,
      categoryRows: categoryRows,
      dailyTotalsMs: dailyTotals,
    );
  }

  (DateTime, DateTime, String) _rangeFor(ReportPeriod period, DateTime now) {
    switch (period) {
      case ReportPeriod.daily:
        return (
          now.startOfDay,
          now.endOfDay,
          'Daily report · ${DateFormat('MMM d, y').format(now)}',
        );
      case ReportPeriod.weekly:
        return (
          now.startOfWeek,
          now.endOfWeek,
          'Weekly report · ${DateFormat('MMM d').format(now.startOfWeek)} – '
              '${DateFormat('MMM d, y').format(now.endOfWeek)}',
        );
      case ReportPeriod.monthly:
        return (
          now.startOfMonth,
          now.endOfMonth,
          'Monthly report · ${DateFormat('MMMM y').format(now)}',
        );
      case ReportPeriod.yearly:
        return (
          now.startOfYear,
          now.endOfYear,
          'Yearly report · ${now.year}',
        );
    }
  }
}
