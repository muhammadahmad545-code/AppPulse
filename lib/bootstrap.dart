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
Future<AppBootstrap> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();

  await Hive.initFlutter();
  final settings = await SettingsStorage.open();
  final database = AppDatabase();

  final platform = UsageStatsPlatform();
  final notifications = NotificationService(database: database);
  await notifications.initialize();

  final tracking = TrackingService(settings: settings, platform: platform);
  await tracking.initialize();

  final scheduler = WorkmanagerScheduler();
  await scheduler.initialize();
  await scheduler.registerPeriodicTasks();

  if (settings.trackingEnabled && await platform.hasUsagePermission()) {
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
    ).check(foregroundPackage: result.foregroundPackage);
    await tracking.startIfPossible();
  }

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
