// ThemeData generator for SOCDaily — "Soft Styles" design system.
//
// Produces a Material 3 theme keyed off (brightness, accent) with:
// - Creamy, warm surfaces with pastel depth
// - Soft shadow cards instead of hard borders
// - Rounded, friendly shapes (24px radius)
// - Gentle typography pairing (Quicksand headlines + Plus Jakarta Sans body)
// - Muted contrast for easy-on-the-eyes reading

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

    final surface = isDark
        ? const Color(0xFF1A1A2E) // soft navy-purple
        : const Color(0xFFFAF8F5); // warm cream

    final surfaceContainer = isDark
        ? const Color(0xFF222240)
        : const Color(0xFFF3F0EB);

    final surfaceContainerHigh = isDark
        ? const Color(0xFF2A2A4A)
        : const Color(0xFFEDE9E3);

    final cardSurface = isDark
        ? const Color(0xFF222240)
        : Colors.white;

    final dividerColor = isDark
        ? Colors.white.withOpacity(0.07)
        : const Color(0xFFE8E2DA);

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

      // ── Cards: soft shadow, no border ──
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide.none,
        ),
        color: cardSurface,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.3)
            : const Color(0xFFD4C9BE).withOpacity(0.3),
      ),

      // ── Filled buttons: pill shape ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _bodyFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Outlined buttons: pill shape, soft border ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.12)
                : const Color(0xFFD4C9BE),
            width: 1.5,
          ),
        ),
      ),

      // ── Text buttons ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── Input fields: soft rounded ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFF5F1EC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: accent.deep.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // ── Bottom navigation: soft, floaty ──
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF1A1A2E).withOpacity(0.97)
            : Colors.white.withOpacity(0.97),
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.soft.withOpacity(isDark ? 0.30 : 0.55),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: _bodyFamily,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? accent.deep
                : updatedScheme.onSurfaceVariant.withOpacity(0.6),
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? accent.deep
                : updatedScheme.onSurfaceVariant.withOpacity(0.5),
            size: 22,
          );
        }),
      ),

      // ── App bar: transparent, soft title ──
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

      // ── Chip: soft rounded ──
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        side: BorderSide.none,
        backgroundColor: isDark
            ? Colors.white.withOpacity(0.06)
            : const Color(0xFFF0EBE4),
      ),

      // ── Dialog: large radius ──
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        backgroundColor: cardSurface,
      ),

      // ── Bottom sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ── Snackbar: pill shape ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),

      // ── Icon buttons: softer ──
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.15,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: _headlineFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.6,
        letterSpacing: 0.15,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.55,
        letterSpacing: 0.1,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: _bodyFamily,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: _bodyFamily,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
