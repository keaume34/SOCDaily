// Flashcard widget: front/back with 3D flip, Mastercard-style stadium cards.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

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

    final bg = isBack
        ? (isDark ? const Color(0xFF222220) : MCColors.liftedCream)
        : (isDark ? const Color(0xFF1A1917) : Colors.white);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isBack
                      ? MCColors.lightSignalOrange
                      : MCColors.slateGray,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 0.56,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isBack
                      ? MCColors.lightSignalOrange
                      : MCColors.slateGray,
                ),
              ),
              const Spacer(),
              if (!isBack)
                Icon(
                  Icons.touch_app_rounded,
                  size: 18,
                  color: MCColors.dustTaupe,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    letterSpacing: -0.44,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (hint != null && !isBack) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: MCColors.signalOrange.withOpacity(isDark ? 0.08 : 0.05),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    size: 16,
                    color: MCColors.signalOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hint!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MCColors.slateGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : MCColors.canvasCream,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '#$t',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: MCColors.slateGray,
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
