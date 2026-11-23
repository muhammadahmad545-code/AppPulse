import 'package:clocked/core/format.dart';
import 'package:clocked/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fmtDuration', () {
    expect(fmtDuration(Duration.zero), '0m');
    expect(fmtDuration(const Duration(seconds: 42)), '42s');
    expect(fmtDuration(const Duration(minutes: 5, seconds: 30)), '5m');
    expect(fmtDuration(const Duration(hours: 2)), '2h');
    expect(fmtDuration(const Duration(hours: 1, minutes: 7)), '1h 7m');
  });

  test('fmtChange', () {
    expect(fmtChange(const Duration(minutes: 30), Duration.zero, 'yesterday'), isNull);
    expect(fmtChange(const Duration(minutes: 90), const Duration(minutes: 60), 'yesterday'), '50% more than yesterday');
    expect(fmtChange(const Duration(minutes: 30), const Duration(minutes: 60), 'yesterday'), '50% less than yesterday');
  });

  test('fmtRelativeDay', () {
    final now = DateTime(2026, 3, 10, 12);
    expect(fmtRelativeDay(DateTime(2026, 3, 10, 1), now: now), 'Today');
    expect(fmtRelativeDay(DateTime(2026, 3, 9, 23), now: now), 'Yesterday');
  });

  test('categories prefer the manifest and fall back to keywords', () {
    expect(categoryFor('com.example.anything', 0), 'Games');
    expect(categoryFor('com.instagram.android', -1), 'Social');
    expect(categoryFor('com.android.settings', -1), 'Tools');
    expect(categoryFor('com.whatsapp', -1), 'Communication');
    expect(categoryFor('org.unknown.thing', -1), 'Other');
  });

  test('prettyPackage makes a readable fallback name', () {
    expect(prettyPackage('com.example.my_notes'), 'My notes');
    expect(prettyPackage('com.android.settings'), 'Settings');
  });
}
