import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showSystemAppsProvider =
    NotifierProvider<ShowSystemAppsNotifier, bool>(ShowSystemAppsNotifier.new);

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(
  NotificationsEnabledNotifier.new,
);

final dateFormatProvider =
    NotifierProvider<DateFormatNotifier, String>(DateFormatNotifier.new);

final timeFormatProvider =
    NotifierProvider<TimeFormatNotifier, String>(TimeFormatNotifier.new);

final defaultHomeProvider =
    NotifierProvider<DefaultHomeNotifier, String>(DefaultHomeNotifier.new);

final warnMinutesPrimaryProvider =
    NotifierProvider<WarnMinutesPrimaryNotifier, int>(
  WarnMinutesPrimaryNotifier.new,
);

final warnMinutesSecondaryProvider =
    NotifierProvider<WarnMinutesSecondaryNotifier, int>(
  WarnMinutesSecondaryNotifier.new,
);

/// null / empty = system locale
final appLocaleCodeProvider =
    NotifierProvider<AppLocaleCodeNotifier, String?>(AppLocaleCodeNotifier.new);

class ShowSystemAppsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsStorageProvider).showSystemApps;

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsStorageProvider).setShowSystemApps(enabled);
    state = enabled;
  }
}

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsStorageProvider).notificationsEnabled;

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsStorageProvider).setNotificationsEnabled(enabled);
    state = enabled;
  }
}

class DateFormatNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(settingsStorageProvider).dateFormat;

  Future<void> setFormat(String value) async {
    await ref.read(settingsStorageProvider).setDateFormat(value);
    state = value;
  }
}

class TimeFormatNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(settingsStorageProvider).timeFormat;

  Future<void> setFormat(String value) async {
    await ref.read(settingsStorageProvider).setTimeFormat(value);
    state = value;
  }
}

class DefaultHomeNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(settingsStorageProvider).defaultHome;

  Future<void> setHome(String value) async {
    await ref.read(settingsStorageProvider).setDefaultHome(value);
    state = value;
  }
}

class WarnMinutesPrimaryNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(settingsStorageProvider).warnMinutesPrimary;

  Future<void> setMinutes(int value) async {
    await ref.read(settingsStorageProvider).setWarnMinutesPrimary(value);
    state = value;
  }
}

class WarnMinutesSecondaryNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(settingsStorageProvider).warnMinutesSecondary;

  Future<void> setMinutes(int value) async {
    await ref.read(settingsStorageProvider).setWarnMinutesSecondary(value);
    state = value;
  }
}

class AppLocaleCodeNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(settingsStorageProvider).localeCode;

  Future<void> setLocaleCode(String? value) async {
    await ref.read(settingsStorageProvider).setLocaleCode(value);
    state = value;
  }
}
