// Top-level [MaterialApp] wiring up theme, locale, and the [go_router] shell.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/settings_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class SocDailyApp extends ConsumerWidget {
  const SocDailyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final router = ref.watch(routerProvider);
    final theme = AppTheme.build(
      brightness: Brightness.light,
      accent: settings.accent,
    );
    final darkTheme = AppTheme.build(
      brightness: Brightness.dark,
      accent: settings.accent,
    );

    return MaterialApp.router(
      title: 'SOCDaily',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
