import 'package:app_pulse/core/constants/app_categories.dart';
import 'package:equatable/equatable.dart';

/// Domain representation of an installed / tracked application.
final class TrackedApp extends Equatable {
  const TrackedApp({
    required this.packageName,
    required this.appName,
    required this.category,
    required this.isSystemApp,
    required this.isFavorite,
    required this.isPinned,
    required this.isHidden,
    this.versionName,
    this.versionCode,
    this.iconCacheKey,
    this.installTime,
    this.updateTime,
    this.lastOpenedAt,
  });

  final String packageName;
  final String appName;
  final String? versionName;
  final int? versionCode;
  final AppCategory category;
  final bool isSystemApp;
  final bool isFavorite;
  final bool isPinned;
  final bool isHidden;
  final String? iconCacheKey;
  final DateTime? installTime;
  final DateTime? updateTime;
  final DateTime? lastOpenedAt;

  TrackedApp copyWith({
    String? appName,
    String? versionName,
    int? versionCode,
    AppCategory? category,
    bool? isSystemApp,
    bool? isFavorite,
    bool? isPinned,
    bool? isHidden,
    String? iconCacheKey,
    DateTime? installTime,
    DateTime? updateTime,
    DateTime? lastOpenedAt,
  }) {
    return TrackedApp(
      packageName: packageName,
      appName: appName ?? this.appName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      category: category ?? this.category,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
      iconCacheKey: iconCacheKey ?? this.iconCacheKey,
      installTime: installTime ?? this.installTime,
      updateTime: updateTime ?? this.updateTime,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  @override
  List<Object?> get props => [
        packageName,
        appName,
        versionName,
        versionCode,
        category,
        isSystemApp,
        isFavorite,
        isPinned,
        isHidden,
        iconCacheKey,
        installTime,
        updateTime,
        lastOpenedAt,
      ];
}
