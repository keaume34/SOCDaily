// Phase 6 Stats screen: streak ring, totals chips, accuracy bar, and a
// 90-day activity heatmap powered by `user_streak`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.current,
    required this.longest,
    required this.accent,
  });
  final int current;
  final int longest;
  final AppAccent accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
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
                  colors: [accent.deep, accent.soft],
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
                  Text('$current-day streak',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Longest: $longest day${longest == 1 ? '' : 's'}',
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
