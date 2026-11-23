import 'package:intl/intl.dart';

String _two(int v) => v.toString().padLeft(2, '0');

/// Local calendar day as `yyyy-MM-dd`.
String dayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Midnight that starts the day after [d] (calendar arithmetic, so DST days stay correct).
DateTime nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

DateTime dayFromKey(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// Monday 00:00 of the week containing [d].
DateTime mondayOf(DateTime d) => addDays(startOfDay(d), -(d.weekday - DateTime.monday));

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Compact duration: `2h 5m`, `45m`, `30s`, `0m`.
String fmtDuration(Duration d) {
  final secs = d.inSeconds;
  if (secs <= 0) return '0m';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0) return m == 0 ? '${h}h' : '${h}h ${m}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m';
  return '${secs}s';
}

/// Minutes as a limit label: `30m`, `1h`, `1h 30m`.
String fmtMinutes(int minutes) => fmtDuration(Duration(minutes: minutes));

String fmtTime(DateTime t) => DateFormat.jm().format(t);

String fmtDayLong(DateTime d) => DateFormat('EEEE, d MMMM').format(d);

String fmtDayShort(DateTime d) => DateFormat('EEE d MMM').format(d);

/// "Today", "Yesterday" or a short date.
String fmtRelativeDay(DateTime d, {DateTime? now}) {
  final today = startOfDay(now ?? DateTime.now());
  final day = startOfDay(d);
  if (day == today) return 'Today';
  if (day == addDays(today, -1)) return 'Yesterday';
  return fmtDayShort(d);
}

/// Percentage change label, e.g. `12% more than yesterday`. Null when there is nothing to compare with.
String? fmtChange(Duration now, Duration before, String against) {
  if (before.inSeconds < 60) return null;
  final pct = ((now.inSeconds - before.inSeconds) / before.inSeconds * 100).round();
  if (pct == 0) return 'Same as $against';
  return pct > 0 ? '$pct% more than $against' : '${-pct}% less than $against';
}
