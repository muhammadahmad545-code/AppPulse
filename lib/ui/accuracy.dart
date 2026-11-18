import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../data/repo.dart';
import '../state.dart';
import 'widgets.dart';

final _accuracyProvider = FutureProvider.autoDispose<(List<AccuracyRow>, Map<String, AppInfo>)>((ref) async {
  ref.watch(revisionProvider);
  final repo = ref.watch(repoProvider);
  await repo.sync();
  final rows = await repo.accuracy();
  return (rows, await repo.appInfos());
});

/// Today's per-app numbers next to Android's own (the figures Digital Wellbeing builds on).
class AccuracyScreen extends ConsumerWidget {
  const AccuracyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.basalt;
    final repo = ref.read(repoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Accuracy check')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        children: [
          Text(
            'AppPulse rebuilds each session from Android\'s usage events. Android also keeps its own daily totals. '
            'The two should be close; small gaps come from how each counts the first minutes after midnight and '
            'apps left open when the screen turns off. The home screen and AppPulse itself are not counted.',
            style: BasaltType.body.copyWith(color: p.textMuted),
          ),
          const SizedBox(height: Gap.md),
          asyncView(ref.watch(_accuracyProvider), (data) {
            final (rows, apps) = data;
            if (rows.isEmpty) {
              return const BEmptyState(icon: Icons.fact_check_outlined, title: 'Nothing to compare yet');
            }
            final ours = rows.fold(Duration.zero, (s, r) => s + r.ours);
            final android = rows.fold(Duration.zero, (s, r) => s + r.android);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: BStatTile(label: 'AppPulse', value: fmtDuration(ours))),
                    const SizedBox(width: Gap.sm),
                    Expanded(child: BStatTile(label: 'Android', value: fmtDuration(android))),
                  ],
                ),
                const BSectionTitle('Today by app'),
                BGroup(
                  children: [
                    for (final r in rows)
                      AppUsageRow(
                        package: r.package,
                        name: repo.infoFrom(apps, r.package).name,
                        duration: r.ours,
                        subtitle: 'AppPulse ${fmtDuration(r.ours)} · Android ${fmtDuration(r.android)}',
                      ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
