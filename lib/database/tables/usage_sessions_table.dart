import 'package:drift/drift.dart';

/// Individual foreground usage sessions for an app.
class UsageSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  /// Duration in milliseconds; null while session is open.
  IntColumn get durationMs => integer().nullable()();
  /// Local calendar day key `yyyy-MM-dd` for fast filtering.
  TextColumn get dayKey => text()();
  BoolColumn get isOngoing =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
