// Smoke widget test ensures the app boots without crashing and surfaces the
// bottom-nav destinations defined in [router.dart].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socdaily_app/src/app/app.dart';
import 'package:socdaily_app/src/features/settings/settings_controller.dart';

void main() {
  testWidgets('SocDailyApp boots and shows bottom navigation',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding.complete': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SocDailyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });
}
