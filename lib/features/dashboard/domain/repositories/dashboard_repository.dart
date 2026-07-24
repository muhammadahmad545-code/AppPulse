import 'package:app_pulse/core/errors/result.dart';
import 'package:app_pulse/features/dashboard/presentation/providers/dashboard_providers.dart';

/// Contract for dashboard aggregates.
abstract interface class DashboardRepository {
  Future<Result<DashboardSnapshot>> loadSnapshot();
}
