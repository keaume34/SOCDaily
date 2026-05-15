// Settings screen — themed picker for appearance + language. Real preferences
// for AI (P7), sync (P11), and notifications (P+) will live here too.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../ai/ai_settings.dart';
import '../../ai/generator_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../sync/sync_controller.dart';
import '../../theme/app_accent.dart';
import '../../theme/gradient_background.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return GradientBackground(
      accent: settings.accent,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: Text(l10n.navSettings),
              pinned: true,
              backgroundColor: Colors.transparent,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList.list(
                children: [
                  _SectionHeader(text: l10n.settingsAppearance),
                  _ThemeModeTile(
                    current: settings.themeMode,
                    onChanged: controller.setThemeMode,
                  ),
                  const SizedBox(height: 12),
                  _AccentPicker(
                    current: settings.accent,
                    onChanged: controller.setAccent,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(text: l10n.settingsLanguage),
                  _LanguageTile(
                    current: settings.locale,
                    onChanged: controller.setLocale,
                  ),
                  const SizedBox(height: 24),
                  const _SectionHeader(text: 'AI tutor'),
                  const _AiTutorCard(),
                  const SizedBox(height: 24),
                  const _SectionHeader(text: 'Content generator'),
                  const _GeneratorCard(),
                  const SizedBox(height: 24),
                  const _SectionHeader(text: 'Cloud sync'),
                  const _CloudSyncCard(),
                  const SizedBox(height: 24),
                  _SectionHeader(text: l10n.settingsAbout),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOCDaily',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.settingsAboutTagline,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.settingsAboutVersion('0.1.0'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({required this.current, required this.onChanged});
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(ThemeMode, String, IconData)>[
      (ThemeMode.light, l10n.settingsThemeLight, Icons.light_mode),
      (ThemeMode.dark, l10n.settingsThemeDark, Icons.dark_mode),
      (ThemeMode.system, l10n.settingsThemeSystem, Icons.brightness_auto),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            for (final (mode, label, icon) in options)
              RadioListTile<ThemeMode>(
                value: mode,
                groupValue: current,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                title: Row(
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 10),
                    Text(label),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.current, required this.onChanged});
  final AppAccent current;
  final ValueChanged<AppAccent> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsAccent,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.settingsAccentSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            const _AccentGroupLabel(label: 'Professional'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final accent in AppAccent.professional)
                  _AccentSwatch(
                    accent: accent,
                    selected: accent == current,
                    onTap: () => onChanged(accent),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const _AccentGroupLabel(label: 'Friendly'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final accent in AppAccent.friendly)
                  _AccentSwatch(
                    accent: accent,
                    selected: accent == current,
                    onTap: () => onChanged(accent),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentGroupLabel extends StatelessWidget {
  const _AccentGroupLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.accent,
    required this.selected,
    required this.onTap,
  });
  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ring = selected
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.outlineVariant;
    return Semantics(
      label: accent.label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: accent.accentGradient(brightness),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ring, width: selected ? 2.4 : 1.0),
          ),
          alignment: Alignment.center,
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 28)
              : null,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.current, required this.onChanged});
  final Locale? current;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(Locale?, String)>[
      (null, l10n.settingsLanguageSystem),
      (const Locale('en'), 'English'),
      (const Locale('vi'), 'Tiếng Việt'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            for (final (locale, label) in options)
              RadioListTile<String>(
                value: locale?.languageCode ?? '__system__',
                groupValue: current?.languageCode ?? '__system__',
                onChanged: (_) => onChanged(locale),
                title: Text(label),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _AiTutorCard extends ConsumerStatefulWidget {
  const _AiTutorCard();

  @override
  ConsumerState<_AiTutorCard> createState() => _AiTutorCardState();
}

class _AiTutorCardState extends ConsumerState<_AiTutorCard> {
  late final TextEditingController _baseUrlCtl;
  late final TextEditingController _apiKeyCtl;
  late final TextEditingController _modelCtl;
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(aiSettingsControllerProvider);
    _baseUrlCtl = TextEditingController(text: s.baseUrl);
    _apiKeyCtl = TextEditingController(text: s.apiKey);
    _modelCtl = TextEditingController(text: s.model);
  }

  @override
  void dispose() {
    _baseUrlCtl.dispose();
    _apiKeyCtl.dispose();
    _modelCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(aiSettingsControllerProvider);
    final c = ref.read(aiSettingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bring your own LLM API key. Used for "Explain deeper" + '
              '"Why was I wrong?". Stored on this device only.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<AiProvider>(
              segments: [
                for (final p in AiProvider.values)
                  ButtonSegment(value: p, label: Text(p.label)),
              ],
              selected: {s.provider},
              onSelectionChanged: (set) async {
                final p = set.first;
                await c.setProvider(p);
                if (p == AiProvider.openaiCompat &&
                    _baseUrlCtl.text.isEmpty) {
                  _baseUrlCtl.text = AiSettings.initial.baseUrl;
                  await c.setBaseUrl(_baseUrlCtl.text);
                }
              },
            ),
            const SizedBox(height: 12),
            if (s.provider == AiProvider.openaiCompat)
              TextField(
                controller: _baseUrlCtl,
                decoration: const InputDecoration(
                  labelText: 'Base URL',
                  hintText: 'https://api.openai.com/v1',
                  border: OutlineInputBorder(),
                ),
                onChanged: c.setBaseUrl,
              ),
            if (s.provider == AiProvider.openaiCompat)
              const SizedBox(height: 8),
            TextField(
              controller: _modelCtl,
              decoration: const InputDecoration(
                labelText: 'Model',
                hintText: 'gpt-4o-mini  /  claude-3-haiku-20240307',
                border: OutlineInputBorder(),
              ),
              onChanged: c.setModel,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyCtl,
              obscureText: !_showKey,
              decoration: InputDecoration(
                labelText: 'API key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showKey ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _showKey = !_showKey),
                ),
              ),
              onChanged: c.setApiKey,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  s.isConfigured
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  size: 16,
                  color: s.isConfigured
                      ? Colors.green
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  s.isConfigured ? 'Configured' : 'Not configured',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await c.clearApiKey();
                    _apiKeyCtl.clear();
                    setState(() {});
                  },
                  child: const Text('Clear key'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CloudSyncCard extends ConsumerWidget {
  const _CloudSyncCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(syncControllerProvider);
    final theme = Theme.of(context);

    if (s.mode == SyncMode.unconfigured) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Not configured', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Build the app with --dart-define=SUPABASE_URL=... and '
                '--dart-define=SUPABASE_ANON_KEY=... to enable two-device '
                'sync via a 6-digit pairing code.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final statusLine = s.isPaired
        ? 'Paired · code ${s.pairCode}'
        : 'Not paired yet';
    final lastLine = s.lastSyncedAt == null
        ? 'Never synced'
        : 'Last synced ${s.lastSyncedAt!.toLocal()}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  s.isPaired
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(statusLine, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              lastLine,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (s.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                s.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.devices_outlined),
              label: const Text('Manage devices…'),
              onPressed: () => context.push('/sync'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratorCard extends ConsumerStatefulWidget {
  const _GeneratorCard();

  @override
  ConsumerState<_GeneratorCard> createState() => _GeneratorCardState();
}

class _GeneratorCardState extends ConsumerState<_GeneratorCard> {
  late final TextEditingController _baseUrlCtl;
  late final TextEditingController _tokenCtl;
  bool _showToken = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(generatorSettingsControllerProvider);
    _baseUrlCtl = TextEditingController(text: s.baseUrl);
    _tokenCtl = TextEditingController(text: s.token);
  }

  @override
  void dispose() {
    _baseUrlCtl.dispose();
    _tokenCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(generatorSettingsControllerProvider);
    final c = ref.read(generatorSettingsControllerProvider.notifier);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Point this at the SOCDaily generator service (P14.A) on your '
              'VPS. The token authenticates uploads + generation requests; '
              'rotate it from the server side.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrlCtl,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://socdaily.example.com',
                border: OutlineInputBorder(),
              ),
              onChanged: c.setBaseUrl,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenCtl,
              obscureText: !_showToken,
              decoration: InputDecoration(
                labelText: 'Bearer token',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showToken ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _showToken = !_showToken),
                ),
              ),
              onChanged: c.setToken,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  s.isConfigured
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
                  size: 16,
                  color: s.isConfigured
                      ? Colors.green
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  s.isConfigured ? 'Configured' : 'Not configured',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await c.clearToken();
                    _tokenCtl.clear();
                    setState(() {});
                  },
                  child: const Text('Clear token'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
