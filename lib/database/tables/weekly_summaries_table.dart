import 'package:drift/drift.dart';

/// Per-app weekly aggregated usage. [weekKey] is ISO week `yyyy-Www`.
class WeeklySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get weekKey => text()();
  IntColumn get totalDurationMs =>
      integer().withDefault(const Constant(0))();
  IntColumn get launchCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {packageName, weekKey},
      ];
}
