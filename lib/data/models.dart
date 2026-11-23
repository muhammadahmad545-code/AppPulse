import '../core/format.dart';

/// UsageEvents.Event types that the reconstruction understands.
abstract final class EventType {
  static const resumed = 1;
  static const paused = 2;
  static const screenOff = 15;
  static const screenOn = 16;
  static const keyguardShown = 17;
  static const keyguardHidden = 18;
  static const shutdown = 26;
  static const startup = 27;
}

class UsageEvent {
  const UsageEvent(this.package, this.type, this.time, {this.className = ''});

  final String package;
  final int type;
  final DateTime time;
  final String className;

  @override
  String toString() => 'UsageEvent($package, $type, $time, $className)';
}

/// One continuous stretch of an app in the foreground.
class Session {
  const Session(this.package, this.start, this.end);

  final String package;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);
  String get day => dayKey(start);

  @override
  bool operator ==(Object other) =>
      other is Session && other.package == package && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(package, start, end);

  @override
  String toString() => 'Session($package, $start → $end)';
}

class AppInfo {
  const AppInfo({
    required this.package,
    required this.name,
    this.category = -1,
    this.system = false,
    this.installed = true,
    this.launchable = true,
  });

  final String package;
  final String name;

  /// ApplicationInfo.category (-1 when the app does not declare one).
  final int category;
  final bool system;
  final bool installed;
  final bool launchable;

  String get categoryLabel => categoryFor(package, category);

  static AppInfo fallback(String package) => AppInfo(package: package, name: prettyPackage(package));
}

/// A readable name for a package we have no label for, e.g. `com.foo.my_app` -> `My app`.
String prettyPackage(String package) {
  final parts = package.split('.').where((p) => p.isNotEmpty && p != 'com' && p != 'android' && p != 'app').toList();
  final last = parts.isEmpty ? package : parts.last;
  final words = last.replaceAll('_', ' ').replaceAll('-', ' ').trim();
  if (words.isEmpty) return package;
  return words[0].toUpperCase() + words.substring(1);
}

const _manifestCategories = {
  0: 'Games',
  1: 'Music & audio',
  2: 'Video',
  3: 'Photos',
  4: 'Social',
  5: 'News',
  6: 'Maps & travel',
  7: 'Productivity',
  8: 'Accessibility',
};

const _keywordCategories = <String, List<String>>{
  'Communication': ['whatsapp', 'telegram', 'signal', 'messag', 'mms', 'dialer', 'contacts', 'discord', 'viber', 'skype', 'mail', 'outlook'],
  'Social': ['instagram', 'facebook', 'twitter', 'tiktok', 'musically', 'snapchat', 'reddit', 'linkedin', 'pinterest', 'threads', 'mastodon', 'bluesky'],
  'Video': ['youtube', 'netflix', 'twitch', 'primevideo', 'disney', 'hulu', 'vlc', 'video'],
  'Music & audio': ['spotify', 'music', 'podcast', 'soundcloud', 'audible'],
  'Browsers': ['chrome', 'firefox', 'browser', 'opera', 'brave', 'duckduckgo', 'edge'],
  'Games': ['game', 'roblox', 'minecraft', 'pubg', 'candycrush', 'supercell'],
  'Maps & travel': ['maps', 'waze', 'uber', 'lyft', 'booking', 'airbnb', 'careem'],
  'Productivity': ['docs', 'sheets', 'slides', 'drive', 'notion', 'slack', 'teams', 'calendar', 'keep', 'todo', 'office', 'zoom'],
  'Shopping': ['amazon', 'ebay', 'aliexpress', 'daraz', 'shop', 'temu'],
  'Finance': ['bank', 'wallet', 'paypal', 'pay', 'finance'],
  'Photos': ['camera', 'photo', 'gallery'],
  'Tools': ['settings', 'clock', 'calculator', 'files', 'documentsui', 'deskclock'],
};

/// Category label: the app's own manifest category when it declares one, otherwise a keyword guess.
String categoryFor(String package, int manifestCategory) {
  final declared = _manifestCategories[manifestCategory];
  if (declared != null) return declared;
  final p = package.toLowerCase();
  for (final entry in _keywordCategories.entries) {
    if (entry.value.any(p.contains)) return entry.key;
  }
  return 'Other';
}

class AppLimit {
  const AppLimit({required this.package, required this.minutes, this.enabled = true});

  final String package;
  final int minutes;
  final bool enabled;

  Duration get duration => Duration(minutes: minutes);
}

enum FocusStatus { active, completed, stopped }

class FocusSession {
  const FocusSession({
    required this.id,
    required this.start,
    required this.plannedEnd,
    this.end,
    required this.status,
    this.distraction = Duration.zero,
    this.topDistraction,
  });

  final int id;
  final DateTime start;
  final DateTime plannedEnd;
  final DateTime? end;
  final FocusStatus status;

  /// Time spent in other apps while the session ran.
  final Duration distraction;
  final String? topDistraction;

  Duration get planned => plannedEnd.difference(start);
  Duration get actual => (end ?? DateTime.now()).difference(start);
}

/// A daily downtime window (minutes after midnight; it may cross midnight) and the apps it applies to.
/// Opening one of those apps inside the window gets a gentle notification. Nothing is blocked.
class Downtime {
  const Downtime({this.enabled = false, this.start = 23 * 60, this.end = 7 * 60, this.apps = const {}});

  final bool enabled;
  final int start;
  final int end;

  /// Package -> app name.
  final Map<String, String> apps;

  Downtime copyWith({bool? enabled, int? start, int? end, Map<String, String>? apps}) => Downtime(
        enabled: enabled ?? this.enabled,
        start: start ?? this.start,
        end: end ?? this.end,
        apps: apps ?? this.apps,
      );

  /// Length of the window, wrapping past midnight.
  Duration get length => Duration(minutes: ((end - start) % (24 * 60) + 24 * 60) % (24 * 60));

  bool get crossesMidnight => end < start;

  /// True when [minute] (0-1439) is inside [start, end).
  bool contains(int minute) {
    if (start == end) return false;
    if (start < end) return minute >= start && minute < end;
    return minute >= start || minute < end;
  }

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'start': start,
        'end': end,
        'apps': [for (final e in apps.entries) {'package': e.key, 'name': e.value}],
      };

  factory Downtime.fromJson(Map<String, Object?> j) => Downtime(
        enabled: j['enabled'] == true,
        start: (j['start'] as num?)?.toInt() ?? 23 * 60,
        end: (j['end'] as num?)?.toInt() ?? 7 * 60,
        apps: {
          for (final a in (j['apps'] as List? ?? const []))
            if (a is Map && a['package'] is String) a['package'] as String: (a['name'] ?? a['package']).toString(),
        },
      );
}
