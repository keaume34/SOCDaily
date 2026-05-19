// Browse: Subject -> Chapter -> Topic hierarchy with improved card design.

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../data/db/content_repository.dart';
import '../../data/seed/seed_bootstrap.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/gradient_background.dart';
import '../../widgets/tap_bounce.dart';
import '../settings/settings_controller.dart';

class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final l10n = AppLocalizations.of(context);
    final boot = ref.watch(seedBootstrapProvider);

    return GradientBackground(
      accent: settings.accent,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Text(l10n.navBrowse),
              pinned: true,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search',
                  onPressed: () => context.push('/search'),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border_rounded),
                  tooltip: 'Bookmarks',
                  onPressed: () => context.push('/bookmarks'),
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded),
                  tooltip: 'Generate more',
                  onPressed: () => context.push('/generate'),
                ),
                const SizedBox(width: 4),
              ],
            ),
            ...boot.when(
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, st) => [
                SliverFillRemaining(
                  child: Center(child: Text('$e')),
                ),
              ],
              data: (_) => [const _SubjectList()],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectList extends ConsumerWidget {
  const _SubjectList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    return subjects.when(
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) =>
          SliverFillRemaining(child: Center(child: Text('$e'))),
      data: (rows) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        sliver: SliverList.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final s = rows[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SubjectCard(subject: s),
            );
          },
        ),
      ),
    );
  }
}

class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = ref.watch(settingsControllerProvider).accent;

    return TapBounce(
      onTap: () => context.push('/browse/subject/${subject.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : MCColors.liftedCream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.push('/browse/subject/${subject.id}'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.deep.withOpacity(isDark ? 0.12 : 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.library_books_rounded,
                      color: accent.deep,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subject.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subject.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : MCColors.canvasCream,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : MCColors.inkBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectDetailScreen extends ConsumerWidget {
  const SubjectDetailScreen({required this.subjectId, super.key});

  final int subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final chapters = ref.watch(chaptersProvider(subjectId));
    final subjects = ref.watch(subjectsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = subjects.maybeWhen(
      data: (rows) {
        for (final s in rows) {
          if (s.id == subjectId) return s.title;
        }
        return '';
      },
      orElse: () => '',
    );

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                title: Text(title),
                pinned: true,
                backgroundColor: Colors.transparent,
              ),
              chapters.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SliverFillRemaining(
                    child: Center(child: Text('$e'))),
                data: (rows) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final c = rows[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TapBounce(
                          onTap: () => context.push('/browse/chapter/${c.id}'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : MCColors.liftedCream,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      isDark ? 0.12 : 0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () =>
                                    context.push('/browse/chapter/${c.id}'),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: MCColors.linkBlue
                                              .withOpacity(
                                                  isDark ? 0.12 : 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.folder_rounded,
                                          color: MCColors.linkBlue,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          c.title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.06)
                                              : MCColors.canvasCream,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.4)
                                              : MCColors.inkBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class ChapterDetailScreen extends ConsumerWidget {
  const ChapterDetailScreen({required this.chapterId, super.key});

  final int chapterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final topicsAsync = ref.watch(topicsProvider(chapterId));
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar.medium(
                title: Text('Topics'),
                pinned: true,
                backgroundColor: Colors.transparent,
              ),
              topicsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) =>
                    SliverFillRemaining(child: Center(child: Text('$e'))),
                data: (rows) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final t = rows[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TopicCard(topic: t, theme: theme),
                      );
                    },
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

class _TopicCard extends ConsumerWidget {
  const _TopicCard({required this.topic, required this.theme});

  final Topic topic;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final isDark = theme.brightness == Brightness.dark;

    return TapBounce(
      onTap: () => context.push('/study/topic/${topic.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : MCColors.liftedCream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.push('/study/topic/${topic.id}'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF047857)
                              .withOpacity(isDark ? 0.12 : 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.article_rounded,
                          color: Color(0xFF047857),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          topic.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : MCColors.canvasCream,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: isDark
                              ? Colors.white.withOpacity(0.4)
                              : MCColors.inkBlack,
                        ),
                      ),
                    ],
                  ),
                  if (topic.summary != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      topic.summary!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, Object?>>>(
                    future: db
                        .customSelect(
                          'SELECT '
                          '(SELECT COUNT(*) FROM flashcards WHERE topic_id = ?1) AS f, '
                          '(SELECT COUNT(*) FROM questions WHERE topic_id = ?1) AS q',
                          variables: [Variable<int>(topic.id)],
                        )
                        .map((r) => r.data)
                        .get(),
                    builder: (context, snap) {
                      final f = snap.data?.first['f'] as int? ?? 0;
                      final q = snap.data?.first['q'] as int? ?? 0;
                      return Row(
                        children: [
                          _Pill(
                            icon: Icons.style_rounded,
                            label: '$f cards',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _Pill(
                            icon: Icons.quiz_rounded,
                            label: '$q questions',
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
        ],
      ),
    );
  }
}
