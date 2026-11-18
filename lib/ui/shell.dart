import 'dart:async';

import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state.dart';
import 'apps.dart';
import 'insights.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// On open and every return to the app: re-check permissions, sync, settle focus, run a limit check.
  Future<void> _refresh() async {
    final repo = ref.read(repoProvider);
    await syncNow(ref);
    final finished = await repo.settleFocus();
    if (finished != null && mounted) bump(ref);
    unawaited(repo.pushLimits());
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
