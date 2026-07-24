import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/features/onboarding/presentation/providers/permission_providers.dart';
import 'package:app_pulse/features/settings/presentation/providers/settings_providers.dart';
import 'package:app_pulse/features/settings/presentation/providers/theme_providers.dart';
import 'package:app_pulse/features/settings/presentation/widgets/update_checker.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings hub: appearance, tracking, formats, backup, and about.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _dateFormats = [
    'MMM d, y',
    'yyyy-MM-dd',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
  ];

  static const _homeOptions = {
    'dashboard': 'Dashboard',
    'apps': 'Apps',
    'timeline': 'Timeline',
    'analytics': 'Analytics',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final dynamicColor = ref.watch(dynamicColorEnabledProvider);
    final showSystemApps = ref.watch(showSystemAppsProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final trackingEnabled = ref.watch(trackingEnabledProvider);
    final dateFormat = ref.watch(dateFormatProvider);
    final timeFormat = ref.watch(timeFormatProvider);
    final defaultHome = ref.watch(defaultHomeProvider);
    final warnPrimary = ref.watch(warnMinutesPrimaryProvider);
    final warnSecondary = ref.watch(warnMinutesSecondaryProvider);
    final localeCode = ref.watch(appLocaleCodeProvider);
    final permissions = ref.watch(permissionSnapshotProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionLabel('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(_themeLabel(themeMode)),
                  onTap: () => _showThemePicker(context, ref, themeMode),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.palette_outlined),
                  title: const Text('Dynamic colors'),
                  subtitle: const Text('Material You from wallpaper'),
                  value: dynamicColor,
                  onChanged: (value) {
                    ref
                        .read(dynamicColorEnabledProvider.notifier)
                        .setEnabled(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Formats'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Date format'),
                  subtitle: Text(dateFormat),
                  onTap: () => _pickOption(
                    context,
                    title: 'Date format',
                    options: {
                      for (final f in _dateFormats) f: f,
                    },
                    current: dateFormat,
                    onSelected: (value) =>
                        ref.read(dateFormatProvider.notifier).setFormat(value),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Time format'),
                  subtitle: Text(timeFormat == '24h' ? '24-hour' : '12-hour'),
                  onTap: () => _pickOption(
                    context,
                    title: 'Time format',
                    options: const {'12h': '12-hour', '24h': '24-hour'},
                    current: timeFormat,
                    onSelected: (value) =>
                        ref.read(timeFormatProvider.notifier).setFormat(value),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Default home tab'),
                  subtitle: Text(_homeOptions[defaultHome] ?? 'Dashboard'),
                  onTap: () => _pickOption(
                    context,
                    title: 'Default home',
                    options: _homeOptions,
                    current: defaultHome,
                    onSelected: (value) =>
                        ref.read(defaultHomeProvider.notifier).setHome(value),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language'),
                  subtitle: Text(_localeLabel(localeCode)),
                  onTap: () => _pickOption(
                    context,
                    title: 'Language',
                    options: const {
                      '': 'System default',
                      'en': 'English',
                    },
                    current: localeCode ?? '',
                    onSelected: (value) => ref
                        .read(appLocaleCodeProvider.notifier)
                        .setLocaleCode(value.isEmpty ? null : value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Tracking'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.play_circle_outline),
                  title: const Text('Usage tracking'),
                  subtitle: const Text(
                    'Foreground service + periodic sync',
                  ),
                  value: trackingEnabled,
                  onChanged: (value) {
                    ref
                        .read(trackingEnabledProvider.notifier)
                        .setEnabled(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Permissions'),
                  subtitle: Text(
                    permissions.when(
                      data: (snap) => snap.usageAccess
                          ? 'Usage access granted'
                          : 'Usage access required',
                      loading: () => 'Checking…',
                      error: (_, _) => 'Unable to check',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.permissions),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync_rounded),
                  title: const Text('Sync now'),
                  subtitle: const Text('Refresh usage from Android'),
                  onTap: () async {
                    await ref
                        .read(appCatalogSyncServiceProvider)
                        .sync(force: true);
                    await ref.read(usageSyncServiceProvider).sync();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync complete')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.android_outlined),
                  title: const Text('Show system apps'),
                  value: showSystemApps,
                  onChanged: (value) {
                    ref
                        .read(showSystemAppsProvider.notifier)
                        .setEnabled(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  value: notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(notificationsEnabledProvider.notifier)
                        .setEnabled(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.layers_outlined),
                  title: const Text('Display over other apps'),
                  subtitle: const Text(
                    'Needed for system overlay limit reminders',
                  ),
                  onTap: () async {
                    final platform = ref.read(usageStatsPlatformProvider);
                    if (await platform.canDrawOverlays()) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Overlay permission already granted'),
                          ),
                        );
                      }
                      return;
                    }
                    await platform.openOverlaySettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Limit defaults'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Primary warn (minutes left)'),
                  subtitle: Text('$warnPrimary minutes'),
                  onTap: () async {
                    final value = await _askInt(
                      context,
                      title: 'Primary warn minutes',
                      initial: warnPrimary,
                    );
                    if (value != null && value >= 0) {
                      await ref
                          .read(warnMinutesPrimaryProvider.notifier)
                          .setMinutes(value);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_none_outlined),
                  title: const Text('Secondary warn (minutes left)'),
                  subtitle: Text('$warnSecondary minutes'),
                  onTap: () async {
                    final value = await _askInt(
                      context,
                      title: 'Secondary warn minutes',
                      initial: warnSecondary,
                    );
                    if (value != null && value >= 0) {
                      await ref
                          .read(warnMinutesSecondaryProvider.notifier)
                          .setMinutes(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Productivity'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('App limits'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.limits),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.center_focus_strong_outlined),
                  title: const Text('Focus mode'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.focus),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Reports'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.reports),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Notification history'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.notifications),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text('Export / share backup'),
                  subtitle: const Text('Share a local SQLite copy'),
                  onTap: () async {
                    try {
                      await ref
                          .read(databaseBackupServiceProvider)
                          .shareExport();
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$error')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_outlined),
                  title: const Text('Restore backup'),
                  subtitle: const Text('Replace local database, then restart'),
                  onTap: () async {
                    final confirmed = await _confirm(
                      context,
                      title: 'Restore backup?',
                      message:
                          'This replaces your current database. Restart the app '
                          'after restore completes.',
                    );
                    if (confirmed != true || !context.mounted) return;
                    try {
                      await ref
                          .read(databaseBackupServiceProvider)
                          .restoreFromPicker();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Backup restored. Please restart AppPulse.',
                            ),
                          ),
                        );
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$error')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restart_alt_outlined),
                  title: const Text('Reset statistics'),
                  subtitle: const Text('Clears summaries & hourly buckets'),
                  onTap: () async {
                    final confirmed = await _confirm(
                      context,
                      title: 'Reset statistics?',
                      message:
                          'Daily/weekly/monthly summaries will be cleared. '
                          'Raw sessions stay unless you clear history.',
                    );
                    if (confirmed != true) return;
                    await ref
                        .read(databaseBackupServiceProvider)
                        .resetStatistics();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Statistics reset')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
                  title: Text(
                    'Clear history',
                    style: TextStyle(color: scheme.error),
                  ),
                  subtitle: const Text('Sessions + statistics'),
                  onTap: () async {
                    final confirmed = await _confirm(
                      context,
                      title: 'Clear all history?',
                      message:
                          'Deletes usage sessions and statistics. Installed '
                          'apps, limits, and settings are kept.',
                    );
                    if (confirmed != true) return;
                    await ref
                        .read(databaseBackupServiceProvider)
                        .clearHistory();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('History cleared')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('About'),
          Card(
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '—';
                final build = snapshot.data?.buildNumber ?? '—';
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.graphic_eq_rounded,
                        color: scheme.primary,
                      ),
                      title: const Text(AppConstants.appName),
                      subtitle: Text(
                        '${AppConstants.tagline}\nVersion $version ($build)',
                        style: textTheme.bodySmall,
                      ),
                      isThreeLine: true,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.system_update_alt_rounded),
                      title: const Text('Check for updates'),
                      subtitle: const Text('Download from GitHub Releases'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => checkAndPromptForAppUpdate(
                        context,
                        ref,
                        silentIfNone: false,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.privacy),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.balance_outlined),
                      title: const Text('Open-source licenses'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        showLicensePage(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: version,
                          applicationLegalese:
                              'OfflinePulse is offline-first. All usage data '
                              'stays on this device unless you export it.',
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  static String _localeLabel(String? code) {
    return switch (code) {
      null || '' => 'System default',
      'en' => 'English',
      _ => code,
    };
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values)
                ListTile(
                  leading: Icon(switch (mode) {
                    ThemeMode.system => Icons.brightness_auto_rounded,
                    ThemeMode.light => Icons.light_mode_rounded,
                    ThemeMode.dark => Icons.dark_mode_rounded,
                  }),
                  title: Text(_themeLabel(mode)),
                  trailing: mode == current
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(context, mode),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(themeModeProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _pickOption(
    BuildContext context, {
    required String title,
    required Map<String, String> options,
    required String current,
    required Future<void> Function(String value) onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final entry in options.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: entry.key == current
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(context, entry.key),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) await onSelected(selected);
  }

  Future<int?> _askInt(
    BuildContext context, {
    required String title,
    required int initial,
  }) async {
    final controller = TextEditingController(text: '$initial');
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Minutes'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
