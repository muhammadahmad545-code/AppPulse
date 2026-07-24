import 'dart:io';

import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/services/limits/limit_check_service.dart';
import 'package:app_pulse/services/limits/limit_models.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SettingsStorage settings;
  late LimitCheckService service;
  late Directory tempDir;
  late Box<dynamic> dedupe;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('limit_check_');
    Hive.init(tempDir.path);
    final settingsBox = await Hive.openBox<dynamic>('settings');
    dedupe = await Hive.openBox<dynamic>('limit_alerts_dedupe');
    await settingsBox.clear();
    await dedupe.clear();
    settings = SettingsStorage(settingsBox);
    database = AppDatabase.forTesting(NativeDatabase.memory());
    service = LimitCheckService(
      database: database,
      settings: settings,
      notifications: NotificationService(database: database),
      dedupeBox: dedupe,
    );

    await database.appsDao.upsertApp(
      InstalledAppsCompanion.insert(
        packageName: 'com.example.social',
        appName: 'Social',
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await Hive.deleteBoxFromDisk('settings');
    await Hive.deleteBoxFromDisk('limit_alerts_dedupe');
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('emits reached alert when daily usage exceeds limit', () async {
    final now = DateTime.now();
    await database.limitsDao.upsertLimit(
      AppLimitsCompanion.insert(
        packageName: 'com.example.social',
        limitType: 'daily',
        limitDurationMs: const Duration(minutes: 30).inMilliseconds,
        actionOnReach: const Value('overlay'),
        warnAtMinutesRemaining: const Value(5),
        secondaryWarnAtMinutesRemaining: const Value(10),
      ),
    );
    await database.summariesDao.upsertDaily(
      DailySummariesCompanion.insert(
        packageName: 'com.example.social',
        dayKey: now.dayKey,
        totalDurationMs: Value(const Duration(minutes: 45).inMilliseconds),
      ),
    );

    final alerts = await service.check(notify: false);
    expect(alerts, hasLength(1));
    expect(alerts.single.kind, LimitAlertKind.reached);
    expect(alerts.single.action, LimitAction.overlay);
  });

  test('emits primary warn when remaining time is within threshold', () async {
    final now = DateTime.now();
    await database.limitsDao.upsertLimit(
      AppLimitsCompanion.insert(
        packageName: 'com.example.social',
        limitType: 'daily',
        limitDurationMs: const Duration(minutes: 60).inMilliseconds,
        warnAtMinutesRemaining: const Value(10),
        secondaryWarnAtMinutesRemaining: const Value(20),
      ),
    );
    await database.summariesDao.upsertDaily(
      DailySummariesCompanion.insert(
        packageName: 'com.example.social',
        dayKey: now.dayKey,
        totalDurationMs: Value(const Duration(minutes: 55).inMilliseconds),
      ),
    );

    final alerts = await service.check(notify: false);
    expect(alerts, hasLength(1));
    expect(alerts.single.kind, LimitAlertKind.primaryWarn);
  });
}
