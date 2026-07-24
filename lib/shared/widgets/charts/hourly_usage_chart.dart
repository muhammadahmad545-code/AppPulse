import 'package:app_pulse/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 24-hour usage curve (minutes per hour).
class HourlyUsageChart extends StatelessWidget {
  const HourlyUsageChart({
    required this.minutesByHour,
    this.height = 180,
    super.key,
  });

  /// Length-24 list of minutes (index = hour 0–23).
  final List<double> minutesByHour;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = minutesByHour.length == 24
        ? minutesByHour
        : List<double>.filled(24, 0);
    final maxY = data.fold<double>(1, (a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 23,
          minY: 0,
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}m',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 6,
                reservedSize: 24,
                getTitlesWidget: (value, _) {
                  final hour = value.toInt();
                  if (hour < 0 || hour > 23) return const SizedBox.shrink();
                  return Text(
                    hour.toString().padLeft(2, '0'),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var h = 0; h < 24; h++) FlSpot(h.toDouble(), data[h]),
              ],
              isCurved: true,
              color: AppColors.pulseTeal,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.pulseTeal.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
