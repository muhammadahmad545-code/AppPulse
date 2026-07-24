import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform channel for Android UsageStatsManager / PackageManager APIs.
class UsageStatsPlatform {
  UsageStatsPlatform({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('com.apppulse.app_pulse/usage_stats');

  final MethodChannel _channel;

  bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> hasUsagePermission() async {
    if (!isAndroid) return false;
    final result = await _channel.invokeMethod<bool>('hasUsagePermission');
    return result ?? false;
  }

  Future<void> openUsageAccessSettings() async {
    if (!isAndroid) return;
    await _channel.invokeMethod<void>('openUsageAccessSettings');
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!isAndroid) return true;
    final result =
        await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
    return result ?? false;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    if (!isAndroid) return;
    await _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (!isAndroid) return;
    await _channel.invokeMethod<void>('openBatteryOptimizationSettings');
  }

  Future<bool> canDrawOverlays() async {
    if (!isAndroid) return false;
    final result = await _channel.invokeMethod<bool>('canDrawOverlays');
    return result ?? false;
  }

  Future<void> openOverlaySettings() async {
    if (!isAndroid) return;
    await _channel.invokeMethod<void>('openOverlaySettings');
  }

  Future<void> showLimitOverlay({
    required String title,
    required String body,
  }) async {
    if (!isAndroid) return;
    await _channel.invokeMethod<void>('showLimitOverlay', {
      'title': title,
      'body': body,
    });
  }

  Future<bool> canRequestPackageInstalls() async {
    if (!isAndroid) return false;
    final result =
        await _channel.invokeMethod<bool>('canRequestPackageInstalls');
    return result ?? false;
  }

  Future<void> openUnknownAppSourcesSettings() async {
    if (!isAndroid) return;
    await _channel.invokeMethod<void>('openUnknownAppSourcesSettings');
  }

  Future<void> installApk(String path) async {
    if (!isAndroid) return;
    await _channel.invokeMethod<void>('installApk', {'path': path});
  }

  Future<String?> getForegroundApp() async {
    if (!isAndroid) return null;
    return _channel.invokeMethod<String>('getForegroundApp');
  }

  Future<List<UsageEventDto>> getUsageEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isAndroid) return const [];
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'getUsageEvents',
      {
        'startMs': start.millisecondsSinceEpoch,
        'endMs': end.millisecondsSinceEpoch,
      },
    );
    if (raw == null) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(UsageEventDto.fromMap)
        .toList(growable: false);
  }

  Future<List<UsageStatDto>> getUsageStats({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isAndroid) return const [];
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'getUsageStats',
      {
        'startMs': start.millisecondsSinceEpoch,
        'endMs': end.millisecondsSinceEpoch,
      },
    );
    if (raw == null) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(UsageStatDto.fromMap)
        .toList(growable: false);
  }

  Future<List<InstalledAppDto>> getInstalledApps({
    bool includeIcons = false,
  }) async {
    if (!isAndroid) return const [];
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'getInstalledApps',
      {'includeIcons': includeIcons},
    );
    if (raw == null) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(InstalledAppDto.fromMap)
        .toList(growable: false);
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    if (!isAndroid) return null;
    final raw = await _channel.invokeMethod<dynamic>(
      'getAppIcon',
      {'packageName': packageName},
    );
    if (raw == null) return null;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return null;
  }
}

final class UsageEventDto {
  const UsageEventDto({
    required this.packageName,
    required this.timestamp,
    required this.eventType,
    this.className,
  });

  final String packageName;
  final DateTime timestamp;
  final int eventType;
  final String? className;

  /// Android UsageEvents.Event.ACTIVITY_RESUMED
  static const int activityResumed = 1;

  /// Android UsageEvents.Event.ACTIVITY_PAUSED
  static const int activityPaused = 2;

  /// Android UsageEvents.Event.MOVE_TO_FOREGROUND (legacy)
  static const int moveToForeground = 1;

  /// Android UsageEvents.Event.MOVE_TO_BACKGROUND (legacy) — value 2 on older APIs
  static const int activityStopped = 23;
  static const int moveToBackground = 2;

  factory UsageEventDto.fromMap(Map<dynamic, dynamic> map) {
    return UsageEventDto(
      packageName: map['packageName'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (map['timestampMs'] as num?)?.toInt() ?? 0,
      ),
      eventType: (map['eventType'] as num?)?.toInt() ?? 0,
      className: map['className'] as String?,
    );
  }

  bool get isResume => eventType == activityResumed;

  bool get isPause =>
      eventType == activityPaused || eventType == activityStopped;
}

final class UsageStatDto {
  const UsageStatDto({
    required this.packageName,
    required this.totalTimeForeground,
    required this.lastTimeUsed,
  });

  final String packageName;
  final Duration totalTimeForeground;
  final DateTime lastTimeUsed;

  factory UsageStatDto.fromMap(Map<dynamic, dynamic> map) {
    return UsageStatDto(
      packageName: map['packageName'] as String? ?? '',
      totalTimeForeground: Duration(
        milliseconds: (map['totalTimeForegroundMs'] as num?)?.toInt() ?? 0,
      ),
      lastTimeUsed: DateTime.fromMillisecondsSinceEpoch(
        (map['lastTimeUsedMs'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

final class InstalledAppDto {
  const InstalledAppDto({
    required this.packageName,
    required this.appName,
    required this.isSystemApp,
    required this.category,
    this.versionName,
    this.versionCode,
    this.installTime,
    this.updateTime,
    this.iconPng,
  });

  final String packageName;
  final String appName;
  final String? versionName;
  final int? versionCode;
  final bool isSystemApp;
  final String category;
  final DateTime? installTime;
  final DateTime? updateTime;
  final Uint8List? iconPng;

  factory InstalledAppDto.fromMap(Map<dynamic, dynamic> map) {
    final iconRaw = map['iconPng'];
    Uint8List? icon;
    if (iconRaw is Uint8List) {
      icon = iconRaw;
    } else if (iconRaw is List<int>) {
      icon = Uint8List.fromList(iconRaw);
    }

    return InstalledAppDto(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      versionName: map['versionName'] as String?,
      versionCode: (map['versionCode'] as num?)?.toInt(),
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      category: map['category'] as String? ?? 'other',
      installTime: _msToDate(map['installTimeMs']),
      updateTime: _msToDate(map['updateTimeMs']),
      iconPng: icon,
    );
  }

  static DateTime? _msToDate(Object? value) {
    if (value is num && value > 0) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }
}
