// Settings screen — themed picker for appearance + language. Real preferences
// for AI (P7), sync (P11), and notifications (P+) will live here too.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
