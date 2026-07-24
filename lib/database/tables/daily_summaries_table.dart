import 'package:drift/drift.dart';

/// Per-app daily aggregated usage.
class DailySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get dayKey => text()();
  IntColumn get totalDurationMs =>
      integer().withDefault(const Constant(0))();
  IntColumn get launchCount => integer().withDefault(const Constant(0))();
  IntColumn get longestSessionMs =>
      integer().withDefault(const Constant(0))();
  IntColumn get shortestSessionMs =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {packageName, dayKey},
      ];
}
