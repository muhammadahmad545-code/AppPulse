import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../data/reconstruct.dart';
import '../state.dart';
import 'limits.dart';
import 'widgets.dart';

void openAppDetail(BuildContext context, String package) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AppDetailScreen(package: package)));
}

/// The last 30 days of one app's sessions.
final appSessionsProvider = FutureProvider.family<List<Session>, String>((ref, package) {
  ref.watch(revisionProvider);
  final today = startOfDay(DateTime.now());
  return ref.watch(repoProvider).appSessions(package, addDays(today, -29), nextDay(today));
});

class AppDetailScreen extends ConsumerWidget {
  const AppDetailScreen({super.key, required this.package});

  final String package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.basalt;
    final repo = ref.read(repoProvider);
    final apps = ref.watch(appInfosProvider).valueOrNull ?? const {};
    final info = repo.infoFrom(apps, package);
    final limits = ref.watch(limitsProvider).valueOrNull ?? const <AppLimit>[];
    final limit = limits.where((l) => l.package == package).firstOrNull;
    final now = DateTime.now();
    final today = startOfDay(now);

    return Scaffold(
      appBar: AppBar(title: Text(info.name)),
      body: asyncView(ref.watch(appSessionsProvider(package)), (sessions) {
        final todaySessions = sessions.where((s) => !s.start.isBefore(today)).toList();
        final todayTotal = totalOf(todaySessions);
        final week = [for (var i = 6; i >= 0; i--) addDays(today, -i)];
        final perDay = [
          for (final d in week) totalOf(sessions.where((s) => sameDay(s.start, d))),
        ];
        final weekTotal = perDay.fold(Duration.zero, (a, b) => a + b);
        final monthTotal = totalOf(sessions);
        final recent = sessions.reversed.take(20).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
          children: [
            Row(
              children: [
                AppIcon(package, size: 56),
                const SizedBox(width: Gap.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.name, style: BasaltType.title.copyWith(color: p.text)),
                      const SizedBox(height: 2),
                      Text(package, style: BasaltType.caption.copyWith(color: p.textMuted)),
                      const SizedBox(height: Gap.sm),
                      Wrap(
                        spacing: Gap.xs,
                        runSpacing: Gap.xs,
                        children: [
                          BBadge(info.categoryLabel),
                          if (info.system) BBadge('System app', color: p.textMuted),
                          if (!info.installed) BBadge('Uninstalled', color: p.warning),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gap.lg),
            Row(
              children: [
                Expanded(child: BStatTile(label: 'Today', value: fmtDuration(todayTotal))),
                const SizedBox(width: Gap.sm),
                Expanded(child: BStatTile(label: 'Daily average', value: fmtDuration(weekTotal ~/ 7), hint: 'last 7 days')),
                const SizedBox(width: Gap.sm),
                Expanded(child: BStatTile(label: '30 days', value: fmtDuration(monthTotal))),
              ],
            ),
            const BSectionTitle('Last 7 days'),
            BCard(
              child: BBars(
                values: [for (final d in perDay) d.inSeconds.toDouble()],
                labels: [for (final d in week) DateFormat('EEE').format(d)],
                highlight: 6,
              ),
            ),
            const BSectionTitle('Today by hour'),
            BCard(child: HourlyChart(hours: hourlyTotals(todaySessions, today), highlightHour: now.hour)),
            const BSectionTitle('Daily limit'),
            BGroup(
              children: [
                BListRow(
                  icon: Icons.timer_outlined,
                  title: limit == null ? 'Set a daily limit' : '${fmtMinutes(limit.minutes)} a day',
                  subtitle: limit == null
                      ? 'Get a reminder when you reach it'
                      : '${fmtDuration(todayTotal)} used today${limit.enabled ? '' : ' · paused'}',
                  trailing: Text(limit == null ? 'Set' : 'Edit', style: BasaltType.label.copyWith(color: p.accent)),
                  onTap: () => showLimitSheet(context, ref, package: package, name: info.name, existing: limit),
                ),
              ],
            ),
            const BSectionTitle('Recent sessions'),
            if (recent.isEmpty)
              BCard(child: Text('No sessions in the last 30 days.', style: BasaltType.body.copyWith(color: p.textMuted)))
            else
              BGroup(
                children: [
                  for (final s in recent)
                    BListRow(
                      dense: true,
                      title: '${fmtTime(s.start)} – ${fmtTime(s.end)}',
                      subtitle: fmtRelativeDay(s.start),
                      trailing: Text(fmtDuration(s.duration), style: BasaltType.label.copyWith(color: p.text)),
                    ),
                ],
              ),
            const SizedBox(height: Gap.lg),
            if (info.installed)
              BButton(
                label: 'Open app info',
                icon: Icons.info_outline_rounded,
                variant: BButtonVariant.secondary,
                expand: true,
                onPressed: () => repo.native.openAppInfo(package),
              ),
          ],
        );
      }),
    );
  }
}
