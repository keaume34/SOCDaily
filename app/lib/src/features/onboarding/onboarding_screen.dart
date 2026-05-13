import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../mascot/mascot_widget.dart';
import '../../theme/gradient_background.dart';
import '../settings/settings_controller.dart';

const _kOnboardingCompleteKey = 'onboarding.complete';

final onboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_kOnboardingCompleteKey) ?? false;
});

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kOnboardingCompleteKey, true);
    ref.invalidate(onboardingCompleteProvider);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final theme = Theme.of(context);
    final accent = settings.accent;

    final steps = _steps(theme);
    final isLast = _page == steps.length - 1;

    return GradientBackground(
      accent: accent,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => steps[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(steps.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == _page ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: i == _page
                              ? accent.deep
                              : accent.deep.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isLast
                        ? _finish
                        : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            ),
                    child: Text(isLast ? 'Get started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _steps(ThemeData theme) {
    return [
      const _OnboardingPage(
        mood: OttoMood.neutral,
        title: 'Meet Otto',
        body:
            'Your friendly SOC analyst owl — always on the night shift, '
            'always rooting for you.',
      ),
      const _OnboardingPage(
        mood: OttoMood.correct,
        title: 'Learn by doing',
        body:
            'Flashcards, MCQs, spaced repetition, and an AI tutor '
            'that explains why you got it wrong.',
      ),
      const _OnboardingPage(
        mood: OttoMood.sleeping,
        title: 'Study at your pace',
        body:
            'Pomodoro timer, streak tracking, and offline mode — '
            'no internet needed.',
      ),
    ];
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.mood,
    required this.title,
    required this.body,
  });

  final OttoMood mood;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MascotWidget(mood: mood, size: 160),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
