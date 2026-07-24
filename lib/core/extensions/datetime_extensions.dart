import 'package:intl/intl.dart';

/// Calendar helpers used across analytics, timeline, and summaries.
extension DateTimeCalendar on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfWeek {
    final weekdayOffset = weekday - DateTime.monday;
    return startOfDay.subtract(Duration(days: weekdayOffset));
  }

  DateTime get endOfWeek =>
      startOfWeek.add(const Duration(days: 6)).endOfDay;

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1, 0).endOfDay;

  DateTime get startOfYear => DateTime(year);

  DateTime get endOfYear => DateTime(year, 12, 31).endOfDay;

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Local calendar day key `yyyy-MM-dd` for grouping / storage.
  String get dayKey {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  /// ISO-8601 week key `yyyy-Www` (Monday week start).
  String get weekKey {
    // Thursday of this week determines the ISO week-year.
    final thursday = startOfWeek.add(const Duration(days: 3));
    final weekYear = thursday.year;
    final jan4 = DateTime(weekYear, 1, 4);
    final week1Monday = jan4.startOfWeek;
    final weekNumber =
        (startOfWeek.difference(week1Monday).inDays ~/ 7) + 1;
    return '$weekYear-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Month key `yyyy-MM`.
  String get monthKey {
    final m = month.toString().padLeft(2, '0');
    return '$year-$m';
  }

  String formatTime({bool use24h = false}) {
    return DateFormat(use24h ? 'HH:mm' : 'h:mm a').format(this);
  }

  String formatDate({String pattern = 'MMM d, y'}) {
    return DateFormat(pattern).format(this);
  }

  String formatDateTime({bool use24h = false, String datePattern = 'MMM d'}) {
    final time = formatTime(use24h: use24h);
    return '${formatDate(pattern: datePattern)} · $time';
  }
}
