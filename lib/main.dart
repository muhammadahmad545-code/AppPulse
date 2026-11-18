import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/db.dart';
import 'data/prefs.dart';
import 'data/repo.dart';
import 'state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BasaltUpdater.instance.start(owner: 'muhammadahmad545-code', repo: 'AppPulse');
  final prefs = await Prefs.load();
  final db = await AppDb.open();
  final repo = UsageRepo(db: db, prefs: prefs);
  runApp(ProviderScope(overrides: [repoProvider.overrideWithValue(repo)], child: const AppPulseApp()));
}
