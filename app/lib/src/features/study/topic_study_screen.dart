// Phase-2 placeholder: just shows topic title + counts. Phase 3 turns this
// into the flashcard + MCQ player.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/db/content_repository.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

final _topicProvider = FutureProvider.family<Topic?, int>((ref, id) async {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.topics)..where((t) => t.id.equals(id)))
      .getSingleOrNull();
});

class TopicStudyScreen extends ConsumerWidget {
  const TopicStudyScreen({required this.topicId, super.key});

  final int topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final topic = ref.watch(_topicProvider(topicId));
    final repo = ref.read(contentRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: topic.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('$e')),
            data: (t) {
              if (t == null) {
                return const Center(child: Text('Topic not found.'));
              }
              return FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  repo.listFlashcardsForTopic(t.id),
                  repo.listQuestionsForTopic(t.id),
                ]),
                builder: (context, snap) {
                  final cards =
                      (snap.data?[0] as List<Flashcard>?) ?? const [];
                  final questions =
                      (snap.data?[1] as List<Question>?) ?? const [];
                  return CustomScrollView(
                    slivers: [
                      SliverAppBar.medium(
                        title: Text(t.title),
                        pinned: true,
                        backgroundColor: Colors.transparent,
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList.list(
                          children: [
                            if (t.summary != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  t.summary!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            _CountTile(
                              icon: Icons.style,
                              title: 'Flashcards',
                              count: cards.length,
                              subtitle:
                                  'Front/back review with SM-2 (Phase 3).',
                            ),
                            const SizedBox(height: 12),
                            _CountTile(
                              icon: Icons.quiz_outlined,
                              title: 'Multiple-choice questions',
                              count: questions.length,
                              subtitle:
                                  'Single/multi/T-F with explanations (Phase 3).',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final int count;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
