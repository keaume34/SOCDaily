// Flashcard widget: front/back with 3D flip animation, swipe-to-continue,
// and improved glass-card styling.

import 'dart:math' as math;

import 'package:flutter/material.dart';

class FlashcardView extends StatefulWidget {
  const FlashcardView({
    required this.front,
    required this.back,
    this.hint,
    this.tags = const [],
    this.onSwipeNext,
    super.key,
  });

  final String front;
  final String back;
  final String? hint;
  final List<String> tags;
  final VoidCallback? onSwipeNext;

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;
  bool _showingBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _angle = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.front != widget.front || oldWidget.back != widget.back) {
      _controller.value = 0;
      _showingBack = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _showingBack = !_showingBack);
    if (_showingBack) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300 &&
            widget.onSwipeNext != null) {
          widget.onSwipeNext!();
        }
      },
      child: AnimatedBuilder(
        animation: _angle,
        builder: (context, _) {
          final isFront = _angle.value <= math.pi / 2;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_angle.value);
          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: isFront
                ? _FlashcardFace(
                    label: 'FRONT',
                    text: widget.front,
                    hint: widget.hint,
                    tags: widget.tags,
                    isBack: false,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _FlashcardFace(
                      label: 'BACK',
                      text: widget.back,
                      tags: widget.tags,
                      isBack: true,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({
    required this.label,
    required this.text,
    required this.isBack,
    this.hint,
    this.tags = const [],
  });

  final String label;
  final String text;
  final String? hint;
  final List<String> tags;
  final bool isBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final bg = isBack
        ? (isDark
            ? primary.withOpacity(0.08)
            : primary.withOpacity(0.04))
        : (isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.8));

    final borderColor = isBack
        ? primary.withOpacity(isDark ? 0.2 : 0.12)
        : (isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05));

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBack
                      ? primary.withOpacity(isDark ? 0.12 : 0.08)
                      : (isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: isBack
                        ? primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              if (!isBack)
                Icon(
                  Icons.touch_app_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (hint != null && !isBack) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(isDark ? 0.1 : 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B)
                      .withOpacity(isDark ? 0.15 : 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hint!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#$t',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
