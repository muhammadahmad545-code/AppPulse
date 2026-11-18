import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state.dart';
import 'ui/shell.dart';

const accent = BasaltAccent.sky;

class AppPulseApp extends ConsumerWidget {
  const AppPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AppPulse',
      debugShowCheckedModeBanner: false,
      theme: basaltTheme(Brightness.light, accent),
      darkTheme: basaltTheme(Brightness.dark, accent),
      themeMode: ref.watch(themeModeProvider),
      home: const _Root(),
    );
  }
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(onboardedProvider)) return const HomeShell();
    return BOnboarding(
      appName: 'AppPulse',
      pages: const [
        BOnboardingPage(
          icon: Icons.insights_rounded,
          title: 'See where your time goes',
          body: 'AppPulse measures how long you spend in each app, hour by hour, using Android\'s own usage records.',
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
