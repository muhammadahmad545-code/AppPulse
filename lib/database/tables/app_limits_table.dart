import 'package:drift/drift.dart';

/// Usage limits configured per app.
class AppLimits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()();
  /// daily | weekly | monthly | custom
  TextColumn get limitType => text()();
  /// Limit duration in milliseconds.
  IntColumn get limitDurationMs => integer()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  /// onlyNotify | fullScreen | overlay | confirm | delay | strict
  TextColumn get actionOnReach =>
      text().withDefault(const Constant('onlyNotify'))();
  IntColumn get warnAtMinutesRemaining =>
      integer().withDefault(const Constant(5))();
  IntColumn get secondaryWarnAtMinutesRemaining =>
      integer().withDefault(const Constant(10))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {packageName, limitType},
      ];
}
