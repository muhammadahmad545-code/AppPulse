import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../data/repo.dart';
import '../state.dart';
import 'app_detail.dart';
import 'focus.dart';
import 'limits.dart';
import 'shell.dart';
import 'widgets.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final access = ref.watch(accessProvider);
    return BPage(
      title: 'Today',
      subtitle: fmtDayLong(now),
      onRefresh: () => syncNow(ref),
      children: [
        const UpdateCard(),
        asyncView(access, (granted) {
          if (!granted) return const UsageAccessCard();
          return _TodayBody(now: now);
        }),
      ],
    );
  }
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(dayProvider(dayKey(now)));
    final yesterday = ref.watch(dayProvider(dayKey(addDays(now, -1)))).valueOrNull;
    final apps = ref.watch(appInfosProvider).valueOrNull ?? const {};
    final repo = ref.read(repoProvider);
    return asyncView(today, (day) {
      final top = day.totals.take(5).toList();
      final maxApp = top.isEmpty || top.first.value.inSeconds < 1 ? 1 : top.first.value.inSeconds;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroCard(day: day, yesterday: yesterday?.total),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(child: BStatTile(label: 'Unlocks', value: '${day.unlocks}', icon: Icons.lock_open_rounded)),
              const SizedBox(width: Gap.sm),
              Expanded(child: BStatTile(label: 'App opens', value: '${day.sessions.length}', icon: Icons.touch_app_outlined)),
              const SizedBox(width: Gap.sm),
              Expanded(child: BStatTile(label: 'Longest', value: fmtDuration(day.longest), icon: Icons.timelapse_rounded)),
            ],
          ),
          const BSectionTitle('By hour'),
          BCard(child: HourlyChart(hours: day.hourly, highlightHour: now.hour)),
          BSectionTitle('Most used', action: 'See all', onAction: () => tabController.index = 1),
          if (top.isEmpty)
            const BCard(
              child: BEmptyState(
                icon: Icons.hourglass_empty_rounded,
                title: 'Nothing yet today',
                message: 'Use your phone as usual. Pull down to refresh.',
              ),
            )
          else
            BGroup(
              children: [
                for (final e in top)
                  AppUsageRow(
                    package: e.key,
                    name: repo.infoFrom(apps, e.key).name,
                    duration: e.value,
                    subtitle: '${day.opensFor(e.key)} opens',
                    share: e.value.inSeconds / maxApp,
                    onTap: () => openAppDetail(context, e.key),
                  ),
              ],
            ),
          const BSectionTitle('Focus and limits'),
          const _ToolsGroup(),
        ],
      );
    });
  }
}

class _HeroCard extends ConsumerWidget {
  const _HeroCard({required this.day, required this.yesterday});

  final DayUsage day;
  final Duration? yesterday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.basalt;
    final goal = ref.watch(goalProvider);
    final total = day.total;
    final change = yesterday == null ? null : fmtChange(total, yesterday!, 'yesterday');
    final progress = goal <= 0 ? 0.0 : total.inSeconds / (goal * 60);
    final over = goal > 0 && progress > 1;
    final goalText = goal <= 0
        ? 'No daily goal set'
        : over
            ? '${fmtDuration(total - Duration(minutes: goal))} over your ${fmtMinutes(goal)} goal'
            : '${fmtDuration(Duration(minutes: goal) - total)} left of your ${fmtMinutes(goal)} goal';
    return Semantics(
      container: true,
      label: 'Screen time today: ${fmtDuration(total)}',
      child: ExcludeSemantics(
        child: BCard(
          padding: const EdgeInsets.all(Gap.xl - 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Screen time', style: BasaltType.label.copyWith(color: p.textMuted)),
                    const SizedBox(height: Gap.xs),
                    Text(fmtDuration(total), style: BasaltType.hero.copyWith(color: p.text, fontSize: 36, height: 1.15)),
                    if (change != null) ...[
                      const SizedBox(height: Gap.xs),
                      Text(change, style: BasaltType.caption.copyWith(color: p.textMuted)),
                    ],
                    const SizedBox(height: Gap.sm),
                    Text(goalText, style: BasaltType.caption.copyWith(color: over ? p.warning : p.textMuted)),
                  ],
                ),
              ),
              if (goal > 0)
                BRing(
                  value: progress,
                  size: 84,
                  stroke: 8,
                  color: over ? p.warning : p.accent,
                  child: Text('${(progress * 100).round()}%', style: BasaltType.label.copyWith(color: p.text)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolsGroup extends ConsumerWidget {
  const _ToolsGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(activeFocusProvider).valueOrNull;
    final limits = ref.watch(limitsProvider).valueOrNull ?? const [];
    final today = ref.watch(dayProvider(dayKey(DateTime.now()))).valueOrNull;
    final enabled = limits.where((l) => l.enabled).toList();
    final reached = today == null ? 0 : enabled.where((l) => today.totalFor(l.package) >= l.duration).length;
    return BGroup(
      children: [
        BListRow(
          icon: Icons.self_improvement_rounded,
          title: focus == null ? 'Start a focus session' : 'Focus session running',
          subtitle: focus == null ? 'See how much you stay off your phone' : 'Until ${fmtTime(focus.plannedEnd)}',
          chevron: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FocusScreen())),
        ),
        BListRow(
          icon: Icons.timer_outlined,
          title: 'App limits',
          subtitle: enabled.isEmpty
              ? 'Get a reminder when an app reaches its daily limit'
              : '${enabled.length} ${enabled.length == 1 ? 'limit' : 'limits'} · $reached reached today',
          chevron: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LimitsScreen())),
        ),
      ],
    );
  }
}
