import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:app_pulse/services/usage/session_reconstructor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const reconstructor = SessionReconstructor(minDurationMs: 1000);

  test('builds a closed session from resume/pause pair', () {
    final start = DateTime(2026, 7, 24, 9, 12);
    final end = DateTime(2026, 7, 24, 9, 48);
    final sessions = reconstructor.reconstruct([
      UsageEventDto(
        packageName: 'com.instagram.android',
        timestamp: start,
        eventType: UsageEventDto.activityResumed,
      ),
      UsageEventDto(
        packageName: 'com.instagram.android',
        timestamp: end,
        eventType: UsageEventDto.activityPaused,
      ),
    ]);

    expect(sessions, hasLength(1));
    expect(sessions.first.packageName, 'com.instagram.android');
    expect(sessions.first.duration, const Duration(minutes: 36));
    expect(sessions.first.isOngoing, isFalse);
  });

  test('ignores launcher and system UI packages', () {
    final sessions = reconstructor.reconstruct([
      UsageEventDto(
        packageName: 'com.android.systemui',
        timestamp: DateTime(2026, 7, 24, 10),
        eventType: UsageEventDto.activityResumed,
      ),
      UsageEventDto(
        packageName: 'com.whatsapp',
        timestamp: DateTime(2026, 7, 24, 10, 1),
        eventType: UsageEventDto.activityResumed,
      ),
      UsageEventDto(
        packageName: 'com.whatsapp',
        timestamp: DateTime(2026, 7, 24, 10, 5),
        eventType: UsageEventDto.activityPaused,
      ),
    ]);

    expect(sessions, hasLength(1));
    expect(sessions.single.packageName, 'com.whatsapp');
  });

  test('marks unfinished resume as ongoing', () {
    final start = DateTime(2026, 7, 24, 11);
    final now = DateTime(2026, 7, 24, 11, 10);
    final sessions = reconstructor.reconstruct(
      [
        UsageEventDto(
          packageName: 'com.android.chrome',
          timestamp: start,
          eventType: UsageEventDto.activityResumed,
        ),
      ],
      now: now,
    );

    expect(sessions.single.isOngoing, isTrue);
    expect(sessions.single.duration, const Duration(minutes: 10));
  });
}
