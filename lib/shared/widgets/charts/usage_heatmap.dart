import 'package:app_pulse/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 7×24 weekday×hour heatmap (rows = Mon–Sun, columns = hours).
class UsageHeatmap extends StatelessWidget {
  const UsageHeatmap({
    required this.matrix,
    this.cellSize = 12,
    super.key,
  });

  /// `[weekdayIndex 0=Mon .. 6=Sun][hour 0..23]` minutes.
  final List<List<double>> matrix;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    var maxValue = 1.0;
    for (final row in matrix) {
      for (final v in row) {
        if (v > maxValue) maxValue = v;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var d = 0; d < 7; d++)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  child: Text(
                    days[d],
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                for (var h = 0; h < 24; h++)
                  Container(
                    width: cellSize,
                    height: cellSize,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: _colorFor(
                        matrix.length > d && matrix[d].length > h
                            ? matrix[d][h]
                            : 0,
                        maxValue,
                        scheme,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Darker = more minutes in that hour',
          style: textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _colorFor(double value, double maxValue, ColorScheme scheme) {
    if (value <= 0) {
      return scheme.surfaceContainerHighest.withValues(alpha: 0.45);
    }
    final t = (value / maxValue).clamp(0.0, 1.0);
    return Color.lerp(
          AppColors.pulseTeal.withValues(alpha: 0.2),
          AppColors.pulseTeal,
          t,
        ) ??
        AppColors.pulseTeal;
  }
}
