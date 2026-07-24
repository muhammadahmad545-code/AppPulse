import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/services/tracking/isolate_bootstrap.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Entry-point for the usage-tracking foreground service isolate.
@pragma('vm:entry-point')
void trackingTaskCallback() {
  FlutterForegroundTask.setTaskHandler(TrackingTaskHandler());
}

final class TrackingTaskHandler extends TaskHandler {
  IsolateBootstrap? _boot;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    AppLogger.i('TrackingTaskHandler onStart (${starter.name})');
    _boot = await IsolateBootstrap.open();
    await _sync(updateNotification: true);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _sync(updateNotification: true);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    AppLogger.i('TrackingTaskHandler onDestroy (timeout=$isTimeout)');
    await _boot?.close();
    _boot = null;
  }

  @override
  void onReceiveData(Object data) {
    if (data == 'sync_now') {
      _sync(updateNotification: true);
    }
  }

  Future<void> _sync({required bool updateNotification}) async {
    final boot = _boot;
    if (boot == null) return;
    try {
      await boot.catalogSync.sync();
      final result = await boot.usageSync.sync();
      await boot.focus.tick();
      final alerts = await boot.limitCheck.check(
        foregroundPackage: result.foregroundPackage,
      );

      if (updateNotification) {
        final label = result.skipped
            ? (result.reason ?? 'Waiting…')
            : '${result.sessionCount} sessions synced';
        await FlutterForegroundTask.updateService(
          notificationTitle: AppConstants.appName,
          notificationText: alerts.isEmpty
              ? 'Tracking screen time · $label'
              : 'Tracking · ${alerts.length} limit alert(s)',
        );
      }

      FlutterForegroundTask.sendDataToMain({
        'type': 'sync_result',
        'skipped': result.skipped,
        'reason': result.reason,
        'sessionCount': result.sessionCount,
        'foregroundPackage': result.foregroundPackage,
        'alerts': alerts.map((a) => a.toMap()).toList(),
      });
    } catch (error, stack) {
      AppLogger.e('TrackingTaskHandler sync failed', error, stack);
    }
  }
}
