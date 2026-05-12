// Phase 8 — Cheatsheet. Table-style "everything front + back" view scoped
// to a chosen subject. Great for last-minute scanning before an exam.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../data/db/content_repository.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

class CheatsheetSubjectPickerScreen extends ConsumerWidget {
  const CheatsheetSubjectPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final subjects = ref.watch(subjectsProvider);
    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar.medium(
                title: Text('Cheatsheet'),
                pinned: true,
                backgroundColor: Colors.transparent,
              ),
              subjects.when(
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SliverToBoxAdapter(child: Text('$e')),
                data: (rows) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList.list(
                    children: [
                      for (final s in rows)
                        Card(
                          child: ListTile(
                            title: Text(s.title),
                            subtitle: Text(s.code),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 14),
                            onTap: () =>
                                context.push('/cheatsheet/${s.id}'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _cheatsheetForSubjectProvider = FutureProvider.autoDispose
    .family<List<({Topic topic, List<Flashcard> flashcards})>, int>(
        (ref, subjectId) async {
  return ref
      .watch(contentRepositoryProvider)
      .cheatsheetForSubject(subjectId);
});

class CheatsheetScreen extends ConsumerWidget {
  const CheatsheetScreen({required this.subjectId, super.key});
  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final rows = ref.watch(_cheatsheetForSubjectProvider(subjectId));
    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar.medium(
                title: Text('Cheatsheet'),
                pinned: true,
                backgroundColor: Colors.transparent,
              ),
              rows.when(
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SliverToBoxAdapter(child: Text('$e')),
                data: (sections) {
                  if (sections.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No flashcards in this subject yet.'),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverList.list(
                      children: [
                        for (final section in sections) ...[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(4, 12, 4, 6),
                            child: Text(
                              section.topic.title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: _CheatsheetTable(
                                cards: section.flashcards),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheatsheetTable extends StatelessWidget {
  const _CheatsheetTable({required this.cards});
  final List<Flashcard> cards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.0),
        1: FlexColumnWidth(1.4),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      border: TableBorder.symmetric(
        inside: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          children: [
            _hdrCell(context, 'Term'),
            _hdrCell(context, 'Definition'),
          ],
        ),
        for (final c in cards)
          TableRow(
            children: [
              _cell(context, c.front, bold: true),
              _cell(context, c.back),
            ],
          ),
      ],
    );
  }

  Widget _hdrCell(BuildContext context, String s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        s.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 1.0,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _cell(BuildContext context, String s, {bool bold = false}) {
    final t = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        s,
        style: bold ? t?.copyWith(fontWeight: FontWeight.w600) : t,
      ),
    );
  }
}
