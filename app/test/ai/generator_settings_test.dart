// Phase 14.B — GeneratorSettings persistence test.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socdaily_app/src/ai/generator_settings.dart';
import 'package:socdaily_app/src/features/settings/settings_controller.dart';

ProviderContainer _container(SharedPreferences prefs) {
  return ProviderContainer(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('initial state is empty + isConfigured false', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = _container(prefs);
    final s = c.read(generatorSettingsControllerProvider);
    expect(s.baseUrl, '');
    expect(s.token, '');
    expect(s.isConfigured, isFalse);
    c.dispose();
  });

  test('setBaseUrl + setToken persist + isConfigured becomes true', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = _container(prefs);
    final ctl = c.read(generatorSettingsControllerProvider.notifier);
    await ctl.setBaseUrl('https://socdaily.example');
    await ctl.setToken('secret');

    expect(prefs.getString('generator.baseUrl'), 'https://socdaily.example');
    expect(prefs.getString('generator.token'), 'secret');

    final s = c.read(generatorSettingsControllerProvider);
    expect(s.isConfigured, isTrue);
    c.dispose();
  });

  test('reload reads saved values', () async {
    SharedPreferences.setMockInitialValues({
      'generator.baseUrl': 'https://x',
      'generator.token': 't',
    });
    final prefs = await SharedPreferences.getInstance();
    final c = _container(prefs);
    final s = c.read(generatorSettingsControllerProvider);
    expect(s.baseUrl, 'https://x');
    expect(s.token, 't');
    expect(s.isConfigured, isTrue);
    c.dispose();
  });

  test('clearToken empties the token', () async {
    SharedPreferences.setMockInitialValues({
      'generator.baseUrl': 'https://x',
      'generator.token': 't',
    });
    final prefs = await SharedPreferences.getInstance();
    final c = _container(prefs);
    final ctl = c.read(generatorSettingsControllerProvider.notifier);
    await ctl.clearToken();
    expect(prefs.containsKey('generator.token'), isFalse);
    expect(c.read(generatorSettingsControllerProvider).isConfigured, isFalse);
    c.dispose();
  });
}
