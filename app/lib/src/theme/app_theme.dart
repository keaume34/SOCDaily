// ThemeData generator for SOCDaily.
//
// Produces a Material 3 theme keyed off (brightness, accent) so the user can
// switch accents at runtime without restarting the app. Light surfaces are a
// near-white gradient, dark surfaces a near-black gradient — buttons and focus
// states pick up the user-selected accent.

import 'package:flutter/material.dart';

import 'app_accent.dart';

class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required AppAccent accent,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent.deep,
      brightness: brightness,
    );

    final surface = brightness == Brightness.dark
        ? const Color(0xFF0B0F14)
        : const Color(0xFFFAFBFC);

    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme.copyWith(surface: surface),
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      textTheme: _textTheme(brightness),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.6),
            width: 1,
          ),
        ),
        color: scheme.surfaceContainerHighest.withOpacity(0.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: accent.soft.withOpacity(0.70),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent.deep, width: 1),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? accent.deep : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? accent.deep : scheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _headlineFamily,
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );

    return base;
  }

  static const _headlineFamily = 'Quicksand';
  static const _bodyFamily = 'PlusJakartaSans';

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: _bodyFamily,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: _bodyFamily,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: _bodyFamily,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: _bodyFamily,
      ),
    );
  }
}
