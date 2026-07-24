import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DurationFormatting', () {
    test('formats seconds', () {
      expect(const Duration(seconds: 12).compactLabel, '12s');
    });

    test('formats minutes and seconds', () {
      expect(const Duration(minutes: 2, seconds: 5).compactLabel, '2m 5s');
    });

    test('formats hours and minutes', () {
      expect(const Duration(hours: 1, minutes: 30).compactLabel, '1h 30m');
    });

    test('long label for minutes', () {
      expect(const Duration(minutes: 1).longLabel, '1 minute');
      expect(const Duration(minutes: 36).longLabel, '36 minutes');
    });
  });
}
