import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Offline privacy policy — all processing stays on device.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text(
            AppConstants.appName,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: July 24, 2026',
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AppPulse is designed to be fully offline. Your usage data is '
            'collected and stored only on this device.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text('What we collect', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'AppPulse reads Android usage statistics (with your permission) to '
            'estimate how long apps are in the foreground. It also stores the '
            'list of installed apps, optional category labels, limits, focus '
            'sessions, notification history, and settings you configure.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('What we do not do', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '• No accounts, Firebase, or remote servers\n'
            '• No analytics SDKs or advertising identifiers\n'
            '• No automatic uploads of usage data\n'
            '• No force-closing of other apps',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Exports & backups', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Reports and database backups leave the device only when you '
            'explicitly share or export them through the system share sheet '
            'or a file you choose.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Permissions', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Usage Access is required for tracking. Notification permission '
            'is optional and used for limit/focus reminders. Battery '
            'optimization exemptions are optional and improve reliability.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Your control', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'You can pause tracking, clear history, reset statistics, or '
            'uninstall the app at any time. Uninstalling removes on-device data.',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
