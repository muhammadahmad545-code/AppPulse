import 'package:app_pulse/core/constants/app_categories.dart';
import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/features/reports/domain/usage_report.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:app_pulse/shared/widgets/app_icon_avatar.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Global search across apps, sessions, categories, and report types.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(globalSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search apps, sessions, reports…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: (value) => setState(() => _query = value.trim()),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      body: _query.isEmpty
          ? const FeatureEmptyState(
              icon: Icons.search_rounded,
              title: 'Start typing',
              message:
                  'Search across installed apps, usage sessions, categories, '
                  'and report types.',
            )
          : resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (results) {
                if (results.isEmpty) {
                  return FeatureEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message: 'Nothing matched “$_query”.',
                  );
                }

                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return ListTile(
                      leading: item.icon,
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                      trailing: item.trailing == null
                          ? null
                          : Text(item.trailing!),
                      onTap: item.onTap == null
                          ? null
                          : () => item.onTap!(context),
                    );
                  },
                );
              },
            ),
    );
  }
}

final class _SearchHit {
  const _SearchHit({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget icon;
  final String? trailing;
  final void Function(BuildContext context)? onTap;
}

final globalSearchProvider = FutureProvider.autoDispose
    .family<List<_SearchHit>, String>((ref, query) async {
  if (query.isEmpty) return const [];
  final q = query.toLowerCase();
  final appsDao = ref.watch(appsDaoProvider);
  final sessionsDao = ref.watch(sessionsDaoProvider);
  final hits = <_SearchHit>[];

  // Reports
  for (final period in ReportPeriod.values) {
    final label = period.name;
    if (label.contains(q) || q.contains('report') || q == 'pdf' || q == 'csv') {
      hits.add(
        _SearchHit(
          title:
              '${period.name[0].toUpperCase()}${period.name.substring(1)} report',
          subtitle: 'Open Reports and export PDF / CSV / JSON',
          icon: const Icon(Icons.description_outlined),
          onTap: (context) => context.push(AppRoutes.reports),
        ),
      );
    }
  }

  // Categories
  for (final category in AppCategory.values) {
    if (category.label.toLowerCase().contains(q) ||
        category.name.toLowerCase().contains(q)) {
      hits.add(
        _SearchHit(
          title: category.label,
          subtitle: 'Category',
          icon: const Icon(Icons.category_outlined),
          onTap: (context) => context.go(AppRoutes.analytics),
        ),
      );
    }
  }

  // Apps
  final apps = await appsDao.search(query);
  for (final app in apps.take(30)) {
    hits.add(
      _SearchHit(
        title: app.appName,
        subtitle: '${app.category} · ${app.packageName}',
        icon: AppIconAvatar(
          packageName: app.packageName,
          cacheKey: app.iconCacheKey,
          size: 36,
          hero: false,
        ),
        onTap: (context) =>
            context.push(AppRoutes.appDetailsPath(app.packageName)),
      ),
    );
  }

  // Recent sessions (name match via apps map)
  final now = DateTime.now();
  final sessions = await sessionsDao.getSessionsInRange(
    now.subtract(const Duration(days: 30)).startOfDay,
    now.endOfDay,
  );
  final appByPackage = {
    for (final app in await appsDao.getAllApps(includeHidden: true))
      app.packageName: app,
  };

  var sessionHits = 0;
  for (final session in sessions) {
    if (sessionHits >= 20) break;
    final app = appByPackage[session.packageName];
    final name = app?.appName ?? session.packageName;
    if (!name.toLowerCase().contains(q) &&
        !session.packageName.toLowerCase().contains(q)) {
      continue;
    }
    sessionHits += 1;
    hits.add(
      _SearchHit(
        title: name,
        subtitle:
            'Session · ${session.startedAt.formatDateTime()} · '
            '${Duration(milliseconds: session.durationMs ?? 0).compactLabel}',
        icon: AppIconAvatar(
          packageName: session.packageName,
          cacheKey: app?.iconCacheKey,
          size: 36,
          hero: false,
        ),
        trailing: 'Timeline',
        onTap: (context) => context.go(AppRoutes.timeline),
      ),
    );
  }

  return hits;
});
