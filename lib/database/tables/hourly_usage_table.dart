import 'package:drift/drift.dart';

/// Hourly usage buckets for heatmap / hourly charts.
class HourlyUsage extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get dayKey => text()();
  /// Hour of day in local time, 0–23.
  IntColumn get hour => integer()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {packageName, dayKey, hour},
      ];
}
