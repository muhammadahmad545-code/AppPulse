import '../core/format.dart';
import 'models.dart';

/// Rebuilds foreground sessions from raw UsageStatsManager events.
///
/// Rules (kept in step with the Kotlin limit checker):
/// - One app is in the foreground at a time. A resume of another app (or of the home screen) ends the
///   current session even when Android never sent the matching pause.
/// - An app stays in front while any of its activities is resumed, so moving between its own screens is
///   one session. Back-to-back sessions of the same app less than [mergeGap] apart are joined.
/// - Screen off, lock and shutdown end the current session. If that app is still on top after the screen
///   comes back and Android only reports its pause, the time from wake-up to that pause is counted.
/// - Excluded packages (home screen, System UI, Clocked) never get sessions.
/// - A session still open at [now] ends at [now].
List<Session> reconstructSessions(
  List<UsageEvent> events, {
  required DateTime now,
  Set<String> excluded = const {},
  Duration mergeGap = const Duration(seconds: 2),
  Duration minLength = const Duration(seconds: 1),
}) {
  // Stable sort by time: events that share a timestamp keep Android's order.
  final indexed = List.generate(events.length, (i) => (i, events[i]));
  indexed.sort((a, b) {
    final c = a.$2.time.compareTo(b.$2.time);
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });

  final out = <Session>[];
  String? open;
  DateTime? since;
  final activities = <String>{};
  String? interrupted;
  DateTime? wokeAt;

  void add(Session s) {
    if (!s.end.isAfter(s.start)) return;
    if (out.isNotEmpty) {
      final last = out.last;
      if (last.package == s.package && !s.start.isAfter(last.end.add(mergeGap))) {
        out[out.length - 1] = Session(last.package, last.start, s.end.isAfter(last.end) ? s.end : last.end);
        return;
      }
    }
    out.add(s);
  }

  void close(DateTime at) {
    final p = open;
    final s = since;
    if (p != null && s != null) add(Session(p, s, at));
    open = null;
    since = null;
    activities.clear();
  }

  for (final (_, e) in indexed) {
    switch (e.type) {
      case EventType.resumed:
        interrupted = null;
        if (excluded.contains(e.package) || e.package.isEmpty) {
          close(e.time);
          break;
        }
        if (open != e.package) {
          close(e.time);
          open = e.package;
          since = e.time;
        }
        activities.add(e.className);
      case EventType.paused:
        if (open == e.package) {
          final known = activities.remove(e.className);
          if (!known || activities.isEmpty) close(e.time);
        } else if (open == null && interrupted == e.package && wokeAt != null && e.time.isAfter(wokeAt)) {
          add(Session(e.package, wokeAt, e.time));
          interrupted = null;
        }
      case EventType.screenOff:
      case EventType.keyguardShown:
      case EventType.shutdown:
        if (open != null) {
          interrupted = open;
          wokeAt = null;
        }
        close(e.time);
      case EventType.screenOn:
      case EventType.keyguardHidden:
        if (interrupted != null) wokeAt = e.time;
      case EventType.startup:
        interrupted = null;
        close(e.time);
    }
  }
  close(now);

  return out.where((s) => s.duration >= minLength).toList();
}

/// Splits sessions at local midnight so each piece belongs to exactly one day.
List<Session> splitByDay(Iterable<Session> sessions) {
  final out = <Session>[];
  for (final s in sessions) {
    var start = s.start;
    while (true) {
      final boundary = nextDay(start);
      if (!s.end.isAfter(boundary)) {
        if (s.end.isAfter(start)) out.add(Session(s.package, start, s.end));
        break;
      }
      out.add(Session(s.package, start, boundary));
      start = boundary;
    }
  }
  return out;
}

/// Keeps the part of each session inside [from, to).
List<Session> clipSessions(Iterable<Session> sessions, DateTime from, DateTime to) {
  final out = <Session>[];
  for (final s in sessions) {
    final a = s.start.isBefore(from) ? from : s.start;
    final b = s.end.isAfter(to) ? to : s.end;
    if (b.isAfter(a)) out.add(Session(s.package, a, b));
  }
  return out;
}

/// Unlocks per day: keyguard-hidden events, or screen-on events on days without a lock screen.
Map<String, int> unlocksByDay(Iterable<UsageEvent> events, {DateTime? from}) {
  final unlocks = <String, int>{};
  final wakes = <String, int>{};
  for (final e in events) {
    if (from != null && e.time.isBefore(from)) continue;
    if (e.type == EventType.keyguardHidden) unlocks.update(dayKey(e.time), (v) => v + 1, ifAbsent: () => 1);
    if (e.type == EventType.screenOn) wakes.update(dayKey(e.time), (v) => v + 1, ifAbsent: () => 1);
  }
  return {for (final day in {...unlocks.keys, ...wakes.keys}) day: unlocks[day] ?? wakes[day] ?? 0};
}

/// Total foreground time per package, largest first.
List<MapEntry<String, Duration>> totalsByPackage(Iterable<Session> sessions) {
  final map = <String, int>{};
  for (final s in sessions) {
    map.update(s.package, (v) => v + s.duration.inMilliseconds, ifAbsent: () => s.duration.inMilliseconds);
  }
  final list = [for (final e in map.entries) MapEntry(e.key, Duration(milliseconds: e.value))];
  list.sort((a, b) => b.value.compareTo(a.value));
  return list;
}

Duration totalOf(Iterable<Session> sessions) =>
    sessions.fold(Duration.zero, (sum, s) => sum + s.duration);

/// Foreground time in each hour (0-23) of [day].
List<Duration> hourlyTotals(Iterable<Session> sessions, DateTime day) {
  final base = startOfDay(day);
  final hours = List<int>.filled(24, 0);
  for (var h = 0; h < 24; h++) {
    final from = DateTime(base.year, base.month, base.day, h);
    final to = DateTime(base.year, base.month, base.day, h + 1);
    for (final s in sessions) {
      final a = s.start.isBefore(from) ? from : s.start;
      final b = s.end.isAfter(to) ? to : s.end;
      if (b.isAfter(a)) hours[h] += b.difference(a).inMilliseconds;
    }
  }
  return [for (final ms in hours) Duration(milliseconds: ms)];
}
