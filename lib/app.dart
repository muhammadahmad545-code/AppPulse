import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state.dart';
import 'ui/shell.dart';

const accent = BasaltAccent.sky;

class ClockedApp extends ConsumerWidget {
  const ClockedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final look = BasaltAppearanceController.instance;
    // Settings → Appearance changes rebuild the app straight away, no restart needed.
    return ListenableBuilder(
      listenable: look ?? const _Never(),
      builder: (context, _) {
        final a = look?.value ?? BasaltAppearance.defaults;
        final reduce = look?.reduceMotion ?? false;
        return MaterialApp(
          title: 'Clocked',
          debugShowCheckedModeBanner: false,
          theme: basaltTheme(Brightness.light, accent, appearance: a, reduceMotion: reduce),
          darkTheme: basaltTheme(Brightness.dark, accent, appearance: a, reduceMotion: reduce),
          themeMode: mode,
          builder: look?.wrap,
          home: const _Root(),
        );
      },
    );
  }
}

/// A listenable that never fires, for tests that start the app without loading the appearance.
class _Never implements Listenable {
  const _Never();
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(onboardedProvider)) return const HomeShell();
    return BOnboarding(
      appName: 'Clocked',
      pages: const [
        BOnboardingPage(
          icon: Icons.insights_rounded,
          title: 'See where your time goes',
          body: 'Clocked measures how long you spend in each app, hour by hour, using Android\'s own usage records.',
        ),
        BOnboardingPage(
          icon: Icons.timer_outlined,
          title: 'Limits and focus',
          body: 'Set a daily limit for any app and get a reminder when you reach it. Start a focus session and see how well it went.',
        ),
        BOnboardingPage(
          icon: Icons.lock_outline_rounded,
          title: 'Private by design',
          body: 'Everything stays on this phone. No account, no cloud, no tracking. You only need to allow usage access once.',
        ),
      ],
      onDone: () {
        ref.read(prefsProvider).onboarded = true;
        ref.read(onboardedProvider.notifier).state = true;
      },
    );
  }
}
