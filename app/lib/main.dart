// SOCDaily — SOC Analyst learning app.
//
// Entry point. Bootstraps Riverpod, restores persisted user settings, then
// hands off to [SocDailyApp] which owns the MaterialApp + router.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app/app.dart';
import 'src/features/settings/settings_controller.dart';
import 'src/sync/sync_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final syncConfig = SyncConfig.fromEnvironment();
  if (syncConfig.isConfigured) {
    await Supabase.initialize(
      url: syncConfig.url,
      anonKey: syncConfig.anonKey,
    );
  }
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SocDailyApp(),
    ),
  );
}
