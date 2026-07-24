import 'package:app_pulse/core/constants/app_categories.dart';
import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/features/apps/domain/entities/tracked_app.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/shared/widgets/charts/usage_bar_chart.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final appDetailsProvider = FutureProvider.autoDispose
    .family<AppDetailsSnapshot?, String>((ref, packageName) async {
  final appsRepo = ref.watch(appsRepositoryProvider);
  final summariesDao = ref.watch(summariesDaoProvider);
  final sessionsDao = ref.watch(sessionsDaoProvider);
  final now = DateTime.now();

  final appResult = await appsRepo.getApp(packageName);
  final app = appResult.valueOrNull;
  if (app == null) return null;

  final today = await summariesDao.getDailyForPackage(packageName, now.dayKey);
  final weekRows = await summariesDao.getWeeklySummaries(now.weekKey);
  final monthRows = await summariesDao.getMonthlySummaries(now.monthKey);

  WeeklySummary? week;
  for (final row in weekRows) {
    if (row.packageName == packageName) {
      week = row;
      break;
    }
  }
  MonthlySummary? month;
  for (final row in monthRows) {
    if (row.packageName == packageName) {
      month = row;
      break;
    }
  }

  final sessions = await sessionsDao.getSessionsForPackage(
    packageName,
    limit: 100,
  );

  var totalMs = 0;
  var shortestMs = 0;
  var longestMs = 0;
  for (final session in sessions) {
    final ms = session.durationMs ?? 0;
    if (ms <= 0) continue;
    totalMs += ms;
    if (longestMs == 0 || ms > longestMs) longestMs = ms;
    if (shortestMs == 0 || ms < shortestMs) shortestMs = ms;
  }

  final yearStart = now.startOfYear;
  final yearSessions = await sessionsDao.getSessionsInRange(
    yearStart,
    now.endOfDay,
    packageName: packageName,
  );
  final yearMs = yearSessions.fold<int>(
    0,
    (s, session) => s + (session.durationMs ?? 0),
  );

  final hourlyRows = await summariesDao.getHourlyForDay(now.dayKey);
  final minutesByHour = List<double>.filled(24, 0);
  for (final row in hourlyRows) {
    if (row.packageName != packageName) continue;
    if (row.hour >= 0 && row.hour < 24) {
      minutesByHour[row.hour] += row.durationMs / 60000;
    }
  }

  final dailyBars = <BarPoint>[];
  for (var i = 6; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final summary =
        await summariesDao.getDailyForPackage(packageName, day.dayKey);
    dailyBars.add(
      BarPoint(
        label: DateFormat('E').format(day).substring(0, 1),
        duration: Duration(milliseconds: summary?.totalDurationMs ?? 0),
      ),
    );
  }

  final weeklyBars = <BarPoint>[];
  for (var i = 5; i >= 0; i--) {
    final weekStart = now.startOfWeek.subtract(Duration(days: 7 * i));
    final rows = await summariesDao.getWeeklySummaries(weekStart.weekKey);
    var ms = 0;
    for (final row in rows) {
      if (row.packageName == packageName) {
        ms = row.totalDurationMs;
        break;
      }
    }
    weeklyBars.add(
      BarPoint(
        label: 'W${weekStart.weekKey.split('-W').last}',
        duration: Duration(milliseconds: ms),
      ),
    );
  }

  final monthlyBars = <BarPoint>[];
  for (var i = 5; i >= 0; i--) {
    final monthDate = DateTime(now.year, now.month - i);
    final rows = await summariesDao.getMonthlySummaries(monthDate.monthKey);
    var ms = 0;
    for (final row in rows) {
      if (row.packageName == packageName) {
        ms = row.totalDurationMs;
        break;
      }
    }
    monthlyBars.add(
      BarPoint(
        label: DateFormat('MMM').format(monthDate),
        duration: Duration(milliseconds: ms),
      ),
    );
  }

  final todayMs = today?.totalDurationMs ?? 0;
  final launches = today?.launchCount ?? 0;
  final avgToday = launches == 0
      ? Duration.zero
      : Duration(milliseconds: todayMs ~/ launches);

  final daysInYear = now.difference(yearStart).inDays + 1;
  final dailyAverage = Duration(milliseconds: yearMs ~/ daysInYear);
  final weeklyAverage = Duration(milliseconds: (yearMs / (daysInYear / 7)).round());

  return AppDetailsSnapshot(
    app: app,
    today: Duration(milliseconds: todayMs),
    week: Duration(milliseconds: week?.totalDurationMs ?? 0),
    month: Duration(milliseconds: month?.totalDurationMs ?? 0),
    year: Duration(milliseconds: yearMs),
    totalTracked: Duration(milliseconds: totalMs),
    longestSession: Duration(milliseconds: longestMs),
    shortestSession: Duration(milliseconds: shortestMs),
    averageSession: avgToday,
    totalLaunches: sessions.length,
    dailyAverage: dailyAverage,
    weeklyAverage: weeklyAverage,
    launchCountToday: launches,
    hourlyMinutes: minutesByHour,
    dailyBars: dailyBars,
    weeklyBars: weeklyBars,
    monthlyBars: monthlyBars,
    sessions: sessions,
  );
});

final class AppDetailsSnapshot extends Equatable {
  const AppDetailsSnapshot({
    required this.app,
    required this.today,
    required this.week,
    required this.month,
    required this.year,
    required this.totalTracked,
    required this.longestSession,
    required this.shortestSession,
    required this.averageSession,
    required this.totalLaunches,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.launchCountToday,
    required this.hourlyMinutes,
    required this.dailyBars,
    required this.weeklyBars,
    required this.monthlyBars,
    required this.sessions,
  });

  final TrackedApp app;
  final Duration today;
  final Duration week;
  final Duration month;
  final Duration year;
  final Duration totalTracked;
  final Duration longestSession;
  final Duration shortestSession;
  final Duration averageSession;
  final int totalLaunches;
  final Duration dailyAverage;
  final Duration weeklyAverage;
  final int launchCountToday;
  final List<double> hourlyMinutes;
  final List<BarPoint> dailyBars;
  final List<BarPoint> weeklyBars;
  final List<BarPoint> monthlyBars;
  final List<UsageSession> sessions;

  String get todayLabel => today.compactLabel;

  @override
  List<Object?> get props => [
        app,
        today,
        week,
        month,
        year,
        totalTracked,
        longestSession,
        shortestSession,
        averageSession,
        totalLaunches,
        dailyAverage,
        weeklyAverage,
        launchCountToday,
        hourlyMinutes,
        dailyBars,
        weeklyBars,
        monthlyBars,
        sessions,
      ];
}

Future<void> updateAppCategory(
  WidgetRef ref,
  String packageName,
  AppCategory category,
) async {
  await ref.read(appsRepositoryProvider).setCategory(
        packageName,
        category.name,
      );
  ref.invalidate(appDetailsProvider(packageName));
}
