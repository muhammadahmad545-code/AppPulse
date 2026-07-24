import 'package:drift/drift.dart';

/// Catalog of apps discovered on the device.
class InstalledApps extends Table {
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  TextColumn get versionName => text().nullable()();
  IntColumn get versionCode => integer().nullable()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  BoolColumn get isSystemApp =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  /// Optional local file path / cache key for icon bytes stored separately.
  TextColumn get iconCacheKey => text().nullable()();
  DateTimeColumn get installTime => dateTime().nullable()();
  DateTimeColumn get updateTime => dateTime().nullable()();
  DateTimeColumn get lastOpenedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {packageName};
}
