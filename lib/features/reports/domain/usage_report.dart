import 'package:equatable/equatable.dart';

enum ReportPeriod { daily, weekly, monthly, yearly }

enum ReportExportFormat { pdf, csv, json }

/// Immutable usage report ready for UI preview and export.
final class UsageReport extends Equatable {
  const UsageReport({
    required this.period,
    required this.title,
    required this.generatedAt,
    required this.rangeStart,
    required this.rangeEnd,
    required this.totalDurationMs,
    required this.sessionCount,
    required this.launchCount,
    required this.averageSessionMs,
    required this.longestSessionMs,
    required this.appRows,
    required this.categoryRows,
    required this.dailyTotalsMs,
  });

  final ReportPeriod period;
  final String title;
  final DateTime generatedAt;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int totalDurationMs;
  final int sessionCount;
  final int launchCount;
  final int averageSessionMs;
  final int longestSessionMs;
  final List<ReportAppRow> appRows;
  final List<ReportCategoryRow> categoryRows;
  /// dayKey → total ms
  final Map<String, int> dailyTotalsMs;

  Duration get totalDuration => Duration(milliseconds: totalDurationMs);

  Map<String, dynamic> toJson() {
    return {
      'period': period.name,
      'title': title,
      'generatedAt': generatedAt.toIso8601String(),
      'rangeStart': rangeStart.toIso8601String(),
      'rangeEnd': rangeEnd.toIso8601String(),
      'totalDurationMs': totalDurationMs,
      'sessionCount': sessionCount,
      'launchCount': launchCount,
      'averageSessionMs': averageSessionMs,
      'longestSessionMs': longestSessionMs,
      'apps': appRows.map((e) => e.toJson()).toList(),
      'categories': categoryRows.map((e) => e.toJson()).toList(),
      'dailyTotalsMs': dailyTotalsMs,
    };
  }

  @override
  List<Object?> get props => [
        period,
        title,
        generatedAt,
        rangeStart,
        rangeEnd,
        totalDurationMs,
        sessionCount,
        launchCount,
        averageSessionMs,
        longestSessionMs,
        appRows,
        categoryRows,
        dailyTotalsMs,
      ];
}

final class ReportAppRow extends Equatable {
  const ReportAppRow({
    required this.packageName,
    required this.appName,
    required this.category,
    required this.durationMs,
    required this.launchCount,
  });

  final String packageName;
  final String appName;
  final String category;
  final int durationMs;
  final int launchCount;

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'category': category,
        'durationMs': durationMs,
        'launchCount': launchCount,
      };

  @override
  List<Object?> get props =>
      [packageName, appName, category, durationMs, launchCount];
}

final class ReportCategoryRow extends Equatable {
  const ReportCategoryRow({
    required this.category,
    required this.durationMs,
    required this.percent,
  });

  final String category;
  final int durationMs;
  final double percent;

  Map<String, dynamic> toJson() => {
        'category': category,
        'durationMs': durationMs,
        'percent': percent,
      };

  @override
  List<Object?> get props => [category, durationMs, percent];
}
