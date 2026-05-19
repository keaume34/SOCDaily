// Phase 8 — Timed quiz / mock exam. Random N MCQs with a count-down timer.
// Auto-submits when time runs out. Results screen shows correctness +
// per-question recap.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/app_database.dart';
import '../../data/db/content_repository.dart';
import '../../data/db/user_state_repository.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';
import '../study/widgets/mcq_view.dart';

class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  int _count = 10;
  int _minutes = 10;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar.medium(
                title: Text('Mock exam'),
                pinned: true,
                backgroundColor: Colors.transparent,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList.list(
                  children: [
                    Text(
                      'A timed quiz of random MCQs from your library.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Questions', style: theme.textTheme.titleMedium),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final n in [5, 10, 20, 30])
                                  ChoiceChip(
                                    label: Text('$n'),
                                    selected: _count == n,
                                    onSelected: (_) =>
                                        setState(() => _count = n),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Time limit',
                                style: theme.textTheme.titleMedium),
                            Wrap(
                              spacing: 8,
                              children: [
                                for (final m in [5, 10, 15, 30])
                                  ChoiceChip(
                                    label: Text('$m min'),
                                    selected: _minutes == m,
                                    onSelected: (_) =>
                                        setState(() => _minutes = m),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start exam'),
                      onPressed: () => context.push(
                          '/quiz/run?count=$_count&minutes=$_minutes'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizRunScreen extends ConsumerStatefulWidget {
  const QuizRunScreen({
    required this.count,
    required this.minutes,
    super.key,
  });
  final int count;
  final int minutes;

  @override
  ConsumerState<QuizRunScreen> createState() => _QuizRunScreenState();
}

class _QuizRunScreenState extends ConsumerState<QuizRunScreen> {
  late Future<List<({Question q, List<QuestionOption> opts})>> _futureItems;
  int _index = 0;
  final Map<int, Set<int>> _answers = {};
  final Map<int, bool> _results = {};
  DateTime _deadline = DateTime.now();
  Stream<int>? _ticker;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _futureItems = _loadItems();
    _deadline =
        DateTime.now().add(Duration(minutes: widget.minutes));
    _ticker = Stream<int>.periodic(
        const Duration(seconds: 1), (i) => i + 1).asBroadcastStream();
  }

  Future<List<({Question q, List<QuestionOption> opts})>>
      _loadItems() async {
    final repo = ref.read(contentRepositoryProvider);
    final qs = await repo.randomQuestions(widget.count);
    final out = <({Question q, List<QuestionOption> opts})>[];
    for (final q in qs) {
      final opts = await repo.listOptionsForQuestion(q.id);
      out.add((q: q, opts: opts));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: FutureBuilder<List<({Question q, List<QuestionOption> opts})>>(
            future: _futureItems,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data!;
              if (items.isEmpty) {
                return const Center(
                    child: Text('No questions available yet.'));
              }
              return _buildPlayer(context, items);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context,
      List<({Question q, List<QuestionOption> opts})> items) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _confirmExit(),
                tooltip: 'Exit',
              ),
              const Spacer(),
              StreamBuilder<int>(
                stream: _ticker,
                builder: (context, _) {
                  final remaining = _deadline.difference(DateTime.now());
                  if (!_finished && remaining.isNegative) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!_finished) _finish(items, autoFinished: true);
                    });
                  }
                  final secs = remaining.inSeconds.clamp(0, 9999);
                  return _TimerChip(seconds: secs);
                },
              ),
              const SizedBox(width: 12),
              Text(
                _finished ? 'Done' : '${_index + 1} / ${items.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: items.isEmpty
              ? 0
              : ((_finished ? items.length : _index) / items.length)
                  .clamp(0.0, 1.0),
          minHeight: 3,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
        Expanded(
          child: _finished
              ? _QuizSummary(
                  items: items,
                  results: _results,
                  answers: _answers,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: _renderQuestion(items),
                ),
        ),
      ],
    );
  }

  Widget _renderQuestion(
      List<({Question q, List<QuestionOption> opts})> items) {
    final entry = items[_index];
    final multiple = entry.q.qtype.toLowerCase() == 'multiple';
    final selected = _answers.putIfAbsent(entry.q.id, () => <int>{});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: McqView(
              question: entry.q,
              options: entry.opts,
              selected: selected,
              submitted: false,
              onToggle: (id) => setState(() {
                if (multiple) {
                  if (!selected.add(id)) selected.remove(id);
                } else {
                  selected
                    ..clear()
                    ..add(id);
                }
              }),
            ),
          ),
        ),
        Row(
          children: [
            if (_index > 0)
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Prev'),
                  onPressed: () => setState(() => _index -= 1),
                ),
              ),
            if (_index > 0) const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                icon: Icon(_index + 1 == items.length
                    ? Icons.flag
                    : Icons.arrow_forward),
                label: Text(_index + 1 == items.length ? 'Finish' : 'Next'),
                onPressed: selected.isEmpty
                    ? null
                    : () {
                        if (_index + 1 == items.length) {
                          _finish(items);
                        } else {
                          setState(() => _index += 1);
                        }
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _finish(
      List<({Question q, List<QuestionOption> opts})> items,
      {bool autoFinished = false}) async {
    final userRepo = ref.read(userStateRepositoryProvider);
    for (final entry in items) {
      final chosen = _answers[entry.q.id] ?? const <int>{};
      final correctIds =
          entry.opts.where((o) => o.isCorrect).map((o) => o.id).toSet();
      final wasCorrect = chosen.length == correctIds.length &&
          correctIds.containsAll(chosen);
      _results[entry.q.id] = wasCorrect;
      await userRepo.recordQuestionAttempt(
        entry.q.id,
        wasCorrect: wasCorrect,
        choice: (chosen.toList()..sort()).join(','),
      );
    }
    if (mounted) {
      setState(() => _finished = true);
      if (autoFinished) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time is up — auto-submitted.')),
        );
      }
    }
  }

  Future<void> _confirmExit() async {
    if (_finished) {
      Navigator.of(context).pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit exam?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.seconds});
  final int seconds;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    final critical = seconds <= 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: critical
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined,
              size: 14,
              color: critical
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            '$m:$s',
            style: theme.textTheme.labelLarge?.copyWith(
              color: critical
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizSummary extends StatelessWidget {
  const _QuizSummary({
    required this.items,
    required this.results,
    required this.answers,
  });
  final List<({Question q, List<QuestionOption> opts})> items;
  final Map<int, bool> results;
  final Map<int, Set<int>> answers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = results.values.where((v) => v).length;
    final pct = items.isEmpty ? 0 : (correct * 100 / items.length).round();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score: $correct / ${items.length}',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('$pct% correct',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final entry in items)
          _QuestionRecap(
            question: entry.q,
            options: entry.opts,
            chosen: answers[entry.q.id] ?? const <int>{},
            wasCorrect: results[entry.q.id] ?? false,
          ),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Back to home'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _QuestionRecap extends StatelessWidget {
  const _QuestionRecap({
    required this.question,
    required this.options,
    required this.chosen,
    required this.wasCorrect,
  });
  final Question question;
  final List<QuestionOption> options;
  final Set<int> chosen;
  final bool wasCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  wasCorrect ? Icons.check_circle : Icons.cancel,
                  color: wasCorrect ? Colors.green : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    question.stem,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final o in options)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      o.isCorrect
                          ? Icons.check
                          : (chosen.contains(o.id)
                              ? Icons.close
                              : Icons.radio_button_unchecked),
                      size: 14,
                      color: o.isCorrect
                          ? Colors.green
                          : (chosen.contains(o.id)
                              ? Colors.redAccent
                              : theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${o.label}) ${o.content}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            if ((question.explanation ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(question.explanation!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
