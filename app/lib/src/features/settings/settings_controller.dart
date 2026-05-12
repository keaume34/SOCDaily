// Immutable settings model + Riverpod controller backed by
// [SharedPreferences]. Phase 1 only persists theme mode, accent, and locale;
// later phases will extend this with notification prefs, AI provider config,
// etc.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_accent.dart';

@immutable
class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.accent,
    required this.locale,
  });

  final ThemeMode themeMode;
  final AppAccent accent;

  /// `null` means "follow the device locale".
  final Locale? locale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppAccent? accent,
    Locale? locale,
    bool clearLocale = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      locale: clearLocale ? null : (locale ?? this.locale),
    );
  }

  static const initial = AppSettings(
    themeMode: ThemeMode.system,
    accent: AppAccent.graphite,
    locale: Locale('en'),
  );
}

const _kThemeKey = 'settings.themeMode';
const _kAccentKey = 'settings.accent';
const _kLocaleKey = 'settings.locale';

/// Injected at app start in `main.dart` after [SharedPreferences.getInstance].
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

class SettingsController extends Notifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  AppSettings build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return _load();
  }

  AppSettings _load() {
    final themeIndex = _prefs.getInt(_kThemeKey);
    final accentName = _prefs.getString(_kAccentKey);
    final localeCode = _prefs.getString(_kLocaleKey);
    return AppSettings(
      themeMode: themeIndex == null
          ? ThemeMode.system
          : ThemeMode.values[themeIndex.clamp(0, ThemeMode.values.length - 1)],
      accent: AppAccent.fromName(accentName),
      locale: localeCode == null || localeCode.isEmpty
          ? null
          : Locale(localeCode),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setInt(_kThemeKey, mode.index);
  }

  Future<void> setAccent(AppAccent accent) async {
    state = state.copyWith(accent: accent);
    await _prefs.setString(_kAccentKey, accent.name);
  }

  /// Pass `null` to follow the device locale.
  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale, clearLocale: locale == null);
    if (locale == null) {
      await _prefs.remove(_kLocaleKey);
    } else {
      await _prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
