import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/features/apps/presentation/widgets/limit_reminder_listener.dart';
import 'package:app_pulse/features/settings/presentation/providers/settings_providers.dart';
import 'package:app_pulse/features/settings/presentation/providers/theme_providers.dart';
import 'package:app_pulse/l10n/app_localizations.dart';
import 'package:app_pulse/routing/app_router.dart';
import 'package:app_pulse/theme/app_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root MaterialApp wired with Riverpod, GoRouter, and Material You.
class AppPulseApp extends ConsumerWidget {
  const AppPulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final dynamicColorEnabled = ref.watch(dynamicColorEnabledProvider);
    final localeCode = ref.watch(appLocaleCodeProvider);
    final locale =
        localeCode == null || localeCode.isEmpty ? null : Locale(localeCode);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final useDynamic = dynamicColorEnabled;
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.light(useDynamic ? lightDynamic : null),
          darkTheme: AppTheme.dark(useDynamic ? darkDynamic : null),
          locale: locale,
          routerConfig: router,
          builder: (context, child) {
            return LimitReminderListener(
              child: child ?? const SizedBox.shrink(),
            );
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
