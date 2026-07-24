import 'package:drift/drift.dart';

/// Local history of notifications shown by AppPulse.
class NotificationHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  /// limit | focus | tracking | general | report
  TextColumn get category => text()();
  TextColumn get packageName => text().nullable()();
  BoolColumn get wasTapped =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get shownAt => dateTime().withDefault(currentDateAndTime)();
}
