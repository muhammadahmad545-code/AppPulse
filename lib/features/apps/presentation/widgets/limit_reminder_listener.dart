import 'dart:async';

import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/services/limits/limit_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Listens for limit alerts from the tracking service and shows in-app UI.
///
/// System notifications still fire from [LimitCheckService]; this layer covers
/// overlay / confirm / full-screen style reminders while AppPulse is open.
class LimitReminderListener extends ConsumerStatefulWidget {
  const LimitReminderListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<LimitReminderListener> createState() =>
      _LimitReminderListenerState();
}

class _LimitReminderListenerState
    extends ConsumerState<LimitReminderListener> {
  final _recentKeys = <String>{};
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    super.dispose();
  }

  void _onTaskData(Object data) {
    if (data is! Map) return;
    if (data['type'] != 'sync_result') return;
    final rawAlerts = data['alerts'];
    if (rawAlerts is! List || rawAlerts.isEmpty) return;

    final alerts = <LimitAlert>[];
    for (final item in rawAlerts) {
      if (item is Map) {
        final alert = LimitAlert.fromMap(item);
        if (alert != null) alerts.add(alert);
      }
    }
    if (alerts.isEmpty) return;
    unawaited(_present(alerts));
  }

  Future<void> _present(List<LimitAlert> alerts) async {
    if (!mounted || _dialogOpen) return;

    // Prefer actionable reminders over silent notify-only.
    int rank(LimitAlert x) => switch (x.action) {
          LimitAction.strict => 0,
          LimitAction.fullScreen => 1,
          LimitAction.confirm => 2,
          LimitAction.overlay => 3,
          LimitAction.delay => 4,
          LimitAction.onlyNotify => 5,
        };
    final ranked = [...alerts]..sort((a, b) => rank(a).compareTo(rank(b)));

    for (final alert in ranked) {
      if (alert.action == LimitAction.onlyNotify) continue;
      final key = '${alert.limitId}_${alert.kind.name}';
      if (_recentKeys.contains(key)) continue;
      _recentKeys.add(key);
      if (_recentKeys.length > 40) {
        _recentKeys.remove(_recentKeys.first);
      }
      await _showFor(alert);
      break;
    }
  }

  Future<void> _showFor(LimitAlert alert) async {
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    if (navigator == null || !mounted) return;
    _dialogOpen = true;

    try {
      switch (alert.action) {
        case LimitAction.fullScreen:
        case LimitAction.strict:
          await showGeneralDialog<void>(
            context: context,
            barrierDismissible: alert.action != LimitAction.strict,
            barrierLabel: 'Limit reminder',
            pageBuilder: (context, _, _) {
              return _FullscreenLimitReminder(
                alert: alert,
                onAck: () => Navigator.of(context).pop(),
              );
            },
          );
        case LimitAction.overlay:
        case LimitAction.confirm:
        case LimitAction.delay:
          await showDialog<void>(
            context: context,
            barrierDismissible: alert.action != LimitAction.confirm,
            builder: (context) => AlertDialog(
              title: Text(alert.title),
              content: Text(alert.body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Dismiss'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ],
            ),
          );
        case LimitAction.onlyNotify:
          break;
      }

      // Optional follow-up check so delay/strict can refresh while open.
      if (alert.action == LimitAction.delay ||
          alert.action == LimitAction.strict) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        final more = await ref.read(limitCheckServiceProvider).check(
              notify: false,
            );
        if (more.isNotEmpty) {
          await _present(more);
        }
      }
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FullscreenLimitReminder extends StatelessWidget {
  const _FullscreenLimitReminder({
    required this.alert,
    required this.onAck,
  });

  final LimitAlert alert;
  final VoidCallback onAck;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.timer_off_outlined,
                size: 72,
                color: scheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                alert.title,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                alert.body,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (alert.action == LimitAction.strict) ...[
                const SizedBox(height: 16),
                Text(
                  'Strict mode cannot force-close other apps. '
                  'Acknowledge to continue.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: onAck,
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
