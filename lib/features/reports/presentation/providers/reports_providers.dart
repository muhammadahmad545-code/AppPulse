import 'package:app_pulse/features/reports/application/report_builder.dart';
import 'package:app_pulse/features/reports/application/report_exporters.dart';
import 'package:app_pulse/features/reports/domain/usage_report.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportBuilderProvider = Provider<ReportBuilder>((ref) {
  return ReportBuilder(ref.watch(databaseProvider));
});

final reportExporterProvider = Provider<ReportExporter>((ref) {
  return ReportExporter();
});

final selectedReportPeriodProvider =
    NotifierProvider<SelectedReportPeriodNotifier, ReportPeriod>(
  SelectedReportPeriodNotifier.new,
);

class SelectedReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.daily;

  void setPeriod(ReportPeriod period) => state = period;
}

final currentReportProvider =
    FutureProvider.autoDispose<UsageReport>((ref) async {
  final period = ref.watch(selectedReportPeriodProvider);
  return ref.watch(reportBuilderProvider).build(period);
});
