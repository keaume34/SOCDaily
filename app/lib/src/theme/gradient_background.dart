// Reusable gradient surface backgrounds for the "Cute Sentinel" design system.
//
// Layered gradients create depth without heaviness: a subtle accent glow in
// one corner, a cool/warm wash in the opposite, and neutral in between.

import 'package:flutter/material.dart';

import 'app_accent.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    required this.accent,
    required this.child,
    this.intensity = 0.08,
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
    final base = Theme.of(context).colorScheme.surface;

    final accentGlow = Color.alphaBlend(
      accent.deep.withOpacity(isDark ? intensity * 0.6 : intensity),
      base,
    );
    final warmCorner = isDark
        ? Color.alphaBlend(
            const Color(0xFF1A1520).withOpacity(0.4), base)
        : Color.alphaBlend(
            const Color(0xFFF5F0FF).withOpacity(0.3), base);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentGlow, base, warmCorner],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: showOrbGlow
          ? CustomPaint(
              painter: _OrbGlowPainter(
                color: accent.deep.withOpacity(isDark ? 0.03 : 0.04),
              ),
              child: child,
            )
          : child,
    );
  }
}

class _OrbGlowPainter extends CustomPainter {
  _OrbGlowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, -0.5),
        radius: 0.8,
        colors: [color, color.withOpacity(0)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_OrbGlowPainter old) => old.color != color;
}

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? accent.deep.withOpacity(0.12)
            : accent.soft.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.deep.withOpacity(isDark ? 0.2 : 0.15),
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
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : accent.deep,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// A frosted-glass container for elevated content sections.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20.0,
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
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
