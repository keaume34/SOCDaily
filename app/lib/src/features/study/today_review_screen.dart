// Today's review queue: collects all flashcards whose nextReview is due
// (or which have never been reviewed) and plays them in a flashcard-only
// study session.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../data/db/user_state_repository.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';
import 'study_session_controller.dart';
import 'widgets/flashcard_view.dart';

class TodayReviewScreen extends ConsumerStatefulWidget {
  const TodayReviewScreen({super.key});

  @override
  ConsumerState<TodayReviewScreen> createState() =>
      _TodayReviewScreenState();
}

class _TodayReviewScreenState extends ConsumerState<TodayReviewScreen> {
  int _index = 0;
  final Map<int, CardRating> _ratings = {};

  Future<void> _onRate(Flashcard card, CardRating rating) async {
    await ref
        .read(userStateRepositoryProvider)
        .recordFlashcardRating(card.id, rating);
    if (!mounted) return;
    setState(() {
      _ratings[card.id] = rating;
      _index += 1;
    });
    ref.invalidate(dueCountsProvider);
    ref.invalidate(dueFlashcardsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final due = ref.watch(dueFlashcardsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: due.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('$e')),
            data: (cards) {
              if (cards.isEmpty) {
                return _EmptyState();
              }
              if (_index >= cards.length) {
                return _AllCaughtUp(
                  total: cards.length,
                  good: _ratings.values
                      .where((r) =>
                          r == CardRating.good || r == CardRating.easy)
                      .length,
                );
              }
              final card = cards[_index];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => context.pop(),
                        ),
                        const Spacer(),
                        Text(
                          '${_index + 1} / ${cards.length}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _index / cards.length,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FlashcardView(
                        key: ValueKey(card.id),
                        front: card.front,
                        back: card.back,
                        hint: card.hint,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: _RatingRow(
                      onRate: (r) => _onRate(card, r),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration,
              size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'Nothing due right now.',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Browse a topic to schedule new cards.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.menu_book),
            label: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp({required this.total, required this.good});
  final int total;
  final int good;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt,
              size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text('Today\'s queue cleared',
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '$good / $total cards rated Good or Easy.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.onRate});
  final void Function(CardRating) onRate;

  @override
  Widget build(BuildContext context) {
    final items = [
      (CardRating.again, 'Again', Colors.red.shade400),
      (CardRating.hard, 'Hard', Colors.orange.shade400),
      (CardRating.good, 'Good', Colors.green.shade400),
      (CardRating.easy, 'Easy', Colors.blue.shade400),
    ];
    return Row(
      children: [
        for (final (rating, label, color) in items) ...[
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.6)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => onRate(rating),
              child: Text(label),
            ),
          ),
          if (rating != CardRating.easy) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
