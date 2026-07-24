import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/services/limits/limit_models.dart';
import 'package:app_pulse/shared/widgets/feature_empty_state.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLimitsProvider = StreamProvider.autoDispose<List<AppLimit>>((ref) {
  return ref.watch(limitsDaoProvider).watchAllLimits();
});

/// Manage per-app daily/weekly/monthly usage limits and reminder actions.
class LimitsScreen extends ConsumerWidget {
  const LimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(appLimitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('App limits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add limit'),
      ),
      body: limitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (limits) {
          if (limits.isEmpty) {
            return FeatureEmptyState(
              icon: Icons.timer_outlined,
              title: 'No limits configured',
              message:
                  'Set daily, weekly, or monthly caps per app. When a limit is '
                  'near or reached, AppPulse notifies or shows a reminder — '
                  'without force-closing other apps.',
              actionLabel: 'Add limit',
              onAction: () => _openEditor(context, ref),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: limits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final limit = limits[index];
              return _LimitCard(limit: limit);
            },
          );
        },
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, [
    AppLimit? existing,
  ]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _LimitEditorSheet(existing: existing),
    );
  }
}

class _LimitCard extends ConsumerWidget {
  const _LimitCard({required this.limit});

  final AppLimit limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = LimitTypeStorage.fromStorage(limit.limitType);
    final action = LimitActionStorage.fromStorage(limit.actionOnReach);

    return FutureBuilder(
      future: Future.wait([
        ref.read(appsDaoProvider).getByPackage(limit.packageName),
        ref.read(summariesDaoProvider).getDailyForPackage(
              limit.packageName,
              DateTime.now().dayKey,
            ),
      ]),
      builder: (context, snapshot) {
        final app = snapshot.data?[0] as InstalledApp?;
        final daily = snapshot.data?[1] as DailySummary?;
        final used = Duration(milliseconds: daily?.totalDurationMs ?? 0);
        final cap = Duration(milliseconds: limit.limitDurationMs);
        final progress = cap.inMilliseconds == 0
            ? 0.0
            : (used.inMilliseconds / cap.inMilliseconds).clamp(0.0, 1.0);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        app?.appName ?? limit.packageName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch(
                      value: limit.isEnabled,
                      onChanged: (value) async {
                        await ref
                            .read(limitsDaoProvider)
                            .setEnabled(limit.id, isEnabled: value);
                      },
                    ),
                  ],
                ),
                Text(
                  '${type.label} · ${cap.compactLabel} · ${action.label}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 6),
                Text(
                  '${used.compactLabel} used today (preview)',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (_) => _LimitEditorSheet(existing: limit),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref.read(limitsDaoProvider).deleteLimit(limit.id);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LimitEditorSheet extends ConsumerStatefulWidget {
  const _LimitEditorSheet({this.existing});

  final AppLimit? existing;

  @override
  ConsumerState<_LimitEditorSheet> createState() => _LimitEditorSheetState();
}

class _LimitEditorSheetState extends ConsumerState<_LimitEditorSheet> {
  String? _packageName;
  LimitType _type = LimitType.daily;
  LimitAction _action = LimitAction.onlyNotify;
  int _hours = 1;
  int _minutes = 0;
  int _warnPrimary = 5;
  int _warnSecondary = 10;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _packageName = existing.packageName;
      _type = LimitTypeStorage.fromStorage(existing.limitType);
      _action = LimitActionStorage.fromStorage(existing.actionOnReach);
      final d = Duration(milliseconds: existing.limitDurationMs);
      _hours = d.inHours;
      _minutes = d.inMinutes % 60;
      _warnPrimary = existing.warnAtMinutesRemaining;
      _warnSecondary = existing.secondaryWarnAtMinutesRemaining;
      if (existing.customWindowStart != null &&
          existing.customWindowEnd != null) {
        _customRange = DateTimeRange(
          start: existing.customWindowStart!,
          end: existing.customWindowEnd!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Add limit' : 'Edit limit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<InstalledApp>>(
              future: ref.read(appsDaoProvider).getAllApps(),
              builder: (context, snapshot) {
                final apps = snapshot.data ?? const <InstalledApp>[];
                return DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _packageName,
                  decoration: const InputDecoration(labelText: 'App'),
                  items: [
                    for (final app in apps)
                      DropdownMenuItem(
                        value: app.packageName,
                        child: Text(app.appName),
                      ),
                  ],
                  onChanged: widget.existing == null
                      ? (value) => setState(() => _packageName = value)
                      : null,
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LimitType>(
              // ignore: deprecated_member_use
              value: _type,
              decoration: const InputDecoration(labelText: 'Limit type'),
              items: [
                for (final type in LimitType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            if (_type == LimitType.custom) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Custom window'),
                subtitle: Text(
                  _customRange == null
                      ? 'Pick start and end dates'
                      : '${_customRange!.start.toLocal().toString().split(' ').first}'
                          ' → '
                          '${_customRange!.end.toLocal().toString().split(' ').first}',
                ),
                trailing: const Icon(Icons.date_range_rounded),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: now.subtract(const Duration(days: 365)),
                    lastDate: now.add(const Duration(days: 365)),
                    initialDateRange: _customRange ??
                        DateTimeRange(
                          start: now,
                          end: now.add(const Duration(days: 7)),
                        ),
                  );
                  if (picked != null) {
                    setState(() => _customRange = picked);
                  }
                },
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '$_hours',
                    decoration: const InputDecoration(labelText: 'Hours'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _hours = int.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '$_minutes',
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _minutes = int.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<LimitAction>(
              // ignore: deprecated_member_use
              value: _action,
              decoration: const InputDecoration(labelText: 'When reached'),
              items: [
                for (final action in LimitAction.values)
                  DropdownMenuItem(
                    value: action,
                    child: Text(action.label),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _action = value);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _action.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '$_warnPrimary',
                    decoration: const InputDecoration(
                      labelText: 'Warn (minutes left)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _warnPrimary = int.tryParse(v) ?? 5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '$_warnSecondary',
                    decoration: const InputDecoration(
                      labelText: 'Second warn',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _warnSecondary = int.tryParse(v) ?? 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final package = _packageName;
                if (package == null) return;
                final duration = Duration(hours: _hours, minutes: _minutes);
                if (duration.inMilliseconds <= 0) return;
                if (_type == LimitType.custom && _customRange == null) return;

                await ref.read(limitsDaoProvider).upsertLimit(
                      AppLimitsCompanion(
                        id: widget.existing == null
                            ? const Value.absent()
                            : Value(widget.existing!.id),
                        packageName: Value(package),
                        limitType: Value(_type.storage),
                        limitDurationMs: Value(duration.inMilliseconds),
                        actionOnReach: Value(_action.storage),
                        warnAtMinutesRemaining: Value(_warnPrimary),
                        secondaryWarnAtMinutesRemaining: Value(_warnSecondary),
                        customWindowStart: _type == LimitType.custom
                            ? Value(_customRange!.start)
                            : const Value(null),
                        customWindowEnd: _type == LimitType.custom
                            ? Value(_customRange!.end.endOfDay)
                            : const Value(null),
                        isEnabled: const Value(true),
                        updatedAt: Value(DateTime.now()),
                      ),
                    );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save limit'),
            ),
          ],
        ),
      ),
    );
  }
}
