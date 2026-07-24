import 'package:freezed_annotation/freezed_annotation.dart';

part 'comparison_metric.freezed.dart';

@freezed
abstract class ComparisonMetric with _$ComparisonMetric {
  const factory ComparisonMetric({
    required String label,
    required Duration current,
    required Duration previous,
  }) = _ComparisonMetric;

  const ComparisonMetric._();

  double get changePercent {
    if (previous.inMilliseconds == 0) return 0;
    return ((current.inMilliseconds - previous.inMilliseconds) /
            previous.inMilliseconds) *
        100;
  }
}
