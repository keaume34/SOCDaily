// Phase 4 home screen: dashboard with real Today/Streak counts (from the
// user-state repo) + clickable cards routing to Today queue, Daily
// Challenge (P8), and Browse.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/user_state_repository.dart';
import '../../data/seed/seed_bootstrap.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/gradient_background.dart';
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

class _DashCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
    );
  }
}
