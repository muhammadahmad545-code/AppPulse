import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/format.dart';
import 'models.dart';

/// Local SQLite store. Android only keeps about a week of usage events, so this is the long-term history.
class AppDb {
  AppDb._(this._db);

  final Database _db;

  static Future<AppDb> open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'apppulse.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, package TEXT NOT NULL, '
          'start_ms INTEGER NOT NULL, end_ms INTEGER NOT NULL, day TEXT NOT NULL)',
        );
        await db.execute('CREATE INDEX idx_sessions_start ON sessions (start_ms)');
        await db.execute('CREATE INDEX idx_sessions_package ON sessions (package, start_ms)');
        await db.execute('CREATE TABLE days (day TEXT PRIMARY KEY, unlocks INTEGER NOT NULL DEFAULT 0)');
        await db.execute(
          'CREATE TABLE apps (package TEXT PRIMARY KEY, name TEXT NOT NULL, category INTEGER NOT NULL DEFAULT -1, '
          'system INTEGER NOT NULL DEFAULT 0, installed INTEGER NOT NULL DEFAULT 1, launchable INTEGER NOT NULL DEFAULT 1)',
        );
        await db.execute(
          'CREATE TABLE limits (package TEXT PRIMARY KEY, minutes INTEGER NOT NULL, '
          'enabled INTEGER NOT NULL DEFAULT 1, created_ms INTEGER NOT NULL)',
        );
        await db.execute(
          'CREATE TABLE focus (id INTEGER PRIMARY KEY AUTOINCREMENT, start_ms INTEGER NOT NULL, '
          'planned_end_ms INTEGER NOT NULL, end_ms INTEGER, status TEXT NOT NULL, '
          'distraction_ms INTEGER NOT NULL DEFAULT 0, top_distraction TEXT)',
        );
      },
    );
    return AppDb._(db);
  }

  // Sessions ---------------------------------------------------------------

  /// Replaces every stored session that starts at or after [from] (sync rebuilds that window).
  Future<void> replaceSessionsFrom(DateTime from, List<Session> sessions, Map<String, int> unlocks) async {
    await _db.transaction((txn) async {
      await txn.delete('sessions', where: 'start_ms >= ?', whereArgs: [from.millisecondsSinceEpoch]);
      await txn.delete('days', where: 'day >= ?', whereArgs: [dayKey(from)]);
      final batch = txn.batch();
      for (final s in sessions) {
        batch.insert('sessions', {
          'package': s.package,
          'start_ms': s.start.millisecondsSinceEpoch,
          'end_ms': s.end.millisecondsSinceEpoch,
          'day': s.day,
        });
      }
      for (final e in unlocks.entries) {
        batch.insert('days', {'day': e.key, 'unlocks': e.value}, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  /// Sessions that start in [from, to).
  Future<List<Session>> sessions(DateTime from, DateTime to, {String? package}) async {
    final rows = await _db.query(
      'sessions',
      columns: ['package', 'start_ms', 'end_ms'],
      where: package == null ? 'start_ms >= ? AND start_ms < ?' : 'start_ms >= ? AND start_ms < ? AND package = ?',
      whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch, ?package],
      orderBy: 'start_ms',
    );
    return [
      for (final r in rows)
        Session(
          r['package']! as String,
          DateTime.fromMillisecondsSinceEpoch(r['start_ms']! as int),
          DateTime.fromMillisecondsSinceEpoch(r['end_ms']! as int),
        ),
    ];
  }

  Future<int> sessionCount() async =>
      Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM sessions')) ?? 0;

  Future<DateTime?> firstDay() async {
    final v = Sqflite.firstIntValue(await _db.rawQuery('SELECT MIN(start_ms) FROM sessions'));
    return v == null ? null : startOfDay(DateTime.fromMillisecondsSinceEpoch(v));
  }

  Future<Map<String, int>> unlocks(DateTime from, DateTime to) async {
    final rows = await _db.query('days', where: 'day >= ? AND day < ?', whereArgs: [dayKey(from), dayKey(to)]);
    return {for (final r in rows) r['day']! as String: r['unlocks']! as int};
  }

  Future<void> clearHistory() async {
    await _db.delete('sessions');
    await _db.delete('days');
    await _db.delete('focus', where: 'status != ?', whereArgs: [FocusStatus.active.name]);
  }

  // Apps -------------------------------------------------------------------

  Future<void> upsertApps(List<AppInfo> apps) async {
    final batch = _db.batch();
    for (final a in apps) {
      if (!a.installed) {
        // Keep the last known label of an uninstalled app; only flag it.
        batch.rawInsert('INSERT OR IGNORE INTO apps (package, name, installed, launchable) VALUES (?, ?, 0, 0)', [a.package, a.name]);
        batch.rawUpdate('UPDATE apps SET installed = 0 WHERE package = ?', [a.package]);
        continue;
      }
      batch.insert('apps', {
        'package': a.package,
        'name': a.name,
        'category': a.category,
        'system': a.system ? 1 : 0,
        'installed': 1,
        'launchable': a.launchable ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, AppInfo>> apps() async {
    final rows = await _db.query('apps');
    return {
      for (final r in rows)
        r['package']! as String: AppInfo(
          package: r['package']! as String,
          name: r['name']! as String,
          category: r['category']! as int,
          system: r['system'] == 1,
          installed: r['installed'] == 1,
          launchable: r['launchable'] == 1,
        ),
    };
  }

  // Limits -----------------------------------------------------------------

  Future<List<AppLimit>> limits() async {
    final rows = await _db.query('limits', orderBy: 'created_ms');
    return [
      for (final r in rows)
        AppLimit(package: r['package']! as String, minutes: r['minutes']! as int, enabled: r['enabled'] == 1),
    ];
  }

  Future<void> saveLimit(AppLimit limit) async {
    final existing = await _db.query('limits', where: 'package = ?', whereArgs: [limit.package]);
    if (existing.isEmpty) {
      await _db.insert('limits', {
        'package': limit.package,
        'minutes': limit.minutes,
        'enabled': limit.enabled ? 1 : 0,
        'created_ms': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await _db.update(
        'limits',
        {'minutes': limit.minutes, 'enabled': limit.enabled ? 1 : 0},
        where: 'package = ?',
        whereArgs: [limit.package],
      );
    }
  }

  Future<void> deleteLimit(String package) => _db.delete('limits', where: 'package = ?', whereArgs: [package]);

  // Focus ------------------------------------------------------------------

  FocusSession _focus(Map<String, Object?> r) => FocusSession(
        id: r['id']! as int,
        start: DateTime.fromMillisecondsSinceEpoch(r['start_ms']! as int),
        plannedEnd: DateTime.fromMillisecondsSinceEpoch(r['planned_end_ms']! as int),
        end: r['end_ms'] == null ? null : DateTime.fromMillisecondsSinceEpoch(r['end_ms']! as int),
        status: FocusStatus.values.firstWhere((s) => s.name == r['status'], orElse: () => FocusStatus.stopped),
        distraction: Duration(milliseconds: (r['distraction_ms'] as int?) ?? 0),
        topDistraction: r['top_distraction'] as String?,
      );

  Future<FocusSession?> activeFocus() async {
    final rows = await _db.query('focus', where: 'status = ?', whereArgs: [FocusStatus.active.name], limit: 1);
    return rows.isEmpty ? null : _focus(rows.first);
  }

  Future<List<FocusSession>> focusHistory({int limit = 50}) async {
    final rows = await _db.query('focus', where: 'status != ?', whereArgs: [FocusStatus.active.name], orderBy: 'start_ms DESC', limit: limit);
    return rows.map(_focus).toList();
  }

  Future<List<FocusSession>> focusBetween(DateTime from, DateTime to) async {
    final rows = await _db.query(
      'focus',
      where: 'status != ? AND start_ms >= ? AND start_ms < ?',
      whereArgs: [FocusStatus.active.name, from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
    );
    return rows.map(_focus).toList();
  }

  /// The session that started at [start] (sessions are matched across the app and the tile by start time).
  Future<FocusSession?> focusByStart(DateTime start) async {
    final rows = await _db.query('focus', where: 'start_ms = ?', whereArgs: [start.millisecondsSinceEpoch], limit: 1);
    return rows.isEmpty ? null : _focus(rows.first);
  }

  Future<int> startFocus(DateTime start, DateTime plannedEnd) => _db.insert('focus', {
        'start_ms': start.millisecondsSinceEpoch,
        'planned_end_ms': plannedEnd.millisecondsSinceEpoch,
        'status': FocusStatus.active.name,
      });

  Future<void> finishFocus(int id, {required DateTime end, required FocusStatus status, required Duration distraction, String? top}) =>
      _db.update(
        'focus',
        {
          'end_ms': end.millisecondsSinceEpoch,
          'status': status.name,
          'distraction_ms': distraction.inMilliseconds,
          'top_distraction': top,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
}
