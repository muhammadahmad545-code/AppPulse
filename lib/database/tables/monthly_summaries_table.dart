import 'package:drift/drift.dart';

/// Per-app monthly aggregated usage. [monthKey] is `yyyy-MM`.
class MonthlySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  TextColumn get monthKey => text()();
  IntColumn get totalDurationMs =>
      integer().withDefault(const Constant(0))();
  IntColumn get launchCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {packageName, monthKey},
      ];
}
