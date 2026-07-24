import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final dynamicColorEnabledProvider =
    NotifierProvider<DynamicColorNotifier, bool>(DynamicColorNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.watch(settingsStorageProvider).themeMode;
    return _parse(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final storage = ref.read(settingsStorageProvider);
    await storage.setThemeMode(_serialize(mode));
    state = mode;
  }

  static ThemeMode _parse(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _serialize(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

class DynamicColorNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsStorageProvider).dynamicColorEnabled;

  Future<void> setEnabled(bool enabled) async {
    await ref.read(settingsStorageProvider).setDynamicColorEnabled(enabled);
    state = enabled;
  }
}
