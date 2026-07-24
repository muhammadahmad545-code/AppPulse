import 'package:app_pulse/core/constants/app_categories.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/features/apps/domain/entities/tracked_app.dart';

/// Maps Drift rows ↔ domain entities.
abstract final class TrackedAppMapper {
  static TrackedApp fromRow(InstalledApp row) {
    return TrackedApp(
      packageName: row.packageName,
      appName: row.appName,
      versionName: row.versionName,
      versionCode: row.versionCode,
      category: AppCategory.fromStorage(row.category),
      isSystemApp: row.isSystemApp,
      isFavorite: row.isFavorite,
      isPinned: row.isPinned,
      isHidden: row.isHidden,
      iconCacheKey: row.iconCacheKey,
      installTime: row.installTime,
      updateTime: row.updateTime,
      lastOpenedAt: row.lastOpenedAt,
    );
  }
}
