// ThemeData generator for SOCDaily — "Cute Sentinel" design system.
//
// Produces a Material 3 theme keyed off (brightness, accent) with:
// - Warm, layered surfaces with subtle depth
// - Glass-morphism card effects
// - Refined typography pairing (Quicksand headlines + Plus Jakarta Sans body)
// - Smooth, professional color transitions between light ↔ dark

import 'package:flutter/material.dart';

import 'app_accent.dart';

class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required AppAccent accent,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent.deep,
      brightness: brightness,
    );

    // Warm surface tones instead of pure black/white
    final surface = isDark
        ? const Color(0xFF0D1117) // warm near-black with blue tint
        : const Color(0xFFF8F9FC); // warm near-white with cool tint

    final surfaceContainer = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF0F2F6);

    final surfaceContainerHigh = isDark
        ? const Color(0xFF1C2128)
        : const Color(0xFFE8EBF0);

    final cardSurface = isDark
        ? const Color(0xFF161B22)
        : Colors.white;

    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    final updatedScheme = scheme.copyWith(
      surface: surface,
      surfaceContainerHighest: surfaceContainerHigh,
      surfaceContainerHigh: surfaceContainer,
      outlineVariant: dividerColor,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: updatedScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      textTheme: _textTheme(brightness),
      splashFactory: InkSparkle.splashFactory,

      // ── Cards: glassmorphism-lite ──
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
        color: cardSurface.withOpacity(isDark ? 0.6 : 0.85),
      ),

      // ── Filled buttons ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _bodyFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ── Outlined buttons ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(
            color: accent.deep.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),

      // ── Input fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer.withOpacity(isDark ? 0.5 : 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: dividerColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: accent.deep.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Bottom navigation ──
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF0D1117).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.soft.withOpacity(isDark ? 0.25 : 0.50),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: accent.deep.withOpacity(0.3),
            width: 1,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: _bodyFamily,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? accent.deep
                : updatedScheme.onSurfaceVariant.withOpacity(0.7),
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? accent.deep
                : updatedScheme.onSurfaceVariant.withOpacity(0.6),
            size: 22,
          );
        }),
      ),

      // ── App bar ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: updatedScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _headlineFamily,
          color: updatedScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ──
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(
          color: dividerColor,
          width: 1,
        ),
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: cardSurface,
      ),

      // ── Bottom sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static const _headlineFamily = 'Quicksand';
  static const _bodyFamily = 'PlusJakartaSans';

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    return base.copyWith(
      // ── Display: big hero numbers / splash text ──
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.15,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),

      // ── Headlines: section titles ──
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
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),

      // ── Titles: card headers, nav ──
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w600,
      ),

      // ── Body: readable paragraphs ──
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.4,
      ),

      // ── Labels: chips, buttons ──
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
      ),
    );
  }
}
