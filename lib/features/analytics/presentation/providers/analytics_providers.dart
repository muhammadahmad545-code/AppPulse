import 'package:app_pulse/core/constants/app_categories.dart';
import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/shared/widgets/charts/usage_bar_chart.dart';
import 'package:app_pulse/shared/widgets/charts/usage_pie_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AnalyticsPeriod { last7Days, last30Days, thisMonth }

final analyticsPeriodProvider =
    NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>(
  AnalyticsPeriodNotifier.new,
);

class AnalyticsPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() => AnalyticsPeriod.last7Days;

  void setPeriod(AnalyticsPeriod period) => state = period;
}

final analyticsSnapshotProvider =
    FutureProvider.autoDispose<AnalyticsSnapshot>((ref) async {
  final period = ref.watch(analyticsPeriodProvider);
  final sessionsDao = ref.watch(sessionsDaoProvider);
  final appsDao = ref.watch(appsDaoProvider);
  final now = DateTime.now();

  final (start, end) = switch (period) {
    AnalyticsPeriod.last7Days => (
        now.subtract(const Duration(days: 6)).startOfDay,
        now.endOfDay,
      ),
    AnalyticsPeriod.last30Days => (
        now.subtract(const Duration(days: 29)).startOfDay,
        now.endOfDay,
      ),
    AnalyticsPeriod.thisMonth => (now.startOfMonth, now.endOfMonth),
  };

  final sessions = await sessionsDao.getSessionsInRange(start, end);
  final apps = await appsDao.getAllApps(includeHidden: true);
  final appByPackage = {for (final app in apps) app.packageName: app};

  final usageByPackage = <String, int>{};
  final launchesByPackage = <String, int>{};
  final categoryMs = <AppCategory, int>{};
  final sessionDurations = <({String package, int ms})>[];
  var morning = 0;
  var afternoon = 0;
  var evening = 0;
  var night = 0;
  var weekday = 0;
  var weekend = 0;
  final heatmap = List.generate(7, (_) => List<double>.filled(24, 0));

  for (final session in sessions) {
    final ms = session.durationMs ?? 0;
    if (ms <= 0) continue;

    usageByPackage[session.packageName] =
        (usageByPackage[session.packageName] ?? 0) + ms;
    launchesByPackage[session.packageName] =
        (launchesByPackage[session.packageName] ?? 0) + 1;
    sessionDurations.add((package: session.packageName, ms: ms));

    final app = appByPackage[session.packageName];
    final category = AppCategory.fromStorage(app?.category);
    categoryMs[category] = (categoryMs[category] ?? 0) + ms;

    final hour = session.startedAt.hour;
    if (hour >= 5 && hour < 12) {
      morning += ms;
    } else if (hour >= 12 && hour < 17) {
      afternoon += ms;
    } else if (hour >= 17 && hour < 22) {
      evening += ms;
    } else {
      night += ms;
    }

    final weekdayIndex = session.startedAt.weekday; // 1=Mon .. 7=Sun
    if (weekdayIndex >= DateTime.saturday) {
      weekend += ms;
    } else {
      weekday += ms;
    }

    heatmap[weekdayIndex - 1][hour] += ms / 60000;
  }

  final totalMs = usageByPackage.values.fold<int>(0, (s, v) => s + v);
  final rankedUsage = usageByPackage.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final rankedLaunches = launchesByPackage.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final rankedSessions = [...sessionDurations]
    ..sort((a, b) => b.ms.compareTo(a.ms));

  String nameOf(String package) =>
      appByPackage[package]?.appName ?? package;

  final mostUsed = rankedUsage
      .take(8)
      .map(
        (e) => RankedApp(
          packageName: e.key,
          appName: nameOf(e.key),
          valueLabel: Duration(milliseconds: e.value).compactLabel,
          sortValue: e.value.toDouble(),
        ),
      )
      .toList(growable: false);

  final leastUsed = rankedUsage.reversed
      .where((e) => e.value > 0)
      .take(8)
      .map(
        (e) => RankedApp(
          packageName: e.key,
          appName: nameOf(e.key),
          valueLabel: Duration(milliseconds: e.value).compactLabel,
          sortValue: e.value.toDouble(),
        ),
      )
      .toList(growable: false);

  final mostOpened = rankedLaunches
      .take(8)
      .map(
        (e) => RankedApp(
          packageName: e.key,
          appName: nameOf(e.key),
          valueLabel: '${e.value} opens',
          sortValue: e.value.toDouble(),
        ),
      )
      .toList(growable: false);

  final longest = rankedSessions
      .take(5)
      .map(
        (e) => RankedApp(
          packageName: e.package,
          appName: nameOf(e.package),
          valueLabel: Duration(milliseconds: e.ms).compactLabel,
          sortValue: e.ms.toDouble(),
        ),
      )
      .toList(growable: false);

  final shortest = rankedSessions.reversed
      .take(5)
      .map(
        (e) => RankedApp(
          packageName: e.package,
          appName: nameOf(e.package),
          valueLabel: Duration(milliseconds: e.ms).compactLabel,
          sortValue: e.ms.toDouble(),
        ),
      )
      .toList(growable: false);

  final avgSession = sessionDurations.isEmpty
      ? Duration.zero
      : Duration(
          milliseconds: totalMs ~/ sessionDurations.length,
        );

  final categorySlices = categoryMs.entries
      .where((e) => e.value > 0)
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final pieSlices = categorySlices
      .map(
        (e) => PieSlice(
          label: e.key.label,
          duration: Duration(milliseconds: e.value),
        ),
      )
      .toList(growable: false);

  double pct(int part) =>
      totalMs == 0 ? 0 : (part / totalMs) * 100;

  final categoryPercents = {
    for (final entry in categorySlices)
      entry.key: pct(entry.value),
  };

  final timeOfDayBars = [
    BarPoint(label: 'Morning', duration: Duration(milliseconds: morning)),
    BarPoint(label: 'Afternoon', duration: Duration(milliseconds: afternoon)),
    BarPoint(label: 'Evening', duration: Duration(milliseconds: evening)),
    BarPoint(label: 'Night', duration: Duration(milliseconds: night)),
  ];

  final weekdayCompare = [
    BarPoint(label: 'Weekday', duration: Duration(milliseconds: weekday)),
    BarPoint(label: 'Weekend', duration: Duration(milliseconds: weekend)),
  ];

  return AnalyticsSnapshot(
    total: Duration(milliseconds: totalMs),
    sessionCount: sessionDurations.length,
    averageSession: avgSession,
    mostUsed: mostUsed,
    leastUsed: leastUsed,
    mostOpened: mostOpened,
    longestSessions: longest,
    shortestSessions: shortest,
    categorySlices: pieSlices,
    categoryPercents: categoryPercents,
    timeOfDayBars: timeOfDayBars,
    weekdayCompare: weekdayCompare,
    heatmap: heatmap,
    socialPercent: categoryPercents[AppCategory.social] ?? 0,
    entertainmentPercent: categoryPercents[AppCategory.entertainment] ?? 0,
    gamingPercent: categoryPercents[AppCategory.gaming] ?? 0,
    educationPercent: categoryPercents[AppCategory.education] ?? 0,
    productivityPercent: categoryPercents[AppCategory.productivity] ?? 0,
    financePercent: categoryPercents[AppCategory.finance] ?? 0,
    shoppingPercent: categoryPercents[AppCategory.shopping] ?? 0,
    healthPercent: categoryPercents[AppCategory.health] ?? 0,
  );
});

final class RankedApp extends Equatable {
  const RankedApp({
    required this.packageName,
    required this.appName,
    required this.valueLabel,
    required this.sortValue,
  });

  final String packageName;
  final String appName;
  final String valueLabel;
  final double sortValue;

  @override
  List<Object?> get props => [packageName, appName, valueLabel, sortValue];
}

final class AnalyticsSnapshot extends Equatable {
  const AnalyticsSnapshot({
    required this.total,
    required this.sessionCount,
    required this.averageSession,
    required this.mostUsed,
    required this.leastUsed,
    required this.mostOpened,
    required this.longestSessions,
    required this.shortestSessions,
    required this.categorySlices,
    required this.categoryPercents,
    required this.timeOfDayBars,
    required this.weekdayCompare,
    required this.heatmap,
    required this.socialPercent,
    required this.entertainmentPercent,
    required this.gamingPercent,
    required this.educationPercent,
    required this.productivityPercent,
    required this.financePercent,
    required this.shoppingPercent,
    required this.healthPercent,
  });

  final Duration total;
  final int sessionCount;
  final Duration averageSession;
  final List<RankedApp> mostUsed;
  final List<RankedApp> leastUsed;
  final List<RankedApp> mostOpened;
  final List<RankedApp> longestSessions;
  final List<RankedApp> shortestSessions;
  final List<PieSlice> categorySlices;
  final Map<AppCategory, double> categoryPercents;
  final List<BarPoint> timeOfDayBars;
  final List<BarPoint> weekdayCompare;
  final List<List<double>> heatmap;
  final double socialPercent;
  final double entertainmentPercent;
  final double gamingPercent;
  final double educationPercent;
  final double productivityPercent;
  final double financePercent;
  final double shoppingPercent;
  final double healthPercent;

  bool get isEmpty => sessionCount == 0;

  @override
  List<Object?> get props => [
        total,
        sessionCount,
        averageSession,
        mostUsed,
        leastUsed,
        mostOpened,
        longestSessions,
        shortestSessions,
        categorySlices,
        categoryPercents,
        timeOfDayBars,
        weekdayCompare,
        heatmap,
        socialPercent,
        entertainmentPercent,
        gamingPercent,
        educationPercent,
        productivityPercent,
        financePercent,
        shoppingPercent,
        healthPercent,
      ];
}
