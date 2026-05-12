// MCQ player widget: renders stem + options, supports single/multiple/T-F,
// reveals correctness and the rationale after the user submits.
//
// The widget is stateless from the caller's perspective: the parent passes
// (`question`, `options`, `selected`, `submitted`) and gets the user's
// selection back via `onChange`. State machine lives in the parent so the
// study session can persist answers + drive SM-2 (Phase 4).

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
            Text(
              _isMultiple
                  ? 'MULTIPLE CHOICE'
                  : (_isTrueFalse ? 'TRUE / FALSE' : 'SINGLE CHOICE'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.3,
              ),
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.6),
                borderRadius: BorderRadius.circular(999),
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
                color: theme.colorScheme.secondaryContainer
                    .withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
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

    Color border = theme.colorScheme.outlineVariant.withOpacity(0.6);
    Color background =
        theme.colorScheme.surfaceContainerHighest.withOpacity(0.4);
    IconData icon = isSelected
        ? Icons.radio_button_checked
        : Icons.radio_button_off;
    Color iconColor = theme.colorScheme.onSurfaceVariant;

    if (submitted) {
      if (isCorrectAnswer) {
        border = Colors.green.shade400;
        background = Colors.green.withOpacity(0.12);
        icon = Icons.check_circle;
        iconColor = Colors.green.shade600;
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

    return InkWell(
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
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.isCorrect});
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? Colors.green.shade600 : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.celebration : Icons.error_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isCorrect ? 'Correct' : 'Not quite',
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
