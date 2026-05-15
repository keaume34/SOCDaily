// Settings for the on-demand content generator (FastAPI service from P14.A).
// Persists base URL + bearer token via SharedPreferences. Mirrors the
// `AiSettings` pattern (P7) so the user pattern is familiar.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/settings_controller.dart';

@immutable
class GeneratorSettings {
  const GeneratorSettings({
    required this.baseUrl,
    required this.token,
  });

  final String baseUrl;
  final String token;

  bool get isConfigured => baseUrl.trim().isNotEmpty && token.trim().isNotEmpty;

  GeneratorSettings copyWith({String? baseUrl, String? token}) {
    return GeneratorSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      token: token ?? this.token,
    );
  }

  static const initial = GeneratorSettings(baseUrl: '', token: '');
}

const _kGenBaseUrlKey = 'generator.baseUrl';
const _kGenTokenKey = 'generator.token';

class GeneratorSettingsController extends Notifier<GeneratorSettings> {
  late SharedPreferences _prefs;

  @override
  GeneratorSettings build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return GeneratorSettings(
      baseUrl: _prefs.getString(_kGenBaseUrlKey) ?? '',
      token: _prefs.getString(_kGenTokenKey) ?? '',
    );
  }

  Future<void> setBaseUrl(String url) async {
    state = state.copyWith(baseUrl: url);
    await _prefs.setString(_kGenBaseUrlKey, url);
  }

  Future<void> setToken(String token) async {
    state = state.copyWith(token: token);
    await _prefs.setString(_kGenTokenKey, token);
  }

  Future<void> clearToken() async {
    state = state.copyWith(token: '');
    await _prefs.remove(_kGenTokenKey);
  }
}

final generatorSettingsControllerProvider =
    NotifierProvider<GeneratorSettingsController, GeneratorSettings>(
        GeneratorSettingsController.new);
