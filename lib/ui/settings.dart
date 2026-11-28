import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../state.dart';
import 'accuracy.dart';
import 'backup.dart';
import 'downtime.dart';
import 'focus.dart';
import 'limits.dart';
import 'reports.dart';
import 'widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current = ref.read(themeModeProvider);
    final mode = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (m, label) in const [(ThemeMode.system, 'System'), (ThemeMode.light, 'Light'), (ThemeMode.dark, 'Dark')])
              ListTile(
                title: Text(label),
                trailing: m == current ? Icon(Icons.check_rounded, color: ctx.basalt.accent) : null,
                onTap: () => Navigator.pop(ctx, m),
              ),
            const SizedBox(height: Gap.sm),
          ],
        ),
      ),
    );
    if (mode == null) return;
    ref.read(prefsProvider).themeMode = mode;
    ref.read(themeModeProvider.notifier).state = mode;
  }

  Future<void> _pickGoal(BuildContext context, WidgetRef ref) async {
    final current = ref.read(goalProvider);
    const options = [0, 60, 120, 180, 240, 300, 360];
    final goal = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final m in options)
                ListTile(
                  title: Text(m == 0 ? 'No goal' : '${fmtMinutes(m)} a day'),
                  trailing: m == current ? Icon(Icons.check_rounded, color: ctx.basalt.accent) : null,
                  onTap: () => Navigator.pop(ctx, m),
                ),
              const SizedBox(height: Gap.sm),
            ],
          ),
        ),
      ),
    );
    if (goal == null) return;
    ref.read(prefsProvider).goalMinutes = goal;
    ref.read(goalProvider.notifier).state = goal;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repoProvider);
    final access = ref.watch(accessProvider).valueOrNull ?? false;
    final notifications = ref.watch(notificationsProvider).valueOrNull ?? false;
    final overlay = ref.watch(overlayAllowedProvider).valueOrNull ?? false;
    final limits = ref.watch(limitsProvider).valueOrNull ?? const [];
    final theme = ref.watch(themeModeProvider);
    final goal = ref.watch(goalProvider);
    final syncing = ref.watch(syncingProvider);
    final lastSync = repo.prefs.lastSync;
    final downtime = ref.watch(downtimeProvider);
    final weekly = ref.watch(weeklySummaryProvider);

    return BPage(
      title: 'Settings',
      children: [
        BGroup(
          title: 'Permissions',
          children: [
            BListRow(
              icon: Icons.query_stats_rounded,
              title: 'Usage access',
              subtitle: access ? 'Clocked can read screen time' : 'Required to measure screen time',
              trailing: StatusBadge(ok: access, okLabel: 'Allowed', offLabel: 'Needed'),
              onTap: repo.native.openUsageAccess,
            ),
            BListRow(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Limits, downtime, focus timer and weekly summary',
              trailing: StatusBadge(ok: notifications, okLabel: 'Allowed', offLabel: 'Off'),
              onTap: () async {
                if (notifications || !await repo.native.requestNotifications()) {
                  await repo.native.openNotificationSettings();
                }
                if (context.mounted) bump(ref);
              },
            ),
            BListRow(
              icon: Icons.layers_outlined,
              title: 'Display over other apps',
              subtitle: 'Optional. Only for the limit reminder card',
              trailing: StatusBadge(ok: overlay, okLabel: 'Allowed', offLabel: 'Off', offIsWarning: false),
              onTap: repo.native.openOverlaySettings,
            ),
          ],
        ),
        BGroup(
          title: 'Tools',
          children: [
            BListRow(
              icon: Icons.timer_outlined,
              title: 'App limits',
              subtitle: limits.isEmpty ? 'No limits yet' : '${limits.length} ${limits.length == 1 ? 'app' : 'apps'}',
              chevron: true,
              onTap: () => _push(context, const LimitsScreen()),
            ),
            BListRow(
              icon: Icons.bedtime_outlined,
              title: 'Downtime',
              subtitle: !downtime.enabled
                  ? 'Off'
                  : '${fmtWindow(context, downtime)} · ${downtime.apps.length} ${downtime.apps.length == 1 ? 'app' : 'apps'}',
              chevron: true,
              onTap: () => _push(context, const DowntimeScreen()),
            ),
            BListRow(
              icon: Icons.self_improvement_rounded,
              title: 'Focus mode',
              subtitle: 'Timed sessions with a summary',
              chevron: true,
              onTap: () => _push(context, const FocusScreen()),
            ),
            BListRow(
              icon: Icons.ios_share_rounded,
              title: 'Reports',
              subtitle: 'Export CSV or PDF',
              chevron: true,
              onTap: () => _push(context, const ReportsScreen()),
            ),
            BListRow(
              icon: Icons.fact_check_outlined,
              title: 'Accuracy check',
              subtitle: 'Compare today with Android\'s own totals',
              chevron: true,
              onTap: () => _push(context, const AccuracyScreen()),
            ),
          ],
        ),
        BGroup(
          title: 'Weekly summary',
          children: [
            BListRow(
              icon: Icons.calendar_view_week_rounded,
              title: 'Monday summary',
              subtitle: 'Last week\'s total and top app, every Monday',
              trailing: Switch(
                value: weekly,
                onChanged: (v) async {
                  repo.prefs.weeklySummary = v;
                  ref.read(weeklySummaryProvider.notifier).state = v;
                  await repo.pushWeekly();
                  if (v && !await repo.native.notificationsEnabled()) await repo.native.requestNotifications();
                },
              ),
            ),
            BListRow(
              icon: Icons.notifications_active_outlined,
              title: 'Send a preview now',
              subtitle: 'Shows last week\'s summary as a notification',
              onTap: () async {
                if (!await repo.native.notificationsEnabled() && !await repo.native.requestNotifications()) {
                  if (context.mounted) {
                    BToast.show(context, 'Notifications are off', actionLabel: 'Settings', onAction: repo.native.openNotificationSettings);
                  }
                  return;
                }
                final full = await repo.native.weeklyPreview();
                if (context.mounted) BToast.show(context, full ? 'Summary sent' : 'Not enough data from last week yet');
              },
            ),
          ],
        ),
        BGroup(
          title: 'Quick access',
          children: const [
            BListRow(
              icon: Icons.widgets_outlined,
              title: 'Home-screen widget',
              subtitle: 'Long-press your home screen, tap Widgets and pick Clocked. It shows today\'s screen time, '
                  'the change against yesterday and your top 3 apps.',
              maxSubtitleLines: 4,
            ),
            BListRow(
              icon: Icons.timer_outlined,
              title: 'Focus tile',
              subtitle: 'Edit Quick Settings and drag in Focus. Tap it to start a 25-minute focus session, tap again '
                  'to stop. Long-press it to open the focus screen.',
              maxSubtitleLines: 4,
            ),
            BListRow(
              icon: Icons.touch_app_outlined,
              title: 'App shortcuts',
              subtitle: 'Long-press the Clocked icon for Start focus and App limits.',
              maxSubtitleLines: 3,
            ),
          ],
        ),
        BGroup(
          title: 'Preferences',
          children: [
            BListRow(
              icon: Icons.brightness_6_outlined,
              title: 'Theme',
              subtitle: switch (theme) {
                ThemeMode.light => 'Light',
                ThemeMode.dark => 'Dark',
                _ => 'System',
              },
              chevron: true,
              onTap: () => _pickTheme(context, ref),
            ),
            BListRow(
              icon: Icons.flag_outlined,
              title: 'Daily goal',
              subtitle: goal == 0 ? 'No goal' : '${fmtMinutes(goal)} of screen time',
              chevron: true,
              onTap: () => _pickGoal(context, ref),
            ),
          ],
        ),
        BGroup(
          title: 'Data',
          children: [
            BListRow(
              icon: Icons.sync_rounded,
              title: 'Sync now',
              subtitle: lastSync == null ? 'Never synced' : 'Last synced ${fmtRelativeDay(lastSync).toLowerCase()} at ${fmtTime(lastSync)}',
              trailing: syncing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
              onTap: syncing
                  ? null
                  : () async {
                      await syncNow(ref);
                      if (context.mounted) BToast.show(context, 'Synced');
                    },
            ),
            BListRow(
              icon: Icons.save_alt_rounded,
              title: 'Back up to a file',
              subtitle: 'Screen-time history, limits, focus sessions and settings, for a new phone or safekeeping',
              chevron: true,
              onTap: () => backUp(context, ref),
            ),
            BListRow(
              icon: Icons.settings_backup_restore_rounded,
              title: 'Restore from a backup',
              subtitle: 'Bring history, limits and settings back from a Clocked backup file',
              chevron: true,
              onTap: () => restoreBackup(context, ref),
            ),
            BListRow(
              icon: Icons.delete_outline_rounded,
              title: 'Clear history',
              subtitle: 'Delete saved screen time and focus history',
              danger: true,
              onTap: () async {
                final ok = await bConfirm(
                  context,
                  title: 'Clear history?',
                  message: 'Saved screen time and focus history will be deleted. Limits and settings stay. '
                      'Today\'s numbers are read from Android again.',
                  confirmLabel: 'Clear',
                  danger: true,
                );
                if (!ok || !context.mounted) return;
                await withRepo(ref, (r) => r.clearHistory());
                if (context.mounted) await syncNow(ref);
                if (context.mounted) BToast.show(context, 'History cleared');
              },
            ),
          ],
        ),
        const SizedBox(height: Gap.md),
        const UpdatesSection(),
        BGroup(
          title: 'About',
          children: const [
            BListRow(
              icon: Icons.lock_outline_rounded,
              title: 'Private by design',
              subtitle: 'Everything stays on this phone. No account, no analytics. Only backup files you save '
                  'yourself leave it. The only network request is the update check on GitHub.',
              maxSubtitleLines: 4,
            ),
          ],
        ),
      ],
    );
  }
}
