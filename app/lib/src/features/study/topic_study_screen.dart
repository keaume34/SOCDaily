// Real Phase-3 study player. Walks the user through the topic's flashcards
// first (front → flip → grade) then the MCQs (select → submit → review).
// Phase 4 will persist results to the user-state tables and feed SM-2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/tutor_sheet.dart';
import '../../data/db/app_database.dart';
import '../../data/db/content_repository.dart';
import '../../data/db/user_state_repository.dart';
import '../../pdf/pdf_source_config.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';
import 'study_session_controller.dart';
import 'widgets/flashcard_view.dart';
import 'widgets/mcq_view.dart';

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
    final session = ref.watch(studySessionControllerProvider(topicId));

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
              return session.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('$e')),
                data: (s) => _SessionView(
                  topic: t,
                  state: s,
                  topicId: topicId,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SessionView extends ConsumerWidget {
  const _SessionView({
    required this.topic,
    required this.state,
    required this.topicId,
  });

  final Topic topic;
  final StudySessionState state;
  final int topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller =
        ref.read(studySessionControllerProvider(topicId).notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
                tooltip: 'Exit session',
              ),
              const Spacer(),
              Text(
                state.isDone
                    ? 'Done'
                    : '${state.index + 1} / ${state.items.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        _ProgressBar(state: state),
        Expanded(
          child: state.isDone
              ? _DoneView(state: state, onRestart: controller.restart)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: _CurrentItem(
                    state: state,
                    topicId: topicId,
                    topic: topic,
                  ),
                ),
        ),
      ],
    );
  }
}

class _CurrentItem extends ConsumerWidget {
  const _CurrentItem({
    required this.state,
    required this.topicId,
    required this.topic,
  });

  final StudySessionState state;
  final int topicId;
  final Topic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(studySessionControllerProvider(topicId).notifier);
    final item = state.current;
    if (item == null) return const SizedBox.shrink();

    if (item is FlashcardItem) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _StepBadge(text: 'FLASHCARD'),
              const Spacer(),
              ItemActions(kind: 'flashcard', id: item.card.id),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FlashcardView(
              front: item.card.front,
              back: item.card.back,
              hint: item.card.hint,
              onSwipeNext: controller.next,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Explain deeper'),
            onPressed: () => TutorSheet.show(
              context,
              title: 'Explain deeper',
              task: (svc) => svc.explainDeeper(
                card: item.card,
                topic: topic.title,
              ),
            ),
          ),
          OpenSourceButton(
            topicId: topicId,
            sourceId: item.card.sourceId,
            sourcePage: item.card.sourcePage,
          ),
          const SizedBox(height: 12),
          _CardRatingBar(
            onRate: controller.rateFlashcard,
          ),
        ],
      );
    }

    final q = item as QuestionItem;
    final isMultiple = q.question.qtype.toLowerCase() == 'multiple';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _StepBadge(text: 'QUESTION'),
            const Spacer(),
            ItemActions(kind: 'question', id: q.question.id),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: McqView(
              question: q.question,
              options: q.options,
              selected: state.selectedOptions,
              submitted: state.submitted,
              onToggle: (id) =>
                  controller.toggleOption(id, multiple: isMultiple),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (state.submitted &&
            state.questionResults[q.question.id] == false)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _GlowingWhyWrongButton(
              onPressed: () => TutorSheet.show(
                context,
                title: 'Why was I wrong?',
                task: (svc) => svc.whyWrong(
                  question: q.question,
                  options: q.options,
                  chosenIds: state.selectedOptions,
                ),
              ),
            ),
          ),
        if (state.submitted)
          OpenSourceButton(
            topicId: topicId,
            sourceId: q.question.sourceId,
            sourcePage: q.question.sourcePage,
          ),
        Row(
          children: [
            if (state.submitted)
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  onPressed: controller.next,
                ),
              )
            else
              Expanded(
                child: FilledButton(
                  onPressed: state.selectedOptions.isEmpty
                      ? null
                      : controller.submitQuestion,
                  child: const Text('Submit'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ItemActions extends ConsumerWidget {
  const ItemActions({required this.kind, required this.id, super.key});
  final String kind;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (kind: kind, id: id);
    final bookmarked = ref.watch(isBookmarkedProvider(key));
    final notes = ref.watch(notesForItemProvider(key));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Bookmark',
          icon: Icon(
            bookmarked.maybeWhen(
              data: (v) => v ? Icons.bookmark : Icons.bookmark_border,
              orElse: () => Icons.bookmark_border,
            ),
          ),
          onPressed: () async {
            await ref
                .read(userStateRepositoryProvider)
                .toggleBookmark(kind, id);
            ref.invalidate(isBookmarkedProvider(key));
            ref.invalidate(bookmarksProvider);
          },
        ),
        IconButton(
          tooltip: 'Notes',
          icon: Badge.count(
            count: notes.maybeWhen(
              data: (rows) => rows.length,
              orElse: () => 0,
            ),
            isLabelVisible: notes.maybeWhen(
              data: (rows) => rows.isNotEmpty,
              orElse: () => false,
            ),
            child: const Icon(Icons.notes_outlined),
          ),
          onPressed: () => _openNotesSheet(context, ref, kind, id),
        ),
      ],
    );
  }

  Future<void> _openNotesSheet(
      BuildContext context, WidgetRef ref, String kind, int id) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => NotesSheet(kind: kind, id: id),
    );
  }
}

class NotesSheet extends ConsumerStatefulWidget {
  const NotesSheet({required this.kind, required this.id, super.key});
  final String kind;
  final int id;

  @override
  ConsumerState<NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends ConsumerState<NotesSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = (kind: widget.kind, id: widget.id);
    final notes = ref.watch(notesForItemProvider(key));
    final theme = Theme.of(context);
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + insets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your notes', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: notes.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('$e'),
              data: (rows) {
                if (rows.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No notes yet. Capture your own commentary, mnemonics, or links to playbooks.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final note = rows[i];
                    return ListTile(
                      title: Text(note.body),
                      subtitle: Text(
                        _format(note.createdAt),
                        style: theme.textTheme.labelSmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref
                              .read(userStateRepositoryProvider)
                              .deleteNote(note.id);
                          ref.invalidate(notesForItemProvider(key));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add a note…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final body = _controller.text.trim();
              if (body.isEmpty) return;
              await ref
                  .read(userStateRepositoryProvider)
                  .addNote(widget.kind, widget.id, body);
              _controller.clear();
              ref.invalidate(notesForItemProvider(key));
            },
            icon: const Icon(Icons.add),
            label: const Text('Save note'),
          ),
        ],
      ),
    );
  }

  String _format(DateTime t) {
    return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.text});
  final String text;

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
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.3,
          ),
        ),
      ),
    );
  }
}

class _CardRatingBar extends StatelessWidget {
  const _CardRatingBar({required this.onRate});
  final void Function(CardRating) onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (CardRating.again, 'Again', Colors.red.shade400),
      (CardRating.hard, 'Hard', Colors.orange.shade400),
      (CardRating.good, 'Good', Colors.green.shade400),
      (CardRating.easy, 'Easy', Colors.blue.shade400),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How well did you know this?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
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
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.state});
  final StudySessionState state;

  @override
  Widget build(BuildContext context) {
    final total = state.items.length;
    final value = total == 0 ? 0.0 : state.index / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({required this.state, required this.onRestart});

  final StudySessionState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.celebration,
              size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'Session complete',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _StatRow(
            label: 'Flashcards graded',
            value: '${state.cardsSeen} / ${state.cardsTotal}',
          ),
          _StatRow(
            label: 'Questions answered',
            value:
                '${state.questionsAnswered} / ${state.questionsTotal}',
          ),
          _StatRow(
            label: 'Accuracy',
            value:
                '${(state.accuracy * 100).toStringAsFixed(0)}%  (${state.questionsCorrect}/${state.questionsAnswered})',
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Study again'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.menu_book),
            label: const Text('Back to browse'),
          ),
        ],
      ),
    );
  }
}

class OpenSourceButton extends ConsumerWidget {
  const OpenSourceButton({
    required this.topicId,
    required this.sourceId,
    required this.sourcePage,
    super.key,
  });

  final int topicId;
  final int? sourceId;
  final int? sourcePage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sourceId == null) return const SizedBox.shrink();
    final config = ref.watch(pdfSourceConfigProvider);
    if (!config.isConfigured) return const SizedBox.shrink();
    final query = <String, String>{
      'topicId': topicId.toString(),
      if (sourcePage != null) 'page': sourcePage!.toString(),
    };
    final uri = Uri(
      path: '/source/$sourceId',
      queryParameters: query.isEmpty ? null : query,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
        label: Text(sourcePage != null
            ? 'Open source page $sourcePage'
            : 'Open source PDF'),
        onPressed: () => context.push(uri.toString()),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _GlowingWhyWrongButton extends ConsumerStatefulWidget {
  const _GlowingWhyWrongButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  ConsumerState<_GlowingWhyWrongButton> createState() =>
      _GlowingWhyWrongButtonState();
}

class _GlowingWhyWrongButtonState
    extends ConsumerState<_GlowingWhyWrongButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    // ~3 pulses (1.4s each) then settle.
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _runPulses();
  }

  Future<void> _runPulses() async {
    for (var i = 0; i < 3; i++) {
      if (!mounted) return;
      await _c.forward(from: 0);
      if (!mounted) return;
      await _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final accent = settings.accent;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accent.deep.withOpacity(0.4 * t),
                blurRadius: 12 * t,
                spreadRadius: 2 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: OutlinedButton.icon(
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Why was I wrong?'),
        onPressed: widget.onPressed,
      ),
    );
  }
}
