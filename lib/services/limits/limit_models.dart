import 'package:equatable/equatable.dart';

enum LimitType { daily, weekly, monthly, custom }

enum LimitAction {
  onlyNotify,
  fullScreen,
  overlay,
  confirm,
  delay,
  strict,
}

enum LimitAlertKind { primaryWarn, secondaryWarn, reached }

extension LimitTypeStorage on LimitType {
  String get storage => name;

  static LimitType fromStorage(String value) {
    return LimitType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LimitType.daily,
    );
  }

  String get label => switch (this) {
        LimitType.daily => 'Daily',
        LimitType.weekly => 'Weekly',
        LimitType.monthly => 'Monthly',
        LimitType.custom => 'Custom',
      };
}

extension LimitActionStorage on LimitAction {
  String get storage => name;

  static LimitAction fromStorage(String value) {
    return LimitAction.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LimitAction.onlyNotify,
    );
  }

  String get label => switch (this) {
        LimitAction.onlyNotify => 'Only notify',
        LimitAction.fullScreen => 'Full-screen reminder',
        LimitAction.overlay => 'Overlay warning',
        LimitAction.confirm => 'Require confirmation',
        LimitAction.delay => 'Delay opening reminder',
        LimitAction.strict => 'Strict reminder mode',
      };

  String get description => switch (this) {
        LimitAction.onlyNotify =>
          'Show a notification. Does not interrupt other apps.',
        LimitAction.fullScreen =>
          'High-priority reminder. Opens a full-screen alert when possible.',
        LimitAction.overlay =>
          'In-app overlay warning when AppPulse is open. Background uses a notification.',
        LimitAction.confirm =>
          'Ask you to acknowledge the limit in AppPulse.',
        LimitAction.delay =>
          'Remind again after a short delay if still over the limit.',
        LimitAction.strict =>
          'Repeated reminders until acknowledged. Still cannot force-close apps.',
      };
}

final class LimitAlert extends Equatable {
  const LimitAlert({
    required this.limitId,
    required this.packageName,
    required this.appName,
    required this.limitType,
    required this.action,
    required this.kind,
    required this.used,
    required this.limit,
    required this.remaining,
  });

  final int limitId;
  final String packageName;
  final String appName;
  final LimitType limitType;
  final LimitAction action;
  final LimitAlertKind kind;
  final Duration used;
  final Duration limit;
  final Duration remaining;

  String get title => switch (kind) {
        LimitAlertKind.reached => 'Limit reached',
        LimitAlertKind.primaryWarn ||
        LimitAlertKind.secondaryWarn =>
          'Limit almost reached',
      };

  String get body {
    final type = limitType.label.toLowerCase();
    return switch (kind) {
      LimitAlertKind.reached =>
        '$appName hit its $type limit (${_fmt(limit)}). Used ${_fmt(used)}.',
      LimitAlertKind.primaryWarn || LimitAlertKind.secondaryWarn =>
        '$appName has ${_fmt(remaining)} left of its $type ${_fmt(limit)} limit.',
    };
  }

  static String _fmt(Duration d) {
    if (d.inHours > 0) {
      final m = d.inMinutes % 60;
      return m == 0 ? '${d.inHours}h' : '${d.inHours}h ${m}m';
    }
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }

  Map<String, dynamic> toMap() => {
        'limitId': limitId,
        'packageName': packageName,
        'appName': appName,
        'limitType': limitType.name,
        'action': action.name,
        'kind': kind.name,
        'usedMs': used.inMilliseconds,
        'limitMs': limit.inMilliseconds,
        'remainingMs': remaining.inMilliseconds,
        'title': title,
        'body': body,
      };

  static LimitAlert? fromMap(Map<Object?, Object?> raw) {
    final map = Map<String, dynamic>.from(raw);
    final limitId = map['limitId'];
    final packageName = map['packageName'];
    final appName = map['appName'];
    if (limitId is! int || packageName is! String || appName is! String) {
      return null;
    }
    return LimitAlert(
      limitId: limitId,
      packageName: packageName,
      appName: appName,
      limitType: LimitTypeStorage.fromStorage('${map['limitType']}'),
      action: LimitActionStorage.fromStorage('${map['action']}'),
      kind: LimitAlertKind.values.firstWhere(
        (e) => e.name == '${map['kind']}',
        orElse: () => LimitAlertKind.reached,
      ),
      used: Duration(milliseconds: (map['usedMs'] as num?)?.toInt() ?? 0),
      limit: Duration(milliseconds: (map['limitMs'] as num?)?.toInt() ?? 0),
      remaining:
          Duration(milliseconds: (map['remainingMs'] as num?)?.toInt() ?? 0),
    );
  }

  @override
  List<Object?> get props => [
        limitId,
        packageName,
        kind,
        used,
        limit,
      ];
}
