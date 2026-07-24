import 'package:app_pulse/core/constants/app_categories.dart';
import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/features/apps/presentation/providers/app_details_providers.dart';
import 'package:app_pulse/features/apps/presentation/providers/apps_list_providers.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/shared/widgets/app_icon_avatar.dart';
import 'package:app_pulse/shared/widgets/charts/hourly_usage_chart.dart';
import 'package:app_pulse/shared/widgets/charts/usage_bar_chart.dart';
import 'package:app_pulse/shared/widgets/metric_tile.dart';
import 'package:app_pulse/shared/widgets/section_header.dart';
import 'package:app_pulse/shared/widgets/session_timeline_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Per-app statistics, charts, and session history.
class AppDetailsScreen extends ConsumerWidget {
  const AppDetailsScreen({required this.packageName, super.key});

  final String packageName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(appDetailsProvider(packageName));
    final use24h = ref.watch(settingsStorageProvider).timeFormat == '24h';
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          if (data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('App details')),
              body: const Center(child: Text('App not found')),
            );
          }

          final app = data.app;
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(app.appName),
                actions: [
                  IconButton(
                    tooltip: app.isFavorite ? 'Unfavorite' : 'Favorite',
                    onPressed: () async {
                      await ref.read(appsRepositoryProvider).setFavorite(
                            packageName,
                            value: !app.isFavorite,
                          );
                      ref.invalidate(appDetailsProvider(packageName));
                      ref.invalidate(appsWithUsageProvider);
                    },
                    icon: Icon(
                      app.isFavorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                    ),
                  ),
                  IconButton(
                    tooltip: app.isPinned ? 'Unpin' : 'Pin',
                    onPressed: () async {
                      await ref.read(appsRepositoryProvider).setPinned(
                            packageName,
                            value: !app.isPinned,
                          );
                      ref.invalidate(appDetailsProvider(packageName));
                      ref.invalidate(appsWithUsageProvider);
                    },
                    icon: Icon(
                      app.isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        AppIconAvatar(
                          packageName: packageName,
                          cacheKey: app.iconCacheKey,
                          size: 80,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app.appName, style: textTheme.headlineSmall),
                              const SizedBox(height: 4),
                              Text(
                                packageName,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ActionChip(
                                    label: Text(app.category.label),
                                    onPressed: () => _pickCategory(
                                      context,
                                      ref,
                                      packageName,
                                      app.category,
                                    ),
                                  ),
                                  if (app.versionName != null)
                                    Chip(label: Text('v${app.versionName}')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      [
                        if (app.installTime != null)
                          'Installed ${app.installTime!.formatDate()}',
                        if (app.updateTime != null)
                          'Updated ${app.updateTime!.formatDate()}',
                      ].join(' · '),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SectionHeader(title: 'Usage'),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Today',
                            value: data.today.compactLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Week',
                            value: data.week.compactLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Month',
                            value: data.month.compactLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Year',
                            value: data.year.compactLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MetricTile(
                      label: 'Total tracked',
                      value: data.totalTracked.compactLabel,
                      subtitle: '${data.totalLaunches} sessions recorded',
                    ),
                    const SectionHeader(title: 'Statistics'),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Longest',
                            value: data.longestSession.compactLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Shortest',
                            value: data.shortestSession == Duration.zero
                                ? '—'
                                : data.shortestSession.compactLabel,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Average',
                            value: data.averageSession.compactLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Launches today',
                            value: '${data.launchCountToday}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Daily average',
                            value: data.dailyAverage.compactLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Weekly average',
                            value: data.weeklyAverage.compactLabel,
                          ),
                        ),
                      ],
                    ),
                    const SectionHeader(
                      title: 'Hourly',
                      subtitle: 'Today',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                        child: HourlyUsageChart(
                          minutesByHour: data.hourlyMinutes,
                        ),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Daily',
                      subtitle: 'Last 7 days',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                        child: UsageBarChart(points: data.dailyBars),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Weekly',
                      subtitle: 'Last 6 weeks',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                        child: UsageBarChart(points: data.weeklyBars),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Monthly',
                      subtitle: 'Last 6 months',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                        child: UsageBarChart(points: data.monthlyBars),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Yearly',
                      subtitle: 'Last 5 years',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                        child: UsageBarChart(points: data.yearlyBars),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Session history',
                      subtitle: 'Most recent first',
                    ),
                    if (data.sessions.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No sessions recorded for this app yet.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final session in data.sessions)
                        SessionTimelineTile(
                          appName: app.appName,
                          packageName: packageName,
                          startedAt: session.startedAt,
                          endedAt: session.endedAt,
                          duration: Duration(
                            milliseconds: session.durationMs ??
                                (session.isOngoing
                                    ? DateTime.now()
                                        .difference(session.startedAt)
                                        .inMilliseconds
                                    : 0),
                          ),
                          iconCacheKey: app.iconCacheKey,
                          isOngoing: session.isOngoing,
                          use24h: use24h,
                        ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickCategory(
    BuildContext context,
    WidgetRef ref,
    String packageName,
    AppCategory current,
  ) async {
    final selected = await showModalBottomSheet<AppCategory>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: ListView(
              children: [
                for (final category in AppCategory.values)
                  ListTile(
                    title: Text(category.label),
                    trailing: category == current
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.pop(context, category),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) {
      await updateAppCategory(ref, packageName, selected);
    }
  }
}
