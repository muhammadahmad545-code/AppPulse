import 'dart:async';

import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/native.dart';
import '../state.dart';
import 'apps.dart';
import 'focus.dart';
import 'insights.dart';
import 'limits.dart';
import 'settings.dart';
import 'today.dart';

/// Lets screens switch tabs (e.g. "See all" on Today opens Apps).
final tabController = BTabController();

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    NativeApi.listen((method, args) {
      if (!mounted) return;
      if (method == 'focusChanged') unawaited(_syncFocus());
      if (method == 'action' && args is String) _open(args);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(repoProvider);
      final action = await repo.native.takeAction();
      if (action != null && mounted) _open(action);
      await _refresh();
      unawaited(repo.pushNative());
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// On open and every return to the app: re-check permissions, sync, settle focus, run a limit check.
  Future<void> _refresh() async {
    final repo = ref.read(repoProvider);
    await _syncFocus();
    await syncNow(ref);
    final finished = await repo.settleFocus();
    if (finished != null && mounted) bump(ref);
    unawaited(repo.pushLimits());
  }

  /// Picks up sessions the Quick Settings tile started or stopped.
  Future<void> _syncFocus() async {
    final changed = await ref.read(repoProvider).reconcileFocus();
    if (changed && mounted) bump(ref);
  }

  /// Launcher shortcuts ("focus" starts a 25-minute session, "limits" opens limits) and the Focus tile's
  /// long-press ("focus-screen" opens the focus screen).
  void _open(String action) {
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    switch (action) {
      case 'focus':
        nav.push(MaterialPageRoute<void>(builder: (_) => const FocusScreen(autoStart: true)));
      case 'focus-screen':
        nav.push(MaterialPageRoute<void>(builder: (_) => const FocusScreen()));
      case 'limits':
        nav.push(MaterialPageRoute<void>(builder: (_) => const LimitsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BTabShell(
      controller: tabController,
      tabs: [
        BTab(label: 'Today', icon: Icons.today_outlined, selectedIcon: Icons.today_rounded, builder: (_) => const TodayScreen()),
        BTab(label: 'Apps', icon: Icons.apps_outlined, selectedIcon: Icons.apps_rounded, builder: (_) => const AppsScreen()),
        BTab(label: 'Insights', icon: Icons.insights_outlined, selectedIcon: Icons.insights_rounded, builder: (_) => const InsightsScreen()),
        BTab(label: 'Settings', icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, builder: (_) => const SettingsScreen()),
      ],
    );
  }
}
