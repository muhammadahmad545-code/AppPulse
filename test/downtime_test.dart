import 'package:clocked/core/format.dart';
import 'package:clocked/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Downtime window', () {
    test('a window that crosses midnight covers late evening and early morning', () {
      const d = Downtime(enabled: true, start: 23 * 60, end: 7 * 60);
      expect(d.crossesMidnight, isTrue);
      expect(d.contains(23 * 60), isTrue);
      expect(d.contains(23 * 60 + 59), isTrue);
      expect(d.contains(0), isTrue);
      expect(d.contains(6 * 60 + 59), isTrue);
      expect(d.contains(7 * 60), isFalse);
      expect(d.contains(12 * 60), isFalse);
      expect(d.contains(22 * 60 + 59), isFalse);
      expect(d.length, const Duration(hours: 8));
    });

    test('a same-day window', () {
      const d = Downtime(enabled: true, start: 13 * 60, end: 14 * 60 + 30);
      expect(d.crossesMidnight, isFalse);
      expect(d.contains(13 * 60), isTrue);
      expect(d.contains(14 * 60 + 29), isTrue);
      expect(d.contains(14 * 60 + 30), isFalse);
      expect(d.length, const Duration(minutes: 90));
    });

    test('an empty window never matches', () {
      const d = Downtime(enabled: true, start: 600, end: 600);
      expect(d.contains(600), isFalse);
    });

    test('round-trips through JSON with its apps', () {
      const d = Downtime(enabled: true, start: 22 * 60 + 15, end: 6 * 60, apps: {'com.example.a': 'App A'});
      final back = Downtime.fromJson(d.toJson());
      expect(back.enabled, isTrue);
      expect(back.start, 22 * 60 + 15);
      expect(back.end, 6 * 60);
      expect(back.apps, {'com.example.a': 'App A'});
    });
  });

  test('mondayOf finds the start of the week', () {
    expect(mondayOf(DateTime(2026, 11, 23, 9)), DateTime(2026, 11, 23));
    expect(mondayOf(DateTime(2026, 11, 29, 23, 59)), DateTime(2026, 11, 23));
    expect(mondayOf(DateTime(2026, 11, 22)), DateTime(2026, 11, 16));
  });
}
