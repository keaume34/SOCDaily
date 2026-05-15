// Reusable gradient surface backgrounds for the "Soft Styles" design system.
//
// Warm, creamy gradients with gentle accent washes. No harsh edges —
// everything feels soft and inviting.

import 'package:flutter/material.dart';

import 'app_accent.dart';

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
    final base = Theme.of(context).colorScheme.surface;

    final accentWash = Color.alphaBlend(
      accent.soft.withOpacity(isDark ? intensity * 0.5 : intensity),
      base,
    );
    final warmCorner = isDark
        ? Color.alphaBlend(
            const Color(0xFF1E1530).withOpacity(0.3), base)
        : Color.alphaBlend(
            const Color(0xFFFFF5EE).withOpacity(0.4), base);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentWash, base, warmCorner],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: showOrbGlow
          ? CustomPaint(
              painter: _SoftGlowPainter(
                color: accent.soft.withOpacity(isDark ? 0.04 : 0.06),
              ),
              child: child,
            )
          : child,
    );
  }
}

class _SoftGlowPainter extends CustomPainter {
  _SoftGlowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, -0.6),
        radius: 1.0,
        colors: [color, color.withOpacity(0)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_SoftGlowPainter old) => old.color != color;
}

/// Soft accent badge / chip.
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
            : accent.soft.withOpacity(0.45),
        borderRadius: BorderRadius.circular(50),
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
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.85)
                  : accent.deep,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft elevated card — uses subtle shadow instead of borders.
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
            : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : const Color(0xFFD4C9BE).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
