import 'package:app_pulse/core/errors/result.dart';
import 'package:app_pulse/features/apps/domain/entities/tracked_app.dart';

/// Contract for installed-app catalog operations.
abstract interface class AppsRepository {
  Future<Result<List<TrackedApp>>> getInstalledApps({
    bool includeSystemApps = false,
    bool includeHidden = false,
  });

  Stream<List<TrackedApp>> watchInstalledApps({
    bool includeSystemApps = false,
    bool includeHidden = false,
  });

  Future<Result<TrackedApp?>> getApp(String packageName);

  Future<Result<List<TrackedApp>>> search(String query);

  Future<Result<void>> setFavorite(String packageName, {required bool value});

  Future<Result<void>> setPinned(String packageName, {required bool value});

  Future<Result<void>> setCategory(String packageName, String category);
}
