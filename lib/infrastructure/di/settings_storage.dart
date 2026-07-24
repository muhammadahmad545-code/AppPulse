import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Typed Hive-backed settings / preferences store.
///
/// Relational analytics live in Drift; lightweight user preferences live here.
final class SettingsStorage {
  SettingsStorage(this._box);

  final Box<dynamic> _box;

  static Future<SettingsStorage> open() async {
    final box = await Hive.openBox<dynamic>(AppConstants.hiveBoxSettings);
    AppLogger.i('SettingsStorage opened');
    return SettingsStorage(box);
  }

  // ── Theme ──────────────────────────────────────────────────────────────

  static const _themeModeKey = 'theme_mode';
  static const _dynamicColorKey = 'dynamic_color';
  static const _showSystemAppsKey = 'show_system_apps';
  static const _defaultHomeKey = 'default_home';
  static const _dateFormatKey = 'date_format';
  static const _timeFormatKey = 'time_format';
  static const _localeKey = 'locale';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _usageAccessGrantedKey = 'usage_access_granted';
  static const _trackingEnabledKey = 'tracking_enabled';
  static const _warnMinutesPrimaryKey = 'warn_minutes_primary';
  static const _warnMinutesSecondaryKey = 'warn_minutes_secondary';
  static const _lastUsageSyncMsKey = 'last_usage_sync_ms';
  static const _lastCatalogSyncMsKey = 'last_catalog_sync_ms';
  static const _lastKnownTimeZoneOffsetKey = 'last_tz_offset_minutes';
  static const _lastKnownDayKey = 'last_known_day_key';

  /// system | light | dark
  String get themeMode =>
      _box.get(_themeModeKey, defaultValue: 'system') as String;

  Future<void> setThemeMode(String value) => _box.put(_themeModeKey, value);

  bool get dynamicColorEnabled =>
      _box.get(_dynamicColorKey, defaultValue: true) as bool;

  Future<void> setDynamicColorEnabled(bool value) =>
      _box.put(_dynamicColorKey, value);

  bool get showSystemApps =>
      _box.get(_showSystemAppsKey, defaultValue: false) as bool;

  Future<void> setShowSystemApps(bool value) =>
      _box.put(_showSystemAppsKey, value);

  /// dashboard | apps | timeline | analytics
  String get defaultHome =>
      _box.get(_defaultHomeKey, defaultValue: 'dashboard') as String;

  Future<void> setDefaultHome(String value) =>
      _box.put(_defaultHomeKey, value);

  /// MMM d, y | yyyy-MM-dd | dd/MM/yyyy | MM/dd/yyyy
  String get dateFormat =>
      _box.get(_dateFormatKey, defaultValue: 'MMM d, y') as String;

  Future<void> setDateFormat(String value) => _box.put(_dateFormatKey, value);

  /// 12h | 24h
  String get timeFormat =>
      _box.get(_timeFormatKey, defaultValue: '12h') as String;

  Future<void> setTimeFormat(String value) => _box.put(_timeFormatKey, value);

  String? get localeCode => _box.get(_localeKey) as String?;

  Future<void> setLocaleCode(String? value) async {
    if (value == null) {
      await _box.delete(_localeKey);
    } else {
      await _box.put(_localeKey, value);
    }
  }

  bool get notificationsEnabled =>
      _box.get(_notificationsEnabledKey, defaultValue: true) as bool;

  Future<void> setNotificationsEnabled(bool value) =>
      _box.put(_notificationsEnabledKey, value);

  bool get onboardingComplete =>
      _box.get(_onboardingCompleteKey, defaultValue: false) as bool;

  Future<void> setOnboardingComplete(bool value) =>
      _box.put(_onboardingCompleteKey, value);

  bool get usageAccessGranted =>
      _box.get(_usageAccessGrantedKey, defaultValue: false) as bool;

  Future<void> setUsageAccessGranted(bool value) =>
      _box.put(_usageAccessGrantedKey, value);

  bool get trackingEnabled =>
      _box.get(_trackingEnabledKey, defaultValue: true) as bool;

  Future<void> setTrackingEnabled(bool value) =>
      _box.put(_trackingEnabledKey, value);

  int get warnMinutesPrimary =>
      _box.get(_warnMinutesPrimaryKey, defaultValue: 5) as int;

  Future<void> setWarnMinutesPrimary(int value) =>
      _box.put(_warnMinutesPrimaryKey, value);

  int get warnMinutesSecondary =>
      _box.get(_warnMinutesSecondaryKey, defaultValue: 10) as int;

  Future<void> setWarnMinutesSecondary(int value) =>
      _box.put(_warnMinutesSecondaryKey, value);

  int? get lastUsageSyncMs => _box.get(_lastUsageSyncMsKey) as int?;

  Future<void> setLastUsageSyncMs(int value) =>
      _box.put(_lastUsageSyncMsKey, value);

  int? get lastCatalogSyncMs => _box.get(_lastCatalogSyncMsKey) as int?;

  Future<void> setLastCatalogSyncMs(int value) =>
      _box.put(_lastCatalogSyncMsKey, value);

  int? get lastKnownTimeZoneOffsetMinutes =>
      _box.get(_lastKnownTimeZoneOffsetKey) as int?;

  Future<void> setLastKnownTimeZoneOffsetMinutes(int value) =>
      _box.put(_lastKnownTimeZoneOffsetKey, value);

  String? get lastKnownDayKey => _box.get(_lastKnownDayKey) as String?;

  Future<void> setLastKnownDayKey(String value) =>
      _box.put(_lastKnownDayKey, value);

  Future<void> clear() => _box.clear();
}
