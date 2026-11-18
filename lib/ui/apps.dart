import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../state.dart';
import 'app_detail.dart';
import 'widgets.dart';

class AppsScreen extends ConsumerStatefulWidget {
  const AppsScreen({super.key});

  @override
  ConsumerState<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends ConsumerState<AppsScreen> {
  int _days = 1;
  String _query = '';
  bool _byName = false;

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    final access = ref.watch(accessProvider);
    return BPage(
      title: 'Apps',
      onRefresh: () => syncNow(ref),
      actions: [
        IconButton(
          tooltip: _byName ? 'Sort by time' : 'Sort by name',
          icon: Icon(_byName ? Icons.schedule_rounded : Icons.sort_by_alpha_rounded),
          onPressed: () => setState(() => _byName = !_byName),
        ),
      ],
      children: [
        asyncView(access, (granted) {
          if (!granted) return const UsageAccessCard(compact: true);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChoiceChips<int>(
                options: const [(1, 'Today'), (7, '7 days'), (30, '30 days')],
                selected: _days,
                onSelected: (v) => setState(() => _days = v),
              ),
              const SizedBox(height: Gap.md),
              BSearchField(hint: 'Search apps', onChanged: (v) => setState(() => _query = v.trim().toLowerCase())),
              const SizedBox(height: Gap.md),
              asyncView(ref.watch(lastDaysProvider(_days)), (range) {
                final apps = ref.watch(appInfosProvider).valueOrNull ?? const {};
                final repo = ref.read(repoProvider);
                final opens = range.opens();
                final rows = range.totals.where((e) {
                  if (_query.isEmpty) return true;
                  final name = repo.infoFrom(apps, e.key).name.toLowerCase();
                  return name.contains(_query) || e.key.toLowerCase().contains(_query);
                }).toList();
                if (_byName) {
                  rows.sort((a, b) => repo.infoFrom(apps, a.key).name.toLowerCase().compareTo(repo.infoFrom(apps, b.key).name.toLowerCase()));
                }
                if (range.totals.isEmpty) {
                  return const BEmptyState(
                    icon: Icons.apps_rounded,
                    title: 'No app usage yet',
                    message: 'Apps you use will show up here.',
                  );
                }
                if (rows.isEmpty) {
                  return BEmptyState(icon: Icons.search_off_rounded, title: 'No apps match "$_query"');
                }
                final max = range.totals.first.value.inSeconds < 1 ? 1 : range.totals.first.value.inSeconds;
                final period = _days == 1 ? 'today' : 'in $_days days';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(Gap.xs, 0, Gap.xs, Gap.sm),
                      child: Text(
                        '${rows.length} ${rows.length == 1 ? 'app' : 'apps'} · ${fmtDuration(range.total)} $period',
                        style: BasaltType.caption.copyWith(color: p.textMuted),
                      ),
                    ),
                    BGroup(
                      children: [
                        for (final e in rows)
                          AppUsageRow(
                            package: e.key,
                            name: repo.infoFrom(apps, e.key).name,
                            duration: e.value,
                            subtitle: '${opens[e.key] ?? 0} opens · ${repo.infoFrom(apps, e.key).categoryLabel}',
                            share: e.value.inSeconds / max,
                            onTap: () => openAppDetail(context, e.key),
                          ),
                      ],
                    ),
                  ],
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}
