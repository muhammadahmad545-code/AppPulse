import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/services/usage/summary_aggregator.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SummaryAggregator aggregator;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    aggregator = SummaryAggregator(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('reaggregateDays builds daily summary from sessions', () async {
    final now = DateTime.now();
    await database.appsDao.upsertApp(
      InstalledAppsCompanion.insert(
        packageName: 'com.example.app',
        appName: 'Example',
      ),
    );
    await database.sessionsDao.insertSession(
      UsageSessionsCompanion.insert(
        packageName: 'com.example.app',
        startedAt: now.subtract(const Duration(minutes: 30)),
        endedAt: Value(now),
        durationMs: Value(const Duration(minutes: 30).inMilliseconds),
        dayKey: now.dayKey,
      ),
    );

    await aggregator.reaggregateDays({now.dayKey});
    final daily = await database.summariesDao.getDailyForPackage(
      'com.example.app',
      now.dayKey,
    );
    expect(daily, isNotNull);
    expect(daily!.totalDurationMs, greaterThan(0));
  });
}
