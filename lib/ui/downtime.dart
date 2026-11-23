import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../state.dart';
import 'limits.dart';
import 'widgets.dart';

String fmtMinuteOfDay(BuildContext context, int minute) =>
    TimeOfDay(hour: minute ~/ 60, minute: minute % 60).format(context);

/// "11:00 PM – 7:00 AM" for a downtime window.
String fmtWindow(BuildContext context, Downtime d) => '${fmtMinuteOfDay(context, d.start)} – ${fmtMinuteOfDay(context, d.end)}';

/// Downtime: a daily window and a list of apps. Opening one of them in the window gets a gentle
/// notification from the native background check. Nothing is blocked.
class DowntimeScreen extends ConsumerWidget {
  const DowntimeScreen({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref, Downtime d) async {
    final repo = ref.read(repoProvider);
    ref.read(downtimeProvider.notifier).state = d;
    await repo.saveDowntime(d);
    if (d.enabled && d.apps.isNotEmpty && !await repo.native.notificationsEnabled()) {
      final granted = await repo.native.requestNotifications();
      if (!granted && context.mounted) {
        BToast.show(context, 'Notifications are off, so downtime reminders can\'t be shown',
            actionLabel: 'Settings', onAction: repo.native.openNotificationSettings);
      }
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, {required bool start}) async {
    final d = ref.read(downtimeProvider);
    final current = start ? d.start : d.end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: start ? 'Downtime starts' : 'Downtime ends',
    );
    if (picked == null || !context.mounted) return;
    final minute = picked.hour * 60 + picked.minute;
    final other = start ? d.end : d.start;
    if (minute == other) {
      BToast.show(context, 'Start and end can\'t be the same time');
      return;
    }
    await _save(context, ref, start ? d.copyWith(start: minute) : d.copyWith(end: minute));
  }

  Future<void> _addApp(BuildContext context, WidgetRef ref) async {
    final app = await Navigator.of(context).push(MaterialPageRoute<AppInfo>(builder: (_) => const AppPickerScreen()));
    if (app == null || !context.mounted) return;
    final d = ref.read(downtimeProvider);
    // Adding the first app turns downtime on; that is almost always what people mean.
    await _save(
      context,
      ref,
      d.copyWith(apps: {...d.apps, app.package: app.name}, enabled: d.apps.isEmpty ? true : d.enabled),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.basalt;
    final d = ref.watch(downtimeProvider);
    final minutesNow = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
    final inside = d.enabled && d.contains(minutesNow);
    final names = d.apps.entries.toList()..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Downtime')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addApp(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add app'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, 96),
        children: [
          Text(
            'Pick a daily window and the apps you want to stay away from then. If you open one of them during '
            'downtime, Clocked sends a gentle "It\'s downtime" reminder, at most once every 10 minutes per app.',
            style: BasaltType.body.copyWith(color: p.textMuted),
          ),
          const SizedBox(height: Gap.lg),
          BGroup(
            children: [
              BListRow(
                icon: Icons.bedtime_outlined,
                title: 'Downtime',
                subtitle: !d.enabled
                    ? 'Off'
                    : d.apps.isEmpty
                        ? 'On. Add apps to get reminders'
                        : 'Every day, ${fmtWindow(context, d)}${inside ? ' · now' : ''}',
                trailing: Switch(value: d.enabled, onChanged: (v) => _save(context, ref, d.copyWith(enabled: v))),
              ),
              BListRow(
                icon: Icons.schedule_rounded,
                title: 'Starts',
                subtitle: fmtMinuteOfDay(context, d.start),
                chevron: true,
                onTap: () => _pickTime(context, ref, start: true),
              ),
              BListRow(
                icon: Icons.wb_twilight_rounded,
                title: 'Ends',
                subtitle: '${fmtMinuteOfDay(context, d.end)}${d.crossesMidnight ? ' (next day)' : ''}',
                chevron: true,
                onTap: () => _pickTime(context, ref, start: false),
              ),
            ],
          ),
          const BSectionTitle('Apps'),
          if (names.isEmpty)
            const BCard(
              child: BEmptyState(
                icon: Icons.apps_outlined,
                title: 'No apps yet',
                message: 'Tap Add app to choose the apps downtime applies to.',
              ),
            )
          else
            BGroup(
              children: [
                for (final e in names)
                  BListRow(
                    leading: AppIcon(e.key),
                    title: e.value,
                    subtitle: 'Reminder during downtime',
                    trailing: IconButton(
                      tooltip: 'Remove ${e.value}',
                      icon: Icon(Icons.close_rounded, color: p.textMuted),
                      onPressed: () => _save(context, ref, d.copyWith(apps: {...d.apps}..remove(e.key))),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: Gap.lg),
          BCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Honest limits', style: BasaltType.heading.copyWith(color: p.text)),
                const SizedBox(height: Gap.xs),
                Text(
                  'Nothing is blocked: the app opens as usual and you decide. Clocked checks which app is open every '
                  '15 minutes, and every 10 minutes while a downtime app stays open, so a reminder can arrive a few '
                  'minutes after you open it.',
                  style: BasaltType.body.copyWith(color: p.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
