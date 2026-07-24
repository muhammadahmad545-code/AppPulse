import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/services/permissions/permission_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final permissionSnapshotProvider =
    FutureProvider.autoDispose<PermissionSnapshot>((ref) async {
  return ref.watch(permissionServiceProvider).snapshot();
});

final trackingEnabledProvider =
    NotifierProvider<TrackingEnabledNotifier, bool>(TrackingEnabledNotifier.new);

class TrackingEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsStorageProvider).trackingEnabled;

  Future<void> setEnabled(bool enabled) async {
    final settings = ref.read(settingsStorageProvider);
    await settings.setTrackingEnabled(enabled);
    state = enabled;

    final tracking = ref.read(trackingServiceProvider);
    if (enabled) {
      final permissions = ref.read(permissionServiceProvider);
      final snap = await permissions.snapshot();
      if (snap.usageAccess) {
        await ref.read(appCatalogSyncServiceProvider).sync(force: true);
        await ref.read(usageSyncServiceProvider).sync();
        await tracking.startIfPossible();
      }
    } else {
      await tracking.stop();
    }
  }
}
