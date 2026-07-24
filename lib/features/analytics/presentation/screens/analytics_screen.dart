import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:app_pulse/shared/widgets/charts/usage_bar_chart.dart';
import 'package:app_pulse/shared/widgets/charts/usage_heatmap.dart';
import 'package:app_pulse/shared/widgets/charts/usage_pie_chart.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:app_pulse/shared/widgets/metric_tile.dart';
import 'package:app_pulse/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Analytics hub: rankings, categories, time-of-day, heatmap.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final snapshot = ref.watch(analyticsSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            tooltip: 'Reports',
            onPressed: () => context.push(AppRoutes.reports),
            icon: const Icon(Icons.description_outlined),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () async {
              await ref.read(usageSyncServiceProvider).sync();
              ref.invalidate(analyticsSnapshotProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                for (final value in AnalyticsPeriod.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_periodLabel(value)),
                      selected: period == value,
                      onSelected: (_) => ref
                          .read(analyticsPeriodProvider.notifier)
                          .setPeriod(value),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: snapshot.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (data) {
                if (data.isEmpty) {
                  return const FeatureEmptyState(
                    icon: Icons.insights_rounded,
                    title: 'Analytics unlock with data',
                    message:
                        'Most used apps, category mixes, time-of-day patterns, '
                        'and heatmaps appear after sessions are recorded.',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Total',
                            value: data.total.compactLabel,
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Sessions',
                            value: '${data.sessionCount}',
                            subtitle: 'Avg ${data.averageSession.compactLabel}',
                            icon: Icons.layers_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SectionHeader(
                      title: 'Categories',
                      subtitle: 'Share of screen time',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: UsagePieChart(slices: data.categorySlices),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PercentChip('Social', data.socialPercent),
                        _PercentChip('Entertainment', data.entertainmentPercent),
                        _PercentChip('Gaming', data.gamingPercent),
                        _PercentChip('Education', data.educationPercent),
                        _PercentChip('Productivity', data.productivityPercent),
                        _PercentChip('Finance', data.financePercent),
                        _PercentChip('Shopping', data.shoppingPercent),
                        _PercentChip('Health', data.healthPercent),
                      ],
                    ),
                    const SectionHeader(
                      title: 'Time of day',
                      subtitle: 'Morning · Afternoon · Evening · Night',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                        child: UsageBarChart(points: data.timeOfDayBars),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Weekday vs weekend',
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                        child: UsageBarChart(points: data.weekdayCompare),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Usage heatmap',
                      subtitle: 'Weekday × hour',
                    ),
                    Card(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16),
                        child: UsageHeatmap(matrix: data.heatmap),
                      ),
                    ),
                    const SectionHeader(title: 'Most used apps'),
                    _RankedCard(items: data.mostUsed),
                    const SectionHeader(title: 'Least used apps'),
                    _RankedCard(items: data.leastUsed),
                    const SectionHeader(title: 'Most opened apps'),
                    _RankedCard(items: data.mostOpened),
                    const SectionHeader(title: 'Longest sessions'),
                    _RankedCard(items: data.longestSessions),
                    const SectionHeader(title: 'Shortest sessions'),
                    _RankedCard(items: data.shortestSessions),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _periodLabel(AnalyticsPeriod period) {
    return switch (period) {
      AnalyticsPeriod.last7Days => '7 days',
      AnalyticsPeriod.last30Days => '30 days',
      AnalyticsPeriod.thisMonth => 'This month',
    };
  }
}

class _PercentChip extends StatelessWidget {
  const _PercentChip(this.label, this.percent);

  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label ${percent.toStringAsFixed(0)}%'),
    );
  }
}

class _RankedCard extends StatelessWidget {
  const _RankedCard({required this.items});

  final List<RankedApp> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No data'),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              leading: CircleAvatar(
                child: Text('${i + 1}'),
              ),
              title: Text(items[i].appName),
              subtitle: Text(items[i].packageName),
              trailing: Text(
                items[i].valueLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onTap: () => context.push(
                AppRoutes.appDetailsPath(items[i].packageName),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
