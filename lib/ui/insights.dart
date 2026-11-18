import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../data/repo.dart';
import '../state.dart';
import 'app_detail.dart';
import 'reports.dart';
import 'widgets.dart';

enum _View { overview, timeline }

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  _View _view = _View.overview;
  int _days = 7;
  DateTime _day = startOfDay(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(accessProvider);
    return BPage(
      title: 'Insights',
      onRefresh: () => syncNow(ref),
      children: [
        ChoiceChips<_View>(
          options: const [(_View.overview, 'Overview'), (_View.timeline, 'Timeline')],
          selected: _view,
          onSelected: (v) => setState(() => _view = v),
        ),
        const SizedBox(height: Gap.md),
        asyncView(access, (granted) {
          if (!granted) return const UsageAccessCard(compact: true);
          return _view == _View.overview ? _overview(context) : _timeline(context);
        }),
      ],
    );
  }

  Widget _overview(BuildContext context) {
    final p = context.basalt;
    final repo = ref.read(repoProvider);
    final apps = ref.watch(appInfosProvider).valueOrNull ?? const {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChoiceChips<int>(
          options: const [(7, 'Last 7 days'), (30, 'Last 30 days')],
          selected: _days,
          onSelected: (v) => setState(() => _days = v),
        ),
        const SizedBox(height: Gap.md),
        asyncView(ref.watch(lastDaysProvider(_days)), (range) {
          final days = range.days;
          final values = [for (final d in days) range.perDay[dayKey(d)] ?? Duration.zero];
          var busiest = 0;
          for (var i = 1; i < values.length; i++) {
            if (values[i] > values[busiest]) busiest = i;
          }
          final categories = _categories(range, repo, apps);
          final top = range.totals.take(5).toList();
          final maxApp = top.isEmpty || top.first.value.inSeconds < 1 ? 1 : top.first.value.inSeconds;
          final focusDone = range.focus.where((f) => f.status == FocusStatus.completed).length;
          final focusTime = range.focus.fold(Duration.zero, (sum, f) => sum + f.actual);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: BStatTile(label: 'Total', value: fmtDuration(range.total))),
                  const SizedBox(width: Gap.sm),
                  Expanded(child: BStatTile(label: 'Daily average', value: fmtDuration(range.dailyAverage))),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                    child: BStatTile(
                      label: 'Busiest day',
                      value: values[busiest].inSeconds < 60 ? '–' : DateFormat('EEE').format(days[busiest]),
                      hint: values[busiest].inSeconds < 60 ? null : fmtDuration(values[busiest]),
                    ),
                  ),
                ],
              ),
              const BSectionTitle('Daily screen time'),
              BCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BBars(
                      values: [for (final v in values) v.inSeconds.toDouble()],
                      labels: _days <= 7 ? [for (final d in days) DateFormat('EEE').format(d)] : null,
                      highlight: values.length - 1,
                    ),
                    if (_days > 7) ...[
                      const SizedBox(height: Gap.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fmtDayShort(days.first), style: BasaltType.caption.copyWith(color: p.textFaint)),
                          Text('Today', style: BasaltType.caption.copyWith(color: p.textFaint)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const BSectionTitle('Categories'),
              if (categories.isEmpty)
                BCard(child: Text('No usage in this period yet.', style: BasaltType.body.copyWith(color: p.textMuted)))
              else
                BGroup(
                  children: [
                    for (final c in categories.take(8))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(c.name, style: BasaltType.bodyStrong.copyWith(color: p.text))),
                                Text(
                                  '${fmtDuration(c.time)} · ${(c.time.inSeconds / (range.total.inSeconds < 1 ? 1 : range.total.inSeconds) * 100).round()}%',
                                  style: BasaltType.label.copyWith(color: p.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            BProgressBar(value: c.time.inSeconds / (categories.first.time.inSeconds < 1 ? 1 : categories.first.time.inSeconds), height: 4),
                          ],
                        ),
                      ),
                  ],
                ),
              const BSectionTitle('Top apps'),
              if (top.isEmpty)
                BCard(child: Text('No usage in this period yet.', style: BasaltType.body.copyWith(color: p.textMuted)))
              else
                BGroup(
                  children: [
                    for (final e in top)
                      AppUsageRow(
                        package: e.key,
                        name: repo.infoFrom(apps, e.key).name,
                        duration: e.value,
                        subtitle: '${fmtDuration(Duration(milliseconds: e.value.inMilliseconds ~/ (range.trackedDays < 1 ? 1 : range.trackedDays)))} a day on average',
                        share: e.value.inSeconds / maxApp,
                        onTap: () => openAppDetail(context, e.key),
                      ),
                  ],
                ),
              const BSectionTitle('Focus and reports'),
              BGroup(
                children: [
                  BListRow(
                    icon: Icons.self_improvement_rounded,
                    title: '$focusDone focus ${focusDone == 1 ? 'session' : 'sessions'} completed',
                    subtitle: range.focus.isEmpty ? 'None in this period' : '${fmtDuration(focusTime)} in ${range.focus.length} sessions',
                  ),
                  BListRow(
                    icon: Icons.ios_share_rounded,
                    title: 'Export a report',
                    subtitle: 'CSV or PDF, shared from your phone',
                    chevron: true,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReportsScreen())),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  List<({String name, Duration time})> _categories(RangeUsage range, UsageRepo repo, Map<String, AppInfo> apps) {
    final map = <String, Duration>{};
    for (final e in range.totals) {
      final c = repo.infoFrom(apps, e.key).categoryLabel;
      map[c] = (map[c] ?? Duration.zero) + e.value;
    }
    final list = [for (final e in map.entries) (name: e.key, time: e.value)];
    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  Widget _timeline(BuildContext context) {
    final p = context.basalt;
    final repo = ref.read(repoProvider);
    final apps = ref.watch(appInfosProvider).valueOrNull ?? const {};
    final today = startOfDay(DateTime.now());
    final isToday = !_day.isBefore(today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BCard(
          padding: const EdgeInsets.symmetric(horizontal: Gap.xs, vertical: Gap.xs),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Previous day',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() => _day = addDays(_day, -1)),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(fmtRelativeDay(_day), style: BasaltType.bodyStrong.copyWith(color: p.text)),
                    Text(fmtDayLong(_day), style: BasaltType.caption.copyWith(color: p.textMuted)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Next day',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: isToday ? null : () => setState(() => _day = addDays(_day, 1)),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.md),
        asyncView(ref.watch(dayProvider(dayKey(_day))), (day) {
          if (day.sessions.isEmpty) {
            return const BEmptyState(icon: Icons.view_timeline_outlined, title: 'No sessions on this day');
          }
          final sessions = day.sessions.reversed.take(300).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.xs, 0, Gap.xs, Gap.sm),
                child: Text(
                  '${day.sessions.length} sessions · ${fmtDuration(day.total)}',
                  style: BasaltType.caption.copyWith(color: p.textMuted),
                ),
              ),
              BGroup(
                children: [
                  for (final s in sessions)
                    BListRow(
                      dense: true,
                      leading: AppIcon(s.package, size: 32),
                      title: repo.infoFrom(apps, s.package).name,
                      subtitle: '${fmtTime(s.start)} – ${fmtTime(s.end)}',
                      trailing: Text(fmtDuration(s.duration), style: BasaltType.label.copyWith(color: p.text)),
                      onTap: () => openAppDetail(context, s.package),
                    ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }
}
