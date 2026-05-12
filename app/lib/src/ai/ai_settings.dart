// AI settings: provider, base URL, API key, model, language. Persisted via
// SharedPreferences alongside the existing UI settings.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/settings_controller.dart';
import 'llm_client.dart';

enum AiProvider {
  openaiCompat('OpenAI-compatible'),
  anthropic('Anthropic');

  const AiProvider(this.label);
  final String label;

  static AiProvider fromName(String? name) {
    for (final v in AiProvider.values) {
      if (v.name == name) return v;
    }
    return AiProvider.openaiCompat;
  }
}

@immutable
class AiSettings {
  const AiSettings({
    required this.provider,
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  final AiProvider provider;
  final String baseUrl;
  final String apiKey;
  final String model;

  bool get isConfigured => apiKey.trim().isNotEmpty && model.trim().isNotEmpty;

  AiSettings copyWith({
    AiProvider? provider,
    String? baseUrl,
    String? apiKey,
    String? model,
  }) {
    return AiSettings(
      provider: provider ?? this.provider,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
    );
  }

  static const initial = AiSettings(
    provider: AiProvider.openaiCompat,
    baseUrl: 'https://api.openai.com/v1',
    apiKey: '',
    model: 'gpt-4o-mini',
  );
}

const _kAiProviderKey = 'ai.provider';
const _kAiBaseUrlKey = 'ai.baseUrl';
const _kAiApiKeyKey = 'ai.apiKey';
const _kAiModelKey = 'ai.model';

class AiSettingsController extends Notifier<AiSettings> {
  late SharedPreferences _prefs;

  @override
  AiSettings build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return _load();
  }

  AiSettings _load() {
    return AiSettings(
      provider: AiProvider.fromName(_prefs.getString(_kAiProviderKey)),
      baseUrl: _prefs.getString(_kAiBaseUrlKey) ?? AiSettings.initial.baseUrl,
      apiKey: _prefs.getString(_kAiApiKeyKey) ?? '',
      model: _prefs.getString(_kAiModelKey) ?? AiSettings.initial.model,
    );
  }

  Future<void> setProvider(AiProvider provider) async {
    state = state.copyWith(provider: provider);
    await _prefs.setString(_kAiProviderKey, provider.name);
  }

  Future<void> setBaseUrl(String url) async {
    state = state.copyWith(baseUrl: url);
    await _prefs.setString(_kAiBaseUrlKey, url);
  }

  Future<void> setApiKey(String key) async {
    state = state.copyWith(apiKey: key);
    await _prefs.setString(_kAiApiKeyKey, key);
  }

  Future<void> setModel(String model) async {
    state = state.copyWith(model: model);
    await _prefs.setString(_kAiModelKey, model);
  }

  Future<void> clearApiKey() async {
    state = state.copyWith(apiKey: '');
    await _prefs.remove(_kAiApiKeyKey);
  }
}

final aiSettingsControllerProvider =
    NotifierProvider<AiSettingsController, AiSettings>(
        AiSettingsController.new);

/// Resolves an [LlmClient] from the current [AiSettings].
final llmClientProvider = Provider<LlmClient>((ref) {
  final s = ref.watch(aiSettingsControllerProvider);
  switch (s.provider) {
    case AiProvider.openaiCompat:
      return OpenAICompatClient(
        baseUrl: s.baseUrl,
        apiKey: s.apiKey,
        model: s.model,
      );
    case AiProvider.anthropic:
      return AnthropicClient(apiKey: s.apiKey, model: s.model);
  }
});
