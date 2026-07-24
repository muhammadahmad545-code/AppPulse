import 'dart:async';

import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:app_pulse/services/limits/limit_check_service.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:app_pulse/services/tracking/tracking_service.dart';
import 'package:app_pulse/services/tracking/workmanager_scheduler.dart';
import 'package:app_pulse/services/usage/app_catalog_sync_service.dart';
import 'package:app_pulse/services/usage/usage_sync_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Application dependencies initialized before [runApp].
typedef AppBootstrap = ({
  AppDatabase database,
  SettingsStorage settings,
  NotificationService notifications,
});

/// Initializes Flutter bindings, Hive, Drift, notifications, and tracking.
///
/// Non-critical services are wrapped so a single plugin failure cannot prevent
/// the UI from launching (common cause of "AppPulse keeps stopping").
Future<AppBootstrap> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    FlutterForegroundTask.initCommunicationPort();
  } catch (error, stack) {
    AppLogger.w('ForegroundTask port init skipped', error, stack);
  }

  await Hive.initFlutter();
  final settings = await SettingsStorage.open();
  final database = AppDatabase();

  final platform = UsageStatsPlatform();
  final notifications = NotificationService(database: database);
  try {
    await notifications.initialize();
  } catch (error, stack) {
    AppLogger.w('Notification init skipped', error, stack);
  }

  final tracking = TrackingService(settings: settings, platform: platform);
  try {
    await tracking.initialize();
  } catch (error, stack) {
    AppLogger.w('TrackingService init skipped', error, stack);
  }

  try {
    final scheduler = WorkmanagerScheduler();
    await scheduler.initialize();
    await scheduler.registerPeriodicTasks();
  } catch (error, stack) {
    AppLogger.w('WorkManager init skipped', error, stack);
  }

  // Defer heavy sync so first frame can paint even if UsageStats is slow/fails.
  unawaited(() async {
    try {
      if (!settings.trackingEnabled) return;
      if (!await platform.hasUsagePermission()) return;

      final catalog = AppCatalogSyncService(
        database: database,
        settings: settings,
        platform: platform,
      );
      final sync = UsageSyncService(
        database: database,
        settings: settings,
        platform: platform,
      );
      await catalog.sync(force: true);
      final result = await sync.sync();
      await LimitCheckService(
        database: database,
        settings: settings,
        notifications: notifications,
        platform: platform,
      ).check(foregroundPackage: result.foregroundPackage);
      await tracking.startIfPossible();
    } catch (error, stack) {
      AppLogger.e('Background boot sync failed', error, stack);
    }
  }());

  AppLogger.i('Bootstrap complete');
  return (
    database: database,
    settings: settings,
    notifications: notifications,
  );
}

/// Builds [ProviderScope] overrides from bootstrap results.
List<Override> bootstrapOverrides(AppBootstrap boot) {
  return [
    databaseProvider.overrideWithValue(boot.database),
    settingsStorageProvider.overrideWithValue(boot.settings),
    notificationServiceProvider.overrideWithValue(boot.notifications),
  ];
}
