// ThemeData generator for SOCDaily — Mastercard-inspired design system.
//
// Produces a Material 3 theme with:
// - Warm cream canvas (#F3F0EE), never sterile white
// - Ink Black (#141413) primary CTAs and headings
// - Signal Orange (#CF4500) reserved for consent/legal
// - Sofia Sans as a single font family (closest open-source match to MarkForMC)
// - Extreme border-radius: 20px buttons, 40px hero frames, 999px pills
// - Atmospheric shadows with 48px+ spread at ≤10% opacity

import 'package:flutter/material.dart';

import 'app_accent.dart';

// ── Mastercard palette constants ──
class MCColors {
  MCColors._();

  static const inkBlack = Color(0xFF141413);
  static const charcoal = Color(0xFF262627);
  static const canvasCream = Color(0xFFF3F0EE);
  static const liftedCream = Color(0xFFFCFBFA);
  static const softBone = Color(0xFFF4F4F4);
  static const slateGray = Color(0xFF696969);
  static const dustTaupe = Color(0xFFD1CDC7);
  static const signalOrange = Color(0xFFCF4500);
  static const lightSignalOrange = Color(0xFFF37338);
  static const linkBlue = Color(0xFF3860BE);
  static const dividerCream = Color(0xFFE8E2DA);
}

class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required AppAccent accent,
  }) {
    final isDark = brightness == Brightness.dark;

    final surface = isDark
        ? const Color(0xFF1A1917)
        : MCColors.canvasCream;

    final surfaceContainer = isDark
        ? const Color(0xFF222220)
        : const Color(0xFFEDE9E3);

    final surfaceContainerHigh = isDark
        ? const Color(0xFF2A2A28)
        : MCColors.dustTaupe;

    final cardSurface = isDark
        ? const Color(0xFF222220)
        : MCColors.liftedCream;

    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : MCColors.dividerCream;

    final onSurface = isDark ? MCColors.liftedCream : MCColors.inkBlack;
    final onSurfaceVariant = isDark
        ? Colors.white.withOpacity(0.6)
        : MCColors.slateGray;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent.deep,
      onPrimary: isDark ? MCColors.inkBlack : MCColors.canvasCream,
      secondary: MCColors.signalOrange,
      onSecondary: Colors.white,
      error: const Color(0xFFB91C1C),
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainerHighest: surfaceContainerHigh,
      surfaceContainerHigh: surfaceContainer,
      outlineVariant: dividerColor,
      outline: isDark
          ? Colors.white.withOpacity(0.12)
          : MCColors.inkBlack.withOpacity(0.15),
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      textTheme: _textTheme(brightness),
      splashFactory: InkSparkle.splashFactory,

      // ── Cards: atmospheric shadow, stadium radius ──
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: cardSurface,
        shadowColor: isDark
            ? Colors.black.withOpacity(0.2)
            : Colors.black.withOpacity(0.06),
      ),

      // ── Filled buttons: ink pill (20px radius) ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MCColors.inkBlack,
          foregroundColor: MCColors.canvasCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.32,
          ),
        ),
      ),

      // ── Outlined buttons: outlined pill, ink border ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MCColors.inkBlack,
          backgroundColor: isDark ? Colors.transparent : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : MCColors.inkBlack,
            width: 1.5,
          ),
          textStyle: TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.48,
            color: isDark ? MCColors.liftedCream : MCColors.inkBlack,
          ),
        ),
      ),

      // ── Text buttons ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? MCColors.liftedCream : MCColors.inkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.48,
          ),
        ),
      ),

      // ── Elevated buttons: ink pill with atmospheric shadow ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MCColors.inkBlack,
          foregroundColor: MCColors.canvasCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.32,
          ),
        ),
      ),

      // ── Input fields: pill-shaped with soft border ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: MCColors.inkBlack.withOpacity(0.5),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : MCColors.inkBlack.withOpacity(0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: accent.deep,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),

      // ── Bottom navigation: warm, floating feel ──
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF1A1917).withOpacity(0.97)
            : Colors.white.withOpacity(0.97),
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.deep.withOpacity(isDark ? 0.15 : 0.08),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? accent.deep
                : onSurfaceVariant.withOpacity(0.7),
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? accent.deep
                : onSurfaceVariant.withOpacity(0.5),
            size: 22,
          );
        }),
      ),

      // ── App bar: transparent, editorial ──
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.44,
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // ── Chip: full pill ──
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide.none,
        backgroundColor: isDark
            ? Colors.white.withOpacity(0.06)
            : MCColors.liftedCream,
      ),

      // ── Dialog: large radius ──
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        backgroundColor: isDark ? const Color(0xFF222220) : Colors.white,
      ),

      // ── Bottom sheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF222220) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
      ),

      // ── Snackbar: pill shape ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        backgroundColor: MCColors.inkBlack,
      ),

      // ── Icon buttons ──
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: const CircleBorder(),
        ),
      ),

      // ── FloatingActionButton ──
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MCColors.inkBlack,
        foregroundColor: MCColors.canvasCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),

      // ── TabBar ──
      tabBarTheme: TabBarThemeData(
        labelColor: isDark ? MCColors.liftedCream : MCColors.inkBlack,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: accent.deep,
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: -0.28,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: -0.28,
        ),
      ),
    );
  }

  static const _fontFamily = 'SofiaSans';

  static TextTheme _textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;
    return base.copyWith(
      // H1 hero: 64px / 500 / -2% tracking
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 64,
        height: 1.0,
        letterSpacing: -1.28,
      ),
      // H2 section: 36px / 500 / -2% tracking
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 36,
        height: 44 / 36,
        letterSpacing: -0.72,
      ),
      // H3 card title: 24px / 500 / -2% tracking
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 24,
        height: 28.8 / 24,
        letterSpacing: -0.48,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 32,
        letterSpacing: -0.64,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 28,
        letterSpacing: -0.56,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 22,
        letterSpacing: -0.44,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 20,
        letterSpacing: -0.4,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        letterSpacing: -0.32,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: -0.28,
      ),
      // Body: 16px / weight 450 (use 400 with tighter spacing)
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 1.4,
        letterSpacing: -0.08,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.4,
        letterSpacing: 0,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.4,
      ),
      // Eyebrow: 14px / 700 / +4% tracking, uppercase
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.56,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        letterSpacing: 0.2,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.3,
      ),
    );
  }
}
