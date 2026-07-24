import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/database/tables/installed_apps_table.dart';
import 'package:drift/drift.dart';

part 'apps_dao.g.dart';

@DriftAccessor(tables: [InstalledApps])
class AppsDao extends DatabaseAccessor<AppDatabase> with _$AppsDaoMixin {
  AppsDao(super.db);

  Future<List<InstalledApp>> getAllApps({bool includeHidden = false}) {
    final query = select(installedApps);
    if (!includeHidden) {
      query.where((t) => t.isHidden.equals(false));
    }
    return (query..orderBy([(t) => OrderingTerm.asc(t.appName)])).get();
  }

  Stream<List<InstalledApp>> watchAllApps({bool includeHidden = false}) {
    final query = select(installedApps);
    if (!includeHidden) {
      query.where((t) => t.isHidden.equals(false));
    }
    return (query..orderBy([(t) => OrderingTerm.asc(t.appName)])).watch();
  }

  Future<InstalledApp?> getByPackage(String packageName) {
    return (select(installedApps)
          ..where((t) => t.packageName.equals(packageName)))
        .getSingleOrNull();
  }

  Future<List<InstalledApp>> search(String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(installedApps)
          ..where(
            (t) =>
                t.appName.lower().like(q) | t.packageName.lower().like(q),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.appName)]))
        .get();
  }

  Future<void> upsertApp(InstalledAppsCompanion companion) {
    return into(installedApps).insertOnConflictUpdate(companion);
  }

  Future<void> upsertApps(List<InstalledAppsCompanion> companions) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(installedApps, companions);
    });
  }

  Future<int> setFavorite(String packageName, {required bool isFavorite}) {
    return (update(installedApps)
          ..where((t) => t.packageName.equals(packageName)))
        .write(
      InstalledAppsCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> setPinned(String packageName, {required bool isPinned}) {
    return (update(installedApps)
          ..where((t) => t.packageName.equals(packageName)))
        .write(
      InstalledAppsCompanion(
        isPinned: Value(isPinned),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> setCategory(String packageName, String category) {
    return (update(installedApps)
          ..where((t) => t.packageName.equals(packageName)))
        .write(
      InstalledAppsCompanion(
        category: Value(category),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<InstalledApp>> getFavorites() {
    return (select(installedApps)
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.appName)]))
        .get();
  }

  Future<List<InstalledApp>> getPinned() {
    return (select(installedApps)
          ..where((t) => t.isPinned.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.appName)]))
        .get();
  }

  Future<int> updateLastOpened(String packageName, DateTime at) {
    return (update(installedApps)
          ..where((t) => t.packageName.equals(packageName)))
        .write(
      InstalledAppsCompanion(
        lastOpenedAt: Value(at),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
