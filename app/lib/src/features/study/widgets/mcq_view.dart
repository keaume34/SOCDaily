// MCQ player widget: renders stem + options, supports single/multiple/T-F,
// reveals correctness and the rationale after the user submits.
//
// The widget is stateless from the caller's perspective: the parent passes
// (`question`, `options`, `selected`, `submitted`) and gets the user's
// selection back via `onChange`. State machine lives in the parent so the
// study session can persist answers + drive SM-2 (Phase 4).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/db/app_database.dart';

class McqView extends StatelessWidget {
  const McqView({
    required this.question,
    required this.options,
    required this.selected,
    required this.submitted,
    required this.onToggle,
    super.key,
  });

  final Question question;
  final List<QuestionOption> options;
  final Set<int> selected;
  final bool submitted;
  final void Function(int optionId) onToggle;

  bool get _isMultiple => question.qtype.toLowerCase() == 'multiple';
  bool get _isTrueFalse => question.qtype.toLowerCase() == 'truefalse';

  bool get isCorrect {
    final correctIds = options.where((o) => o.isCorrect).map((o) => o.id).toSet();
    return correctIds.length == selected.length &&
        correctIds.containsAll(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary
                    .withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isMultiple
                    ? 'MULTIPLE CHOICE'
                    : (_isTrueFalse ? 'TRUE / FALSE' : 'SINGLE CHOICE'),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                question.difficulty,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(question.stem, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              option: option,
              isSelected: selected.contains(option.id),
              submitted: submitted,
              isCorrectAnswer: option.isCorrect,
              onTap: submitted ? null : () => onToggle(option.id),
            ),
          ),
        if (submitted) ...[
          const SizedBox(height: 12),
          _ResultBanner(isCorrect: isCorrect),
          if (question.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.submitted,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  final QuestionOption option;
  final bool isSelected;
  final bool submitted;
  final bool isCorrectAnswer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    Color border = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);
    Color background = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.white.withOpacity(0.7);
    IconData icon = isSelected
        ? Icons.radio_button_checked
        : Icons.radio_button_off;
    Color iconColor = theme.colorScheme.onSurfaceVariant;

    if (submitted) {
      if (isCorrectAnswer) {
        border = const Color(0xFF10B981).withOpacity(0.3);
        background = const Color(0xFF10B981).withOpacity(isDark ? 0.1 : 0.06);
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF10B981);
      } else if (isSelected) {
        border = theme.colorScheme.error;
        background = theme.colorScheme.error.withOpacity(0.12);
        icon = Icons.cancel;
        iconColor = theme.colorScheme.error;
      }
    } else if (isSelected) {
      border = theme.colorScheme.primary;
      background = theme.colorScheme.primary.withOpacity(0.10);
      iconColor = theme.colorScheme.primary;
    }

    final tile = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                option.label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.content,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );

    // After submit, an option that was selected but is wrong shakes once.
    if (submitted && isSelected && !isCorrectAnswer) {
      return _ShakeOnce(child: tile);
    }
    return tile;
  }
}

class _ShakeOnce extends StatefulWidget {
  const _ShakeOnce({required this.child});
  final Widget child;
  @override
  State<_ShakeOnce> createState() => _ShakeOnceState();
}

class _ShakeOnceState extends State<_ShakeOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Decaying sine wiggle: 3 oscillations across 180ms, fades to 0.
        final t = _c.value;
        final dx = 6.0 * math.sin(t * math.pi * 6) * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

class _ResultBanner extends StatefulWidget {
  const _ResultBanner({required this.isCorrect});
  final bool isCorrect;

  @override
  State<_ResultBanner> createState() => _ResultBannerState();
}

class _ResultBannerState extends State<_ResultBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return FadeTransition(
      opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.1 : 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(isDark ? 0.2 : 0.15)),
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
              child: Icon(
                widget.isCorrect ? Icons.check_circle : Icons.error_outline,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.isCorrect ? 'Correct' : 'Not quite',
              style: theme.textTheme.titleSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
