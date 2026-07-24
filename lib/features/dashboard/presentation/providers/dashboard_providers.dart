import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/shared/widgets/charts/usage_bar_chart.dart';
import 'package:app_pulse/shared/widgets/charts/usage_pie_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final todayScreenTimeProvider = StreamProvider.autoDispose<Duration>((ref) {
  final dayKey = DateTime.now().dayKey;
  return ref.watch(summariesDaoProvider).watchTotalDurationForDay(dayKey).map(
        (ms) => Duration(milliseconds: ms),
      );
});

final dashboardSnapshotProvider =
    FutureProvider.autoDispose<DashboardSnapshot>((ref) async {
  final summariesDao = ref.watch(summariesDaoProvider);
  final sessionsDao = ref.watch(sessionsDaoProvider);
  final appsDao = ref.watch(appsDaoProvider);
  final platform = ref.watch(usageStatsPlatformProvider);
  final now = DateTime.now();
  final todayKey = now.dayKey;
  final yesterdayKey = now.subtract(const Duration(days: 1)).dayKey;

  final todayRows = await summariesDao.getDailySummaries(todayKey);
  final yesterdayRows = await summariesDao.getDailySummaries(yesterdayKey);
  final weekRows = await summariesDao.getWeeklySummaries(now.weekKey);
  final monthRows = await summariesDao.getMonthlySummaries(now.monthKey);
  final hourlyRows = await summariesDao.getHourlyForDay(todayKey);

  final todayTotal = _sumDuration(todayRows.map((r) => r.totalDurationMs));
  final yesterdayTotal =
      _sumDuration(yesterdayRows.map((r) => r.totalDurationMs));
  final weekTotal = _sumDuration(weekRows.map((r) => r.totalDurationMs));
  final monthTotal = _sumDuration(monthRows.map((r) => r.totalDurationMs));
  final launches = todayRows.fold<int>(0, (s, r) => s + r.launchCount);

  final avgSession = launches == 0
      ? Duration.zero
      : Duration(milliseconds: todayTotal.inMilliseconds ~/ launches);

  var longestMs = 0;
  for (final row in todayRows) {
    if (row.longestSessionMs > longestMs) longestMs = row.longestSessionMs;
  }

  final ranked = [...todayRows]
    ..sort((a, b) => b.totalDurationMs.compareTo(a.totalDurationMs));

  String? mostUsedPackage;
  String? mostUsedName;
  var mostUsedMs = 0;
  String? leastUsedPackage;
  String? leastUsedName;
  var leastUsedMs = 0;

  if (ranked.isNotEmpty) {
    mostUsedPackage = ranked.first.packageName;
    mostUsedMs = ranked.first.totalDurationMs;
    leastUsedPackage = ranked.last.packageName;
    leastUsedMs = ranked.last.totalDurationMs;
    mostUsedName =
        (await appsDao.getByPackage(mostUsedPackage))?.appName ??
            mostUsedPackage;
    leastUsedName =
        (await appsDao.getByPackage(leastUsedPackage))?.appName ??
            leastUsedPackage;
  }

  final appNames = <String, String>{};
  for (final row in ranked.take(8)) {
    appNames[row.packageName] =
        (await appsDao.getByPackage(row.packageName))?.appName ??
            row.packageName;
  }

  final pieSlices = ranked.take(8).map((row) {
    return PieSlice(
      label: appNames[row.packageName] ?? row.packageName,
      duration: Duration(milliseconds: row.totalDurationMs),
    );
  }).toList(growable: false);

  final minutesByHour = List<double>.filled(24, 0);
  for (final row in hourlyRows) {
    if (row.hour >= 0 && row.hour < 24) {
      minutesByHour[row.hour] += row.durationMs / 60000;
    }
  }

  final weekBars = <BarPoint>[];
  for (var i = 0; i < 7; i++) {
    final day = now.startOfWeek.add(Duration(days: i));
    final rows = await summariesDao.getDailySummaries(day.dayKey);
    final total = _sumDuration(rows.map((r) => r.totalDurationMs));
    weekBars.add(
      BarPoint(
        label: DateFormat('E').format(day).substring(0, 1),
        duration: total,
      ),
    );
  }

  final monthBars = <BarPoint>[];
  for (var i = 5; i >= 0; i--) {
    final monthDate = DateTime(now.year, now.month - i);
    final key = monthDate.monthKey;
    final rows = await summariesDao.getMonthlySummaries(key);
    final total = _sumDuration(rows.map((r) => r.totalDurationMs));
    monthBars.add(
      BarPoint(
        label: DateFormat('MMM').format(monthDate),
        duration: total,
      ),
    );
  }

  final yesterdayCompare = yesterdayTotal.inMilliseconds == 0
      ? 0.0
      : ((todayTotal.inMilliseconds - yesterdayTotal.inMilliseconds) /
              yesterdayTotal.inMilliseconds) *
          100;

  String? foreground;
  String? foregroundName;
  try {
    foreground = await platform.getForegroundApp();
    if (foreground != null) {
      foregroundName =
          (await appsDao.getByPackage(foreground))?.appName ?? foreground;
    }
  } catch (_) {}

  final ongoing = await sessionsDao.getOngoingSession();

  return DashboardSnapshot(
    today: todayTotal,
    yesterday: yesterdayTotal,
    week: weekTotal,
    month: monthTotal,
    launchCount: launches,
    averageSession: avgSession,
    longestSession: Duration(milliseconds: longestMs),
    mostUsedAppName: mostUsedName,
    mostUsedDuration: Duration(milliseconds: mostUsedMs),
    leastUsedAppName: leastUsedName,
    leastUsedDuration: Duration(milliseconds: leastUsedMs),
    foregroundPackage: foreground,
    foregroundAppName: foregroundName,
    currentSessionDuration: ongoing == null
        ? null
        : DateTime.now().difference(ongoing.startedAt),
    appCountTrackedToday: todayRows.length,
    trendPercentVsYesterday: yesterdayCompare,
    pieSlices: pieSlices,
    hourlyMinutes: minutesByHour,
    weekBars: weekBars,
    monthBars: monthBars,
  );
});

Duration _sumDuration(Iterable<int> values) {
  final ms = values.fold<int>(0, (s, v) => s + v);
  return Duration(milliseconds: ms);
}

final class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.today,
    required this.yesterday,
    required this.week,
    required this.month,
    required this.launchCount,
    required this.averageSession,
    required this.longestSession,
    required this.mostUsedAppName,
    required this.mostUsedDuration,
    required this.leastUsedAppName,
    required this.leastUsedDuration,
    required this.foregroundPackage,
    required this.foregroundAppName,
    required this.currentSessionDuration,
    required this.appCountTrackedToday,
    required this.trendPercentVsYesterday,
    required this.pieSlices,
    required this.hourlyMinutes,
    required this.weekBars,
    required this.monthBars,
  });

  final Duration today;
  final Duration yesterday;
  final Duration week;
  final Duration month;
  final int launchCount;
  final Duration averageSession;
  final Duration longestSession;
  final String? mostUsedAppName;
  final Duration mostUsedDuration;
  final String? leastUsedAppName;
  final Duration leastUsedDuration;
  final String? foregroundPackage;
  final String? foregroundAppName;
  final Duration? currentSessionDuration;
  final int appCountTrackedToday;
  final double trendPercentVsYesterday;
  final List<PieSlice> pieSlices;
  final List<double> hourlyMinutes;
  final List<BarPoint> weekBars;
  final List<BarPoint> monthBars;

  String get todayLabel => today.compactLabel;
  String get yesterdayLabel => yesterday.compactLabel;
  String get weekLabel => week.compactLabel;
  String get monthLabel => month.compactLabel;

  String get trendLabel {
    if (yesterday.inMilliseconds == 0) return 'No yesterday baseline';
    final sign = trendPercentVsYesterday >= 0 ? '+' : '';
    return '$sign${trendPercentVsYesterday.toStringAsFixed(0)}% vs yesterday';
  }

  @override
  List<Object?> get props => [
        today,
        yesterday,
        week,
        month,
        launchCount,
        averageSession,
        longestSession,
        mostUsedAppName,
        mostUsedDuration,
        leastUsedAppName,
        leastUsedDuration,
        foregroundPackage,
        foregroundAppName,
        currentSessionDuration,
        appCountTrackedToday,
        trendPercentVsYesterday,
        pieSlices,
        hourlyMinutes,
        weekBars,
        monthBars,
      ];
}
