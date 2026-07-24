import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/database/tables/focus_sessions_table.dart';
import 'package:drift/drift.dart';

part 'focus_dao.g.dart';

@DriftAccessor(tables: [FocusSessions])
class FocusDao extends DatabaseAccessor<AppDatabase> with _$FocusDaoMixin {
  FocusDao(super.db);

  Future<int> insertSession(FocusSessionsCompanion companion) {
    return into(focusSessions).insert(companion);
  }

  Future<bool> updateSession(FocusSession session) {
    return update(focusSessions).replace(session);
  }

  Future<FocusSession?> getActiveSession() {
    return (select(focusSessions)
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<FocusSession?> watchActiveSession() {
    return (select(focusSessions)
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<List<FocusSession>> getSessionsForDay(String dayKey) {
    return (select(focusSessions)
          ..where((t) => t.dayKey.equals(dayKey))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Future<List<FocusSession>> getCompletedSessions({int limit = 50}) {
    return (select(focusSessions)
          ..where((t) => t.status.equals('completed'))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .get();
  }
}
