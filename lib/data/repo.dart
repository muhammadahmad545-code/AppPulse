import 'package:flutter/foundation.dart';

import '../core/format.dart';
import 'db.dart';
import 'models.dart';
import 'native.dart';
import 'prefs.dart';
import 'reconstruct.dart';

/// One day of usage.
class DayUsage {
  DayUsage({required this.day, required this.sessions, required this.unlocks});

  final DateTime day;
  final List<Session> sessions;
  final int unlocks;

  late final List<MapEntry<String, Duration>> totals = totalsByPackage(sessions);
  late final Duration total = totalOf(sessions);
  late final List<Duration> hourly = hourlyTotals(sessions, day);
  late final Duration longest = sessions.fold(Duration.zero, (m, s) => s.duration > m ? s.duration : m);

  Duration totalFor(String package) {
    for (final e in totals) {
      if (e.key == package) return e.value;
    }
    return Duration.zero;
  }

  int opensFor(String package) => sessions.where((s) => s.package == package).length;
}

/// Usage over several days ([from], [to]).
class RangeUsage {
  RangeUsage({
    required this.from,
    required this.to,
    required this.sessions,
    required this.unlocks,
    required this.focus,
    required this.firstDay,
  });

  final DateTime from;
  final DateTime to;
  final List<Session> sessions;
  final Map<String, int> unlocks;
  final List<FocusSession> focus;

  /// First day with any recorded data (null when the database is empty).
  final DateTime? firstDay;

  List<DateTime> get days {
    final out = <DateTime>[];
    for (var d = startOfDay(from); d.isBefore(to); d = nextDay(d)) {
      out.add(d);
    }
    return out;
  }

  late final Map<String, Duration> perDay = () {
    final map = {for (final d in days) dayKey(d): Duration.zero};
    for (final s in sessions) {
      map[s.day] = (map[s.day] ?? Duration.zero) + s.duration;
    }
    return map;
  }();

  late final List<MapEntry<String, Duration>> totals = totalsByPackage(sessions);
  late final Duration total = totalOf(sessions);

  /// Days in the range that Clocked has data for (not in the future, not before the first record).
  int get trackedDays {
    final today = startOfDay(DateTime.now());
    final first = firstDay;
    return days.where((d) => !d.isAfter(today) && (first == null || !d.isBefore(first))).length;
  }

  Duration get dailyAverage {
    final n = trackedDays;
    return n == 0 ? Duration.zero : Duration(milliseconds: total.inMilliseconds ~/ n);
  }

  Map<String, int> opens() {
    final map = <String, int>{};
    for (final s in sessions) {
      map.update(s.package, (v) => v + 1, ifAbsent: () => 1);
    }
    return map;
  }
}

class AccuracyRow {
  const AccuracyRow(this.package, this.ours, this.android);

  final String package;
  final Duration ours;
  final Duration android;
}

/// Everything the screens need: sync from Android, queries, limits and focus sessions.
class UsageRepo {
  UsageRepo({required this.db, required this.prefs, this.native = const NativeApi()});

  final AppDb db;
  final Prefs prefs;
  final NativeApi native;

  /// Android keeps roughly 7-10 days of events; the first sync imports what is there.
  static const importDays = 9;

  /// Events are read from a little before the sync window so sessions already open at its start are found.
  static const lookback = Duration(hours: 3);

  Set<String>? _excluded;
  Future<bool>? _syncing;
  Map<String, AppInfo>? _apps;
  final _icons = <String, Future<Uint8List?>>{};

  Future<Set<String>> excluded() async => _excluded ??= await native.excludedPackages();

  /// Pulls new events from Android into the database. Returns false without usage access.
  Future<bool> sync() => _syncing ??= _sync().whenComplete(() => _syncing = null);

  Future<bool> _sync() async {
    if (!await native.hasUsageAccess()) {
      await native.updateWidget({'day': dayKey(DateTime.now()), 'access': false});
      return false;
    }
    final now = DateTime.now();
    final today = startOfDay(now);
    final earliest = addDays(today, -importDays);
    var from = prefs.syncFrom ?? earliest;
    if (from.isBefore(earliest)) from = earliest;
    if (from.isAfter(today)) from = today;

    final events = await native.events(from.subtract(lookback), now);
    if (events.isNotEmpty) {
      final sessions = splitByDay(
        clipSessions(reconstructSessions(events, now: now, excluded: await excluded()), from, now),
      );
      await db.replaceSessionsFrom(from, sessions, unlocksByDay(events, from: from));
      await _refreshApps({for (final s in sessions) s.package});
      // Everything before today is complete now; later syncs only rebuild today.
      prefs.syncFrom = today;
    }
    prefs.lastSync = now;
    await pushWidget();
    return true;
  }

  // Quick access and background features -----------------------------------

  /// Sends today's numbers (the same ones the Today screen shows) to the home-screen widget.
  Future<void> pushWidget() async {
    try {
      final now = DateTime.now();
      final today = await day(now);
      final yesterday = await day(addDays(now, -1));
      final apps = await appInfos();
      await native.updateWidget({
        'day': dayKey(now),
        'access': true,
        'total': today.total.inMilliseconds,
        'yesterday': yesterday.total.inMilliseconds,
        'top': [
          for (final e in today.totals.take(3)) {'name': infoFrom(apps, e.key).name, 'ms': e.value.inMilliseconds},
        ],
      });
    } catch (e) {
      debugPrint('widget update failed: $e');
    }
  }

  Future<void> saveDowntime(Downtime d) async {
    prefs.downtime = d;
    await native.syncDowntime(d.toJson());
  }

  /// Weekly summary setting plus the last few complete weeks' totals (Monday key -> ms), which the
  /// native summary uses for "the week before" when Android no longer has those days.
  Future<void> pushWeekly() async {
    final monday = mondayOf(DateTime.now());
    final weeks = <String, int>{};
    for (var i = 1; i <= 3; i++) {
      final from = addDays(monday, -7 * i);
      final total = totalOf(await db.sessions(from, addDays(from, 7)));
      if (total > Duration.zero) weeks[dayKey(from)] = total.inMilliseconds;
    }
    await native.weeklySummary(enabled: prefs.weeklySummary, weeks: weeks);
  }

  /// Everything the native side keeps a copy of, sent on every app open.
  Future<void> pushNative() async {
    await native.installShortcuts();
    await native.syncDowntime(prefs.downtime.toJson());
    await pushWeekly();
  }

  Future<void> _refreshApps(Set<String> packages) async {
    final known = await appInfos();
    final missing = packages.where((p) => !known.containsKey(p)).toList();
    final stale = known.values.where((a) => a.installed && packages.contains(a.package)).map((a) => a.package);
    final ask = {...missing, ...stale}.toList();
    if (ask.isEmpty) return;
    await db.upsertApps(await native.apps(ask));
    _apps = null;
  }

  Future<Map<String, AppInfo>> appInfos() async => _apps ??= await db.apps();

  AppInfo infoFrom(Map<String, AppInfo> apps, String package) => apps[package] ?? AppInfo.fallback(package);

  /// Launchable apps on the phone, for picking a limit target.
  Future<List<AppInfo>> launchableApps() async {
    final excluded = await this.excluded();
    final apps = (await native.apps()).where((a) => !excluded.contains(a.package)).toList();
    await db.upsertApps(apps);
    _apps = null;
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return apps;
  }

  Future<Uint8List?> icon(String package) => _icons.putIfAbsent(package, () => native.icon(package));

  // Queries ----------------------------------------------------------------

  Future<DayUsage> day(DateTime day) async {
    final from = startOfDay(day);
    final to = nextDay(day);
    final sessions = await db.sessions(from, to);
    final unlocks = await db.unlocks(from, to);
    return DayUsage(day: from, sessions: sessions, unlocks: unlocks[dayKey(from)] ?? 0);
  }

  /// The last [days] days, ending today.
  Future<RangeUsage> lastDays(int days) {
    final today = startOfDay(DateTime.now());
    return range(addDays(today, -(days - 1)), nextDay(today));
  }

  Future<RangeUsage> range(DateTime from, DateTime to) async => RangeUsage(
        from: from,
        to: to,
        sessions: await db.sessions(from, to),
        unlocks: await db.unlocks(from, to),
        focus: await db.focusBetween(from, to),
        firstDay: await db.firstDay(),
      );

  Future<List<Session>> appSessions(String package, DateTime from, DateTime to) => db.sessions(from, to, package: package);

  /// Today's totals next to Android's own numbers (queryAndAggregateUsageStats).
  Future<List<AccuracyRow>> accuracy() async {
    final now = DateTime.now();
    final ours = await day(now);
    final android = await native.androidTotals(startOfDay(now), now);
    final excluded = await this.excluded();
    final oursMap = {for (final e in ours.totals) e.key: e.value};
    final packages = {...oursMap.keys, ...android.keys.where((p) => !excluded.contains(p))};
    final rows = [
      for (final p in packages) AccuracyRow(p, oursMap[p] ?? Duration.zero, Duration(milliseconds: android[p] ?? 0)),
    ]..sort((a, b) => (b.ours > b.android ? b.ours : b.android).compareTo(a.ours > a.android ? a.ours : a.android));
    await _refreshApps(packages);
    return rows.where((r) => r.ours.inSeconds > 0 || r.android.inSeconds > 0).take(20).toList();
  }

  // Limits -----------------------------------------------------------------

  Future<List<AppLimit>> limits() => db.limits();

  Future<void> saveLimit(AppLimit limit) async {
    await db.saveLimit(limit);
    await pushLimits();
  }

  Future<void> deleteLimit(String package) async {
    await db.deleteLimit(package);
    await pushLimits();
  }

  /// Sends enabled limits to the native background checker and runs a check right away.
  Future<void> pushLimits() async {
    final limits = await db.limits();
    final apps = await appInfos();
    await native.syncLimits(
      [
        for (final l in limits.where((l) => l.enabled))
          (package: l.package, name: infoFrom(apps, l.package).name, minutes: l.minutes),
      ],
      overlay: prefs.limitOverlay,
    );
    await native.checkLimits();
  }

  // Focus ------------------------------------------------------------------

  Future<FocusSession?> activeFocus() => db.activeFocus();

  Future<void> startFocus(Duration length) async {
    await reconcileFocus();
    if (await db.activeFocus() != null) return;
    final start = DateTime.now();
    final end = start.add(length);
    await db.startFocus(start, end);
    await native.focusStart(start, end, length.inMinutes);
  }

  /// Ends [session]: completed when its time is up, otherwise stopped early.
  Future<FocusSession> finishFocus(FocusSession session, {DateTime? at, bool notifyNative = true}) async {
    final now = at ?? DateTime.now();
    final completed = !now.isBefore(session.plannedEnd);
    final end = completed ? session.plannedEnd : now;
    final (distraction, top) = await _timeInApps(session.start, end);
    final status = completed ? FocusStatus.completed : FocusStatus.stopped;
    await db.finishFocus(session.id, end: end, status: status, distraction: distraction, top: top);
    if (notifyNative) await native.focusStop();
    return FocusSession(
      id: session.id,
      start: session.start,
      plannedEnd: session.plannedEnd,
      end: end,
      status: status,
      distraction: distraction,
      topDistraction: top,
    );
  }

  /// Brings the database in line with the native focus state, which the Quick Settings tile and the
  /// end-of-session timer change while the app may be closed. Returns true when anything changed.
  Future<bool> reconcileFocus() => _reconciling ??= _reconcileFocus().whenComplete(() => _reconciling = null);

  Future<bool>? _reconciling;

  Future<bool> _reconcileFocus() async {
    final state = await native.focusState();
    if (!state.available) return false;
    var changed = false;
    // 1. Sessions that ended outside the app (tile stop, timer): record their results.
    final imported = <DateTime>[];
    for (final p in state.pending) {
      final known = await db.focusByStart(p.start);
      if (known == null) {
        final id = await db.startFocus(p.start, p.plannedEnd);
        await finishFocus(
          FocusSession(id: id, start: p.start, plannedEnd: p.plannedEnd, status: FocusStatus.active),
          at: p.completed ? p.plannedEnd : p.end,
          notifyNative: false,
        );
        changed = true;
      } else if (known.status == FocusStatus.active) {
        await finishFocus(known, at: p.completed ? known.plannedEnd : p.end, notifyNative: false);
        changed = true;
      }
      imported.add(p.start);
    }
    if (imported.isNotEmpty) await native.focusAck(imported);
    // 2. The running session.
    final mine = await db.activeFocus();
    final theirs = state.active;
    if (theirs != null) {
      if (mine != null && mine.start != theirs.start) {
        await finishFocus(mine, notifyNative: false);
        changed = true;
      }
      if (mine == null || mine.start != theirs.start) {
        await db.startFocus(theirs.start, theirs.end);
        changed = true;
      }
    } else if (mine != null && DateTime.now().isBefore(mine.plannedEnd)) {
      // Running here but unknown natively (a session from before 2.1): hand it to the native side.
      await native.focusStart(mine.start, mine.plannedEnd, mine.planned.inMinutes);
    }
    return changed;
  }

  /// Completes an active session whose time ran out while the app was closed.
  Future<FocusSession?> settleFocus() async {
    final active = await db.activeFocus();
    if (active == null || DateTime.now().isBefore(active.plannedEnd)) return null;
    return finishFocus(active);
  }

  Future<(Duration, String?)> _timeInApps(DateTime from, DateTime to) async {
    if (!await native.hasUsageAccess()) return (Duration.zero, null);
    final events = await native.events(from.subtract(lookback), to);
    final sessions = clipSessions(reconstructSessions(events, now: to, excluded: await excluded()), from, to);
    final totals = totalsByPackage(sessions);
    if (totals.isEmpty) return (Duration.zero, null);
    await _refreshApps({for (final e in totals) e.key});
    final apps = await appInfos();
    return (totalOf(sessions), infoFrom(apps, totals.first.key).name);
  }

  Future<void> clearHistory() async {
    await db.clearHistory();
    // Today is read straight from Android again on the next sync; older days are gone.
    prefs.syncFrom = startOfDay(DateTime.now());
  }
}
