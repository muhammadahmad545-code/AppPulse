import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/features/apps/domain/entities/tracked_app.dart';
import 'package:app_pulse/features/settings/presentation/providers/settings_providers.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppsSortMode {
  alphabetical,
  usageToday,
  launchCount,
  recentlyUsed,
}

enum AppsFilterMode {
  all,
  favorites,
  pinned,
  userApps,
  systemApps,
}

final appsSearchQueryProvider =
    NotifierProvider<AppsSearchQueryNotifier, String>(
  AppsSearchQueryNotifier.new,
);

final appsSortModeProvider =
    NotifierProvider<AppsSortModeNotifier, AppsSortMode>(
  AppsSortModeNotifier.new,
);

final appsFilterModeProvider =
    NotifierProvider<AppsFilterModeNotifier, AppsFilterMode>(
  AppsFilterModeNotifier.new,
);

class AppsSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

class AppsSortModeNotifier extends Notifier<AppsSortMode> {
  @override
  AppsSortMode build() => AppsSortMode.usageToday;

  void setMode(AppsSortMode mode) => state = mode;
}

class AppsFilterModeNotifier extends Notifier<AppsFilterMode> {
  @override
  AppsFilterMode build() => AppsFilterMode.all;

  void setMode(AppsFilterMode mode) => state = mode;
}

final appsWithUsageProvider =
    FutureProvider.autoDispose<List<AppUsageListItem>>((ref) async {
  final includeSystem = ref.watch(showSystemAppsProvider);
  final query = ref.watch(appsSearchQueryProvider).trim().toLowerCase();
  final sort = ref.watch(appsSortModeProvider);
  final filter = ref.watch(appsFilterModeProvider);

  final result = await ref.watch(appsRepositoryProvider).getInstalledApps(
        includeSystemApps: includeSystem || filter == AppsFilterMode.systemApps,
      );
  final list = result.valueOrNull ?? const <TrackedApp>[];

  final summariesDao = ref.watch(summariesDaoProvider);
  final now = DateTime.now();

  final todayMap = {
    for (final row in await summariesDao.getDailySummaries(now.dayKey))
      row.packageName: row,
  };
  final yesterdayMap = {
    for (final row in await summariesDao.getDailySummaries(
      now.subtract(const Duration(days: 1)).dayKey,
    ))
      row.packageName: row,
  };
  final weekMap = {
    for (final row in await summariesDao.getWeeklySummaries(now.weekKey))
      row.packageName: row,
  };
  final monthMap = {
    for (final row in await summariesDao.getMonthlySummaries(now.monthKey))
      row.packageName: row,
  };

  var items = list.map((app) {
    final today = todayMap[app.packageName];
    final yesterday = yesterdayMap[app.packageName];
    final week = weekMap[app.packageName];
    final month = monthMap[app.packageName];
    final todayMs = today?.totalDurationMs ?? 0;
    final launches = today?.launchCount ?? 0;
    final avg = launches == 0
        ? Duration.zero
        : Duration(milliseconds: todayMs ~/ launches);

    return AppUsageListItem(
      app: app,
      today: Duration(milliseconds: todayMs),
      yesterday: Duration(milliseconds: yesterday?.totalDurationMs ?? 0),
      week: Duration(milliseconds: week?.totalDurationMs ?? 0),
      month: Duration(milliseconds: month?.totalDurationMs ?? 0),
      launchCount: launches,
      averageSession: avg,
    );
  }).toList();

  items = items.where((item) {
    switch (filter) {
      case AppsFilterMode.all:
        return true;
      case AppsFilterMode.favorites:
        return item.app.isFavorite;
      case AppsFilterMode.pinned:
        return item.app.isPinned;
      case AppsFilterMode.userApps:
        return !item.app.isSystemApp;
      case AppsFilterMode.systemApps:
        return item.app.isSystemApp;
    }
  }).toList();

  if (query.isNotEmpty) {
    items = items
        .where(
          (item) =>
              item.app.appName.toLowerCase().contains(query) ||
              item.app.packageName.toLowerCase().contains(query) ||
              item.app.category.label.toLowerCase().contains(query),
        )
        .toList();
  }

  items.sort((a, b) {
    if (a.app.isPinned != b.app.isPinned) {
      return a.app.isPinned ? -1 : 1;
    }
    switch (sort) {
      case AppsSortMode.alphabetical:
        return a.app.appName.toLowerCase().compareTo(b.app.appName.toLowerCase());
      case AppsSortMode.usageToday:
        return b.today.compareTo(a.today);
      case AppsSortMode.launchCount:
        return b.launchCount.compareTo(a.launchCount);
      case AppsSortMode.recentlyUsed:
        final aTime =
            a.app.lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            b.app.lastOpenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
    }
  });

  return items;
});

final class AppUsageListItem extends Equatable {
  const AppUsageListItem({
    required this.app,
    required this.today,
    required this.yesterday,
    required this.week,
    required this.month,
    required this.launchCount,
    required this.averageSession,
  });

  final TrackedApp app;
  final Duration today;
  final Duration yesterday;
  final Duration week;
  final Duration month;
  final int launchCount;
  final Duration averageSession;

  String get todayLabel => today.compactLabel;

  @override
  List<Object?> get props => [
        app,
        today,
        yesterday,
        week,
        month,
        launchCount,
        averageSession,
      ];
}
