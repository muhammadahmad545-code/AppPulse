import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/format.dart';
import 'data/models.dart';
import 'data/prefs.dart';
import 'data/repo.dart';

final repoProvider = Provider<UsageRepo>((ref) => throw UnimplementedError('repoProvider is overridden in main()'));
final prefsProvider = Provider<Prefs>((ref) => ref.watch(repoProvider).prefs);

/// Bumped after every sync or edit; data providers watch it to reload.
final revisionProvider = StateProvider<int>((ref) => 0);

/// True while a sync is running (for the refresh indicator in headers).
final syncingProvider = StateProvider<bool>((ref) => false);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ref.watch(prefsProvider).themeMode);
final onboardedProvider = StateProvider<bool>((ref) => ref.watch(prefsProvider).onboarded);
final goalProvider = StateProvider<int>((ref) => ref.watch(prefsProvider).goalMinutes);
final downtimeProvider = StateProvider<Downtime>((ref) => ref.watch(prefsProvider).downtime);
final weeklySummaryProvider = StateProvider<bool>((ref) => ref.watch(prefsProvider).weeklySummary);

final accessProvider = FutureProvider<bool>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).native.hasUsageAccess();
});

final notificationsProvider = FutureProvider<bool>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).native.notificationsEnabled();
});

final overlayAllowedProvider = FutureProvider<bool>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).native.canDrawOverlays();
});

final dayProvider = FutureProvider.family<DayUsage, String>((ref, key) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).day(dayFromKey(key));
});

/// The last N days, ending today.
final lastDaysProvider = FutureProvider.family<RangeUsage, int>((ref, days) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).lastDays(days);
});

final appInfosProvider = FutureProvider<Map<String, AppInfo>>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).appInfos();
});

final limitsProvider = FutureProvider<List<AppLimit>>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).limits();
});

final activeFocusProvider = FutureProvider<FocusSession?>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).activeFocus();
});

final focusHistoryProvider = FutureProvider<List<FocusSession>>((ref) {
  ref.watch(revisionProvider);
  return ref.watch(repoProvider).db.focusHistory();
});

/// Reload every data provider.
void bump(WidgetRef ref) => ref.read(revisionProvider.notifier).state++;

/// Sync from Android, then reload the screens. Safe to call from a widget that may be disposed meanwhile.
Future<void> syncNow(WidgetRef ref) async {
  final repo = ref.read(repoProvider);
  final syncing = ref.read(syncingProvider.notifier);
  final revision = ref.read(revisionProvider.notifier);
  syncing.state = true;
  try {
    await repo.sync();
  } finally {
    syncing.state = false;
    revision.state++;
  }
}

/// Runs [action] against the repository, then reloads the screens.
Future<T> withRepo<T>(WidgetRef ref, Future<T> Function(UsageRepo repo) action) async {
  final repo = ref.read(repoProvider);
  final revision = ref.read(revisionProvider.notifier);
  try {
    return await action(repo);
  } finally {
    revision.state++;
  }
}
