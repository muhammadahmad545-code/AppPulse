import 'package:app_pulse/core/errors/failures.dart';
import 'package:app_pulse/core/errors/result.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/daos/apps_dao.dart';
import 'package:app_pulse/features/apps/data/models/tracked_app_mapper.dart';
import 'package:app_pulse/features/apps/domain/entities/tracked_app.dart';
import 'package:app_pulse/features/apps/domain/repositories/apps_repository.dart';

final class AppsRepositoryImpl implements AppsRepository {
  AppsRepositoryImpl(this._dao);

  final AppsDao _dao;

  @override
  Future<Result<List<TrackedApp>>> getInstalledApps({
    bool includeSystemApps = false,
    bool includeHidden = false,
  }) async {
    try {
      final rows = await _dao.getAllApps(includeHidden: includeHidden);
      final apps = rows
          .where((row) => includeSystemApps || !row.isSystemApp)
          .map(TrackedAppMapper.fromRow)
          .toList(growable: false);
      return Success(apps);
    } catch (error, stack) {
      AppLogger.e('getInstalledApps failed', error, stack);
      return Error(DatabaseFailure('Failed to load apps', cause: error));
    }
  }

  @override
  Stream<List<TrackedApp>> watchInstalledApps({
    bool includeSystemApps = false,
    bool includeHidden = false,
  }) {
    return _dao.watchAllApps(includeHidden: includeHidden).map((rows) {
      return rows
          .where((row) => includeSystemApps || !row.isSystemApp)
          .map(TrackedAppMapper.fromRow)
          .toList(growable: false);
    });
  }

  @override
  Future<Result<TrackedApp?>> getApp(String packageName) async {
    try {
      final row = await _dao.getByPackage(packageName);
      return Success(row == null ? null : TrackedAppMapper.fromRow(row));
    } catch (error, stack) {
      AppLogger.e('getApp failed', error, stack);
      return Error(DatabaseFailure('Failed to load app', cause: error));
    }
  }

  @override
  Future<Result<List<TrackedApp>>> search(String query) async {
    try {
      final rows = await _dao.search(query);
      return Success(
        rows.map(TrackedAppMapper.fromRow).toList(growable: false),
      );
    } catch (error, stack) {
      AppLogger.e('search apps failed', error, stack);
      return Error(DatabaseFailure('Failed to search apps', cause: error));
    }
  }

  @override
  Future<Result<void>> setFavorite(
    String packageName, {
    required bool value,
  }) async {
    try {
      await _dao.setFavorite(packageName, isFavorite: value);
      return const Success(null);
    } catch (error, stack) {
      AppLogger.e('setFavorite failed', error, stack);
      return Error(DatabaseFailure('Failed to update favorite', cause: error));
    }
  }

  @override
  Future<Result<void>> setPinned(
    String packageName, {
    required bool value,
  }) async {
    try {
      await _dao.setPinned(packageName, isPinned: value);
      return const Success(null);
    } catch (error, stack) {
      AppLogger.e('setPinned failed', error, stack);
      return Error(DatabaseFailure('Failed to update pin', cause: error));
    }
  }

  @override
  Future<Result<void>> setCategory(String packageName, String category) async {
    try {
      await _dao.setCategory(packageName, category);
      return const Success(null);
    } catch (error, stack) {
      AppLogger.e('setCategory failed', error, stack);
      return Error(DatabaseFailure('Failed to update category', cause: error));
    }
  }
}
