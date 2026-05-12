// Settings screen — themed picker for appearance + language. Real preferences
// for AI (P7), sync (P11), and notifications (P+) will live here too.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/ai_settings.dart';
import '../../l10n/app_localizations.dart';
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsAccent,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.settingsAccentSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final accent in AppAccent.values)
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
