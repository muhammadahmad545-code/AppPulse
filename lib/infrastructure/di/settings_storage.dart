import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Typed Hive-backed settings / preferences store.
///
/// Relational analytics live in Drift; lightweight user preferences live here.
/// The settings box uses AES encryption. The key is kept in app documents so
/// background isolates can open the same box, and mirrored in secure storage.
final class SettingsStorage {
  SettingsStorage(this._box);

  final Box<dynamic> _box;

  static const _cipherKeyStorageKey = 'app_pulse_hive_aes_key';
  static const _cipherKeyFileName = '.app_pulse_hive.key';

  static Future<SettingsStorage> open({
    FlutterSecureStorage? secureStorage,
  }) async {
    final storage = secureStorage ??
        const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

    try {
      final cipher = HiveAesCipher(await _loadOrCreateKey(storage));
      final box = await Hive.openBox<dynamic>(
        AppConstants.hiveBoxSettings,
        encryptionCipher: cipher,
      );
      AppLogger.i('SettingsStorage opened (encrypted)');
      return SettingsStorage(box);
    } catch (error, stack) {
      // Existing plain boxes / missing secure storage fall back gracefully.
      AppLogger.w('Encrypted Hive open failed; using plain box', error, stack);
      final box =
          await Hive.openBox<dynamic>(AppConstants.hiveBoxSettings);
      return SettingsStorage(box);
    }
  }

  static Future<Uint8List> _loadOrCreateKey(FlutterSecureStorage storage) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _cipherKeyFileName));

    if (await file.exists()) {
      final fromFile = await file.readAsString();
      if (fromFile.isNotEmpty) {
        return Uint8List.fromList(base64Decode(fromFile));
      }
    }

    try {
      final existing = await storage.read(key: _cipherKeyStorageKey);
      if (existing != null && existing.isNotEmpty) {
        await file.writeAsString(existing);
        return Uint8List.fromList(base64Decode(existing));
      }
    } catch (_) {
      // Secure storage may be unavailable in background isolates.
    }

    final key = Hive.generateSecureKey();
    final encoded = base64Encode(key);
    await file.writeAsString(encoded);
    try {
      await storage.write(key: _cipherKeyStorageKey, value: encoded);
    } catch (_) {}
    return Uint8List.fromList(key);
  }

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

  String get defaultHome =>
      _box.get(_defaultHomeKey, defaultValue: 'dashboard') as String;

  Future<void> setDefaultHome(String value) =>
      _box.put(_defaultHomeKey, value);

  String get dateFormat =>
      _box.get(_dateFormatKey, defaultValue: 'MMM d, y') as String;

  Future<void> setDateFormat(String value) => _box.put(_dateFormatKey, value);

  String get timeFormat =>
      _box.get(_timeFormatKey, defaultValue: '12h') as String;

  Future<void> setTimeFormat(String value) => _box.put(_timeFormatKey, value);

  String? get localeCode => _box.get(_localeKey) as String?;

  Future<void> setLocaleCode(String? value) async {
    if (value == null || value.isEmpty) {
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
