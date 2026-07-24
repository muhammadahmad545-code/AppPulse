import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/database/tables/app_limits_table.dart';
import 'package:drift/drift.dart';

part 'limits_dao.g.dart';

@DriftAccessor(tables: [AppLimits])
class LimitsDao extends DatabaseAccessor<AppDatabase> with _$LimitsDaoMixin {
  LimitsDao(super.db);

  Future<List<AppLimit>> getAllLimits() {
    return (select(appLimits)
          ..orderBy([(t) => OrderingTerm.asc(t.packageName)]))
        .get();
  }

  Stream<List<AppLimit>> watchAllLimits() {
    return (select(appLimits)
          ..orderBy([(t) => OrderingTerm.asc(t.packageName)]))
        .watch();
  }

  Future<List<AppLimit>> getLimitsForPackage(String packageName) {
    return (select(appLimits)
          ..where((t) => t.packageName.equals(packageName)))
        .get();
  }

  Future<void> upsertLimit(AppLimitsCompanion companion) {
    return into(appLimits).insertOnConflictUpdate(companion);
  }

  Future<int> deleteLimit(int id) {
    return (delete(appLimits)..where((t) => t.id.equals(id))).go();
  }

  Future<int> setEnabled(int id, {required bool isEnabled}) {
    return (update(appLimits)..where((t) => t.id.equals(id))).write(
      AppLimitsCompanion(
        isEnabled: Value(isEnabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
