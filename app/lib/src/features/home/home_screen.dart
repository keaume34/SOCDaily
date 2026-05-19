// Home screen: Mastercard-inspired dashboard with hero greeting, stat chips,
// feature grid, and weak-areas section.

import 'dart:ui';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18,
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : MCColors.slateGray),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : MCColors.inkBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? Colors.white.withValues(alpha: 0.45) : MCColors.slateGray,
                  letterSpacing: 0.56,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
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
        icon: Icons.timer_rounded,
        title: 'Mock exam',
        subtitle: 'Timed random MCQs \u2014 practice under pressure.',
        isDark: isDark,
        onTap: () => context.push('/quiz'),
      ),
      _FeatureCard(
        icon: Icons.table_chart_rounded,
        title: 'Cheatsheet',
        subtitle: 'Table view of all flashcards by subject.',
        isDark: isDark,
        onTap: () => context.push('/cheatsheet'),
      ),
      _FeatureCard(
        icon: Icons.av_timer_rounded,
        title: 'Pomodoro',
        subtitle: 'Focus / break cycles while you study.',
        isDark: isDark,
        onTap: () => context.push('/pomodoro'),
      ),
      _FeatureCard(
        icon: Icons.workspace_premium_rounded,
        title: 'Certificate',
        subtitle: 'Generate a printable study certificate.',
        isDark: isDark,
        onTap: () => context.push('/certificate'),
      ),
      _FeatureCard(
        icon: Icons.menu_book_rounded,
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
    return TapBounce(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : MCColors.inkBlack,
                          size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDark ? Colors.white : MCColors.inkBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : MCColors.slateGray,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : MCColors.slateGray,
                        ),
                      ),
                    ],
                  ),
                ),
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
