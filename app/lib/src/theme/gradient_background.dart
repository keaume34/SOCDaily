// Reusable surface backgrounds for the Mastercard-inspired design system.
//
// Warm cream canvas (#F3F0EE), never sterile white. Surfaces use
// canvas cream → lifted cream → ink footer hierarchy.

import 'package:flutter/material.dart';

import 'app_accent.dart';
import 'app_theme.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    required this.accent,
    required this.child,
    this.intensity = 0.06,
    this.showOrbGlow = true,
    super.key,
  });

  final AppAccent accent;
  final Widget child;
  final double intensity;
  final bool showOrbGlow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark
          ? const Color(0xFF1A1917)
          : MCColors.canvasCream,
      child: child,
    );
  }
}

/// Accent chip — pill-shaped with eyebrow dot.
class AccentChip extends StatelessWidget {
  const AccentChip({
    required this.label,
    required this.accent,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final AppAccent accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? accent.soft.withOpacity(0.12)
            : accent.soft.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: accent.deep),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SofiaSans',
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.85)
                  : accent.deep,
              fontSize: 13,
              letterSpacing: -0.13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mastercard-style elevated card — atmospheric shadow, warm surface.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24.0,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : MCColors.liftedCream,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: child,
    );
  }
}
