import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/features/reports/domain/usage_report.dart';
import 'package:app_pulse/features/reports/presentation/providers/reports_providers.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:app_pulse/shared/widgets/metric_tile.dart';
import 'package:app_pulse/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Offline reports with PDF / CSV / JSON export via the system share sheet.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _exporting = false;

  Future<void> _export(UsageReport report, ReportExportFormat format) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      await ref.read(reportExporterProvider).exportAndShare(report, format);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${format.name.toUpperCase()} ready to share')),
        );
      }
    } catch (error, stack) {
      AppLogger.e('Report export failed', error, stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(selectedReportPeriodProvider);
    final reportAsync = ref.watch(currentReportProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                for (final value in ReportPeriod.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_periodLabel(value)),
                      selected: period == value,
                      onSelected: (_) => ref
                          .read(selectedReportPeriodProvider.notifier)
                          .setPeriod(value),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (report) {
                if (report.sessionCount == 0) {
                  return FeatureEmptyState(
                    icon: Icons.description_outlined,
                    title: 'No data for this period',
                    message:
                        'Use your phone with tracking enabled, then generate '
                        '${_periodLabel(period).toLowerCase()} reports here.',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  children: [
                    Text(report.title, style: textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${report.rangeStart.formatDate()} – '
                      '${report.rangeEnd.formatDate()}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Total',
                            value: report.totalDuration.compactLabel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Sessions',
                            value: '${report.sessionCount}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            label: 'Launches',
                            value: '${report.launchCount}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricTile(
                            label: 'Avg session',
                            value: Duration(
                              milliseconds: report.averageSessionMs,
                            ).compactLabel,
                          ),
                        ),
                      ],
                    ),
                    const SectionHeader(title: 'Export'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              'Exports stay on this device until you share them.',
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_exporting)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => _export(
                                      report,
                                      ReportExportFormat.pdf,
                                    ),
                                    icon: const Icon(Icons.picture_as_pdf_outlined),
                                    label: const Text('PDF'),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: () => _export(
                                      report,
                                      ReportExportFormat.csv,
                                    ),
                                    icon: const Icon(Icons.table_chart_outlined),
                                    label: const Text('CSV'),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: () => _export(
                                      report,
                                      ReportExportFormat.json,
                                    ),
                                    icon: const Icon(Icons.data_object_outlined),
                                    label: const Text('JSON'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SectionHeader(title: 'Top apps'),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < report.appRows.length && i < 15;
                              i++) ...[
                            if (i > 0) const Divider(height: 1),
                            ListTile(
                              title: Text(report.appRows[i].appName),
                              subtitle: Text(
                                '${report.appRows[i].category} · '
                                '${report.appRows[i].launchCount} launches',
                              ),
                              trailing: Text(
                                Duration(
                                  milliseconds: report.appRows[i].durationMs,
                                ).compactLabel,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SectionHeader(title: 'Categories'),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < report.categoryRows.length; i++) ...[
                            if (i > 0) const Divider(height: 1),
                            ListTile(
                              title: Text(report.categoryRows[i].category),
                              subtitle: Text(
                                '${report.categoryRows[i].percent.toStringAsFixed(1)}%',
                              ),
                              trailing: Text(
                                Duration(
                                  milliseconds:
                                      report.categoryRows[i].durationMs,
                                ).compactLabel,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _periodLabel(ReportPeriod period) {
    return switch (period) {
      ReportPeriod.daily => 'Daily',
      ReportPeriod.weekly => 'Weekly',
      ReportPeriod.monthly => 'Monthly',
      ReportPeriod.yearly => 'Yearly',
    };
  }
}
