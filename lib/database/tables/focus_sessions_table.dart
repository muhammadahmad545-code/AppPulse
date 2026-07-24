import 'package:drift/drift.dart';

/// Focus mode sessions and outcomes.
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  /// Planned duration in milliseconds.
  IntColumn get plannedDurationMs => integer()();
  /// Actual completed duration in milliseconds.
  IntColumn get actualDurationMs => integer().nullable()();
  /// JSON-encoded list of blocked package names.
  TextColumn get blockedPackagesJson => text()();
  /// active | completed | cancelled
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get dayKey => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
