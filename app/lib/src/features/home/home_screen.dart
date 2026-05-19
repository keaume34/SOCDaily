// Home screen: Mastercard-inspired dashboard with hero greeting, stat chips,
// feature grid, and weak-areas section.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/user_state_repository.dart';
import '../../data/db/weakness_scorer.dart';
import '../../data/seed/seed_bootstrap.dart';
import '../../widgets/tap_bounce.dart';
import '../../l10n/app_localizations.dart';
import '../../mascot/mascot_widget.dart';
import '../../theme/app_theme.dart';
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
            // ── Hero greeting (stadium frame) ──
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
                  isWide ? 32 : 20, 20, isWide ? 32 : 20, 0),
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
                  isWide ? 32 : 20, 24, isWide ? 32 : 20, 0),
                child: const _WeakTopicsSection(),
              ),
            ),

            // ── Feature grid ──
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 32 : 20, 24, isWide ? 32 : 20, 32),
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

// ── Hero section: stadium-shaped card with 40px radius ──
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2A2A28), const Color(0xFF1A1917)]
              : [MCColors.inkBlack, const Color(0xFF2A2A28)],
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 48,
            offset: const Offset(0, 24),
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
                // Eyebrow label
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: MCColors.lightSignalOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.homeGreeting.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MCColors.slateGray,
                        fontSize: 12,
                        letterSpacing: 0.48,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.appName,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: MCColors.canvasCream,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your SOC learning companion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: MCColors.dustTaupe,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
            child: const MascotWidget(mood: OttoMood.neutral, size: 56),
          ),
        ],
      ),
    );
  }
}

// ── Stats row with Mastercard-style cards ──
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
            label: 'STREAK',
            value: '0',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.timelapse_rounded,
            label: 'DUE TODAY',
            value: '$dueCount',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.auto_awesome_rounded,
            label: 'NEW',
            value: '$newCount',
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
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A4A3A), Color(0xFF1A2A2A), Color(0xFF1A1F2A)],
              )
            : null,
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: const Color(0xFF00C896).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00C896),
                    Color(0xFF006644),
                    Color(0xFF003322),
                  ],
                )
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0D1117)
                : Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: isDark
                ? null
                : Border.all(color: Colors.black.withValues(alpha: 0.06)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : MCColors.slateGray,
                      letterSpacing: 0.56,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  Icon(icon, size: 18,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : MCColors.slateGray.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: isDark ? Colors.white : MCColors.inkBlack,
                ),
              ),
            ],
          ),
        ),
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
        childAspectRatio: 3.8,
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
        icon: Icons.style_rounded,
        title: l10n.homeStartSession,
        subtitle: l10n.homeStartSessionSubtitle,
        isDark: isDark,
        onTap: () => context.push('/study/today'),
      ),
      _FeatureCard(
        icon: Icons.bolt_rounded,
        title: l10n.homeDailyChallenge,
        subtitle: l10n.homeDailyChallengeSubtitle,
        isDark: isDark,
        onTap: () => context.push('/daily'),
      ),
      _FeatureCard(
        icon: Icons.quiz_rounded,
        title: 'Mock exam',
        subtitle: 'Timed random MCQs — test under pressure.',
        isDark: isDark,
        onTap: () => context.push('/quiz'),
      ),
      _FeatureCard(
        icon: Icons.grid_view_rounded,
        title: 'Cheatsheet',
        subtitle: 'Quick-reference table by subject.',
        isDark: isDark,
        onTap: () => context.push('/cheatsheet'),
      ),
      _FeatureCard(
        icon: Icons.timer_rounded,
        title: 'Pomodoro',
        subtitle: 'Focus / break study cycles.',
        isDark: isDark,
        onTap: () => context.push('/pomodoro'),
      ),
      _FeatureCard(
        icon: Icons.verified_rounded,
        title: 'Certificate',
        subtitle: 'Generate a study certificate.',
        isDark: isDark,
        onTap: () => context.push('/certificate'),
      ),
      _FeatureCard(
        icon: Icons.library_books_rounded,
        title: l10n.homeBrowse,
        subtitle: l10n.homeBrowseSubtitle,
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
    required this.isDark,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : MCColors.charcoal,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.white,
                  size: 20),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? Colors.white : MCColors.inkBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : MCColors.slateGray,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isDark) {
      return TapBounce(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(1.2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00C896),
                Color(0xFF006644),
                Color(0xFF003322),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C896).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(19),
            ),
            child: cardContent,
          ),
        ),
      );
    }

    return TapBounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: cardContent,
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
            // Section eyebrow
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: MCColors.lightSignalOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WEAK AREAS',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: MCColors.slateGray,
                      fontSize: 12,
                      letterSpacing: 0.48,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : MCColors.liftedCream,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Top ${rows.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: MCColors.slateGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : MCColors.liftedCream,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                              isDark ? 0.1 : 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: MCColors.signalOrange
                                .withOpacity(isDark ? 0.12 : 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${(row.mcqAccuracy != null ? (row.mcqAccuracy! * 100).round() : '?')}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: MCColors.signalOrange,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                    color: MCColors.slateGray,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: accent.deep.withOpacity(0.4),
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
