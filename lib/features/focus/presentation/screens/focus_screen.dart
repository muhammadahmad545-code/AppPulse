import 'dart:async';

import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/services/focus/focus_session_service.dart';
import 'package:app_pulse/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final activeFocusProvider = StreamProvider.autoDispose<FocusSession?>((ref) {
  return ref.watch(focusSessionServiceProvider).watchActive();
});

final focusDayStatsProvider =
    FutureProvider.autoDispose<FocusDayStats>((ref) async {
  return ref.watch(focusSessionServiceProvider).statsForToday();
});

/// Focus mode: timed sessions with apps to avoid and daily stats.
class FocusScreen extends HookConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planned = useState(FocusSessionService.presets[1]);
    final blocked = useState(<String>{});
    final tick = useState(0);

    useEffect(() {
      final ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(focusSessionServiceProvider).tick();
        ref.invalidate(activeFocusProvider);
        ref.invalidate(focusDayStatsProvider);
        tick.value++;
      });
      return ticker.cancel;
    }, const []);

    final activeAsync = ref.watch(activeFocusProvider);
    final statsAsync = ref.watch(focusDayStatsProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Focus mode')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          activeAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (active) {
              if (active != null) {
                final elapsed = DateTime.now().difference(active.startedAt);
                final remaining = Duration(
                  milliseconds: (active.plannedDurationMs -
                          elapsed.inMilliseconds)
                      .clamp(0, active.plannedDurationMs),
                );
                final progress = active.plannedDurationMs == 0
                    ? 0.0
                    : elapsed.inMilliseconds / active.plannedDurationMs;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('Focusing', style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text(
                          remaining.compactLabel,
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'of ${Duration(milliseconds: active.plannedDurationMs).compactLabel}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(focusSessionServiceProvider)
                                      .cancel(active);
                                  ref.invalidate(activeFocusProvider);
                                  ref.invalidate(focusDayStatsProvider);
                                },
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  await ref
                                      .read(focusSessionServiceProvider)
                                      .complete(active);
                                  ref.invalidate(activeFocusProvider);
                                  ref.invalidate(focusDayStatsProvider);
                                },
                                child: const Text('Complete'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(
                    title: 'Duration',
                    subtitle: 'Choose a preset or keep the selected length',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preset in FocusSessionService.presets)
                        ChoiceChip(
                          label: Text('${preset.inMinutes}m'),
                          selected: planned.value == preset,
                          onSelected: (_) => planned.value = preset,
                        ),
                      ActionChip(
                        label: const Text('Custom'),
                        onPressed: () async {
                          final minutes = await _askCustomMinutes(context);
                          if (minutes != null && minutes > 0) {
                            planned.value = Duration(minutes: minutes);
                          }
                        },
                      ),
                    ],
                  ),
                  const SectionHeader(
                    title: 'Apps to avoid',
                    subtitle:
                        'Reminders for these apps stay active during focus',
                  ),
                  FutureBuilder<List<InstalledApp>>(
                    future: ref.read(appsDaoProvider).getAllApps(),
                    builder: (context, snapshot) {
                      final apps = snapshot.data ?? const <InstalledApp>[];
                      return Card(
                        child: Column(
                          children: [
                            for (final app in apps.take(40))
                              CheckboxListTile(
                                value:
                                    blocked.value.contains(app.packageName),
                                title: Text(app.appName),
                                subtitle: Text(app.packageName),
                                onChanged: (checked) {
                                  final next = {...blocked.value};
                                  if (checked == true) {
                                    next.add(app.packageName);
                                  } else {
                                    next.remove(app.packageName);
                                  }
                                  blocked.value = next;
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await ref.read(focusSessionServiceProvider).start(
                              planned: planned.value,
                              blockedPackages: blocked.value.toList(),
                            );
                        ref.invalidate(activeFocusProvider);
                        ref.invalidate(focusDayStatsProvider);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$error')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.center_focus_strong_rounded),
                    label: Text('Start ${planned.value.inMinutes}m focus'),
                  ),
                ],
              );
            },
          ),
          const SectionHeader(title: "Today's focus"),
          statsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (stats) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.completedCount} completed · '
                      '${stats.totalFocused.compactLabel} focused',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Limit reminders are silenced during focus except for '
                      'blocked apps currently in use, and limit-reached alerts.',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<int?> _askCustomMinutes(BuildContext context) async {
    final controller = TextEditingController(text: '30');
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom minutes'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Minutes'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
