import 'package:app_pulse/features/onboarding/presentation/providers/permission_providers.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Explains and requests tracking-related permissions.
class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({this.fromOnboarding = false, super.key});

  final bool fromOnboarding;

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionSnapshotProvider);
    }
  }

  Future<void> _finish() async {
    await ref.read(settingsStorageProvider).setOnboardingComplete(true);
    final snap = await ref.read(permissionServiceProvider).snapshot();
    if (snap.usageAccess) {
      await ref.read(trackingEnabledProvider.notifier).setEnabled(true);
    }
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final asyncSnap = ref.watch(permissionSnapshotProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        automaticallyImplyLeading: !widget.fromOnboarding,
      ),
      body: asyncSnap.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (snap) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text(
                'AppPulse needs a few Android permissions to track screen '
                'time offline. Nothing leaves this device.',
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              _PermissionCard(
                icon: Icons.query_stats_rounded,
                title: 'Usage access',
                body:
                    'Required. Lets AppPulse read which apps you use and for '
                    'how long via Android UsageStats — the same API Digital '
                    'Wellbeing uses.',
                granted: snap.usageAccess,
                actionLabel:
                    snap.usageAccess ? 'Granted' : 'Open usage access',
                onAction: snap.usageAccess
                    ? null
                    : () async {
                        await ref
                            .read(permissionServiceProvider)
                            .requestUsageAccess();
                      },
              ),
              const SizedBox(height: 12),
              _PermissionCard(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                body:
                    'Recommended. Used for limit reminders, focus timers, and '
                    'the ongoing tracking status notification.',
                granted: snap.notifications,
                actionLabel:
                    snap.notifications ? 'Granted' : 'Allow notifications',
                onAction: snap.notifications
                    ? null
                    : () async {
                        await ref
                            .read(permissionServiceProvider)
                            .requestNotificationPermission();
                        ref.invalidate(permissionSnapshotProvider);
                      },
              ),
              const SizedBox(height: 12),
              _PermissionCard(
                icon: Icons.battery_saver_outlined,
                title: 'Battery optimization',
                body:
                    'Optional. Ignoring battery optimizations helps tracking '
                    'stay reliable on some OEM devices. Only enable if you '
                    'notice gaps in the timeline.',
                granted: snap.batteryOptimizationIgnored,
                actionLabel: snap.batteryOptimizationIgnored
                    ? 'Already ignored'
                    : 'Request exception',
                onAction: snap.batteryOptimizationIgnored
                    ? null
                    : () async {
                        await ref
                            .read(permissionServiceProvider)
                            .requestIgnoreBatteryOptimizations();
                        ref.invalidate(permissionSnapshotProvider);
                      },
              ),
              const SizedBox(height: 28),
              if (widget.fromOnboarding) ...[
                FilledButton(
                  onPressed: _finish,
                  child: Text(
                    snap.usageAccess
                        ? 'Start tracking'
                        : 'Continue without tracking',
                  ),
                ),
                if (!snap.usageAccess) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You can grant usage access later from Settings.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ] else
                FilledButton(
                  onPressed: () async {
                    if (snap.usageAccess) {
                      await ref
                          .read(trackingEnabledProvider.notifier)
                          .setEnabled(true);
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.granted,
    required this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool granted;
  final String actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: textTheme.titleMedium),
                ),
                Icon(
                  granted ? Icons.check_circle_rounded : Icons.info_outline,
                  color: granted ? scheme.primary : scheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: granted
                  ? Text(
                      actionLabel,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                    )
                  : FilledButton.tonal(
                      onPressed: onAction == null
                          ? null
                          : () async => onAction!(),
                      child: Text(actionLabel),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
