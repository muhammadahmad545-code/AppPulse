import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

final class PieSlice {
  const PieSlice({
    required this.label,
    required this.duration,
    this.color,
  });

  final String label;
  final Duration duration;
  final Color? color;
}

/// Donut chart for app / category share of screen time.
class UsagePieChart extends StatelessWidget {
  const UsagePieChart({
    required this.slices,
    this.height = 220,
    this.centerLabel,
    super.key,
  });

  final List<PieSlice> slices;
  final double height;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalMs = slices.fold<int>(0, (s, e) => s + e.duration.inMilliseconds);
    if (slices.isEmpty || totalMs <= 0) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No usage data',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final top = slices.take(8).toList(growable: false);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 44,
                sections: [
                  for (var i = 0; i < top.length; i++)
                    PieChartSectionData(
                      value: top[i].duration.inMilliseconds.toDouble(),
                      color: top[i].color ??
                          AppColors.chartPalette[i % AppColors.chartPalette.length],
                      radius: 28,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (centerLabel != null) ...[
                  Text(centerLabel!, style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                ],
                for (var i = 0; i < top.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: top[i].color ??
                                AppColors.chartPalette[
                                    i % AppColors.chartPalette.length],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            top[i].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          top[i].duration.compactLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
