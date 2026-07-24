import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimelineRange {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  thisYear,
  custom,
}

final timelineRangeProvider =
    NotifierProvider<TimelineRangeNotifier, TimelineRange>(
  TimelineRangeNotifier.new,
);

final timelineCustomRangeProvider =
    NotifierProvider<TimelineCustomRangeNotifier, DateTimeRangeSelection?>(
  TimelineCustomRangeNotifier.new,
);

class TimelineRangeNotifier extends Notifier<TimelineRange> {
  @override
  TimelineRange build() => TimelineRange.today;

  void setRange(TimelineRange range) => state = range;
}

class TimelineCustomRangeNotifier
    extends Notifier<DateTimeRangeSelection?> {
  @override
  DateTimeRangeSelection? build() => null;

  void setRange(DateTimeRangeSelection? range) => state = range;
}

final class DateTimeRangeSelection extends Equatable {
  const DateTimeRangeSelection({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}

final timelineSessionsProvider =
    FutureProvider.autoDispose<List<TimelineSessionItem>>((ref) async {
  final range = ref.watch(timelineRangeProvider);
  final custom = ref.watch(timelineCustomRangeProvider);
  final sessionsDao = ref.watch(sessionsDaoProvider);
  final appsDao = ref.watch(appsDaoProvider);
  final now = DateTime.now();

  late final DateTime start;
  late final DateTime end;

  switch (range) {
    case TimelineRange.today:
      start = now.startOfDay;
      end = now.endOfDay;
    case TimelineRange.yesterday:
      final y = now.subtract(const Duration(days: 1));
      start = y.startOfDay;
      end = y.endOfDay;
    case TimelineRange.last7Days:
      start = now.subtract(const Duration(days: 6)).startOfDay;
      end = now.endOfDay;
    case TimelineRange.last30Days:
      start = now.subtract(const Duration(days: 29)).startOfDay;
      end = now.endOfDay;
    case TimelineRange.thisMonth:
      start = now.startOfMonth;
      end = now.endOfMonth;
    case TimelineRange.thisYear:
      start = now.startOfYear;
      end = now.endOfYear;
    case TimelineRange.custom:
      start = custom?.start.startOfDay ?? now.startOfDay;
      end = custom?.end.endOfDay ?? now.endOfDay;
  }

  final sessions = await sessionsDao.getSessionsInRange(start, end);
  final apps = await appsDao.getAllApps(includeHidden: true);
  final appByPackage = {
    for (final app in apps) app.packageName: app,
  };

  return [
    for (final session in sessions)
      TimelineSessionItem(
        session: session,
        appName: appByPackage[session.packageName]?.appName ??
            session.packageName,
        iconCacheKey: appByPackage[session.packageName]?.iconCacheKey,
        duration: Duration(
          milliseconds: session.durationMs ??
              (session.isOngoing
                  ? DateTime.now()
                      .difference(session.startedAt)
                      .inMilliseconds
                  : 0),
        ),
      ),
  ];
});

final class TimelineSessionItem extends Equatable {
  const TimelineSessionItem({
    required this.session,
    required this.appName,
    required this.duration,
    this.iconCacheKey,
  });

  final UsageSession session;
  final String appName;
  final String? iconCacheKey;
  final Duration duration;

  @override
  List<Object?> get props => [session, appName, iconCacheKey, duration];
}
