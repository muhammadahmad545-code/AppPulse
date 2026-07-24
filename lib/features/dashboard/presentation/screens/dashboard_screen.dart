import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:app_pulse/features/onboarding/presentation/providers/permission_providers.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:app_pulse/shared/widgets/charts/hourly_usage_chart.dart';
import 'package:app_pulse/shared/widgets/charts/usage_bar_chart.dart';
import 'package:app_pulse/shared/widgets/charts/usage_pie_chart.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:app_pulse/shared/widgets/metric_tile.dart';
import 'package:app_pulse/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main dashboard with live screen-time metrics and charts.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final permissions = ref.watch(permissionSnapshotProvider);
    final snapshot = ref.watch(dashboardSnapshotProvider);
    final trackingEnabled = ref.watch(trackingEnabledProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(usageSyncServiceProvider).sync();
          await ref.read(appCatalogSyncServiceProvider).sync(force: true);
          ref.invalidate(dashboardSnapshotProvider);
          ref.invalidate(permissionSnapshotProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: textTheme.headlineMedium),
                  Text(
                    AppConstants.tagline,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () => context.push(AppRoutes.search),
                  icon: const Icon(Icons.search_rounded),
                ),
                IconButton(
                  tooltip: 'Focus',
                  onPressed: () => context.push(AppRoutes.focus),
                  icon: const Icon(Icons.center_focus_strong_outlined),
                ),
              ],
            ),
            ...permissions.when(
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(child: Center(child: Text('$e'))),
              ],
              data: (snap) {
                if (!snap.usageAccess) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: FeatureEmptyState(
                        icon: Icons.lock_clock_outlined,
                        title: 'Usage access required',
                        message:
                            'Grant Usage Access so AppPulse can read on-device '
                            'app usage stats. No data leaves this phone.',
                        actionLabel: 'Grant permissions',
                        onAction: () => context.push(AppRoutes.permissions),
                      ),
                    ),
                  ];
                }

                return snapshot.when(
                  loading: () => [
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (e, _) => [
                    SliverFillRemaining(child: Center(child: Text('$e'))),
                  ],
                  data: (data) {
                    if (data.today == Duration.zero &&
                        data.appCountTrackedToday == 0) {
                      return [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: FeatureEmptyState(
                            icon: Icons.timer_outlined,
                            title: trackingEnabled
                                ? 'Collecting your first sessions'
                                : 'Tracking is paused',
                            message: trackingEnabled
                                ? 'Use other apps for a minute, then pull to '
                                    'refresh.'
                                : 'Enable tracking in Settings to start '
                                    'recording screen time.',
                            actionLabel: trackingEnabled
                                ? 'Sync now'
                                : 'Open settings',
                            onAction: trackingEnabled
                                ? () async {
                                    await ref
                                        .read(usageSyncServiceProvider)
                                        .sync();
                                    ref.invalidate(dashboardSnapshotProvider);
                                  }
                                : () => context.go(AppRoutes.settings),
                          ),
                        ),
                      ];
                    }

                    return [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        sliver: SliverList.list(
                          children: [
                            _HeroTimeCard(
                              label: 'Today',
                              value: data.todayLabel,
                              subtitle:
                                  '${data.launchCount} launches · '
                                  '${data.appCountTrackedToday} apps',
                              trend: data.trendLabel,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: MetricTile(
                                    label: 'Yesterday',
                                    value: data.yesterdayLabel,
                                    icon: Icons.history_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricTile(
                                    label: 'This week',
                                    value: data.weekLabel,
                                    icon: Icons.date_range_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: MetricTile(
                                    label: 'This month',
                                    value: data.monthLabel,
                                    icon: Icons.calendar_month_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricTile(
                                    label: 'Avg session',
                                    value: data.averageSession.compactLabel,
                                    icon: Icons.timelapse_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: MetricTile(
                                    label: 'Most used',
                                    value: data.mostUsedAppName ?? '—',
                                    subtitle: data.mostUsedAppName == null
                                        ? null
                                        : data.mostUsedDuration.compactLabel,
                                    icon: Icons.trending_up_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricTile(
                                    label: 'Least used',
                                    value: data.leastUsedAppName ?? '—',
                                    subtitle: data.leastUsedAppName == null
                                        ? null
                                        : data.leastUsedDuration.compactLabel,
                                    icon: Icons.trending_down_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: MetricTile(
                                    label: 'Longest session',
                                    value: data.longestSession.compactLabel,
                                    icon: Icons.hourglass_top_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricTile(
                                    label: 'Current app',
                                    value: data.foregroundAppName ?? '—',
                                    subtitle: data
                                        .currentSessionDuration?.compactLabel,
                                    icon: Icons.smartphone_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Card(
                              child: SwitchListTile(
                                secondary: Icon(
                                  trackingEnabled
                                      ? Icons.play_circle_outline
                                      : Icons.pause_circle_outline,
                                ),
                                title: const Text('Usage tracking'),
                                subtitle: Text(
                                  trackingEnabled
                                      ? 'Foreground service active'
                                      : 'Paused — no new sessions recorded',
                                ),
                                value: trackingEnabled,
                                onChanged: (value) {
                                  ref
                                      .read(trackingEnabledProvider.notifier)
                                      .setEnabled(value);
                                },
                              ),
                            ),
                            const SectionHeader(
                              title: 'Today by app',
                              subtitle: 'Share of screen time',
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: UsagePieChart(
                                  slices: data.pieSlices,
                                  centerLabel: data.todayLabel,
                                ),
                              ),
                            ),
                            const SectionHeader(
                              title: 'Hourly usage',
                              subtitle: 'Minutes per hour today',
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
                              title: 'This week',
                              subtitle: 'Daily totals',
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                                child: UsageBarChart(points: data.weekBars),
                              ),
                            ),
                            const SectionHeader(
                              title: 'Monthly trend',
                              subtitle: 'Last 6 months',
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                                child: UsageBarChart(points: data.monthBars),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTimeCard extends StatelessWidget {
  const _HeroTimeCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.trend,
  });

  final String label;
  final String value;
  final String subtitle;
  final String trend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer,
              scheme.surfaceContainerLow,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              trend,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
