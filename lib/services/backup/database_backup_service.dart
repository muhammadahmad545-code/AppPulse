import 'dart:io';

import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Local SQLite backup / restore / export helpers (fully offline).
final class DatabaseBackupService {
  DatabaseBackupService(this._db);

  final AppDatabase _db;

  Future<File> _dbFile() async {
    final dir = await getApplicationDocumentsDirectory();
    // drift_flutter stores as `<name>` under documents.
    final candidates = [
      File(p.join(dir.path, AppConstants.databaseName)),
      File(p.join(dir.path, '${AppConstants.databaseName}.sqlite')),
    ];
    for (final file in candidates) {
      if (file.existsSync()) return file;
    }
    return candidates.first;
  }

  Future<File> exportCopy() async {
    await _db.customStatement('PRAGMA wal_checkpoint(FULL)');
    final source = await _dbFile();
    if (!source.existsSync()) {
      throw StateError('Database file not found');
    }
    final temp = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final dest = File(p.join(temp.path, 'app_pulse_backup_$stamp.db'));
    await source.copy(dest.path);
    AppLogger.i('Database exported to ${dest.path}');
    return dest;
  }

  Future<void> shareExport() async {
    final file = await exportCopy();
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'application/x-sqlite3',
            name: p.basename(file.path),
          ),
        ],
        subject: 'AppPulse database backup',
        text: 'Offline AppPulse SQLite backup',
      ),
    );
  }

  /// Replaces the local DB with a user-picked backup file.
  /// The app should be restarted afterward.
  Future<void> restoreFromPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final backup = File(path);
    if (!backup.existsSync()) {
      throw StateError('Selected backup does not exist');
    }

    await _db.close();
    final target = await _dbFile();
    if (target.existsSync()) {
      await target.delete();
    }
    final wal = File('${target.path}-wal');
    final shm = File('${target.path}-shm');
    if (wal.existsSync()) await wal.delete();
    if (shm.existsSync()) await shm.delete();
    await backup.copy(target.path);
    AppLogger.i('Database restored from $path');
  }

  Future<void> resetStatistics() => _db.resetStatistics();

  Future<void> clearHistory() async {
    await _db.sessionsDao.clearAll();
    await _db.resetStatistics();
  }
}
