// Accent palette for the SOCDaily gradient theme system.
//
// The user wanted a monochrome (black ↔ white) gradient look as the default
// but with selectable accents that blend with white or black to produce a
// professional but distinct vibe. This enum captures the supported choices.

import 'package:flutter/material.dart';

enum AppAccent {
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

  /// Human-readable label (English; the picker translates via [AppLocalizations]).
  final String label;

  /// Strong end of the accent gradient — pairs with white on light surfaces
  /// and with off-black on dark surfaces.
  final Color deep;

  /// Soft end of the accent gradient — kept very close to white/grey so
  /// surfaces still feel professional rather than playful.
  final Color soft;

  /// Convenience: gradient appropriate for a button or focus ring on the
  /// given [brightness].
  LinearGradient accentGradient(Brightness brightness) {
    final pairedEnd = brightness == Brightness.dark
        ? const Color(0xFF0B0F14)
        : Colors.white;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [deep, Color.alphaBlend(deep.withOpacity(0.6), pairedEnd)],
    );
  }

  /// Professional accents (the original 6).
  static const professional = [graphite, azure, violet, crimson, forest, amber];

  /// Friendly / pastel accents (the 3 new additions).
  static const friendly = [sakura, mint, mocha];

  static AppAccent fromName(String? name) {
    if (name == null) return AppAccent.graphite;
    return AppAccent.values.firstWhere(
      (a) => a.name == name,
      orElse: () => AppAccent.graphite,
    );
  }
}
