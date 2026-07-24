import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:equatable/equatable.dart';

/// Immutable reconstructed foreground session.
final class ReconstructedSession extends Equatable {
  const ReconstructedSession({
    required this.packageName,
    required this.startedAt,
    required this.endedAt,
    required this.isOngoing,
  });

  final String packageName;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool isOngoing;

  Duration get duration => endedAt.difference(startedAt);

  String get dayKey => startedAt.dayKey;

  @override
  List<Object?> get props => [packageName, startedAt, endedAt, isOngoing];
}

/// Builds usage sessions from Android [UsageEvents].
final class SessionReconstructor {
  const SessionReconstructor({
    this.minDurationMs = AppConstants.minSessionDurationMs,
    this.ignoredPackages = const {
      'android',
      'com.android.systemui',
      'com.android.launcher',
      'com.google.android.apps.nexuslauncher',
      'com.sec.android.app.launcher',
      'com.miui.home',
      'com.huawei.android.launcher',
      'com.oppo.launcher',
      'com.android.settings',
    },
  });

  final int minDurationMs;
  final Set<String> ignoredPackages;

  List<ReconstructedSession> reconstruct(
    List<UsageEventDto> events, {
    DateTime? now,
    String? ownPackageName,
  }) {
    if (events.isEmpty) return const [];

    final sorted = [...events]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final ignore = {
      ...ignoredPackages,
      ?ownPackageName,
    };

    final sessions = <ReconstructedSession>[];
    String? currentPackage;
    DateTime? sessionStart;

    void closeAt(DateTime end, {required bool ongoing}) {
      final package = currentPackage;
      final start = sessionStart;
      if (package == null || start == null) return;
      final durationMs = end.difference(start).inMilliseconds;
      if (!ongoing && durationMs < minDurationMs) {
        currentPackage = null;
        sessionStart = null;
        return;
      }
      sessions.add(
        ReconstructedSession(
          packageName: package,
          startedAt: start,
          endedAt: end,
          isOngoing: ongoing,
        ),
      );
      currentPackage = null;
      sessionStart = null;
    }

    for (final event in sorted) {
      if (event.packageName.isEmpty || ignore.contains(event.packageName)) {
        continue;
      }

      if (event.isResume) {
        if (currentPackage != null && currentPackage != event.packageName) {
          closeAt(event.timestamp, ongoing: false);
        }
        if (currentPackage != event.packageName) {
          currentPackage = event.packageName;
          sessionStart = event.timestamp;
        }
      } else if (event.isPause) {
        if (currentPackage == event.packageName) {
          closeAt(event.timestamp, ongoing: false);
        }
      }
    }

    final clock = now ?? DateTime.now();
    if (currentPackage != null && sessionStart != null) {
      closeAt(clock, ongoing: true);
    }

    return sessions;
  }
}
