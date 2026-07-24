import 'dart:async';

import 'package:app_pulse/app.dart';
import 'package:app_pulse/bootstrap.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    final boot = await bootstrap();

    runApp(
      ProviderScope(
        overrides: bootstrapOverrides(boot),
        child: const AppPulseApp(),
      ),
    );
  }, (error, stack) {
    AppLogger.e('Uncaught zone error', error, stack);
  });
}
