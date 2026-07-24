import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/features/apps/presentation/providers/apps_list_providers.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:app_pulse/shared/widgets/app_icon_avatar.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Installed apps with search, sort, filter, favorites, and pins.
class AppsScreen extends ConsumerWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsWithUsageProvider);
    final query = ref.watch(appsSearchQueryProvider);
    final sort = ref.watch(appsSortModeProvider);
    final filter = ref.watch(appsFilterModeProvider);
    final use24h =
        ref.watch(settingsStorageProvider).timeFormat == '24h';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
        actions: [
          IconButton(
            tooltip: 'Refresh catalog',
            onPressed: () async {
              await ref.read(appCatalogSyncServiceProvider).sync(force: true);
              ref.invalidate(appsWithUsageProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sort & filter',
            onPressed: () => _showSortFilterSheet(context, ref, sort, filter),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: ref.read(appsSearchQueryProvider.notifier).setQuery,
              decoration: InputDecoration(
                hintText: 'Search apps, packages, categories',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => ref
                            .read(appsSearchQueryProvider.notifier)
                            .setQuery(''),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                for (final mode in AppsFilterMode.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filterLabel(mode)),
                      selected: filter == mode,
                      onSelected: (_) => ref
                          .read(appsFilterModeProvider.notifier)
                          .setMode(mode),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: appsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (apps) {
                if (apps.isEmpty) {
                  return FeatureEmptyState(
                    icon: Icons.apps_rounded,
                    title: query.isEmpty ? 'No apps indexed yet' : 'No matches',
                    message: query.isEmpty
                        ? 'Grant usage access and sync to load launcher apps.'
                        : 'Nothing matched “$query”.',
                    actionLabel: 'Sync apps',
                    onAction: () async {
                      await ref
                          .read(appCatalogSyncServiceProvider)
                          .sync(force: true);
                      ref.invalidate(appsWithUsageProvider);
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: apps.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final item = apps[index];
                    final app = item.app;
                    return ListTile(
                      leading: AppIconAvatar(
                        packageName: app.packageName,
                        cacheKey: app.iconCacheKey,
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(app.appName)),
                          if (app.isPinned)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.push_pin_rounded, size: 16),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${app.category.label} · Today ${item.todayLabel}'
                        '${app.lastOpenedAt == null ? '' : ' · ${app.lastOpenedAt!.formatDateTime(use24h: use24h, datePattern: 'MMM d')}'}\n'
                        'Week ${item.week.compactLabel} · '
                        '${item.launchCount} launches · '
                        'avg ${item.averageSession.compactLabel}',
                        maxLines: 3,
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: app.isFavorite ? 'Unfavorite' : 'Favorite',
                        onPressed: () async {
                          await ref.read(appsRepositoryProvider).setFavorite(
                                app.packageName,
                                value: !app.isFavorite,
                              );
                          ref.invalidate(appsWithUsageProvider);
                        },
                        icon: Icon(
                          app.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: app.isFavorite
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      onLongPress: () async {
                        await ref.read(appsRepositoryProvider).setPinned(
                              app.packageName,
                              value: !app.isPinned,
                            );
                        ref.invalidate(appsWithUsageProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                app.isPinned
                                    ? 'Unpinned ${app.appName}'
                                    : 'Pinned ${app.appName}',
                              ),
                            ),
                          );
                        }
                      },
                      onTap: () => context.push(
                        AppRoutes.appDetailsPath(app.packageName),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _filterLabel(AppsFilterMode mode) {
    return switch (mode) {
      AppsFilterMode.all => 'All',
      AppsFilterMode.favorites => 'Favorites',
      AppsFilterMode.pinned => 'Pinned',
      AppsFilterMode.userApps => 'User',
      AppsFilterMode.systemApps => 'System',
    };
  }

  Future<void> _showSortFilterSheet(
    BuildContext context,
    WidgetRef ref,
    AppsSortMode sort,
    AppsFilterMode filter,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Sort by')),
              for (final mode in AppsSortMode.values)
                ListTile(
                  title: Text(_sortLabel(mode)),
                  trailing: mode == sort
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    ref.read(appsSortModeProvider.notifier).setMode(mode);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  static String _sortLabel(AppsSortMode mode) {
    return switch (mode) {
      AppsSortMode.alphabetical => 'Alphabetical',
      AppsSortMode.usageToday => 'Usage today',
      AppsSortMode.launchCount => 'Launch count',
      AppsSortMode.recentlyUsed => 'Recently used',
    };
  }
}
