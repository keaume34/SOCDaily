// Phase 1 home screen: a welcoming dashboard placeholder. Subsequent phases
// fill it with today's review count, daily challenge card, streak ring, etc.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                    Wrap(
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
                          label: l10n.homeDueToday('0'),
                        ),
                      ],
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
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.bolt,
                    title: l10n.homeDailyChallenge,
                    subtitle: l10n.homeDailyChallengeSubtitle,
                  ),
                  const SizedBox(height: 12),
                  _DashCard(
                    icon: Icons.menu_book,
                    title: l10n.homeBrowse,
                    subtitle: l10n.homeBrowseSubtitle,
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
  });

  final IconData icon;
  final String title;
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
    );
  }
}
