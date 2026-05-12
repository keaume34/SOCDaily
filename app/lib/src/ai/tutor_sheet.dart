// Modal bottom sheet that calls the AI tutor (Explain deeper / Why wrong)
// and streams the response into a scrollable markdown view. Falls back to
// a hint card when AI is not yet configured.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ai_settings.dart';
import 'tutor_service.dart';

typedef TutorTask = Future<String> Function(TutorService service);

class TutorSheet extends ConsumerStatefulWidget {
  const TutorSheet({
    required this.title,
    required this.task,
    super.key,
  });

  final String title;
  final TutorTask task;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required TutorTask task,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TutorSheet(title: title, task: task),
    );
  }

  @override
  ConsumerState<TutorSheet> createState() => _TutorSheetState();
}

class _TutorSheetState extends ConsumerState<TutorSheet> {
  late Future<String> _future;
  bool _ranOnce = false;

  void _run() {
    final svc = ref.read(tutorServiceProvider);
    setState(() {
      _ranOnce = true;
      _future = widget.task(svc);
    });
  }

  @override
  void initState() {
    super.initState();
    // Lazy: only trigger when the user is actually configured.
    _future = Future.error('not started');
  }

  @override
  Widget build(BuildContext context) {
    final ai = ref.watch(aiSettingsControllerProvider);
    final theme = Theme.of(context);
    final insets = MediaQuery.of(context).viewInsets;

    if (!_ranOnce && ai.isConfigured) {
      // Start the call on first build after a configured controller.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_ranOnce) _run();
      });
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + insets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.title,
                    style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!ai.isConfigured)
            _ConfigureCard(onConfigure: () {
              Navigator.of(context).pop();
              context.push('/settings');
            })
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: FutureBuilder<String>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const _LoadingState();
                  }
                  if (snap.hasError) {
                    final msg = '${snap.error}';
                    if (msg == 'not started') return const _LoadingState();
                    return _ErrorState(message: msg, onRetry: _run);
                  }
                  final text = snap.data ?? '';
                  return SingleChildScrollView(
                    child: MarkdownBody(
                      data: text,
                      selectable: true,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Asking the tutor…'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: theme.colorScheme.errorContainer.withOpacity(0.6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

class _ConfigureCard extends StatelessWidget {
  const _ConfigureCard({required this.onConfigure});
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AI tutor is not configured',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your own OpenAI-compatible or Anthropic API key in '
              'Settings → AI tutor to enable Explain Deeper and Why was I '
              'wrong?. Your key stays on this device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onConfigure,
              icon: const Icon(Icons.settings),
              label: const Text('Open settings'),
            ),
          ],
        ),
      ),
    );
  }
}
