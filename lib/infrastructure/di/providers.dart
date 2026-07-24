import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/features/apps/data/repositories/apps_repository_impl.dart';
import 'package:app_pulse/features/apps/domain/repositories/apps_repository.dart';
import 'package:app_pulse/features/apps/domain/usecases/get_installed_apps.dart';
import 'package:app_pulse/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:app_pulse/features/limits/data/repositories/limits_repository_impl.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:app_pulse/services/backup/database_backup_service.dart';
import 'package:app_pulse/services/focus/focus_session_service.dart';
import 'package:app_pulse/services/limits/limit_check_service.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:app_pulse/services/permissions/permission_service.dart';
import 'package:app_pulse/services/tracking/tracking_service.dart';
import 'package:app_pulse/services/tracking/workmanager_scheduler.dart';
import 'package:app_pulse/services/usage/app_catalog_sync_service.dart';
import 'package:app_pulse/services/usage/usage_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Core infrastructure providers. Feature providers live under each feature.
///
/// [databaseProvider], [settingsStorageProvider], and optionally
/// [notificationServiceProvider] are overridden in [bootstrap].

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden in ProviderScope',
  );
});

final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  throw UnimplementedError(
    'settingsStorageProvider must be overridden in ProviderScope',
  );
});

final usageStatsPlatformProvider = Provider<UsageStatsPlatform>((ref) {
  return UsageStatsPlatform();
});

final appsDaoProvider = Provider((ref) => ref.watch(databaseProvider).appsDao);
final sessionsDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).sessionsDao);
final summariesDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).summariesDao);
final limitsDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).limitsDao);
final focusDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).focusDao);
final notificationsDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).notificationsDao);

final appsRepositoryProvider = Provider<AppsRepository>((ref) {
  return AppsRepositoryImpl(ref.watch(appsDaoProvider));
});

final getInstalledAppsProvider = Provider<GetInstalledApps>((ref) {
  return GetInstalledApps(ref.watch(appsRepositoryProvider));
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService(
    platform: ref.watch(usageStatsPlatformProvider),
    settings: ref.watch(settingsStorageProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService(database: ref.watch(databaseProvider));
  return service;
});

final usageSyncServiceProvider = Provider<UsageSyncService>((ref) {
  return UsageSyncService(
    database: ref.watch(databaseProvider),
    settings: ref.watch(settingsStorageProvider),
    platform: ref.watch(usageStatsPlatformProvider),
  );
});

final appCatalogSyncServiceProvider = Provider<AppCatalogSyncService>((ref) {
  return AppCatalogSyncService(
    database: ref.watch(databaseProvider),
    settings: ref.watch(settingsStorageProvider),
    platform: ref.watch(usageStatsPlatformProvider),
  );
});

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService(
    settings: ref.watch(settingsStorageProvider),
    platform: ref.watch(usageStatsPlatformProvider),
  );
});

final workmanagerSchedulerProvider = Provider<WorkmanagerScheduler>((ref) {
  return WorkmanagerScheduler();
});

final limitCheckServiceProvider = Provider<LimitCheckService>((ref) {
  return LimitCheckService(
    database: ref.watch(databaseProvider),
    settings: ref.watch(settingsStorageProvider),
    notifications: ref.watch(notificationServiceProvider),
    platform: ref.watch(usageStatsPlatformProvider),
  );
});

final focusSessionServiceProvider = Provider<FocusSessionService>((ref) {
  return FocusSessionService(
    database: ref.watch(databaseProvider),
    notifications: ref.watch(notificationServiceProvider),
  );
});

final databaseBackupServiceProvider = Provider<DatabaseBackupService>((ref) {
  return DatabaseBackupService(ref.watch(databaseProvider));
});

final limitsRepositoryProvider = Provider((ref) {
  return LimitsRepositoryImpl(ref.watch(limitsDaoProvider));
});

final dashboardRepositoryProvider = Provider((ref) {
  return DashboardRepositoryImpl(ref);
});
