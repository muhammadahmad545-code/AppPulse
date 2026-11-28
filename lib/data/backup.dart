import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'models.dart';

/// The file is not a Clocked backup, or it is damaged.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The backup is protected and no password was given.
class BackupNeedsPassword implements Exception {
  const BackupNeedsPassword();
  @override
  String toString() => 'This backup is protected with a password.';
}

/// The password does not open this backup. Nothing was changed.
class BackupWrongPassword implements Exception {
  const BackupWrongPassword();
  @override
  String toString() => 'That password is not right for this backup.';
}

class BackupDay {
  const BackupDay(this.day, this.unlocks, this.sessions);

  /// yyyy-MM-dd, local time.
  final String day;
  final int unlocks;
  final List<Session> sessions;
}

class BackupFocus {
  const BackupFocus({
    required this.start,
    required this.plannedEnd,
    required this.end,
    required this.status,
    required this.distraction,
    this.top,
  });

  final DateTime start;
  final DateTime plannedEnd;
  final DateTime end;
  final FocusStatus status;
  final Duration distraction;
  final String? top;
}

/// Settings that travel with a backup. Permissions and the limit card (which needs this phone's
/// "display over other apps" permission) stay per phone.
class BackupSettings {
  const BackupSettings({required this.goalMinutes, required this.weeklySummary, required this.themeMode, required this.downtime});

  final int goalMinutes;
  final bool weeklySummary;

  /// system | light | dark
  final String themeMode;
  final Downtime downtime;
}

/// Everything Clocked keeps, in the shape of a backup file.
class BackupData {
  const BackupData({
    required this.exportedAt,
    required this.appVersion,
    required this.settings,
    required this.limits,
    required this.apps,
    required this.days,
    required this.focus,
  });

  final DateTime exportedAt;
  final String appVersion;
  final BackupSettings settings;
  final List<AppLimit> limits;

  /// Package -> app name, so apps that are not installed on the new phone still show a name.
  final Map<String, ({String name, int category, bool system})> apps;
  final List<BackupDay> days;
  final List<BackupFocus> focus;

  int get sessionCount => days.fold(0, (n, d) => n + d.sessions.length);
}

/// What a restore will add, given what is already on this phone.
class RestorePlan {
  const RestorePlan({required this.days, required this.skippedDays, required this.limits, required this.focus, required this.apps});

  final List<BackupDay> days;
  final int skippedDays;
  final List<AppLimit> limits;
  final List<BackupFocus> focus;
  final Map<String, ({String name, int category, bool system})> apps;

  int get sessionCount => days.fold(0, (n, d) => n + d.sessions.length);
}

abstract final class ClockedBackup {
  static const app = 'clocked';
  static const format = 1;
  static const iterations = 210000;
  static const minPasswordLength = 6;
  static const _aad = 'clocked-backup-v1';

  static final _dayKey = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final _package = RegExp(r'^[A-Za-z0-9_.]{1,255}$');

  // Plain JSON -------------------------------------------------------------

  static String encode(BackupData d) => jsonEncode({
        'app': app,
        'format': format,
        'exportedAt': d.exportedAt.toIso8601String(),
        'appVersion': d.appVersion,
        'settings': {
          'goalMinutes': d.settings.goalMinutes,
          'weeklySummary': d.settings.weeklySummary,
          'themeMode': d.settings.themeMode,
          'downtime': d.settings.downtime.toJson(),
        },
        'limits': [for (final l in d.limits) {'package': l.package, 'minutes': l.minutes, 'enabled': l.enabled}],
        'apps': [
          for (final e in d.apps.entries) {'package': e.key, 'name': e.value.name, 'category': e.value.category, 'system': e.value.system},
        ],
        // Sessions as [package, start ms, end ms] to keep long histories small.
        'days': [
          for (final day in d.days)
            {
              'day': day.day,
              'unlocks': day.unlocks,
              'sessions': [for (final s in day.sessions) [s.package, s.start.millisecondsSinceEpoch, s.end.millisecondsSinceEpoch]],
            },
        ],
        'focus': [
          for (final f in d.focus)
            {
              'start': f.start.millisecondsSinceEpoch,
              'plannedEnd': f.plannedEnd.millisecondsSinceEpoch,
              'end': f.end.millisecondsSinceEpoch,
              'status': f.status.name,
              'distractionMs': f.distraction.inMilliseconds,
              'top': f.top,
            },
        ],
      });

  static int? _int(Object? v) => v is int ? v : (v is num && v == v.roundToDouble() ? v.toInt() : null);

  /// Reads a plain backup. Malformed entries are dropped; a file that is not Clocked's is refused.
  static BackupData decode(String text) {
    Object? raw;
    try {
      raw = jsonDecode(text);
    } catch (_) {
      throw const BackupFormatException('This is not a Clocked backup file.');
    }
    if (raw is! Map || raw['app'] != app) throw const BackupFormatException('This is not a Clocked backup file.');
    if (raw['encrypted'] == true) throw const BackupNeedsPassword();
    final version = _int(raw['format']) ?? 0;
    if (version > format) throw const BackupFormatException('This backup was made by a newer Clocked. Update the app, then try again.');
    if (version < 1) throw const BackupFormatException('This backup file is damaged.');

    final s = raw['settings'] is Map ? raw['settings'] as Map : const {};
    final goal = _int(s['goalMinutes']);
    final theme = s['themeMode'];
    Downtime downtime = const Downtime();
    if (s['downtime'] is Map) {
      try {
        final d = Downtime.fromJson((s['downtime'] as Map).cast<String, Object?>());
        final ok = d.start >= 0 && d.start < 1440 && d.end >= 0 && d.end < 1440;
        downtime = ok ? Downtime(enabled: d.enabled, start: d.start, end: d.end, apps: {for (final e in d.apps.entries) if (_package.hasMatch(e.key)) e.key: e.value}) : const Downtime();
      } catch (_) {}
    }
    final settings = BackupSettings(
      goalMinutes: goal != null && goal >= 0 && goal <= 24 * 60 ? goal : 180,
      weeklySummary: s['weeklySummary'] != false,
      themeMode: theme == 'light' || theme == 'dark' ? theme as String : 'system',
      downtime: downtime,
    );

    final limits = <AppLimit>[];
    final seenLimits = <String>{};
    for (final l in raw['limits'] is List ? raw['limits'] as List : const []) {
      if (l is! Map) continue;
      final p = l['package'];
      final m = _int(l['minutes']);
      if (p is! String || !_package.hasMatch(p) || m == null || m < 1 || m > 24 * 60 || !seenLimits.add(p)) continue;
      limits.add(AppLimit(package: p, minutes: m, enabled: l['enabled'] != false));
    }

    final apps = <String, ({String name, int category, bool system})>{};
    for (final a in raw['apps'] is List ? raw['apps'] as List : const []) {
      if (a is! Map) continue;
      final p = a['package'];
      final n = a['name'];
      if (p is! String || !_package.hasMatch(p) || n is! String || n.trim().isEmpty) continue;
      apps[p] = (name: n, category: _int(a['category']) ?? -1, system: a['system'] == true);
    }

    final days = <BackupDay>[];
    final seenDays = <String>{};
    for (final d in raw['days'] is List ? raw['days'] as List : const []) {
      if (d is! Map) continue;
      final key = d['day'];
      if (key is! String || !_dayKey.hasMatch(key) || !seenDays.add(key)) continue;
      final sessions = <Session>[];
      for (final x in d['sessions'] is List ? d['sessions'] as List : const []) {
        if (x is! List || x.length != 3) continue;
        final p = x[0];
        final start = _int(x[1]);
        final end = _int(x[2]);
        if (p is! String || !_package.hasMatch(p) || start == null || end == null || start <= 0 || end <= start || end - start > 86400000) continue;
        final session = Session(p, DateTime.fromMillisecondsSinceEpoch(start), DateTime.fromMillisecondsSinceEpoch(end));
        // A session is stored under the day it starts on; anything else is damage.
        if (session.day != key) continue;
        sessions.add(session);
      }
      final unlocks = _int(d['unlocks']) ?? 0;
      days.add(BackupDay(key, unlocks < 0 ? 0 : unlocks, sessions));
    }
    days.sort((a, b) => a.day.compareTo(b.day));

    final focus = <BackupFocus>[];
    final seenFocus = <int>{};
    for (final f in raw['focus'] is List ? raw['focus'] as List : const []) {
      if (f is! Map) continue;
      final start = _int(f['start']);
      final planned = _int(f['plannedEnd']);
      final end = _int(f['end']);
      final status = FocusStatus.values.where((v) => v.name == f['status'] && v != FocusStatus.active).firstOrNull;
      if (start == null || planned == null || end == null || status == null || start <= 0 || planned < start || end < start || !seenFocus.add(start)) continue;
      final top = f['top'];
      focus.add(BackupFocus(
        start: DateTime.fromMillisecondsSinceEpoch(start),
        plannedEnd: DateTime.fromMillisecondsSinceEpoch(planned),
        end: DateTime.fromMillisecondsSinceEpoch(end),
        status: status,
        distraction: Duration(milliseconds: (_int(f['distractionMs']) ?? 0).clamp(0, 86400000).toInt()),
        top: top is String ? top : null,
      ));
    }

    final exported = raw['exportedAt'] is String ? DateTime.tryParse(raw['exportedAt'] as String) : null;
    return BackupData(
      exportedAt: exported ?? DateTime.fromMillisecondsSinceEpoch(0),
      appVersion: raw['appVersion'] is String ? raw['appVersion'] as String : '',
      settings: settings,
      limits: limits,
      apps: apps,
      days: days,
      focus: focus,
    );
  }

  // Password protection ----------------------------------------------------

  /// True when [text] is a Clocked backup protected with a password.
  static bool isEncrypted(String text) {
    if (!text.contains('"encrypted"')) return false;
    try {
      final d = jsonDecode(text);
      return d is Map && d['app'] == app && d['encrypted'] == true;
    } catch (_) {
      return false;
    }
  }

  static Future<SecretKey> _key(String password, List<int> salt, int rounds) =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: rounds, bits: 256).deriveKeyFromPassword(password: password, nonce: salt);

  /// AES-256-GCM under a PBKDF2-HMAC-SHA256 key. The file stays JSON so the app recognises it.
  static Future<String> encrypt(String plain, String password, {int rounds = iterations}) async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final aes = AesGcm.with256bits();
    final box = await aes.encrypt(utf8.encode(plain), secretKey: await _key(password, salt, rounds), nonce: aes.newNonce(), aad: utf8.encode(_aad));
    return jsonEncode({
      'app': app,
      'format': format,
      'encrypted': true,
      'cipher': 'AES-256-GCM',
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': rounds,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'data': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  /// Opens a protected backup. Throws [BackupWrongPassword] or [BackupFormatException].
  static Future<String> decrypt(String text, String password) async {
    Object? raw;
    try {
      raw = jsonDecode(text);
    } catch (_) {
      throw const BackupFormatException('This is not a Clocked backup file.');
    }
    if (raw is! Map || raw['app'] != app || raw['encrypted'] != true) throw const BackupFormatException('This is not a protected Clocked backup.');
    if (raw['cipher'] != 'AES-256-GCM' || raw['kdf'] != 'PBKDF2-HMAC-SHA256') {
      throw const BackupFormatException('This backup was made by a newer Clocked. Update the app, then try again.');
    }
    final rounds = _int(raw['iterations']);
    if (rounds == null || rounds < 1 || rounds > 10000000) throw const BackupFormatException('This backup file is damaged.');
    final List<int> salt, nonce, data, mac;
    try {
      salt = base64Decode(raw['salt'] as String);
      nonce = base64Decode(raw['nonce'] as String);
      data = base64Decode(raw['data'] as String);
      mac = base64Decode(raw['mac'] as String);
    } catch (_) {
      throw const BackupFormatException('This backup file is damaged.');
    }
    try {
      final clear = await AesGcm.with256bits().decrypt(SecretBox(data, nonce: nonce, mac: Mac(mac)), secretKey: await _key(password, salt, rounds), aad: utf8.encode(_aad));
      return utf8.decode(clear);
    } on SecretBoxAuthenticationError {
      throw const BackupWrongPassword();
    } on FormatException {
      throw const BackupWrongPassword();
    }
  }

  /// Plain or protected file text -> backup data. Throws [BackupNeedsPassword] when a password is needed.
  static Future<BackupData> open(String text, String? password) async {
    if (isEncrypted(text)) {
      if (password == null || password.isEmpty) throw const BackupNeedsPassword();
      return decode(await Isolate.run(() => decrypt(text, password)));
    }
    return decode(text);
  }

  /// Plain JSON, or protected when [password] is given. Key stretching runs off the UI thread.
  static Future<String> seal(BackupData data, String? password) {
    final plain = encode(data);
    if (password == null || password.isEmpty) return Future.value(plain);
    return Isolate.run(() => encrypt(plain, password));
  }

  // Merging ----------------------------------------------------------------

  /// Restores only what this phone lacks. Days this phone already has (from its own Android history
  /// or an earlier restore) are kept as they are, so nothing is counted twice; today and later are
  /// left to this phone's live tracking. Limits already set here win; focus sessions match by start.
  static RestorePlan plan(
    BackupData data, {
    required Set<String> daysHere,
    required Set<String> limitsHere,
    required Set<int> focusHere,
    required Set<String> appsHere,
    required DateTime now,
  }) {
    final today = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final days = data.days.where((d) => d.day.compareTo(today) < 0 && !daysHere.contains(d.day) && (d.sessions.isNotEmpty || d.unlocks > 0)).toList();
    return RestorePlan(
      days: days,
      skippedDays: data.days.length - days.length,
      limits: data.limits.where((l) => !limitsHere.contains(l.package)).toList(),
      focus: data.focus.where((f) => !focusHere.contains(f.start.millisecondsSinceEpoch)).toList(),
      apps: {for (final e in data.apps.entries) if (!appsHere.contains(e.key)) e.key: e.value},
    );
  }

  static String fileName(DateTime now) =>
      'clocked-backup-${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.json';
}
