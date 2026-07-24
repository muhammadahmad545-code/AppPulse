import 'package:app_pulse/core/errors/result.dart';
import 'package:app_pulse/database/app_database.dart';

abstract interface class LimitsRepository {
  Stream<List<AppLimit>> watchLimits();
  Future<Result<void>> upsert(AppLimitsCompanion companion);
  Future<Result<void>> delete(int id);
  Future<Result<void>> setEnabled(int id, {required bool enabled});
}
