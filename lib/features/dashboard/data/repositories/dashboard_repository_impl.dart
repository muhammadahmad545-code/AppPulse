import 'package:app_pulse/core/errors/failures.dart';
import 'package:app_pulse/core/errors/result.dart';
import 'package:app_pulse/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:app_pulse/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin repository wrapper around dashboard snapshot loading.
final class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._ref);

  final Ref _ref;

  @override
  Future<Result<DashboardSnapshot>> loadSnapshot() async {
    try {
      final value = await _ref.read(dashboardSnapshotProvider.future);
      return Success(value);
    } catch (error) {
      return Error(UnknownFailure('Failed to load dashboard', cause: error));
    }
  }
}
