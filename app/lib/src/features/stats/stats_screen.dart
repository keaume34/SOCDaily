// Phase 6 Stats screen: streak ring, totals chips, accuracy bar, and a
// 90-day activity heatmap powered by `user_streak`.

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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.list(
                children: [
                  streak.when(
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (e, st) => Text('$e'),
                    data: (s) => s.current == 0 && s.longest == 0
                        ? const _EmptyStatsCard()
                        : _StreakCard(
                            current: s.current,
                            longest: s.longest,
                            milestoneHit: s.milestoneHit,
                            accent: settings.accent,
                          ),
                  ),
                  const SizedBox(height: 16),
                  totals.when(
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (e, st) => Text('$e'),
                    data: (t) => _TotalsRow(snapshot: t),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last 90 days',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  heatmap.when(
                    loading: () =>
                        const LinearProgressIndicator(minHeight: 2),
                    error: (e, st) => Text('$e'),
                    data: (rows) => _Heatmap(
                      rows: rows,
                      accent: settings.accent,
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
  });
  final int current;
  final int longest;
  final int? milestoneHit;
  final AppAccent accent;

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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.accent.deep, widget.accent.soft],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${widget.current}-day streak',
                          style: theme.textTheme.titleLarge),
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
        ),
        // Confetti burst centred above the card.
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
        // Mascot peeks up from below the card with a thumbs-up.
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
  const _TotalsRow({required this.snapshot});
  final TotalsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracyPct =
        (snapshot.accuracy * 100).toStringAsFixed(0);
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.style,
            label: 'Cards rated',
            value: '${snapshot.cardsKnown}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.repeat,
            label: 'Total reviews',
            value: '${snapshot.cardsReviewed}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatChip(
            icon: Icons.bolt,
            label: 'MCQ accuracy',
            value: snapshot.mcqAttempts == 0 ? '—' : '$accuracyPct%',
            subtitle: snapshot.mcqAttempts == 0
                ? null
                : '${snapshot.mcqCorrect}/${snapshot.mcqAttempts}',
            valueStyle: theme.textTheme.titleLarge,
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
    this.subtitle,
    this.valueStyle,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: valueStyle ?? theme.textTheme.titleLarge),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.rows, required this.accent});
  final List<HeatmapDay> rows;
  final AppAccent accent;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final maxCount = rows.fold<int>(0, (m, r) => r.count > m ? r.count : m);
    // 13 weeks × 7 days = 91 cells. We render 90 days right-aligned, so the
    // earliest cells may be empty if rows.length < 91.
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Less',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(width: 6),
                for (final v in [0, 1, 2, 3, 4]) ...[
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: _colorFor(context, v, 4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
                Text('More',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(BuildContext context, int count, int max) {
    final scheme = Theme.of(context).colorScheme;
    if (count == 0) {
      return scheme.surfaceContainerHighest.withOpacity(0.5);
    }
    // Bucket into 4 intensity levels.
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
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _EmptyStatsCard extends StatelessWidget {
  const _EmptyStatsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            const MascotWidget(mood: OttoMood.sleeping, size: 100),
            const SizedBox(height: 16),
            Text(
              'No stats yet',
              style: theme.textTheme.titleMedium,
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
      ),
    );
  }
}
