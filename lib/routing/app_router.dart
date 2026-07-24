import 'package:app_pulse/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:app_pulse/features/apps/presentation/screens/app_details_screen.dart';
import 'package:app_pulse/features/apps/presentation/screens/apps_screen.dart';
import 'package:app_pulse/features/apps/presentation/screens/limits_screen.dart';
import 'package:app_pulse/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:app_pulse/features/focus/presentation/screens/focus_screen.dart';
import 'package:app_pulse/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:app_pulse/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:app_pulse/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:app_pulse/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:app_pulse/features/reports/presentation/screens/reports_screen.dart';
import 'package:app_pulse/features/settings/presentation/screens/privacy_screen.dart';
import 'package:app_pulse/features/settings/presentation/screens/settings_screen.dart';
import 'package:app_pulse/features/timeline/presentation/screens/timeline_screen.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:app_pulse/shared/widgets/app_scaffold_shell.dart';
import 'package:app_pulse/shared/widgets/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.permissions,
        name: 'permissions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final fromOnboarding =
              state.uri.queryParameters['setup'] == '1';
          return PermissionsScreen(fromOnboarding: fromOnboarding);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.apps,
                name: 'apps',
                builder: (context, state) => const AppsScreen(),
                routes: [
                  GoRoute(
                    path: ':packageName',
                    name: 'appDetails',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final packageName = Uri.decodeComponent(
                        state.pathParameters['packageName']!,
                      );
                      return AppDetailsScreen(packageName: packageName);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timeline,
                name: 'timeline',
                builder: (context, state) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                name: 'analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.focus,
        name: 'focus',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FocusScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.limits,
        name: 'limits',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LimitsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyScreen(),
      ),
    ],
  );
});
