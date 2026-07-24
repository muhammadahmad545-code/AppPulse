import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/database/tables/usage_sessions_table.dart';
import 'package:drift/drift.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [UsageSessions])
class SessionsDao extends DatabaseAccessor<AppDatabase>
    with _$SessionsDaoMixin {
  SessionsDao(super.db);

  Future<int> insertSession(UsageSessionsCompanion companion) {
    return into(usageSessions).insert(companion);
  }

  Future<bool> updateSession(UsageSession session) {
    return update(usageSessions).replace(session);
  }

  Future<UsageSession?> getOngoingSession() {
    return (select(usageSessions)
          ..where((t) => t.isOngoing.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<UsageSession>> getSessionsForDay(String dayKey) {
    return (select(usageSessions)
          ..where((t) => t.dayKey.equals(dayKey))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
  }

  Stream<List<UsageSession>> watchSessionsForDay(String dayKey) {
    return (select(usageSessions)
          ..where((t) => t.dayKey.equals(dayKey))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch();
  }

  Future<List<UsageSession>> getSessionsInRange(
    DateTime start,
    DateTime end, {
    String? packageName,
  }) {
    final query = select(usageSessions)
      ..where(
        (t) =>
            t.startedAt.isBiggerOrEqualValue(start) &
            t.startedAt.isSmallerThanValue(end),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (packageName != null) {
      query.where((t) => t.packageName.equals(packageName));
    }
    return query.get();
  }

  Future<List<UsageSession>> getSessionsForPackage(
    String packageName, {
    int? limit,
  }) {
    final query = select(usageSessions)
      ..where((t) => t.packageName.equals(packageName))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<int> clearAll() => delete(usageSessions).go();

  Future<int> clearBefore(DateTime before) {
    return (delete(usageSessions)
          ..where((t) => t.startedAt.isSmallerThanValue(before)))
        .go();
  }

  /// Removes closed sessions that started inside [[start], [end]).
  /// Ongoing rows are closed first by the sync engine before rebuild.
  Future<int> deleteClosedSessionsInRange(DateTime start, DateTime end) {
    return (delete(usageSessions)
          ..where(
            (t) =>
                t.startedAt.isBiggerOrEqualValue(start) &
                t.startedAt.isSmallerThanValue(end) &
                t.isOngoing.equals(false),
          ))
        .go();
  }

  Future<int> closeAllOngoing({required DateTime endedAt}) async {
    final ongoing = await (select(usageSessions)
          ..where((t) => t.isOngoing.equals(true)))
        .get();
    var count = 0;
    for (final session in ongoing) {
      final durationMs = endedAt.difference(session.startedAt).inMilliseconds;
      await update(usageSessions).replace(
        session.copyWith(
          endedAt: Value(endedAt),
          durationMs: Value(durationMs < 0 ? 0 : durationMs),
          isOngoing: false,
        ),
      );
      count += 1;
    }
    return count;
  }

  Future<void> insertSessions(List<UsageSessionsCompanion> companions) async {
    await batch((b) {
      b.insertAll(usageSessions, companions);
    });
  }
}
