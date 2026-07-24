import 'package:app_pulse/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Responsive navigation shell with bottom bar (phone) / rail (tablet+).
class AppScaffoldShell extends StatelessWidget {
  const AppScaffoldShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_Destination>[
    _Destination(
      label: 'Home',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
      location: AppRoutes.dashboard,
    ),
    _Destination(
      label: 'Apps',
      icon: Icons.apps_outlined,
      selectedIcon: Icons.apps_rounded,
      location: AppRoutes.apps,
    ),
    _Destination(
      label: 'Timeline',
      icon: Icons.view_timeline_outlined,
      selectedIcon: Icons.view_timeline_rounded,
      location: AppRoutes.timeline,
    ),
    _Destination(
      label: 'Analytics',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights_rounded,
      location: AppRoutes.analytics,
    ),
    _Destination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      location: AppRoutes.settings,
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 900;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String location;
}
