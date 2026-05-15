// Home screen: dashboard with hero greeting, stat chips, feature grid,
// and weak-areas section. "Soft Styles" — rounded, warm, shadow-based.

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
    final isDark = theme.brightness == Brightness.dark;
    final seed = ref.watch(seedBootstrapProvider);
    final counts = ref.watch(dueCountsProvider);
    final accent = settings.accent;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600;

    return GradientBackground(
      accent: accent,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Hero greeting ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 32 : 20, isWide ? 32 : 20, isWide ? 32 : 20, 0),
                child: _HeroSection(
                  accent: accent,
                  isDark: isDark,
                  l10n: l10n,
                  theme: theme,
                ),
              ),
            ),

            // ── Stats row ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 32 : 20, 16, isWide ? 32 : 20, 0),
                child: seed.when(
                  loading: () => const SizedBox(height: 4),
                  error: (e, st) => Text('Seed import failed: $e'),
                  data: (_) => counts.when(
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (e, st) => Text('$e'),
                    data: (c) => _StatsRow(
                      accent: accent,
                      isDark: isDark,
                      dueCount: c.due,
                      newCount: c.newCount,
                    ),
                  ),
                ),
              ),
            ),

            // ── Weak areas ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 32 : 20, 20, isWide ? 32 : 20, 0),
                child: const _WeakTopicsSection(),
              ),
            ),

            // ── Feature grid ──
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 32 : 20, 20, isWide ? 32 : 20, 32),
              sliver: _FeatureGrid(
                isWide: isWide,
                accent: accent,
                isDark: isDark,
                l10n: l10n,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero section with greeting + mascot ──
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.accent,
    required this.isDark,
    required this.l10n,
    required this.theme,
  });

  final dynamic accent;
  final bool isDark;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  accent.deep.withOpacity(0.15),
                  accent.deep.withOpacity(0.05),
                ]
              : [
                  accent.soft.withOpacity(0.5),
                  accent.soft.withOpacity(0.15),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? accent.deep.withOpacity(0.15)
                : accent.soft.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your SOC learning companion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const MascotWidget(mood: OttoMood.neutral, size: 72),
        ],
      ),
    );
  }
}

// ── Stats row with animated chips ──
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.accent,
    required this.isDark,
    required this.dueCount,
    required this.newCount,
  });

  final dynamic accent;
  final bool isDark;
  final int dueCount;
  final int newCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '0',
            color: const Color(0xFFEF4444),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.timelapse_rounded,
            label: 'Due today',
            value: '$dueCount',
            color: accent.deep,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.auto_awesome_rounded,
            label: 'New',
            value: '$newCount',
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? color.withOpacity(0.08)
            : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature grid ──
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({
    required this.isWide,
    required this.accent,
    required this.isDark,
    required this.l10n,
  });

  final bool isWide;
  final dynamic accent;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = _featureItems(context, l10n);

    if (isWide) {
      return SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.8,
        children: items,
      );
    }

    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => items[i],
    );
  }

  List<Widget> _featureItems(BuildContext context, AppLocalizations l10n) {
    return [
      _FeatureCard(
        icon: Icons.school_rounded,
        title: l10n.homeStartSession,
        subtitle: l10n.homeStartSessionSubtitle,
        accentColor: const Color(0xFF3B82F6),
        isDark: isDark,
        onTap: () => context.push('/study/today'),
      ),
      _FeatureCard(
        icon: Icons.bolt_rounded,
        title: l10n.homeDailyChallenge,
        subtitle: l10n.homeDailyChallengeSubtitle,
        accentColor: const Color(0xFFF59E0B),
        isDark: isDark,
        onTap: () => context.push('/daily'),
      ),
      _FeatureCard(
        icon: Icons.timer_rounded,
        title: 'Mock exam',
        subtitle: 'Timed random MCQs — practice under pressure.',
        accentColor: const Color(0xFFEF4444),
        isDark: isDark,
        onTap: () => context.push('/quiz'),
      ),
      _FeatureCard(
        icon: Icons.table_chart_rounded,
        title: 'Cheatsheet',
        subtitle: 'Table view of all flashcards by subject.',
        accentColor: const Color(0xFF10B981),
        isDark: isDark,
        onTap: () => context.push('/cheatsheet'),
      ),
      _FeatureCard(
        icon: Icons.av_timer_rounded,
        title: 'Pomodoro',
        subtitle: 'Focus / break cycles while you study.',
        accentColor: const Color(0xFF8B5CF6),
        isDark: isDark,
        onTap: () => context.push('/pomodoro'),
      ),
      _FeatureCard(
        icon: Icons.workspace_premium_rounded,
        title: 'Certificate',
        subtitle: 'Generate a printable study certificate.',
        accentColor: const Color(0xFF06B6D4),
        isDark: isDark,
        onTap: () => context.push('/certificate'),
      ),
      _FeatureCard(
        icon: Icons.menu_book_rounded,
        title: l10n.homeBrowse,
        subtitle: l10n.homeBrowseSubtitle,
        accentColor: const Color(0xFFEC4899),
        isDark: isDark,
        onTap: () => context.go('/browse'),
      ),
    ];
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TapBounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.15)
                  : const Color(0xFFD4C9BE).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
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

class _WeakTopicsSection extends ConsumerWidget {
  const _WeakTopicsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final accent = ref.watch(settingsControllerProvider).accent;
    final isDark = theme.brightness == Brightness.dark;
    final weakAsync = ref.watch(topWeakTopicsProvider);

    return weakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (rows) {
        if (rows.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(
                          isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.trending_down_rounded,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Weak areas',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Top ${rows.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: TapBounce(
                  onTap: () {
                    context.push(
                      '/generate',
                      extra: GeneratePrefill(
                        topicCode: row.topic.code,
                        topicTitle: row.topic.title,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.12)
                              : const Color(0xFFD4C9BE).withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withOpacity(isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(row.mcqAccuracy != null ? (row.mcqAccuracy! * 100).round() : '?')}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.topic.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (row.dueRatio > 0)
                                Text(
                                  '${(row.dueRatio * 100).round()}% due',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: accent.deep.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class AccentChip extends StatelessWidget {
  const AccentChip({
    required this.label,
    required this.accent,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;
  final dynamic accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? accent.deep.withOpacity(0.12)
            : accent.soft.withOpacity(0.6),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: accent.deep),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : accent.deep,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
