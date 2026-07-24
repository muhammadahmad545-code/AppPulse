import 'dart:async';

import 'package:app_pulse/app.dart';
import 'package:app_pulse/bootstrap.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    try {
      final boot = await bootstrap();
      runApp(
        ProviderScope(
          overrides: bootstrapOverrides(boot),
          child: const AppPulseApp(),
        ),
      );
    } catch (error, stack) {
      AppLogger.e('Bootstrap failed', error, stack);
      runApp(_BootstrapErrorApp(error: error));
    }
  }, (error, stack) {
    AppLogger.e('Uncaught zone error', error, stack);
  });
}

/// Shown if critical bootstrap fails so the process does not silently die.
class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'AppPulse failed to start',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text('$error'),
                const SizedBox(height: 12),
                const Text(
                  'Uninstall the previous AppPulse build, then reinstall this APK.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
