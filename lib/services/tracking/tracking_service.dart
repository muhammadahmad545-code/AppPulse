import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:app_pulse/services/tracking/tracking_task_handler.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Starts / stops the Android foreground tracking service.
final class TrackingService {
  TrackingService({
    required SettingsStorage settings,
    required UsageStatsPlatform platform,
  })  : _settings = settings,
        _platform = platform;

  final SettingsStorage _settings;
  final UsageStatsPlatform _platform;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppConstants.notificationChannelTracking,
        channelName: 'Usage tracking',
        channelDescription:
            'Shown while AppPulse is collecting on-device usage stats',
        onlyAlertOnce: true,
        playSound: false,
        showWhen: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          AppConstants.usagePollInterval.inMilliseconds,
        ),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _initialized = true;
    AppLogger.i('TrackingService initialized');
  }

  Future<bool> get isRunning => FlutterForegroundTask.isRunningService;

  /// Starts tracking when usage access is granted and tracking is enabled.
  Future<ServiceRequestResult?> startIfPossible() async {
    await initialize();
    if (!_settings.trackingEnabled) {
      AppLogger.i('Tracking disabled in settings');
      return null;
    }
    if (!await _platform.hasUsagePermission()) {
      AppLogger.w('Cannot start tracking — usage access missing');
      return null;
    }

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    }

    return FlutterForegroundTask.startService(
      serviceId: 2407,
      notificationTitle: AppConstants.appName,
      notificationText: 'Tracking screen time on this device',
      callback: trackingTaskCallback,
      serviceTypes: const [ForegroundServiceTypes.specialUse],
    );
  }

  Future<ServiceRequestResult> stop() async {
    await initialize();
    return FlutterForegroundTask.stopService();
  }

  Future<void> requestSync() async {
    if (await isRunning) {
      FlutterForegroundTask.sendDataToTask('sync_now');
    }
  }
}
