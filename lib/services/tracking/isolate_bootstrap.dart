import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:app_pulse/services/focus/focus_session_service.dart';
import 'package:app_pulse/services/limits/limit_check_service.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:app_pulse/services/usage/app_catalog_sync_service.dart';
import 'package:app_pulse/services/usage/usage_sync_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Shared initialization for background isolates (FGS / WorkManager).
final class IsolateBootstrap {
  IsolateBootstrap._(
    this.database,
    this.settings,
    this.platform,
    this.notifications,
  );

  final AppDatabase database;
  final SettingsStorage settings;
  final UsageStatsPlatform platform;
  final NotificationService notifications;

  UsageSyncService get usageSync => UsageSyncService(
        database: database,
        settings: settings,
        platform: platform,
      );

  AppCatalogSyncService get catalogSync => AppCatalogSyncService(
        database: database,
        settings: settings,
        platform: platform,
      );

  LimitCheckService get limitCheck => LimitCheckService(
        database: database,
        settings: settings,
        notifications: notifications,
      );

  FocusSessionService get focus => FocusSessionService(
        database: database,
        notifications: notifications,
      );

  static Future<IsolateBootstrap> open() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    final settings = await SettingsStorage.open();
    final database = AppDatabase();
    final platform = UsageStatsPlatform();
    final notifications = NotificationService(database: database);
    await notifications.initialize();
    AppLogger.i('IsolateBootstrap ready');
    return IsolateBootstrap._(database, settings, platform, notifications);
  }

  Future<void> close() async {
    await database.close();
  }
}
