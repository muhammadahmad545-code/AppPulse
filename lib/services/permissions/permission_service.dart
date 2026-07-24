import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Explains and requests the permissions AppPulse needs on Android.
final class PermissionService {
  PermissionService({
    required UsageStatsPlatform platform,
    required SettingsStorage settings,
  })  : _platform = platform,
        _settings = settings;

  final UsageStatsPlatform _platform;
  final SettingsStorage _settings;

  Future<PermissionSnapshot> snapshot() async {
    if (!_platform.isAndroid) {
      return const PermissionSnapshot(
        usageAccess: false,
        notifications: true,
        batteryOptimizationIgnored: true,
      );
    }

    final usage = await _platform.hasUsagePermission();
    await _settings.setUsageAccessGranted(usage);

    final notificationStatus = await Permission.notification.status;
    final battery = await _platform.isIgnoringBatteryOptimizations();

    return PermissionSnapshot(
      usageAccess: usage,
      notifications: notificationStatus.isGranted || notificationStatus.isLimited,
      batteryOptimizationIgnored: battery,
    );
  }

  /// Opens the system Usage Access screen. User must grant manually.
  Future<void> requestUsageAccess() async {
    AppLogger.i('Opening Usage Access settings');
    await _platform.openUsageAccessSettings();
  }

  Future<bool> requestNotificationPermission() async {
    if (!_platform.isAndroid) return true;
    final status = await Permission.notification.request();
    AppLogger.i('Notification permission: $status');
    return status.isGranted || status.isLimited;
  }

  /// Requests ignore-battery-optimization. Optional — only when needed.
  Future<void> requestIgnoreBatteryOptimizations() async {
    AppLogger.i('Requesting ignore battery optimizations');
    await _platform.requestIgnoreBatteryOptimizations();
  }

  Future<void> openBatteryOptimizationSettings() async {
    await _platform.openBatteryOptimizationSettings();
  }

  Future<bool> openAppSettingsPage() => openAppSettings();
}

@immutable
final class PermissionSnapshot extends Equatable {
  const PermissionSnapshot({
    required this.usageAccess,
    required this.notifications,
    required this.batteryOptimizationIgnored,
  });

  final bool usageAccess;
  final bool notifications;
  final bool batteryOptimizationIgnored;

  bool get isReadyForTracking => usageAccess;

  @override
  List<Object?> get props => [
        usageAccess,
        notifications,
        batteryOptimizationIgnored,
      ];
}
