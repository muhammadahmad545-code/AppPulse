import 'package:app_pulse/core/errors/failures.dart';
import 'package:app_pulse/core/errors/result.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/database/daos/limits_dao.dart';
import 'package:app_pulse/features/limits/domain/repositories/limits_repository.dart';

final class LimitsRepositoryImpl implements LimitsRepository {
  LimitsRepositoryImpl(this._dao);

  final LimitsDao _dao;

  @override
  Stream<List<AppLimit>> watchLimits() => _dao.watchAllLimits();

  @override
  Future<Result<void>> upsert(AppLimitsCompanion companion) async {
    try {
      await _dao.upsertLimit(companion);
      return const Success(null);
    } catch (error) {
      return Error(UnknownFailure('Failed to save limit', cause: error));
    }
  }

  @override
  Future<Result<void>> delete(int id) async {
    try {
      await _dao.deleteLimit(id);
      return const Success(null);
    } catch (error) {
      return Error(UnknownFailure('Failed to delete limit', cause: error));
    }
  }

  @override
  Future<Result<void>> setEnabled(int id, {required bool enabled}) async {
    try {
      await _dao.setEnabled(id, isEnabled: enabled);
      return const Success(null);
    } catch (error) {
      return Error(UnknownFailure('Failed to update limit', cause: error));
    }
  }
}
