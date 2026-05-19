// Phase 11 — Cloud sync screen. Lets the user generate or redeem a
// 6-digit pairing code, then run a two-way sync round-trip with the
// partner device.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/sync_controller.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  final _codeCtl = TextEditingController();

  @override
  void dispose() {
    _codeCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final state = ref.watch(syncControllerProvider);
    final controller = ref.read(syncControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud sync'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        accent: settings.accent,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (state.mode == SyncMode.unconfigured)
                _UnconfiguredCard(theme: theme)
              else ...[
                _StatusCard(state: state, theme: theme),
                const SizedBox(height: 16),
                _GenerateCodeCard(
                  state: state,
                  controller: controller,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _RedeemCard(
                  state: state,
                  controller: controller,
                  theme: theme,
                  codeCtl: _codeCtl,
                ),
                const SizedBox(height: 16),
                _SyncActionsCard(
                  state: state,
                  controller: controller,
                  theme: theme,
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              _SyncExplainer(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnconfiguredCard extends StatelessWidget {
  const _UnconfiguredCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sync is not configured',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define at '
              'build time, then re-launch the app. The app still works fully '
              'offline without it.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state, required this.theme});
  final SyncState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final pair = state.pairCode ?? '—';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isPaired ? 'Paired' : 'Not paired',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              state.isPaired
                  ? 'Active code: $pair'
                  : 'Generate a code on this device or redeem one from '
                      'another.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.lastSyncedAt == null
                  ? 'Never synced'
                  : 'Last sync: ${state.lastSyncedAt!.toLocal()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateCodeCard extends StatelessWidget {
  const _GenerateCodeCard({
    required this.state,
    required this.controller,
    required this.theme,
  });
  final SyncState state;
  final SyncController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pair this device',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Generate a 6-digit code, then enter it on the other device. '
              'Codes expire after 10 minutes.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: state.mode == SyncMode.generating
                      ? null
                      : () async {
                          final code = await controller.generatePairCode();
                          if (code == null) return;
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pairing code: $code')),
                          );
                        },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    state.mode == SyncMode.generating
                        ? 'Generating…'
                        : state.isPaired
                            ? 'Regenerate code'
                            : 'Generate code',
                  ),
                ),
                const SizedBox(width: 12),
                if (state.isPaired)
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: state.pairCode ?? ''),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  const _RedeemCard({
    required this.state,
    required this.controller,
    required this.theme,
    required this.codeCtl,
  });
  final SyncState state;
  final SyncController controller;
  final ThemeData theme;
  final TextEditingController codeCtl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Redeem a code',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Enter the 6-digit code shown on the device you already use.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '123456',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: state.mode == SyncMode.redeeming
                  ? null
                  : () async {
                      final ok =
                          await controller.redeemPairCode(codeCtl.text);
                      if (!context.mounted) return;
                      if (ok) {
                        codeCtl.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pair confirmed')),
                        );
                      }
                    },
              child: Text(
                state.mode == SyncMode.redeeming
                    ? 'Redeeming…'
                    : 'Redeem code',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncActionsCard extends StatelessWidget {
  const _SyncActionsCard({
    required this.state,
    required this.controller,
    required this.theme,
  });
  final SyncState state;
  final SyncController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sync now', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Pushes your local card / question / bookmark state up, then '
              'pulls the partner device\'s updates back. Conflicts are '
              'resolved by most-recent timestamp.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed:
                      state.isPaired && state.mode != SyncMode.syncing
                          ? () async {
                              final res = await controller.syncNow();
                              if (!context.mounted || res == null) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Synced: ↑${res.uploaded} '
                                    '↓${res.downloaded} '
                                    '(applied ${res.applied})',
                                  ),
                                ),
                              );
                            }
                          : null,
                  icon: const Icon(Icons.sync),
                  label: Text(
                    state.mode == SyncMode.syncing ? 'Syncing…' : 'Sync now',
                  ),
                ),
                const SizedBox(width: 12),
                if (state.isPaired)
                  TextButton.icon(
                    onPressed: () => controller.unpair(),
                    icon: const Icon(Icons.link_off),
                    label: const Text('Unpair'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncExplainer extends StatelessWidget {
  const _SyncExplainer({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How it works', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '• Generate a 6-digit code on phone A.\n'
              '• Type the code on phone B → Redeem.\n'
              '• Tap "Sync now" on either device — your card state, '
              'question state, and bookmarks travel both ways.\n'
              '• No account, no email. The 6-digit code itself is the '
              'capability and expires after 10 minutes if not redeemed.\n'
              '• Notes and source PDFs are NOT synced in this MVP.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
