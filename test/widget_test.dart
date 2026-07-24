import 'dart:io';

import 'package:app_pulse/app.dart';
import 'package:app_pulse/bootstrap.dart';
import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/settings_storage.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late SettingsStorage settings;
  late NotificationService notifications;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_pulse_test_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox<dynamic>('test_settings');
    await box.clear();
    settings = SettingsStorage(box);
    database = AppDatabase.forTesting(NativeDatabase.memory());
    notifications = NotificationService(database: database);
  });

  tearDown(() async {
    await database.close();
    await Hive.deleteBoxFromDisk('test_settings');
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('AppPulse boots to splash branding', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: bootstrapOverrides((
          database: database,
          settings: settings,
          notifications: notifications,
        )),
        child: const AppPulseApp(),
      ),
    );

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.tagline), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
  });
}
