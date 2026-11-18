import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../state.dart';

/// Shows [data] once [value] has loaded; a quiet spinner before, a short message on error.
Widget asyncView<T>(AsyncValue<T> value, Widget Function(T data) data, {double height = 160}) {
  return value.when(
    data: data,
    loading: () => SizedBox(height: height, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
    error: (e, _) => Padding(
      padding: const EdgeInsets.all(Gap.lg),
      child: Builder(builder: (context) => Text('Could not load: $e', style: BasaltType.caption.copyWith(color: context.basalt.danger))),
    ),
  );
}

/// The app's launcher icon, loaded from Android once and cached.
class AppIcon extends ConsumerStatefulWidget {
  const AppIcon(this.package, {super.key, this.size = 38});

  final String package;
  final double size;

  @override
  ConsumerState<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends ConsumerState<AppIcon> {
  late var _icon = ref.read(repoProvider).icon(widget.package);

  @override
  void didUpdateWidget(AppIcon old) {
    super.didUpdateWidget(old);
    if (old.package != widget.package) _icon = ref.read(repoProvider).icon(widget.package);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    return FutureBuilder(
      future: _icon,
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes == null || bytes.isEmpty) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(color: p.fill, borderRadius: BorderRadius.circular(Radii.md)),
            child: Icon(Icons.apps_rounded, size: widget.size * 0.5, color: p.textFaint),
          );
        }
        return Image.memory(bytes, width: widget.size, height: widget.size, gaplessPlayback: true, filterQuality: FilterQuality.medium);
      },
    );
  }
}

/// A row for one app: icon, name, a detail line, the time on the right and an optional share bar.
class AppUsageRow extends StatelessWidget {
  const AppUsageRow({
    super.key,
    required this.package,
    required this.name,
    required this.duration,
    this.subtitle,
    this.share,
    this.onTap,
    this.trailing,
  });

  final String package;
  final String name;
  final Duration duration;
  final String? subtitle;

  /// 0..1 relative to the top app, drawn as a thin bar under the name.
  final double? share;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    // One accessibility node per row ("Name, detail, time"), so TalkBack reads it as a unit.
    return MergeSemantics(
      child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
        child: Row(
          children: [
            AppIcon(package),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: BasaltType.bodyStrong.copyWith(color: p.text)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: BasaltType.caption.copyWith(color: p.textMuted)),
                  ],
                  if (share != null) ...[
                    const SizedBox(height: 6),
                    ExcludeSemantics(child: BProgressBar(value: share!, height: 4)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Gap.md),
            trailing ?? Text(fmtDuration(duration), style: BasaltType.label.copyWith(color: p.text)),
          ],
        ),
      ),
      ),
    );
  }
}

/// 24 thin bars, one per hour, with a few axis labels underneath.
class HourlyChart extends StatelessWidget {
  const HourlyChart({super.key, required this.hours, this.height = 96, this.highlightHour});

  final List<Duration> hours;
  final double height;
  final int? highlightHour;

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    final max = hours.fold<int>(0, (m, d) => d.inSeconds > m ? d.inSeconds : m);
    final peak = max == 0 ? null : hours.indexWhere((d) => d.inSeconds == max);
    return Semantics(
      label: peak == null ? 'No usage by hour yet' : 'Busiest hour ${_hourLabel(peak)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var h = 0; h < 24; h++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: Container(
                          height: max == 0 ? 3 : (hours[h].inSeconds / max * height).clamp(3, height).toDouble(),
                          decoration: BoxDecoration(
                            color: hours[h].inSeconds == 0
                                ? p.fill
                                : (highlightHour == null || highlightHour == h ? p.accent : p.accent.withValues(alpha: 0.45)),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final label in const ['12 AM', '6 AM', '12 PM', '6 PM', '12 AM'])
                  Text(label, style: BasaltType.caption.copyWith(color: p.textFaint, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "1 open", "3 opens".
String opensLabel(int n) => n == 1 ? '1 open' : '$n opens';

String _hourLabel(int h) {
  final suffix = h < 12 ? 'AM' : 'PM';
  final v = h % 12 == 0 ? 12 : h % 12;
  return '$v $suffix';
}

/// Shown wherever data would be when usage access is missing.
class UsageAccessCard extends ConsumerWidget {
  const UsageAccessCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.basalt;
    return BCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BIconTile(Icons.query_stats_rounded, color: p.warning),
              const SizedBox(width: Gap.md),
              Expanded(child: Text('Allow usage access', style: BasaltType.heading.copyWith(color: p.text))),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(
            'AppPulse reads Android\'s usage records to measure screen time. They never leave your phone.',
            style: BasaltType.body.copyWith(color: p.textMuted),
          ),
          if (!compact) ...[
            const SizedBox(height: Gap.md),
            for (final (i, step) in const ['Tap Open settings', 'Choose AppPulse', 'Turn on Permit usage access, then come back'].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.xs),
                child: Text('${i + 1}.  $step', style: BasaltType.body.copyWith(color: p.text, fontSize: 14)),
              ),
          ],
          const SizedBox(height: Gap.md),
          BButton(
            label: 'Open settings',
            icon: Icons.open_in_new_rounded,
            expand: true,
            onPressed: () => ref.read(repoProvider).native.openUsageAccess(),
          ),
        ],
      ),
    );
  }
}

/// A trailing status label for permission rows.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.ok, this.okLabel = 'On', this.offLabel = 'Off', this.offIsWarning = true});

  final bool ok;
  final String okLabel;
  final String offLabel;
  final bool offIsWarning;

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    return BBadge(ok ? okLabel : offLabel, color: ok ? p.success : (offIsWarning ? p.warning : p.textMuted));
  }
}

/// Day-picker chips used by several screens.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({super.key, required this.options, required this.selected, required this.onSelected});

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.sm,
      children: [
        for (final (value, label) in options) BChip(label: label, selected: value == selected, onTap: () => onSelected(value)),
      ],
    );
  }
}
