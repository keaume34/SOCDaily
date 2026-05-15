// Phase 8 — Daily Challenge screen. Same item set on every device for a
// given UTC day (deterministic Fisher-Yates seeded by yyyymmdd). Runs the
// player against a mixed list of flashcards and MCQs without touching the
// per-topic study session controller.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/content_repository.dart';
import '../../data/db/user_state_repository.dart';
import '../../mascot/mascot_widget.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';
import '../study/study_session_controller.dart';
import '../study/widgets/flashcard_view.dart';
import '../study/widgets/mcq_view.dart';

final _dailyItemsProvider =
    FutureProvider.autoDispose<List<StudyItem>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  final picked = await repo.dailyChallenge();
  final items = <StudyItem>[
    for (final c in picked.flashcards) FlashcardItem(c),
  ];
  for (final q in picked.questions) {
    final opts = await repo.listOptionsForQuestion(q.id);
    items.add(QuestionItem(q, opts));
  }
  return items;
});

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  int _index = 0;
  final Set<int> _selectedOptions = {};
  bool _submitted = false;
  final Map<int, CardRating> _ratings = {};
  final Map<int, bool> _results = {};

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final items = ref.watch(_dailyItemsProvider);
    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: items.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('$e')),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                    child: Text('No daily challenge yet — load some content.'));
              }
              return _buildPlayer(context, items);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, List<StudyItem> items) {
    final theme = Theme.of(context);
    final isDone = _index >= items.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => context.pop(),
                tooltip: 'Exit',
              ),
              const Spacer(),
              Text(
                isDone ? 'Done' : '${_index + 1} / ${items.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: items.isEmpty ? 0 : (_index / items.length).clamp(0.0, 1.0),
          minHeight: 3,
          backgroundColor: theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        Expanded(
          child: isDone
              ? _DailyResult(
                  total: items.length,
                  correct: _results.values.where((v) => v).length,
                  asked: _results.length,
                  cardsRated: _ratings.length,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: _renderItem(items),
                ),
        ),
      ],
    );
  }

  Widget _renderItem(List<StudyItem> items) {
    final item = items[_index];
    if (item is FlashcardItem) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Badge(label: 'FLASHCARD'),
          const SizedBox(height: 12),
          Expanded(
            child: FlashcardView(
              front: item.card.front,
              back: item.card.back,
              hint: item.card.hint,
              onSwipeNext: _next,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final r in CardRating.values)
                FilledButton(
                  onPressed: () async {
                    final c = item.card.id;
                    await ref
                        .read(userStateRepositoryProvider)
                        .recordFlashcardRating(c, r);
                    setState(() {
                      _ratings[c] = r;
                    });
                    _next();
                  },
                  child: Text(_label(r)),
                ),
            ],
          ),
        ],
      );
    }
    final q = item as QuestionItem;
    final multiple = q.question.qtype.toLowerCase() == 'multiple';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Badge(label: 'QUESTION'),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: McqView(
              question: q.question,
              options: q.options,
              selected: _selectedOptions,
              submitted: _submitted,
              onToggle: (id) => _toggle(id, multiple),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_submitted)
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  onPressed: _next,
                ),
              )
            else
              Expanded(
                child: FilledButton(
                  onPressed: _selectedOptions.isEmpty
                      ? null
                      : () => _submit(q),
                  child: const Text('Submit'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _label(CardRating r) {
    switch (r) {
      case CardRating.again:
        return 'Again';
      case CardRating.hard:
        return 'Hard';
      case CardRating.good:
        return 'Good';
      case CardRating.easy:
        return 'Easy';
    }
  }

  void _toggle(int id, bool multiple) {
    if (_submitted) return;
    setState(() {
      if (multiple) {
        if (!_selectedOptions.add(id)) _selectedOptions.remove(id);
      } else {
        _selectedOptions
          ..clear()
          ..add(id);
      }
    });
  }

  Future<void> _submit(QuestionItem q) async {
    final correctIds =
        q.options.where((o) => o.isCorrect).map((o) => o.id).toSet();
    final wasCorrect = correctIds.length == _selectedOptions.length &&
        correctIds.containsAll(_selectedOptions);
    await ref.read(userStateRepositoryProvider).recordQuestionAttempt(
          q.question.id,
          wasCorrect: wasCorrect,
          choice: (_selectedOptions.toList()..sort()).join(','),
        );
    setState(() {
      _submitted = true;
      _results[q.question.id] = wasCorrect;
    });
  }

  void _next() {
    setState(() {
      _index += 1;
      _selectedOptions.clear();
      _submitted = false;
    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _DailyResult extends StatelessWidget {
  const _DailyResult({
    required this.total,
    required this.correct,
    required this.asked,
    required this.cardsRated,
  });
  final int total;
  final int correct;
  final int asked;
  final int cardsRated;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = asked == 0 ? 0 : ((correct / asked) * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MascotWidget(mood: OttoMood.correct, size: 100),
            const SizedBox(height: 8),
            Icon(Icons.emoji_events_outlined,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('Daily challenge complete',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Total: $total · MCQ: $correct / $asked ($pct%) · Cards: $cardsRated',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}
