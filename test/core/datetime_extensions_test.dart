import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeCalendar', () {
    test('dayKey / monthKey format', () {
      final date = DateTime(2026, 7, 24, 15, 30);
      expect(date.dayKey, '2026-07-24');
      expect(date.monthKey, '2026-07');
    });

    test('startOfWeek is Monday', () {
      final friday = DateTime(2026, 7, 24);
      expect(friday.startOfWeek.weekday, DateTime.monday);
      expect(friday.startOfWeek.dayKey, '2026-07-20');
    });

    test('formatTime 12h / 24h', () {
      final date = DateTime(2026, 7, 24, 9, 5);
      expect(date.formatTime(), '9:05 AM');
      expect(date.formatTime(use24h: true), '09:05');
    });
  });
}
