import 'dart:convert';

import 'package:clocked/data/backup.dart';
import 'package:clocked/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime at(int day, int hour, [int minute = 0]) => DateTime(2026, 11, day, hour, minute);

BackupData sample() => BackupData(
      exportedAt: at(25, 21),
      appVersion: '2.3.0',
      settings: const BackupSettings(
        goalMinutes: 120,
        weeklySummary: false,
        themeMode: 'dark',
        downtime: Downtime(enabled: true, start: 22 * 60, end: 6 * 60, apps: {'com.instagram.android': 'Instagram'}),
      ),
      limits: const [AppLimit(package: 'com.instagram.android', minutes: 45), AppLimit(package: 'com.google.android.youtube', minutes: 60, enabled: false)],
      apps: {'com.instagram.android': (name: 'Instagram', category: 4, system: false)},
      days: [
        BackupDay('2026-11-20', 31, [
          Session('com.instagram.android', at(20, 9), at(20, 9, 40)),
          Session('com.whatsapp', at(20, 12), at(20, 12, 5)),
        ]),
        BackupDay('2026-11-21', 12, [Session('com.instagram.android', at(21, 22), at(21, 23))]),
      ],
      focus: [
        BackupFocus(start: at(21, 10), plannedEnd: at(21, 10, 25), end: at(21, 10, 25), status: FocusStatus.completed, distraction: const Duration(minutes: 2), top: 'WhatsApp'),
      ],
    );

void main() {
  group('Backup file', () {
    test('a plain backup round-trips every field', () {
      final back = ClockedBackup.decode(ClockedBackup.encode(sample()));
      expect(back.exportedAt, at(25, 21));
      expect(back.settings.goalMinutes, 120);
      expect(back.settings.weeklySummary, isFalse);
      expect(back.settings.themeMode, 'dark');
      expect(back.settings.downtime.enabled, isTrue);
      expect(back.settings.downtime.start, 22 * 60);
      expect(back.settings.downtime.apps, {'com.instagram.android': 'Instagram'});
      expect(back.limits.map((l) => '${l.package}:${l.minutes}:${l.enabled}'), ['com.instagram.android:45:true', 'com.google.android.youtube:60:false']);
      expect(back.apps['com.instagram.android']?.name, 'Instagram');
      expect(back.days.map((d) => d.day), ['2026-11-20', '2026-11-21']);
      expect(back.days.first.unlocks, 31);
      expect(back.days.first.sessions, sample().days.first.sessions);
      expect(back.sessionCount, 3);
      expect(back.focus.single.start, at(21, 10));
      expect(back.focus.single.status, FocusStatus.completed);
      expect(back.focus.single.distraction, const Duration(minutes: 2));
      expect(back.focus.single.top, 'WhatsApp');
    });

    test('a protected backup opens only with its password', () async {
      final plain = ClockedBackup.encode(sample());
      final sealed = await ClockedBackup.encrypt(plain, 'secret123', rounds: 1000);
      expect(ClockedBackup.isEncrypted(sealed), isTrue);
      expect(sealed.contains('instagram'), isFalse);
      expect(await ClockedBackup.decrypt(sealed, 'secret123'), plain);
      await expectLater(ClockedBackup.decrypt(sealed, 'wrongpass'), throwsA(isA<BackupWrongPassword>()));
      await expectLater(ClockedBackup.open(sealed, null), throwsA(isA<BackupNeedsPassword>()));
      final opened = await ClockedBackup.open(sealed, 'secret123');
      expect(opened.sessionCount, 3);
    });

    test('a tampered protected backup is refused', () async {
      final sealed = jsonDecode(await ClockedBackup.encrypt(ClockedBackup.encode(sample()), 'secret123', rounds: 1000)) as Map<String, Object?>;
      final data = base64Decode(sealed['data']! as String)..[0] ^= 1;
      sealed['data'] = base64Encode(data);
      await expectLater(ClockedBackup.decrypt(jsonEncode(sealed), 'secret123'), throwsA(isA<BackupWrongPassword>()));
    });

    test('other files are refused', () {
      expect(() => ClockedBackup.decode('not json'), throwsA(isA<BackupFormatException>()));
      expect(() => ClockedBackup.decode('{"app":"lifeos","format":1}'), throwsA(isA<BackupFormatException>()));
      expect(() => ClockedBackup.decode('{"app":"clocked","format":9}'), throwsA(isA<BackupFormatException>()));
    });

    test('malformed entries are dropped and settings fall back to defaults', () {
      final raw = {
        'app': 'clocked',
        'format': 1,
        'settings': {'goalMinutes': -5, 'themeMode': 'neon', 'downtime': {'enabled': true, 'start': 5000, 'end': 10}},
        'limits': [
          {'package': 'com.a', 'minutes': 0},
          {'package': '../x', 'minutes': 30},
          {'package': 'com.b', 'minutes': 30},
          {'package': 'com.b', 'minutes': 90},
          'junk',
        ],
        'days': [
          {
            'day': '2026-11-20',
            'unlocks': -3,
            'sessions': [
              ['com.a', at(20, 9).millisecondsSinceEpoch, at(20, 10).millisecondsSinceEpoch],
              ['com.a', at(20, 11).millisecondsSinceEpoch, at(20, 10).millisecondsSinceEpoch],
              ['com.a', at(21, 9).millisecondsSinceEpoch, at(21, 10).millisecondsSinceEpoch],
              ['bad package!', at(20, 9).millisecondsSinceEpoch, at(20, 10).millisecondsSinceEpoch],
              'junk',
            ],
          },
          {'day': '2026-11-20', 'sessions': []},
          {'day': 'yesterday'},
        ],
        'focus': [
          {'start': 1, 'plannedEnd': 2, 'end': 2, 'status': 'active'},
          {'start': 5, 'plannedEnd': 2, 'end': 9, 'status': 'completed'},
        ],
      };
      final d = ClockedBackup.decode(jsonEncode(raw));
      expect(d.settings.goalMinutes, 180);
      expect(d.settings.themeMode, 'system');
      expect(d.settings.downtime.enabled, isFalse);
      expect(d.limits.map((l) => '${l.package}:${l.minutes}'), ['com.b:30']);
      expect(d.days.length, 1);
      expect(d.days.single.unlocks, 0);
      expect(d.days.single.sessions, [Session('com.a', at(20, 9), at(20, 10))]);
      expect(d.focus, isEmpty);
    });
  });

  group('Restore plan', () {
    test('a new phone gets every past day, but not today', () {
      final data = sample();
      final withToday = BackupData(
        exportedAt: data.exportedAt,
        appVersion: '',
        settings: data.settings,
        limits: data.limits,
        apps: data.apps,
        days: [...data.days, BackupDay('2026-11-25', 4, [Session('com.a', at(25, 8), at(25, 9))])],
        focus: data.focus,
      );
      final plan = ClockedBackup.plan(withToday, daysHere: {}, limitsHere: {}, focusHere: {}, appsHere: {}, now: at(25, 22));
      expect(plan.days.map((d) => d.day), ['2026-11-20', '2026-11-21']);
      expect(plan.skippedDays, 1);
      expect(plan.limits.length, 2);
      expect(plan.focus.length, 1);
      expect(plan.apps.keys, ['com.instagram.android']);
      expect(plan.sessionCount, 3);
    });

    test('days, limits, focus sessions and app names already here are left alone', () {
      final plan = ClockedBackup.plan(
        sample(),
        daysHere: {'2026-11-21'},
        limitsHere: {'com.instagram.android'},
        focusHere: {at(21, 10).millisecondsSinceEpoch},
        appsHere: {'com.instagram.android'},
        now: at(28, 9),
      );
      expect(plan.days.map((d) => d.day), ['2026-11-20']);
      expect(plan.skippedDays, 1);
      expect(plan.limits.map((l) => l.package), ['com.google.android.youtube']);
      expect(plan.focus, isEmpty);
      expect(plan.apps, isEmpty);
    });

    test('restoring the same backup twice adds nothing the second time', () {
      final data = sample();
      final first = ClockedBackup.plan(data, daysHere: {}, limitsHere: {}, focusHere: {}, appsHere: {}, now: at(28, 9));
      final second = ClockedBackup.plan(
        data,
        daysHere: first.days.map((d) => d.day).toSet(),
        limitsHere: first.limits.map((l) => l.package).toSet(),
        focusHere: first.focus.map((f) => f.start.millisecondsSinceEpoch).toSet(),
        appsHere: first.apps.keys.toSet(),
        now: at(28, 9),
      );
      expect(second.days, isEmpty);
      expect(second.limits, isEmpty);
      expect(second.focus, isEmpty);
      expect(second.skippedDays, 2);
    });

    test('file names carry the local date', () {
      expect(ClockedBackup.fileName(DateTime(2026, 1, 9, 23)), 'clocked-backup-2026-01-09.json');
    });
  });
}
