// Reusable gradient surface backgrounds used across feature screens to give
// the app the "monochrome with a touch of accent" feel the user asked for.

import 'package:flutter/material.dart';

import 'app_accent.dart';

/// Subtle full-screen gradient: near-surface → near-surface with the accent
/// barely peeking through one corner. Designed to feel like a soft sheen,
/// not a colorful poster.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    required this.accent,
    required this.child,
    this.intensity = 0.12,
    super.key,
  });

  final AppAccent accent;
  final Widget child;

  /// 0 = pure monochrome, 1 = full accent. Default 0.12 keeps it professional.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final base = Theme.of(context).colorScheme.surface;
    final corner = Color.alphaBlend(
      accent.deep.withOpacity(intensity),
      base,
    );
    final far = brightness == Brightness.dark
        ? Color.alphaBlend(Colors.black.withOpacity(0.6), base)
        : Color.alphaBlend(Colors.white.withOpacity(0.5), base);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [corner, base, far],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// A pill-shaped chip with a soft monochrome-plus-accent gradient. Used for
/// streak counters, category badges, etc.
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
    final brightness = Theme.of(context).brightness;
    final base = brightness == Brightness.dark ? Colors.black : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(accent.deep.withOpacity(0.18), base),
            base,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.deep.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: accent.deep),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
