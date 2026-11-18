import 'dart:io';

import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/format.dart';
import '../data/repo.dart';
import '../reports/report.dart';
import '../state.dart';
import 'widgets.dart';

enum ReportRange { thisWeek, last7, last30, thisMonth }

extension on ReportRange {
  String get label => switch (this) {
        ReportRange.thisWeek => 'This week',
        ReportRange.last7 => 'Last 7 days',
        ReportRange.last30 => 'Last 30 days',
        ReportRange.thisMonth => 'This month',
      };

  (DateTime, DateTime) bounds(DateTime now) {
    final today = startOfDay(now);
    final end = nextDay(today);
    return switch (this) {
      ReportRange.thisWeek => (addDays(today, -(today.weekday - 1)), end),
      ReportRange.last7 => (addDays(today, -6), end),
      ReportRange.last30 => (addDays(today, -29), end),
      ReportRange.thisMonth => (DateTime(today.year, today.month), end),
    };
  }
}

final _reportRangeProvider = FutureProvider.autoDispose.family<RangeUsage, ReportRange>((ref, range) {
  ref.watch(revisionProvider);
  final (from, to) = range.bounds(DateTime.now());
  return ref.watch(repoProvider).range(from, to);
});

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportRange _range = ReportRange.last7;
  String? _busy;

  Future<void> _share(String format) async {
    if (_busy != null) return;
    setState(() => _busy = format);
    try {
      final repo = ref.read(repoProvider);
      final (from, to) = _range.bounds(DateTime.now());
      final report = buildReport(title: _range.label, range: await repo.range(from, to), apps: await repo.appInfos());
      final dir = await getTemporaryDirectory();
      final name = 'apppulse-${_range.name}-${dayKey(DateTime.now())}.$format';
      final file = File('${dir.path}/$name');
      if (format == 'csv') {
        await file.writeAsString(reportCsv(report));
      } else {
        await file.writeAsBytes(await reportPdf(report));
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: format == 'csv' ? 'text/csv' : 'application/pdf', name: name)],
          subject: 'AppPulse report: ${_range.label}',
        ),
      );
    } catch (e) {
      if (mounted) BToast.show(context, 'Could not create the report: $e');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    final repo = ref.read(repoProvider);
    final apps = ref.watch(appInfosProvider).valueOrNull ?? const {};
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        children: [
          ChoiceChips<ReportRange>(
            options: [for (final r in ReportRange.values) (r, r.label)],
            selected: _range,
            onSelected: (v) => setState(() => _range = v),
          ),
          const SizedBox(height: Gap.lg),
          asyncView(ref.watch(_reportRangeProvider(_range)), (range) {
            final report = buildReport(title: _range.label, range: range, apps: apps);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.period, style: BasaltType.label.copyWith(color: p.textMuted)),
                      const SizedBox(height: Gap.xs),
                      Text(fmtDuration(report.total), style: BasaltType.display.copyWith(color: p.text)),
                      const SizedBox(height: Gap.xs),
                      Text(
                        '${fmtDuration(report.dailyAverage)} a day on average · ${report.unlocks} unlocks · ${report.focusSessions} focus sessions',
                        style: BasaltType.caption.copyWith(color: p.textMuted),
                      ),
                    ],
                  ),
                ),
                const BSectionTitle('Included apps'),
                if (report.apps.isEmpty)
                  BCard(child: Text('No app usage in this period yet.', style: BasaltType.body.copyWith(color: p.textMuted)))
                else
                  BGroup(
                    children: [
                      for (final a in report.apps.take(5))
                        AppUsageRow(package: a.package, name: repo.infoFrom(apps, a.package).name, duration: a.time, subtitle: '${opensLabel(a.opens)} · ${a.category}'),
                      if (report.apps.length > 5)
                        BListRow(dense: true, title: 'and ${report.apps.length - 5} more', subtitle: 'All apps are in the exported file'),
                    ],
                  ),
              ],
            );
          }),
          const SizedBox(height: Gap.xl),
          BButton(
            label: 'Share CSV',
            icon: Icons.table_chart_outlined,
            expand: true,
            busy: _busy == 'csv',
            onPressed: () => _share('csv'),
          ),
          const SizedBox(height: Gap.sm),
          BButton(
            label: 'Share PDF',
            icon: Icons.picture_as_pdf_outlined,
            variant: BButtonVariant.secondary,
            expand: true,
            busy: _busy == 'pdf',
            onPressed: () => _share('pdf'),
          ),
          const SizedBox(height: Gap.md),
          Text(
            'Reports are created on your phone and only go where you send them.',
            textAlign: TextAlign.center,
            style: BasaltType.caption.copyWith(color: p.textFaint),
          ),
        ],
      ),
    );
  }
}
