// Accent palette for SOCDaily — Mastercard-inspired design system.
//
// The default accent is Ink (warm near-black) which matches Mastercard's
// primary CTA color. Additional accents are provided for personalisation
// but all share the warm editorial tone of the Mastercard palette.

import 'package:flutter/material.dart';

enum AppAccent {
  // ── Default: Mastercard Ink ──
  ink('Ink', Color(0xFF141413), Color(0xFFEDE9E3)),

  // ── Warm accents inspired by Mastercard palette ──
  signal('Signal', Color(0xFFCF4500), Color(0xFFFDE8DD)),
  clay('Clay', Color(0xFF9A3A0A), Color(0xFFF5E6DD)),

  // ── Professional ──
  graphite('Graphite', Color(0xFF1F2933), Color(0xFFE4E7EB)),
  azure('Azure', Color(0xFF1D4ED8), Color(0xFFDBEAFE)),
  violet('Violet', Color(0xFF6D28D9), Color(0xFFEDE9FE)),
  crimson('Crimson', Color(0xFFB91C1C), Color(0xFFFEE2E2)),
  forest('Forest', Color(0xFF047857), Color(0xFFD1FAE5)),
  amber('Amber', Color(0xFFB45309), Color(0xFFFEF3C7)),

  // ── Friendly (pastel) ──
  sakura('Sakura', Color(0xFFDB2777), Color(0xFFFCE7F3)),
  mint('Mint', Color(0xFF0F766E), Color(0xFFCCFBF1)),
  mocha('Mocha', Color(0xFF92400E), Color(0xFFFEF3C7));

  const AppAccent(this.label, this.deep, this.soft);

  final String label;

  /// Strong end — pairs with cream text on buttons and surfaces.
  final Color deep;

  /// Soft end — warm background washes, active indicators, chips.
  final Color soft;

  LinearGradient accentGradient(Brightness brightness) {
    final pairedEnd = brightness == Brightness.dark
        ? const Color(0xFF1A1917)
        : const Color(0xFFF3F0EE);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [deep, Color.alphaBlend(deep.withOpacity(0.6), pairedEnd)],
    );
  }

  /// Mastercard-inspired warm accents (the first 3).
  static const mastercard = [ink, signal, clay];

  /// Professional accents.
  static const professional = [graphite, azure, violet, crimson, forest, amber];

  /// Friendly / pastel accents.
  static const friendly = [sakura, mint, mocha];

  static AppAccent fromName(String? name) {
    if (name == null) return AppAccent.ink;
    return AppAccent.values.firstWhere(
      (a) => a.name == name,
      orElse: () => AppAccent.ink,
    );
  }
}
