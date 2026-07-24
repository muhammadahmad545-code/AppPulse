import 'dart:io';

import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Syncs launcher-visible installed apps into Drift and caches icons on disk.
final class AppCatalogSyncService {
  AppCatalogSyncService({
    required AppDatabase database,
    required SettingsStorage settings,
    required UsageStatsPlatform platform,
  })  : _db = database,
        _settings = settings,
        _platform = platform;

  final AppDatabase _db;
  final SettingsStorage _settings;
  final UsageStatsPlatform _platform;

  static const _catalogTtl = Duration(hours: 12);

  Future<int> sync({bool force = false}) async {
    if (!_platform.isAndroid) return 0;

    final last = _settings.lastCatalogSyncMs;
    if (!force &&
        last != null &&
        DateTime.now().difference(
              DateTime.fromMillisecondsSinceEpoch(last),
            ) <
            _catalogTtl) {
      return 0;
    }

    try {
      final apps = await _platform.getInstalledApps();
      final iconDir = await _iconDirectory();
      final companions = <InstalledAppsCompanion>[];

      for (final app in apps) {
        if (app.packageName.isEmpty) continue;
        final existing = await _db.appsDao.getByPackage(app.packageName);
        final iconKey = await _ensureIcon(iconDir, app.packageName);

        companions.add(
          InstalledAppsCompanion(
            packageName: Value(app.packageName),
            appName: Value(app.appName),
            versionName: Value(app.versionName),
            versionCode: Value(app.versionCode),
            category: Value(
              existing != null && existing.category != 'other'
                  ? existing.category
                  : app.category,
            ),
            isSystemApp: Value(app.isSystemApp),
            isFavorite: Value(existing?.isFavorite ?? false),
            isPinned: Value(existing?.isPinned ?? false),
            isHidden: Value(existing?.isHidden ?? false),
            iconCacheKey: Value(iconKey ?? existing?.iconCacheKey),
            installTime: Value(app.installTime),
            updateTime: Value(app.updateTime),
            lastOpenedAt: Value(existing?.lastOpenedAt),
            createdAt: Value(existing?.createdAt ?? DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      await _db.appsDao.upsertApps(companions);
      await _settings.setLastCatalogSyncMs(DateTime.now().millisecondsSinceEpoch);
      AppLogger.i('App catalog synced: ${companions.length} apps');
      return companions.length;
    } catch (error, stack) {
      AppLogger.e('App catalog sync failed', error, stack);
      return 0;
    }
  }

  Future<Directory> _iconDirectory() async {
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, 'app_icons'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String?> _ensureIcon(Directory dir, String packageName) async {
    final file = File(p.join(dir.path, '$packageName.png'));
    if (file.existsSync() && file.lengthSync() > 0) {
      return file.path;
    }
    final bytes = await _platform.getAppIcon(packageName);
    if (bytes == null || bytes.isEmpty) return null;
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
