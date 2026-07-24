import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final notificationHistoryProvider =
    StreamProvider.autoDispose<List<NotificationHistoryData>>((ref) {
  return ref.watch(notificationsDaoProvider).watchRecent();
});

/// Local notification history from Drift.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(notificationHistoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear history?'),
                  content: const Text(
                    'Removes local notification history. This does not change '
                    'limits or usage data.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(notificationsDaoProvider).clearAll();
              }
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          if (items.isEmpty) {
            return const FeatureEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
              message:
                  'Limit warnings, focus alerts, and system reminders will be '
                  'logged here for review.',
            );
          }

          final formatter = DateFormat.MMMd().add_jm();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                    child: Icon(_iconFor(item.category)),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    '${item.body}\n'
                    '${item.category}'
                    '${item.packageName == null ? '' : ' · ${item.packageName}'}'
                    '\n${formatter.format(item.shownAt)}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _iconFor(String category) {
    return switch (category) {
      'limit' => Icons.timer_outlined,
      'focus' => Icons.center_focus_strong_outlined,
      'tracking' => Icons.graphic_eq_rounded,
      'report' => Icons.description_outlined,
      _ => Icons.notifications_outlined,
    };
  }
}
