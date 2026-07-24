import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/features/timeline/presentation/providers/timeline_providers.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:app_pulse/shared/widgets/session_timeline_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Chronological usage history with date-range filters.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(timelineRangeProvider);
    final sessionsAsync = ref.watch(timelineSessionsProvider);
    final use24h = ref.watch(settingsStorageProvider).timeFormat == '24h';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            tooltip: 'Custom range',
            onPressed: () => _pickCustomRange(context, ref),
            icon: const Icon(Icons.date_range_rounded),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              await ref.read(usageSyncServiceProvider).sync();
              ref.invalidate(timelineSessionsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                for (final mode in TimelineRange.values)
                  if (mode != TimelineRange.custom)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_rangeLabel(mode)),
                        selected: range == mode,
                        onSelected: (_) {
                          ref
                              .read(timelineRangeProvider.notifier)
                              .setRange(mode);
                        },
                      ),
                    ),
                FilterChip(
                  label: Text(
                    range == TimelineRange.custom
                        ? _customLabel(ref)
                        : 'Custom',
                  ),
                  selected: range == TimelineRange.custom,
                  onSelected: (_) => _pickCustomRange(context, ref),
                ),
              ],
            ),
          ),
          Expanded(
            child: sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return const FeatureEmptyState(
                    icon: Icons.view_timeline_rounded,
                    title: 'No sessions yet',
                    message:
                        'When apps are used, open and close events appear here '
                        'with duration and filters.',
                  );
                }

                String? lastDayKey;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final dayKey = item.session.startedAt.dayKey;
                    final showHeader = dayKey != lastDayKey;
                    lastDayKey = dayKey;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 12,
                              bottom: 8,
                            ),
                            child: Text(
                              DateFormat('EEEE, MMM d').format(
                                item.session.startedAt,
                              ),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        SessionTimelineTile(
                          appName: item.appName,
                          packageName: item.session.packageName,
                          startedAt: item.session.startedAt,
                          endedAt: item.session.endedAt,
                          duration: item.duration,
                          iconCacheKey: item.iconCacheKey,
                          isOngoing: item.session.isOngoing,
                          use24h: use24h,
                          onTap: () => context.push(
                            AppRoutes.appDetailsPath(item.session.packageName),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _rangeLabel(TimelineRange range) {
    return switch (range) {
      TimelineRange.today => 'Today',
      TimelineRange.yesterday => 'Yesterday',
      TimelineRange.last7Days => '7 days',
      TimelineRange.last30Days => '30 days',
      TimelineRange.thisMonth => 'This month',
      TimelineRange.thisYear => 'This year',
      TimelineRange.custom => 'Custom',
    };
  }

  static String _customLabel(WidgetRef ref) {
    final custom = ref.read(timelineCustomRangeProvider);
    if (custom == null) return 'Custom';
    final a = DateFormat('MMM d').format(custom.start);
    final b = DateFormat('MMM d').format(custom.end);
    return '$a – $b';
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 6)),
        end: now,
      ),
    );
    if (picked == null) return;
    ref.read(timelineCustomRangeProvider.notifier).setRange(
          DateTimeRangeSelection(start: picked.start, end: picked.end),
        );
    ref.read(timelineRangeProvider.notifier).setRange(TimelineRange.custom);
  }
}
