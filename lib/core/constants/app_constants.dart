/// Global application constants for AppPulse.
abstract final class AppConstants {
  static const String appName = 'AppPulse';
  static const String tagline = 'Know Where Your Time Goes.';
  static const String packageName = 'com.apppulse.app_pulse';

  static const String databaseName = 'app_pulse.db';
  static const String hiveBoxSettings = 'settings';

  /// Minimum session duration (ms) to persist — filters noise / flicker.
  static const int minSessionDurationMs = 3_000;

  /// Default polling interval for usage stats collection.
  static const Duration usagePollInterval = Duration(seconds: 15);

  /// WorkManager unique task names.
  static const String usageSyncTask = 'app_pulse_usage_sync';
  static const String dailyRolloverTask = 'app_pulse_daily_rollover';
  static const String limitCheckTask = 'app_pulse_limit_check';

  /// Notification channel IDs.
  static const String notificationChannelLimits = 'limits';
  static const String notificationChannelFocus = 'focus';
  static const String notificationChannelTracking = 'tracking';
  static const String notificationChannelGeneral = 'general';
}
