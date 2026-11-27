import 'dart:convert';

import 'package:flutter/material.dart';

import 'models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small, non-secret settings.
class Prefs {
  Prefs(this._p);

  final SharedPreferences _p;

  static Future<Prefs> load() async => Prefs(await SharedPreferences.getInstance());

  bool get onboarded => _p.getBool('onboarded') ?? false;
  set onboarded(bool v) => _p.setBool('onboarded', v);

  ThemeMode get themeMode => switch (_p.getString('themeMode')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
  set themeMode(ThemeMode v) => _p.setString('themeMode', v.name);

  /// Daily screen-time goal in minutes (0 = no goal).
  int get goalMinutes => _p.getInt('goalMinutes') ?? 180;
  set goalMinutes(int v) => _p.setInt('goalMinutes', v);

  /// Show a reminder on top of an app that reached its limit (needs the overlay permission).
  bool get limitOverlay => _p.getBool('limitOverlay') ?? false;
  set limitOverlay(bool v) => _p.setBool('limitOverlay', v);

  /// Days before this one are final in the database; sync rebuilds from here on.
  DateTime? get syncFrom {
    final ms = _p.getInt('syncFrom');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  set syncFrom(DateTime? v) => v == null ? _p.remove('syncFrom') : _p.setInt('syncFrom', v.millisecondsSinceEpoch);

  /// Version of the session rules the stored history was built with. Older history is rebuilt once
  /// (as far back as Android still has events) when the rules are fixed.
  int get sessionRules => _p.getInt('sessionRules') ?? 1;
  set sessionRules(int v) => _p.setInt('sessionRules', v);

  DateTime? get lastSync {
    final ms = _p.getInt('lastSync');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  set lastSync(DateTime? v) => v == null ? _p.remove('lastSync') : _p.setInt('lastSync', v.millisecondsSinceEpoch);

  /// Monday-morning summary notification (on unless turned off).
  bool get weeklySummary => _p.getBool('weeklySummary') ?? true;
  set weeklySummary(bool v) => _p.setBool('weeklySummary', v);

  Downtime get downtime {
    final raw = _p.getString('downtime');
    if (raw == null) return const Downtime();
    try {
      return Downtime.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } catch (_) {
      return const Downtime();
    }
  }

  set downtime(Downtime v) => _p.setString('downtime', jsonEncode(v.toJson()));
}
