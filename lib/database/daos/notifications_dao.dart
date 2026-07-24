import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/database/tables/notification_history_table.dart';
import 'package:drift/drift.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [NotificationHistory])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  Future<int> insert(NotificationHistoryCompanion companion) {
    return into(notificationHistory).insert(companion);
  }

  Future<List<NotificationHistoryData>> getRecent({int limit = 100}) {
    return (select(notificationHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.shownAt)])
          ..limit(limit))
        .get();
  }

  Stream<List<NotificationHistoryData>> watchRecent({int limit = 100}) {
    return (select(notificationHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.shownAt)])
          ..limit(limit))
        .watch();
  }

  Future<int> clearAll() => delete(notificationHistory).go();
}
