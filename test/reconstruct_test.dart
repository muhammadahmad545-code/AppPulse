import 'package:app_pulse/core/format.dart';
import 'package:app_pulse/data/models.dart';
import 'package:app_pulse/data/reconstruct.dart';
import 'package:flutter_test/flutter_test.dart';

final base = DateTime(2026, 3, 10, 9);
DateTime t(int minutes, [int seconds = 0]) => base.add(Duration(minutes: minutes, seconds: seconds));

UsageEvent resume(String p, DateTime at, [String c = 'Main']) => UsageEvent(p, EventType.resumed, at, className: c);
UsageEvent pause(String p, DateTime at, [String c = 'Main']) => UsageEvent(p, EventType.paused, at, className: c);
UsageEvent sys(int type, DateTime at) => UsageEvent('android', type, at);

const launcher = 'com.android.launcher3';
const excluded = {launcher, 'com.android.systemui', 'android'};

List<Session> run(List<UsageEvent> events, {DateTime? now}) =>
    reconstructSessions(events, now: now ?? t(600), excluded: excluded);

void main() {
  group('reconstructSessions', () {
    test('a resume followed by a pause is one session', () {
      final s = run([resume('a', t(0)), pause('a', t(10))]);
      expect(s, [Session('a', t(0), t(10))]);
    });

    test('moving between screens of the same app stays one session', () {
      final s = run([
        resume('a', t(0), 'Main'),
        pause('a', t(5), 'Main'),
        resume('a', t(5, 1), 'Detail'),
        pause('a', t(8), 'Detail'),
      ]);
      expect(s, [Session('a', t(0), t(8))]);
    });

    test('a second activity resumed before the first pauses keeps the session open', () {
      final s = run([
        resume('a', t(0), 'Main'),
        resume('a', t(2), 'Dialog'),
        pause('a', t(3), 'Main'),
        pause('a', t(6), 'Dialog'),
      ]);
      expect(s, [Session('a', t(0), t(6))]);
    });

    test('missing pause: the next app ends the previous session', () {
      final s = run([resume('a', t(0)), resume('b', t(4)), pause('b', t(9))]);
      expect(s, [Session('a', t(0), t(4)), Session('b', t(4), t(9))]);
    });

    test('the home screen ends a session even without a pause, and is never counted', () {
      final s = run([resume('a', t(0)), resume(launcher, t(3)), pause(launcher, t(7)), resume('b', t(7)), pause('b', t(8))]);
      expect(s, [Session('a', t(0), t(3)), Session('b', t(7), t(8))]);
    });

    test('reopening the same app after a real break makes two sessions', () {
      final s = run([resume('a', t(0)), pause('a', t(2)), resume('a', t(5)), pause('a', t(6))]);
      expect(s.length, 2);
      expect(totalOf(s), const Duration(minutes: 3));
    });

    test('screen off ends the session', () {
      final s = run([resume('a', t(0)), sys(EventType.screenOff, t(5)), pause('a', t(5, 1))]);
      expect(s, [Session('a', t(0), t(5))]);
    });

    test('app left on top through screen off counts again from unlock until its pause', () {
      final s = run([
        resume('a', t(0)),
        sys(EventType.screenOff, t(5)),
        sys(EventType.keyguardShown, t(5)),
        sys(EventType.screenOn, t(20)),
        sys(EventType.keyguardHidden, t(21)),
        pause('a', t(24)),
      ]);
      expect(s, [Session('a', t(0), t(5)), Session('a', t(21), t(24))]);
      expect(totalOf(s), const Duration(minutes: 8));
    });

    test('time with the screen off is never counted', () {
      final s = run([
        resume('a', t(0)),
        sys(EventType.keyguardShown, t(10)),
        sys(EventType.screenOff, t(10)),
        sys(EventType.screenOn, t(70)),
        sys(EventType.keyguardHidden, t(71)),
        resume('a', t(71)),
        pause('a', t(75)),
      ]);
      expect(totalOf(s), const Duration(minutes: 14));
    });

    test('shutdown ends the session', () {
      final s = run([resume('a', t(0)), sys(EventType.shutdown, t(3)), sys(EventType.startup, t(30)), pause('a', t(31))]);
      expect(s, [Session('a', t(0), t(3))]);
    });

    test('an app still open ends at now', () {
      final s = run([resume('a', t(0))], now: t(12));
      expect(s, [Session('a', t(0), t(12))]);
    });

    test('a pause without any resume is ignored', () {
      final s = run([pause('a', t(1)), resume('b', t(2)), pause('b', t(3))]);
      expect(s, [Session('b', t(2), t(3))]);
    });

    test('sessions shorter than a second are dropped', () {
      final s = run([resume('a', t(0)), pause('a', t(0).add(const Duration(milliseconds: 300)))]);
      expect(s, isEmpty);
    });

    test('events with equal timestamps keep Android order', () {
      final s = run([resume('a', t(0)), pause('a', t(4)), resume('b', t(4)), pause('b', t(6))]);
      expect(s, [Session('a', t(0), t(4)), Session('b', t(4), t(6))]);
    });

    test('unsorted input is sorted first', () {
      final s = run([pause('a', t(4)), resume('a', t(0))]);
      expect(s, [Session('a', t(0), t(4))]);
    });

    test('totals match a simple per-app sum of foreground time', () {
      final events = [
        resume('a', t(0)), pause('a', t(10)),
        resume('b', t(10)), pause('b', t(25)),
        resume('a', t(30)), pause('a', t(32)),
        resume(launcher, t(32)), pause(launcher, t(40)),
        resume('b', t(40)), pause('b', t(41)),
      ];
      final totals = {for (final e in totalsByPackage(run(events))) e.key: e.value};
      expect(totals['a'], const Duration(minutes: 12));
      expect(totals['b'], const Duration(minutes: 16));
      expect(totals.containsKey(launcher), isFalse);
    });
  });

  group('splitByDay', () {
    test('a session over midnight is split between the two days', () {
      final start = DateTime(2026, 3, 10, 23, 50);
      final end = DateTime(2026, 3, 11, 0, 20);
      final parts = splitByDay([Session('a', start, end)]);
      expect(parts, [
        Session('a', start, DateTime(2026, 3, 11)),
        Session('a', DateTime(2026, 3, 11), end),
      ]);
      expect(parts.map((s) => s.day), ['2026-03-10', '2026-03-11']);
      expect(totalOf(parts), const Duration(minutes: 30));
    });

    test('a session over two midnights becomes three pieces', () {
      final parts = splitByDay([Session('a', DateTime(2026, 3, 10, 23), DateTime(2026, 3, 12, 1))]);
      expect(parts.length, 3);
      expect(parts[1].duration, const Duration(hours: 24));
    });

    test('a session ending exactly at midnight stays on its day', () {
      final parts = splitByDay([Session('a', DateTime(2026, 3, 10, 23), DateTime(2026, 3, 11))]);
      expect(parts.length, 1);
      expect(parts.first.day, '2026-03-10');
    });

    test('reconstruct then split keeps the total', () {
      final events = [
        resume('a', DateTime(2026, 3, 10, 23, 55)),
        pause('a', DateTime(2026, 3, 11, 0, 5)),
      ];
      final parts = splitByDay(reconstructSessions(events, now: DateTime(2026, 3, 11, 1)));
      expect(parts.length, 2);
      expect(parts.first.duration, const Duration(minutes: 5));
      expect(parts.last.duration, const Duration(minutes: 5));
    });
  });

  test('clipSessions keeps only the window', () {
    final s = clipSessions([Session('a', t(0), t(10)), Session('b', t(20), t(30))], t(5), t(25));
    expect(s, [Session('a', t(5), t(10)), Session('b', t(20), t(25))]);
  });

  test('hourlyTotals spreads a session over the hours it touches', () {
    final day = DateTime(2026, 3, 10);
    final hours = hourlyTotals([Session('a', DateTime(2026, 3, 10, 9, 40), DateTime(2026, 3, 10, 10, 15))], day);
    expect(hours[9], const Duration(minutes: 20));
    expect(hours[10], const Duration(minutes: 15));
    expect(hours.fold(Duration.zero, (a, b) => a + b), const Duration(minutes: 35));
  });

  test('unlocksByDay counts unlocks, or screen-ons on days without a lock screen', () {
    final u = unlocksByDay([
      sys(EventType.keyguardHidden, DateTime(2026, 3, 10, 8)),
      sys(EventType.screenOn, DateTime(2026, 3, 10, 8)),
      sys(EventType.keyguardHidden, DateTime(2026, 3, 10, 12)),
      sys(EventType.screenOn, DateTime(2026, 3, 11, 9)),
    ]);
    expect(u, {'2026-03-10': 2, '2026-03-11': 1});
  });

  test('dayKey pads and nextDay crosses months', () {
    expect(dayKey(DateTime(2026, 1, 5)), '2026-01-05');
    expect(nextDay(DateTime(2026, 1, 31, 15)), DateTime(2026, 2, 1));
  });
}
