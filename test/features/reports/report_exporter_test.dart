import 'package:app_pulse/features/reports/domain/usage_report.dart';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('report JSON contains apps and categories', () {
    final report = UsageReport(
      period: ReportPeriod.daily,
      title: 'Daily report',
      generatedAt: DateTime(2026, 7, 24, 12),
      rangeStart: DateTime(2026, 7, 24),
      rangeEnd: DateTime(2026, 7, 24, 23, 59),
      totalDurationMs: 60000,
      sessionCount: 1,
      launchCount: 1,
      averageSessionMs: 60000,
      longestSessionMs: 60000,
      appRows: const [
        ReportAppRow(
          packageName: 'com.example',
          appName: 'Example',
          category: 'Other',
          durationMs: 60000,
          launchCount: 1,
        ),
      ],
      categoryRows: const [
        ReportCategoryRow(
          category: 'Other',
          durationMs: 60000,
          percent: 100,
        ),
      ],
      dailyTotalsMs: const {'2026-07-24': 60000},
    );

    final json = report.toJson();
    expect(json['title'], 'Daily report');
    expect(json['apps'], isA<List<dynamic>>());
    expect((json['apps'] as List).first['appName'], 'Example');

    final csv = Csv().encode([
      ['App', 'Duration'],
      ['Example', 60000],
    ]);
    expect(csv, contains('Example'));
  });
}
