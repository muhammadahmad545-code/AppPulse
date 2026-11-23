import 'dart:async';

import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../state.dart';
import 'widgets.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key, this.autoStart = false});

  /// Opened from the "Start focus" shortcut: start a 25-minute session unless one is running.
  final bool autoStart;

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  static const presets = [15, 25, 45, 60, 90];
  int _minutes = 25;
  bool _busy = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final repo = ref.read(repoProvider);
        await repo.reconcileFocus();
        if (!mounted || await repo.activeFocus() != null) {
          if (mounted) bump(ref);
          return;
        }
        _minutes = 25;
        await _start();
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _tick() {
    final active = ref.read(activeFocusProvider).valueOrNull;
    if (active == null || !mounted) return;
    if (!DateTime.now().isBefore(active.plannedEnd)) {
      _finish(active);
    } else {
      setState(() {});
    }
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    final native = ref.read(repoProvider).native;
    try {
      await withRepo(ref, (r) => r.startFocus(Duration(minutes: _minutes)));
      // The countdown lives in a quiet notification; ask once if notifications are off.
      if (!await native.notificationsEnabled()) await native.requestNotifications();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop(FocusSession session) async {
    final ok = await bConfirm(
      context,
      title: 'Stop this session?',
      message: 'It will be saved as stopped early.',
      confirmLabel: 'Stop',
      danger: true,
    );
    if (ok) await _finish(session);
  }

  Future<void> _finish(FocusSession session) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final done = await withRepo(ref, (r) => r.finishFocus(session));
      if (!mounted) return;
      final completed = done.status == FocusStatus.completed;
      final away = done.distraction.inSeconds < 1
          ? 'You didn\'t open any other apps.'
          : 'Time in other apps: ${fmtDuration(done.distraction)}${done.topDistraction == null ? '' : ', mostly ${done.topDistraction}'}.';
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(completed ? 'Focus complete' : 'Session stopped'),
          content: Text('You focused for ${fmtDuration(done.actual)}. $away'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        children: [
          asyncView(ref.watch(activeFocusProvider), (active) => active == null ? _idle(p) : _running(p, active)),
          const BSectionTitle('History'),
          asyncView(ref.watch(focusHistoryProvider), (history) {
            if (history.isEmpty) {
              return BCard(child: Text('Sessions you finish show up here.', style: BasaltType.body.copyWith(color: p.textMuted)));
            }
            return BGroup(
              children: [
                for (final s in history)
                  BListRow(
                    icon: s.status == FocusStatus.completed ? Icons.check_circle_outline_rounded : Icons.stop_circle_outlined,
                    iconColor: s.status == FocusStatus.completed ? p.success : p.textMuted,
                    title: '${fmtDuration(s.actual)} · ${s.status == FocusStatus.completed ? 'Completed' : 'Stopped'}',
                    subtitle: '${fmtRelativeDay(s.start)}, ${fmtTime(s.start)} · '
                        '${s.distraction.inSeconds < 1 ? 'no other apps' : '${fmtDuration(s.distraction)} in other apps'}'
                        '${s.topDistraction == null ? '' : ' (${s.topDistraction})'}',
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _idle(BasaltPalette p) {
    return BCard(
      padding: const EdgeInsets.all(Gap.xl - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How long do you want to focus?', style: BasaltType.heading.copyWith(color: p.text)),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final m in presets) BChip(label: '$m min', selected: m == _minutes, onTap: () => setState(() => _minutes = m)),
            ],
          ),
          const SizedBox(height: Gap.lg),
          Text(
            'Clocked doesn\'t block anything. While the session runs it notes the time you spend in other apps, '
            'so afterwards you can see how focused you stayed. The Focus tile in Quick Settings starts and stops '
            'a 25-minute session too.',
            style: BasaltType.body.copyWith(color: p.textMuted, fontSize: 14),
          ),
          const SizedBox(height: Gap.lg),
          BButton(label: 'Start focus', icon: Icons.play_arrow_rounded, expand: true, busy: _busy, onPressed: _start),
        ],
      ),
    );
  }

  Widget _running(BasaltPalette p, FocusSession s) {
    final now = DateTime.now();
    final total = s.planned.inSeconds <= 0 ? 1 : s.planned.inSeconds;
    final left = s.plannedEnd.difference(now);
    final secs = left.isNegative ? 0 : left.inSeconds;
    final mm = (secs ~/ 60).toString().padLeft(2, '0');
    final ss = (secs % 60).toString().padLeft(2, '0');
    return BCard(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        children: [
          BRing(
            value: 1 - secs / total,
            size: 200,
            stroke: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$mm:$ss', style: BasaltType.hero.copyWith(color: p.text, fontSize: 40)),
                Text('left', style: BasaltType.caption.copyWith(color: p.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          Text('Focusing until ${fmtTime(s.plannedEnd)}', style: BasaltType.bodyStrong.copyWith(color: p.text)),
          const SizedBox(height: Gap.xs),
          Text('You can leave Clocked. A notification tells you when it\'s done.', textAlign: TextAlign.center, style: BasaltType.caption.copyWith(color: p.textMuted)),
          const SizedBox(height: Gap.lg),
          BButton(label: 'Stop session', variant: BButtonVariant.secondary, expand: true, busy: _busy, onPressed: () => _stop(s)),
        ],
      ),
    );
  }
}
