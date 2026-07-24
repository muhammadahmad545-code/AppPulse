import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/services/focus/focus_session_service.dart';
import 'package:app_pulse/services/notifications/notification_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late FocusSessionService service;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    service = FocusSessionService(
      database: database,
      notifications: NotificationService(database: database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('start creates an active session and rejects duplicates', () async {
    final id = await service.start(
      planned: const Duration(minutes: 25),
      blockedPackages: const ['com.example.social'],
    );
    expect(id, greaterThan(0));

    final active = await service.getActive();
    expect(active, isNotNull);
    expect(active!.plannedDurationMs, const Duration(minutes: 25).inMilliseconds);
    expect(active.status, 'active');

    await expectLater(
      () => service.start(
        planned: const Duration(minutes: 15),
        blockedPackages: const [],
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('complete marks session done and updates daily stats', () async {
    await service.start(
      planned: const Duration(minutes: 15),
      blockedPackages: const [],
    );
    final active = await service.getActive();
    expect(active, isNotNull);

    await service.complete(active!);
    expect(await service.getActive(), isNull);

    final stats = await service.statsForToday();
    expect(stats.completedCount, 1);
    expect(stats.totalFocused.inMilliseconds, greaterThanOrEqualTo(0));
  });
}
