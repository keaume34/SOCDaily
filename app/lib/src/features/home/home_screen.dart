// Phase 4 home screen: dashboard with real Today/Streak counts (from the
// user-state repo) + clickable cards routing to Today queue, Daily
// Challenge (P8), and Browse.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/user_state_repository.dart';
import '../../data/db/weakness_scorer.dart';
import '../../data/seed/seed_bootstrap.dart';
import '../../widgets/tap_bounce.dart';
import '../../l10n/app_localizations.dart';
import '../../mascot/mascot_widget.dart';
import '../../theme/gradient_background.dart';
import '../generate/generate_screen.dart';
import '../settings/settings_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final seed = ref.watch(seedBootstrapProvider);
    final counts = ref.watch(dueCountsProvider);

    return GradientBackground(
      accent: settings.accent,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.homeGreeting,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.appName,
                                style: theme.textTheme.displayMedium,
                              ),
                            ],
                          ),
                        ),
                        const MascotWidget(mood: OttoMood.neutral, size: 64),
                      ],
                    ),
                    const SizedBox(height: 12),
                    seed.when(
                      loading: () => const SizedBox(height: 4),
                      error: (e, st) =>
                          Text('Seed import failed: $e'),
                      data: (_) => counts.when(
                        loading: () =>
                            const LinearProgressIndicator(minHeight: 2),
                        error: (e, st) => Text('$e'),
                        data: (c) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AccentChip(
                              accent: settings.accent,
                              icon: Icons.local_fire_department,
                              label: l10n.homeStreak('0'),
                            ),
                            AccentChip(
                              accent: settings.accent,
                              icon: Icons.timelapse,
                              label: l10n.homeDueToday('${c.due}'),
                            ),
                            AccentChip(
                              accent: settings.accent,
                              icon: Icons.style,
                              label: '${c.newCount} new',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.list(
                children: [
                  const _WeakTopicsSection(),
                  _DashCard(
                    icon: Icons.school,
                    title: l10n.homeStartSession,
                    subtitle: l10n.homeStartSessionSubtitle,
                    onTap: () => context.push('/study/today'),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.bolt,
                    title: l10n.homeDailyChallenge,
                    subtitle: l10n.homeDailyChallengeSubtitle,
                    onTap: () => context.push('/daily'),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.timer_outlined,
                    title: 'Mock exam',
                    subtitle: 'Timed random MCQs — practice under pressure.',
                    onTap: () => context.push('/quiz'),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.table_chart_outlined,
                    title: 'Cheatsheet',
                    subtitle: 'Table view of all flashcards by subject.',
                    onTap: () => context.push('/cheatsheet'),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.av_timer,
                    title: 'Pomodoro',
                    subtitle: 'Focus / break cycles while you study.',
                    onTap: () => context.push('/pomodoro'),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Certificate',
                    subtitle: 'Generate a printable study certificate.',
                    onTap: () => context.push('/certificate'),
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.menu_book,
                    title: l10n.homeBrowse,
                    subtitle: l10n.homeBrowseSubtitle,
                    onTap: () => context.go('/browse'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends ConsumerWidget {
  const _DashCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = ref.watch(settingsControllerProvider).accent;
    return TapBounce(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.soft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent.deep),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeakTopicsSection extends ConsumerWidget {
  const _WeakTopicsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = ref.watch(settingsControllerProvider).accent;
    final weakAsync = ref.watch(topWeakTopicsProvider);

    return weakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (rows) {
        if (rows.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(
                  children: [
                    Icon(Icons.trending_down,
                        size: 18, color: accent.deep),
                    const SizedBox(width: 6),
                    Text(
                      'Weak areas',
                      style: theme.textTheme.titleSmall?.copyWith(
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Top ${rows.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              for (final entry in rows) ...[
                _WeakTopicCard(entry: entry),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

class _WeakTopicCard extends ConsumerWidget {
  const _WeakTopicCard({required this.entry});

  final WeaknessEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = ref.watch(settingsControllerProvider).accent;
    final acc = entry.mcqAccuracy;
    final reasonBits = <String>[
      if (acc != null) '${(acc * 100).toStringAsFixed(0)}% MCQ',
      if (entry.dueRatio > 0)
        '${(entry.dueRatio * 100).toStringAsFixed(0)}% due',
      if (entry.avgEase != null)
        'ease ${entry.avgEase!.toStringAsFixed(2)}',
    ];
    final reason = reasonBits.isEmpty
        ? 'Not enough data yet — try a session.'
        : reasonBits.join('  ·  ');

    return TapBounce(
      onTap: () => _practice(context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _practice(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.soft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.priority_high, color: accent.deep),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.topic.title,
                          style: theme.textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.subject.title} · ${entry.chapter.title}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reason,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.auto_awesome_outlined,
                    color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _practice(BuildContext context) {
    context.push(
      '/generate',
      extra: GeneratePrefill(
        subjectCode: entry.subject.code,
        subjectTitle: entry.subject.title,
        chapterCode: entry.chapter.code,
        chapterTitle: entry.chapter.title,
        topicCode: entry.topic.code,
        topicTitle: entry.topic.title,
        lockTopic: true,
        nQuestions: 8,
      ),
    );
  }
}
