// Bookmarks screen: shows every bookmarked flashcard + question with quick
// previews. Tapping navigates to the parent topic study screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../data/db/content_repository.dart';
import '../../data/db/user_state_repository.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

/// Batch-loads preview text for all bookmarks in just 2 queries
/// (flashcards + questions) instead of N individual queries.
final _bookmarkPreviewsProvider = FutureProvider.autoDispose
    .family<Map<String, String>, List<UserBookmark>>((ref, bookmarks) async {
  if (bookmarks.isEmpty) return const {};
  final db = ref.read(appDatabaseProvider);
  final fcIds = <int>[];
  final qIds = <int>[];
  for (final b in bookmarks) {
    if (b.itemKind == 'flashcard') {
      fcIds.add(b.itemId);
    } else {
      qIds.add(b.itemId);
    }
  }
  final results = await Future.wait([
    fcIds.isEmpty
        ? Future.value(<Flashcard>[])
        : (db.select(db.flashcards)..where((f) => f.id.isIn(fcIds))).get(),
    qIds.isEmpty
        ? Future.value(<Question>[])
        : (db.select(db.questions)..where((q) => q.id.isIn(qIds))).get(),
  ]);
  final map = <String, String>{};
  for (final f in results[0] as List<Flashcard>) {
    map['flashcard/${f.id}'] = f.front;
  }
  for (final q in results[1] as List<Question>) {
    map['question/${q.id}'] = q.stem;
  }
  return map;
});

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      'Bookmarks',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bookmarks.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('$e')),
                  data: (rows) {
                    if (rows.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No bookmarks yet.',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap the bookmark icon on any flashcard or question to save it here.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final previews = ref.watch(
                        _bookmarkPreviewsProvider(rows));
                    final previewMap = previews.valueOrNull ?? const {};
                    return ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: rows.length,
                      itemBuilder: (context, i) => _BookmarkTile(
                        bookmark: rows[i],
                        preview: previewMap[
                            '${rows[i].itemKind}/${rows[i].itemId}'],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  const _BookmarkTile({required this.bookmark, this.preview});
  final UserBookmark bookmark;
  final String? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(
          bookmark.itemKind == 'flashcard'
              ? Icons.style
              : Icons.quiz_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(preview ?? 'Loading…', maxLines: 2),
        subtitle: Text(
          bookmark.itemKind.toUpperCase(),
          style: theme.textTheme.labelSmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remove bookmark',
          onPressed: () async {
            await ref
                .read(userStateRepositoryProvider)
                .toggleBookmark(bookmark.itemKind, bookmark.itemId);
            ref.invalidate(bookmarksProvider);
          },
        ),
      ),
    );
  }
}
