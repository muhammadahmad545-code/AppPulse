import 'package:app_pulse/core/errors/result.dart';
import 'package:app_pulse/features/apps/domain/entities/tracked_app.dart';
import 'package:app_pulse/features/apps/domain/repositories/apps_repository.dart';

/// Loads the installed-app catalog for list screens.
final class GetInstalledApps {
  const GetInstalledApps(this._repository);

  final AppsRepository _repository;

  Future<Result<List<TrackedApp>>> call({
    bool includeSystemApps = false,
    bool includeHidden = false,
  }) {
    return _repository.getInstalledApps(
      includeSystemApps: includeSystemApps,
      includeHidden: includeHidden,
    );
  }
}
