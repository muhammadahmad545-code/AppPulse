import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/services/tracking/isolate_bootstrap.dart';
import 'package:workmanager/workmanager.dart';

/// WorkManager entry-point for periodic sync / midnight rollover.
@pragma('vm:entry-point')
void workmanagerCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AppLogger.i('WorkManager task: $taskName');
    final boot = await IsolateBootstrap.open();
    try {
      switch (taskName) {
        case AppConstants.usageSyncTask:
        case AppConstants.limitCheckTask:
        case Workmanager.iOSBackgroundTask:
          await boot.catalogSync.sync();
          final result = await boot.usageSync.sync();
          await boot.focus.tick();
          await boot.limitCheck.check(
            foregroundPackage: result.foregroundPackage,
          );
          break;
        case AppConstants.dailyRolloverTask:
          await boot.usageSync.sync(forceFullDay: true);
          await boot.limitCheck.check();
          break;
        default:
          await boot.usageSync.sync();
          await boot.limitCheck.check();
      }
      return true;
    } catch (error, stack) {
      AppLogger.e('WorkManager task failed', error, stack);
      return false;
    } finally {
      await boot.close();
    }
  });
}

final class WorkmanagerScheduler {
  Future<void> initialize() async {
    await Workmanager().initialize(
      workmanagerCallbackDispatcher,
      isInDebugMode: false,
    );
    AppLogger.i('WorkmanagerScheduler initialized');
  }

  Future<void> registerPeriodicTasks() async {
    await Workmanager().registerPeriodicTask(
      AppConstants.usageSyncTask,
      AppConstants.usageSyncTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.not_required),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );

    await Workmanager().registerPeriodicTask(
      AppConstants.dailyRolloverTask,
      AppConstants.dailyRolloverTask,
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.not_required),
    );

    await Workmanager().registerPeriodicTask(
      AppConstants.limitCheckTask,
      AppConstants.limitCheckTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.not_required),
    );

    AppLogger.i('Periodic WorkManager tasks registered');
  }

  Future<void> cancelAll() => Workmanager().cancelAll();
}
