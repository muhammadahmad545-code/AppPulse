import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';

/// Thin wrapper around the app's Kotlin side (UsageStatsManager, PackageManager, notifications).
/// Every call degrades to an empty/false result instead of throwing, so screens never crash on it.
class NativeApi {
  const NativeApi();

  static const _ch = MethodChannel('dev.basalt.apppulse/native');

  Future<T?> _call<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _ch.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('native $method failed: ${e.message}');
      return null;
    }
  }

  Future<bool> hasUsageAccess() async => await _call<bool>('hasUsageAccess') ?? false;

  Future<void> openUsageAccess() => _call<void>('openUsageAccess');

  Future<List<UsageEvent>> events(DateTime start, DateTime end) async {
    final raw = await _call<Map<Object?, Object?>>('events', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    if (raw == null) return const [];
    final packages = [for (final p in (raw['packages'] as List? ?? const [])) p.toString()];
    final classes = [for (final c in (raw['classes'] as List? ?? const [])) c.toString()];
    final ts = (raw['ts'] as List?)?.cast<int>() ?? const <int>[];
    final types = (raw['types'] as List?)?.cast<int>() ?? const <int>[];
    final pkg = (raw['pkg'] as List?)?.cast<int>() ?? const <int>[];
    final cls = (raw['cls'] as List?)?.cast<int>() ?? const <int>[];
    final n = [ts.length, types.length, pkg.length, cls.length].reduce((a, b) => a < b ? a : b);
    return [
      for (var i = 0; i < n; i++)
        UsageEvent(
          packages[pkg[i]],
          types[i],
          DateTime.fromMillisecondsSinceEpoch(ts[i]),
          className: classes[cls[i]],
        ),
    ];
  }

  /// Android's own per-app totals (queryAndAggregateUsageStats), in milliseconds.
  Future<Map<String, int>> androidTotals(DateTime start, DateTime end) async {
    final raw = await _call<Map<Object?, Object?>>('androidTotals', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    if (raw == null) return const {};
    return {for (final e in raw.entries) e.key.toString(): (e.value as num).toInt()};
  }

  /// Describes [packages], or every launchable app when null.
  Future<List<AppInfo>> apps([List<String>? packages]) async {
    final raw = await _call<List<Object?>>('apps', {'packages': packages});
    if (raw == null) return const [];
    final out = <AppInfo>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final package = item['package']?.toString() ?? '';
      if (package.isEmpty) continue;
      if (item['installed'] != true) {
        out.add(AppInfo(package: package, name: prettyPackage(package), installed: false, launchable: false));
        continue;
      }
      out.add(
        AppInfo(
          package: package,
          name: (item['name']?.toString().trim().isNotEmpty ?? false) ? item['name'].toString().trim() : prettyPackage(package),
          category: (item['category'] as num?)?.toInt() ?? -1,
          system: item['system'] == true,
          launchable: item['launchable'] == true,
        ),
      );
    }
    return out;
  }

  Future<Uint8List?> icon(String package, {int size = 96}) => _call<Uint8List>('icon', {'package': package, 'size': size});

  Future<Set<String>> excludedPackages() async {
    final raw = await _call<List<Object?>>('excludedPackages');
    return {for (final p in raw ?? const <Object?>[]) p.toString()};
  }

  Future<void> openAppInfo(String package) => _call<void>('openAppInfo', {'package': package});

  Future<bool> notificationsEnabled() async => await _call<bool>('notificationsEnabled') ?? false;

  Future<bool> requestNotifications() async => await _call<bool>('requestNotifications') ?? false;

  Future<void> openNotificationSettings() => _call<void>('openNotificationSettings');

  Future<bool> canDrawOverlays() async => await _call<bool>('canDrawOverlays') ?? false;

  Future<void> openOverlaySettings() => _call<void>('openOverlaySettings');

  /// Mirrors enabled limits to the native background checker (and schedules or cancels it).
  Future<void> syncLimits(List<({String package, String name, int minutes})> limits, {required bool overlay}) =>
      _call<void>('syncLimits', {
        'limits': jsonEncode([
          for (final l in limits) {'package': l.package, 'name': l.name, 'minutes': l.minutes},
        ]),
        'overlay': overlay,
      });

  Future<void> checkLimits() => _call<void>('checkLimits');

  Future<void> focusStart(DateTime endAt, int minutes) =>
      _call<void>('focusStart', {'endAt': endAt.millisecondsSinceEpoch, 'minutes': minutes});

  Future<void> focusStop() => _call<void>('focusStop');
}
