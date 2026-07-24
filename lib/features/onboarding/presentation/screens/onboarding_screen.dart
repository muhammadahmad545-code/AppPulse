import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// First-run experience introducing AppPulse and privacy posture.
///
/// Permission grants are handled in Phase 2 once the tracking engine lands.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.graphic_eq_rounded,
      title: 'Know where your time goes',
      body:
          'AppPulse tracks time spent in every installed app — privately, '
          'entirely on your device. No accounts. No cloud. No ads.',
    ),
    _OnboardingPage(
      icon: Icons.lock_outline_rounded,
      title: 'Offline by design',
      body:
          'Usage history, limits, focus sessions, and reports stay on this '
          'phone. Nothing is uploaded. You can export or wipe data anytime.',
    ),
    _OnboardingPage(
      icon: Icons.verified_user_outlined,
      title: 'Permissions, explained',
      body:
          'Usage Access lets AppPulse read app usage stats. Notifications '
          'power limit reminders. A foreground service keeps tracking '
          'reliable without draining the battery.',
    ),
  ];

  Future<void> _finish() async {
    if (!mounted) return;
    context.go(AppRoutes.permissionsSetup);
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.primary,
                                scheme.tertiary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          child: Icon(
                            page.icon,
                            size: 56,
                            color: scheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          AppConstants.appName,
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final selected = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primary
                        : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? 'Get started' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
