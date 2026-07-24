import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/features/reports/application/report_builder.dart';
import 'package:app_pulse/features/reports/domain/usage_report.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ReportBuilder builder;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    builder = ReportBuilder(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('builds daily report with app and category rows', () async {
    final now = DateTime(2026, 7, 24, 12);
    await db.appsDao.upsertApp(
      InstalledAppsCompanion.insert(
        packageName: 'com.example.social',
        appName: 'SocialApp',
        category: const Value('social'),
      ),
    );
    await db.sessionsDao.insertSession(
      UsageSessionsCompanion.insert(
        packageName: 'com.example.social',
        startedAt: now.subtract(const Duration(minutes: 30)),
        endedAt: Value(now),
        durationMs: const Value(30 * 60 * 1000),
        dayKey: '2026-07-24',
      ),
    );

    final report = await builder.build(ReportPeriod.daily, anchor: now);

    expect(report.period, ReportPeriod.daily);
    expect(report.sessionCount, 1);
    expect(report.totalDurationMs, 30 * 60 * 1000);
    expect(report.appRows, hasLength(1));
    expect(report.appRows.first.appName, 'SocialApp');
    expect(report.categoryRows.first.category, 'Social');
  });
}
