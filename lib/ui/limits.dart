import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../state.dart';
import 'widgets.dart';

typedef _LimitChoice = ({int minutes, bool remove});

/// Bottom sheet to set, change or remove one app's daily limit.
Future<void> showLimitSheet(BuildContext context, WidgetRef ref, {required String package, required String name, AppLimit? existing}) async {
  final choice = await showModalBottomSheet<_LimitChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LimitSheet(name: name, initial: existing?.minutes ?? 30, exists: existing != null),
  );
  if (choice == null || !context.mounted) return;
  final repo = ref.read(repoProvider);
  await withRepo(ref, (r) async {
    if (choice.remove) {
      await r.deleteLimit(package);
    } else {
      await r.saveLimit(AppLimit(package: package, minutes: choice.minutes, enabled: existing?.enabled ?? true));
    }
  });
  if (!context.mounted) return;
  BToast.show(context, choice.remove ? 'Limit removed' : 'Limit saved: ${fmtMinutes(choice.minutes)} a day');
  if (!choice.remove && !await repo.native.notificationsEnabled()) {
    final granted = await repo.native.requestNotifications();
    if (!granted && context.mounted) {
      BToast.show(context, 'Notifications are off, so limit reminders can\'t be shown', actionLabel: 'Settings', onAction: repo.native.openNotificationSettings);
    }
  }
}

class _LimitSheet extends StatefulWidget {
  const _LimitSheet({required this.name, required this.initial, required this.exists});

  final String name;
  final int initial;
  final bool exists;

  @override
  State<_LimitSheet> createState() => _LimitSheetState();
}

class _LimitSheetState extends State<_LimitSheet> {
  static const presets = [15, 30, 45, 60, 90, 120, 180];
  late int _minutes = widget.initial < 5 ? 5 : (widget.initial > 300 ? 300 : widget.initial);

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Daily limit for ${widget.name}', style: BasaltType.title.copyWith(color: p.text)),
            const SizedBox(height: Gap.xs),
            Text('You get a reminder 5 minutes before and when you reach it.', style: BasaltType.body.copyWith(color: p.textMuted)),
            const SizedBox(height: Gap.xl),
            Center(child: Text(fmtMinutes(_minutes), style: BasaltType.hero.copyWith(color: p.text))),
            Slider(
              value: _minutes.toDouble(),
              min: 5,
              max: 300,
              divisions: 59,
              label: fmtMinutes(_minutes),
              onChanged: (v) => setState(() => _minutes = v.round()),
            ),
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (final m in presets) BChip(label: fmtMinutes(m), selected: m == _minutes, onTap: () => setState(() => _minutes = m)),
              ],
            ),
            const SizedBox(height: Gap.xl),
            BButton(label: 'Save limit', expand: true, onPressed: () => Navigator.pop(context, (minutes: _minutes, remove: false))),
            if (widget.exists) ...[
              const SizedBox(height: Gap.sm),
              BButton(
                label: 'Remove limit',
                variant: BButtonVariant.ghost,
                expand: true,
                onPressed: () => Navigator.pop(context, (minutes: _minutes, remove: true)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LimitsScreen extends ConsumerWidget {
  const LimitsScreen({super.key});

  Future<void> _toggleOverlay(BuildContext context, WidgetRef ref, bool on, bool allowed) async {
    final repo = ref.read(repoProvider);
    if (on && !allowed) {
      final ok = await bConfirm(
        context,
        title: 'Allow display over other apps',
        message: 'To put a reminder card on top of an app that is past its limit, Android needs the '
            '"Display over other apps" permission. AppPulse uses it only for that card. '
            'Notifications work without it.',
        confirmLabel: 'Open settings',
      );
      if (!ok) return;
      repo.prefs.limitOverlay = true;
      await repo.native.openOverlaySettings();
      return;
    }
    repo.prefs.limitOverlay = on;
    if (!context.mounted) return;
    await withRepo(ref, (r) => r.pushLimits());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.basalt;
    final repo = ref.read(repoProvider);
    final apps = ref.watch(appInfosProvider).valueOrNull ?? const {};
    final today = ref.watch(dayProvider(dayKey(DateTime.now()))).valueOrNull;
    final notifications = ref.watch(notificationsProvider).valueOrNull ?? true;
    final overlayAllowed = ref.watch(overlayAllowedProvider).valueOrNull ?? false;
    final overlayOn = repo.prefs.limitOverlay && overlayAllowed;

    return Scaffold(
      appBar: AppBar(title: const Text('App limits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final app = await Navigator.of(context).push(MaterialPageRoute<AppInfo>(builder: (_) => const AppPickerScreen()));
          if (app == null || !context.mounted) return;
          final limits = ref.read(limitsProvider).valueOrNull ?? const <AppLimit>[];
          await showLimitSheet(
            context,
            ref,
            package: app.package,
            name: app.name,
            existing: limits.where((l) => l.package == app.package).firstOrNull,
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add limit'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, 96),
        children: [
          Text(
            'AppPulse checks every 15 minutes, and right on time while a limited app is open. '
            'You get a notification 5 minutes before the limit and when you reach it. Apps are never blocked.',
            style: BasaltType.body.copyWith(color: p.textMuted),
          ),
          if (!notifications) ...[
            const SizedBox(height: Gap.md),
            BCard(
              borderColor: p.warning.withValues(alpha: 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications are off', style: BasaltType.heading.copyWith(color: p.text)),
                  const SizedBox(height: Gap.xs),
                  Text('Limit reminders are sent as notifications.', style: BasaltType.body.copyWith(color: p.textMuted)),
                  const SizedBox(height: Gap.md),
                  BButton(
                    label: 'Allow notifications',
                    variant: BButtonVariant.secondary,
                    onPressed: () async {
                      final granted = await repo.native.requestNotifications();
                      if (!granted) await repo.native.openNotificationSettings();
                      if (context.mounted) bump(ref);
                    },
                  ),
                ],
              ),
            ),
          ],
          const BSectionTitle('Reminder style'),
          BGroup(
            children: [
              BListRow(
                icon: Icons.notifications_none_rounded,
                title: 'Notification',
                subtitle: 'Always on',
                trailing: StatusBadge(ok: notifications, offLabel: 'Blocked'),
              ),
              BListRow(
                icon: Icons.layers_outlined,
                title: 'Card on top of the app',
                subtitle: overlayAllowed
                    ? 'Shows a reminder over an app that is past its limit'
                    : 'Optional. Needs "Display over other apps"',
                trailing: Switch(value: overlayOn, onChanged: (v) => _toggleOverlay(context, ref, v, overlayAllowed)),
              ),
            ],
          ),
          const BSectionTitle('Your limits'),
          asyncView(ref.watch(limitsProvider), (limits) {
            if (limits.isEmpty) {
              return const BCard(
                child: BEmptyState(
                  icon: Icons.timer_outlined,
                  title: 'No limits yet',
                  message: 'Tap Add limit to choose an app and a daily time.',
                ),
              );
            }
            return BGroup(
              children: [
                for (final l in limits)
                  Builder(builder: (context) {
                    final used = today?.totalFor(l.package) ?? Duration.zero;
                    final name = repo.infoFrom(apps, l.package).name;
                    final reached = used >= l.duration;
                    return AppUsageRow(
                      package: l.package,
                      name: name,
                      duration: used,
                      subtitle: !l.enabled
                          ? 'Paused · ${fmtMinutes(l.minutes)} a day'
                          : '${fmtDuration(used)} of ${fmtMinutes(l.minutes)} today${reached ? ' · reached' : ''}',
                      share: l.enabled ? used.inSeconds / l.duration.inSeconds : null,
                      onTap: () => showLimitSheet(context, ref, package: l.package, name: name, existing: l),
                      trailing: Switch(
                        value: l.enabled,
                        onChanged: (v) => withRepo(ref, (r) => r.saveLimit(AppLimit(package: l.package, minutes: l.minutes, enabled: v))),
                      ),
                    );
                  }),
              ],
            );
          }),
        ],
      ),
    );
  }
}

final _launchableProvider = FutureProvider.autoDispose<List<AppInfo>>((ref) => ref.read(repoProvider).launchableApps());

/// Pick an installed app (used to add a limit).
class AppPickerScreen extends ConsumerStatefulWidget {
  const AppPickerScreen({super.key});

  @override
  ConsumerState<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends ConsumerState<AppPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose an app')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.md),
            child: BSearchField(hint: 'Search apps', autofocus: false, onChanged: (v) => setState(() => _query = v.trim().toLowerCase())),
          ),
          Expanded(
            child: asyncView(ref.watch(_launchableProvider), (apps) {
              final rows = apps.where((a) => _query.isEmpty || a.name.toLowerCase().contains(_query)).toList();
              if (rows.isEmpty) return const BEmptyState(icon: Icons.search_off_rounded, title: 'No apps found');
              return ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  final a = rows[i];
                  return BListRow(
                    leading: AppIcon(a.package),
                    title: a.name,
                    subtitle: a.categoryLabel,
                    onTap: () => Navigator.pop(context, a),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
