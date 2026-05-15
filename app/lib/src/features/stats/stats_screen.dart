// Stats screen: streak card, totals row, accuracy, and a 90-day heatmap
// with pastel accent ramp. Redesigned with glass cards and softer visuals.

import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/db/user_state_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../mascot/mascot_widget.dart';
import '../../theme/app_accent.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final streak = ref.watch(streakStatsProvider);
    final heatmap = ref.watch(activityHeatmapProvider);
    final totals = ref.watch(totalsSnapshotProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientBackground(
      accent: settings.accent,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Text(l10n.navStats),
              backgroundColor: Colors.transparent,
              pinned: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList.list(
                children: [
                  streak.when(
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (e, st) => Text('$e'),
                    data: (s) => s.current == 0 && s.longest == 0
                        ? _EmptyStatsCard(isDark: isDark)
                        : _StreakCard(
                            current: s.current,
                            longest: s.longest,
                            milestoneHit: s.milestoneHit,
                            accent: settings.accent,
                            isDark: isDark,
                          ),
                  ),
                  const SizedBox(height: 16),
                  totals.when(
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (e, st) => Text('$e'),
                    data: (t) => _TotalsRow(
                      snapshot: t,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withOpacity(isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last 90 days',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  heatmap.when(
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (e, st) => Text('$e'),
                    data: (rows) => _Heatmap(
                      rows: rows,
                      accent: settings.accent,
                      isDark: isDark,
                    ),
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

class _StreakCard extends StatefulWidget {
  const _StreakCard({
    required this.current,
    required this.longest,
    required this.milestoneHit,
    required this.accent,
    required this.isDark,
  });
  final int current;
  final int longest;
  final int? milestoneHit;
  final AppAccent accent;
  final bool isDark;

  @override
  State<_StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<_StreakCard>
    with TickerProviderStateMixin {
  static const _prefsKey = 'stats.lastCelebratedMilestoneDay';

  late final ConfettiController _confetti;
  late final AnimationController _peek;
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 2500));
    _peek = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _maybeCelebrate();
  }

  @override
  void didUpdateWidget(covariant _StreakCard old) {
    super.didUpdateWidget(old);
    if (widget.milestoneHit != old.milestoneHit) {
      _maybeCelebrate();
    }
  }

  Future<void> _maybeCelebrate() async {
    final hit = widget.milestoneHit;
    if (hit == null) return;
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final lastKey = '$today:$hit';
    if (prefs.getString(_prefsKey) == lastKey) return;
    await prefs.setString(_prefsKey, lastKey);
    if (!mounted) return;
    setState(() => _celebrating = true);
    _confetti.play();
    _peek.forward(from: 0);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _peek.reverse();
    if (!mounted) return;
    setState(() => _celebrating = false);
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _confetti.dispose();
    _peek.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [
                      widget.accent.deep.withOpacity(0.15),
                      widget.accent.deep.withOpacity(0.05),
                    ]
                  : [
                      widget.accent.soft.withOpacity(0.5),
                      widget.accent.soft.withOpacity(0.15),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? widget.accent.deep.withOpacity(0.15)
                    : widget.accent.soft.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.accent.deep, widget.accent.soft],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.deep.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.current}-day streak',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longest: ${widget.longest} day${widget.longest == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -8,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirection: math.pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 18,
                maxBlastForce: 18,
                minBlastForce: 6,
                gravity: 0.25,
                shouldLoop: false,
                colors: [widget.accent.deep, widget.accent.soft, Colors.white],
              ),
            ),
          ),
        ),
        if (_celebrating)
          Positioned(
            bottom: -32,
            right: 12,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _peek,
                curve: Curves.easeOutBack,
              )),
              child: const MascotWidget(
                mood: OttoMood.correct,
                size: 64,
              ),
            ),
          ),
      ],
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.snapshot, required this.isDark});
  final TotalsSnapshot snapshot;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = (snapshot.accuracy * 100).toStringAsFixed(0);
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.style_rounded,
            label: 'Cards rated',
            value: '${snapshot.cardsKnown}',
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.repeat_rounded,
            label: 'Reviews',
            value: '${snapshot.cardsReviewed}',
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            icon: Icons.bolt_rounded,
            label: 'MCQ acc.',
            value: snapshot.mcqAttempts == 0 ? '—' : '$accuracyPct%',
            subtitle: snapshot.mcqAttempts == 0
                ? null
                : '${snapshot.mcqCorrect}/${snapshot.mcqAttempts}',
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.subtitle,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({
    required this.rows,
    required this.accent,
    required this.isDark,
  });
  final List<HeatmapDay> rows;
  final AppAccent accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final maxCount = rows.fold<int>(0, (m, r) => r.count > m ? r.count : m);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final weeks = (rows.length / 7).ceil();
              final cellSize =
                  ((constraints.maxWidth - (weeks - 1) * 4) / weeks)
                      .clamp(8.0, 18.0);
              return SizedBox(
                height: cellSize * 7 + 6 * 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var w = 0; w < weeks; w++) ...[
                      if (w > 0) const SizedBox(width: 4),
                      Column(
                        children: [
                          for (var d = 0; d < 7; d++) ...[
                            if (d > 0) const SizedBox(height: 4),
                            _Cell(
                              size: cellSize,
                              color: _colorFor(
                                context,
                                w * 7 + d < rows.length
                                    ? rows[w * 7 + d].count
                                    : 0,
                                maxCount,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Less',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  )),
              const SizedBox(width: 6),
              for (final v in [0, 1, 2, 3, 4]) ...[
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _colorFor(context, v, 4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
              Text('More',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorFor(BuildContext context, int count, int max) {
    if (count == 0) {
      return isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.04);
    }
    final levels = max == 0 ? 0 : (count / (max / 4)).ceil().clamp(1, 4);
    final t = levels / 4.0;
    return Color.lerp(accent.soft, accent.deep, t)!;
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _EmptyStatsCard extends StatelessWidget {
  const _EmptyStatsCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        children: [
          const MascotWidget(mood: OttoMood.sleeping, size: 100),
          const SizedBox(height: 16),
          Text(
            'No stats yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start a study session to build your streak!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
