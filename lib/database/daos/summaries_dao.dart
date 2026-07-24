import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/database/tables/daily_summaries_table.dart';
import 'package:app_pulse/database/tables/hourly_usage_table.dart';
import 'package:app_pulse/database/tables/monthly_summaries_table.dart';
import 'package:app_pulse/database/tables/weekly_summaries_table.dart';
import 'package:drift/drift.dart';

part 'summaries_dao.g.dart';

@DriftAccessor(
  tables: [DailySummaries, WeeklySummaries, MonthlySummaries, HourlyUsage],
)
class SummariesDao extends DatabaseAccessor<AppDatabase>
    with _$SummariesDaoMixin {
  SummariesDao(super.db);

  Future<List<DailySummary>> getDailySummaries(String dayKey) {
    return (select(dailySummaries)
          ..where((t) => t.dayKey.equals(dayKey))
          ..orderBy([(t) => OrderingTerm.desc(t.totalDurationMs)]))
        .get();
  }

  Stream<List<DailySummary>> watchDailySummaries(String dayKey) {
    return (select(dailySummaries)
          ..where((t) => t.dayKey.equals(dayKey))
          ..orderBy([(t) => OrderingTerm.desc(t.totalDurationMs)]))
        .watch();
  }

  Future<DailySummary?> getDailyForPackage(String packageName, String dayKey) {
    return (select(dailySummaries)
          ..where(
            (t) =>
                t.packageName.equals(packageName) & t.dayKey.equals(dayKey),
          ))
        .getSingleOrNull();
  }

  Future<void> upsertDaily(DailySummariesCompanion companion) {
    return into(dailySummaries).insertOnConflictUpdate(companion);
  }

  Future<List<WeeklySummary>> getWeeklySummaries(String weekKey) {
    return (select(weeklySummaries)
          ..where((t) => t.weekKey.equals(weekKey))
          ..orderBy([(t) => OrderingTerm.desc(t.totalDurationMs)]))
        .get();
  }

  Future<void> upsertWeekly(WeeklySummariesCompanion companion) {
    return into(weeklySummaries).insertOnConflictUpdate(companion);
  }

  Future<List<MonthlySummary>> getMonthlySummaries(String monthKey) {
    return (select(monthlySummaries)
          ..where((t) => t.monthKey.equals(monthKey))
          ..orderBy([(t) => OrderingTerm.desc(t.totalDurationMs)]))
        .get();
  }

  Future<void> upsertMonthly(MonthlySummariesCompanion companion) {
    return into(monthlySummaries).insertOnConflictUpdate(companion);
  }

  Future<List<HourlyUsageData>> getHourlyForDay(String dayKey) {
    return (select(hourlyUsage)..where((t) => t.dayKey.equals(dayKey))).get();
  }

  Future<void> upsertHourly(HourlyUsageCompanion companion) {
    return into(hourlyUsage).insertOnConflictUpdate(companion);
  }

  Future<int> totalDurationForDay(String dayKey) async {
    final rows = await getDailySummaries(dayKey);
    return rows.fold<int>(0, (sum, row) => sum + row.totalDurationMs);
  }

  Stream<int> watchTotalDurationForDay(String dayKey) {
    return watchDailySummaries(dayKey).map(
      (rows) => rows.fold<int>(0, (sum, row) => sum + row.totalDurationMs),
    );
  }
}
