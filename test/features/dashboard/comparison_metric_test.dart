import 'package:app_pulse/features/dashboard/domain/entities/comparison_metric.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comparison metric computes percent change', () {
    const metric = ComparisonMetric(
      label: 'Screen time',
      current: Duration(hours: 3),
      previous: Duration(hours: 2),
    );
    expect(metric.changePercent, closeTo(50, 0.01));
  });

  test('comparison metric is zero when previous is zero', () {
    const metric = ComparisonMetric(
      label: 'Screen time',
      current: Duration(hours: 1),
      previous: Duration.zero,
    );
    expect(metric.changePercent, 0);
  });
}
