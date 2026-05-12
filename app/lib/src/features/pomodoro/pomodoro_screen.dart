// Phase 9 — Pomodoro / study timer UI. Big circular progress ring with
// gradient stroke, phase label, remaining time, and start/pause/skip/reset
// controls. Durations are tweakable from the same screen.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';
import 'pomodoro_controller.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final pom = ref.watch(pomodoroControllerProvider);
    final ctl = ref.read(pomodoroControllerProvider.notifier);
    final theme = Theme.of(context);
    final accent = settings.accent;

    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar.medium(
                title: Text('Pomodoro'),
                pinned: true,
                backgroundColor: Colors.transparent,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    children: [
                      _PhaseChip(phase: pom.phase),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: pom.progress,
                            gradientStart: accent.deep,
                            gradientEnd: accent.soft,
                            track: theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _format(pom.remainingSeconds),
                                  style:
                                      theme.textTheme.displayLarge?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${pom.completedFocus} focus done',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            iconSize: 28,
                            onPressed: ctl.reset,
                            icon: const Icon(Icons.replay),
                            tooltip: 'Reset',
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: pom.running
                                ? FilledButton(
                                    style: FilledButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: ctl.pause,
                                    child: const Icon(Icons.pause, size: 32),
                                  )
                                : FilledButton(
                                    style: FilledButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    onPressed: ctl.start,
                                    child: const Icon(Icons.play_arrow,
                                        size: 32),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          IconButton.filledTonal(
                            iconSize: 28,
                            onPressed: ctl.skip,
                            icon: const Icon(Icons.skip_next),
                            tooltip: 'Skip',
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _DurationCard(state: pom, controller: ctl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.phase});
  final PomodoroPhase phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, fg, bg) = switch (phase) {
      PomodoroPhase.idle => (
          'Ready',
          Icons.hourglass_empty,
          theme.colorScheme.onSurface,
          theme.colorScheme.surfaceContainerHighest,
        ),
      PomodoroPhase.focus => (
          'Focus',
          Icons.center_focus_strong,
          theme.colorScheme.onPrimaryContainer,
          theme.colorScheme.primaryContainer,
        ),
      PomodoroPhase.shortBreak => (
          'Short break',
          Icons.local_cafe_outlined,
          theme.colorScheme.onSecondaryContainer,
          theme.colorScheme.secondaryContainer,
        ),
      PomodoroPhase.longBreak => (
          'Long break',
          Icons.weekend_outlined,
          theme.colorScheme.onTertiaryContainer,
          theme.colorScheme.tertiaryContainer,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.gradientStart,
    required this.gradientEnd,
    required this.track,
  });

  final double progress;
  final Color gradientStart;
  final Color gradientEnd;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.06;
    final r = (size.shortestSide / 2) - stroke;
    final c = Offset(size.width / 2, size.height / 2);
    final trackPaint = Paint()
      ..color = track
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: c, radius: r);
      final sweep = 2 * math.pi * progress;
      final paint = Paint()
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [gradientStart, gradientEnd, gradientStart],
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + 2 * math.pi,
        ).createShader(rect);
      canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.gradientStart != gradientStart ||
      old.gradientEnd != gradientEnd ||
      old.track != track;
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({required this.state, required this.controller});
  final PomodoroState state;
  final PomodoroController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Durations', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Changes apply on the next phase.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _Picker(
              label: 'Focus',
              minutes: state.focusMinutes,
              options: const [15, 20, 25, 30, 45, 50],
              onChange: (m) => controller.updateDurations(focus: m),
            ),
            const SizedBox(height: 8),
            _Picker(
              label: 'Short break',
              minutes: state.shortBreakMinutes,
              options: const [3, 5, 7, 10],
              onChange: (m) => controller.updateDurations(short: m),
            ),
            const SizedBox(height: 8),
            _Picker(
              label: 'Long break',
              minutes: state.longBreakMinutes,
              options: const [10, 15, 20, 30],
              onChange: (m) => controller.updateDurations(long: m),
            ),
            const SizedBox(height: 8),
            _Picker(
              label: 'Cycles → long break',
              minutes: state.cyclesUntilLongBreak,
              suffix: '',
              options: const [2, 3, 4, 5, 6],
              onChange: (n) => controller.updateDurations(cycles: n),
            ),
          ],
        ),
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({
    required this.label,
    required this.minutes,
    required this.options,
    required this.onChange,
    this.suffix = ' min',
  });

  final String label;
  final int minutes;
  final List<int> options;
  final String suffix;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Wrap(
          spacing: 4,
          children: [
            for (final v in options)
              ChoiceChip(
                label: Text('$v$suffix'),
                selected: minutes == v,
                onSelected: (_) => onChange(v),
              ),
          ],
        ),
      ],
    );
  }
}
