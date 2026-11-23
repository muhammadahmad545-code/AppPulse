import 'package:clocked/data/models.dart';
import 'package:clocked/data/repo.dart';
import 'package:clocked/reports/report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final from = DateTime(2026, 3, 9);
  final to = DateTime(2026, 3, 11);
  final range = RangeUsage(
    from: from,
    to: to,
    sessions: [
      Session('com.instagram.android', DateTime(2026, 3, 9, 10), DateTime(2026, 3, 9, 10, 30)),
      Session('com.instagram.android', DateTime(2026, 3, 10, 9), DateTime(2026, 3, 10, 9, 15)),
      Session('com.android.settings', DateTime(2026, 3, 10, 11), DateTime(2026, 3, 10, 11, 6)),
    ],
    unlocks: {'2026-03-09': 4, '2026-03-10': 6},
    focus: const [],
    firstDay: from,
  );
  final apps = {
    'com.instagram.android': const AppInfo(package: 'com.instagram.android', name: 'Instagram, "IG"'),
  };

  test('buildReport sums the period', () {
    final r = buildReport(title: 'Test', range: range, apps: apps, created: DateTime(2026, 3, 10, 12));
    expect(r.total, const Duration(minutes: 51));
    expect(r.unlocks, 10);
    expect(r.apps.first.name, 'Instagram, "IG"');
    expect(r.apps.first.opens, 2);
    expect(r.apps.last.name, 'Settings');
    expect(r.days.length, 2);
  });

  test('reportCsv escapes fields and lists apps and days', () {
    final csv = reportCsv(buildReport(title: 'Test', range: range, apps: apps));
    expect(csv, contains('"Instagram, ""IG"""'));
    expect(csv, contains('com.instagram.android,Social,45.0,2'));
    expect(csv, contains('2026-03-10,21.0'));
    expect(csv, contains('Period,2026-03-09,2026-03-10'));
  });

  test('reportPdf produces a PDF', () async {
    final bytes = await reportPdf(buildReport(title: 'Test', range: range, apps: apps));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
