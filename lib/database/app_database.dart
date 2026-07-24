import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/daos/apps_dao.dart';
import 'package:app_pulse/database/daos/focus_dao.dart';
import 'package:app_pulse/database/daos/limits_dao.dart';
import 'package:app_pulse/database/daos/notifications_dao.dart';
import 'package:app_pulse/database/daos/sessions_dao.dart';
import 'package:app_pulse/database/daos/summaries_dao.dart';
import 'package:app_pulse/database/tables/app_limits_table.dart';
import 'package:app_pulse/database/tables/daily_summaries_table.dart';
import 'package:app_pulse/database/tables/focus_sessions_table.dart';
import 'package:app_pulse/database/tables/hourly_usage_table.dart';
import 'package:app_pulse/database/tables/installed_apps_table.dart';
import 'package:app_pulse/database/tables/monthly_summaries_table.dart';
import 'package:app_pulse/database/tables/notification_history_table.dart';
import 'package:app_pulse/database/tables/usage_sessions_table.dart';
import 'package:app_pulse/database/tables/weekly_summaries_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    InstalledApps,
    UsageSessions,
    DailySummaries,
    WeeklySummaries,
    MonthlySummaries,
    HourlyUsage,
    AppLimits,
    FocusSessions,
    NotificationHistory,
  ],
  daos: [
    AppsDao,
    SessionsDao,
    SummariesDao,
    LimitsDao,
    FocusDao,
    NotificationsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  /// Testing / in-memory constructor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
          AppLogger.i('AppDatabase schema created (v$schemaVersion)');
        },
        onUpgrade: (Migrator m, int from, int to) async {
          AppLogger.i('AppDatabase migrating from $from to $to');
          if (from < 2) {
            await m.addColumn(appLimits, appLimits.customWindowStart);
            await m.addColumn(appLimits, appLimits.customWindowEnd);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_day '
      'ON usage_sessions (day_key);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_package '
      'ON usage_sessions (package_name);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sessions_started '
      'ON usage_sessions (started_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_daily_day '
      'ON daily_summaries (day_key);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_hourly_day '
      'ON hourly_usage (day_key);',
    );
  }

  /// Wipes all tracked statistics while preserving installed app metadata
  /// and user limit configuration.
  Future<void> resetStatistics() async {
    await transaction(() async {
      await delete(usageSessions).go();
      await delete(dailySummaries).go();
      await delete(weeklySummaries).go();
      await delete(monthlySummaries).go();
      await delete(hourlyUsage).go();
      await delete(focusSessions).go();
      await delete(notificationHistory).go();
    });
    AppLogger.i('Statistics reset');
  }

  /// Full wipe of all relational data (settings live in Hive separately).
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
    AppLogger.i('All database tables cleared');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: AppConstants.databaseName);
  }
}
