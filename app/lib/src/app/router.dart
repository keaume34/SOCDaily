// Application route table built around a [StatefulShellRoute] so the bottom
// navigation bar preserves per-tab state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/browse/browse_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/certificate/certificate_screen.dart';
import '../features/cheatsheet/cheatsheet_screen.dart';
import '../features/daily/daily_challenge_screen.dart';
import '../features/generate/generate_screen.dart';
import '../features/home/home_screen.dart';
import '../features/library/bookmarks_screen.dart';
import '../features/pdf/pdf_viewer_screen.dart';
import '../features/pomodoro/pomodoro_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/study/study_screen.dart';
import '../features/study/today_review_screen.dart';
import '../features/study/topic_study_screen.dart';
import '../features/sync/sync_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingCompleteProvider);
  return GoRouter(
    initialLocation: onboardingDone ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/browse/subject/:id',
        builder: (context, state) => SubjectDetailScreen(
          subjectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/browse/chapter/:id',
        builder: (context, state) => ChapterDetailScreen(
          chapterId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/study/today',
        builder: (context, state) => const TodayReviewScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/study/topic/:id',
        builder: (context, state) => TopicStudyScreen(
          topicId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/daily',
        builder: (context, state) => const DailyChallengeScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizSetupScreen(),
      ),
      GoRoute(
        path: '/quiz/run',
        builder: (context, state) {
          final count =
              int.tryParse(state.uri.queryParameters['count'] ?? '') ?? 10;
          final minutes =
              int.tryParse(state.uri.queryParameters['minutes'] ?? '') ?? 10;
          return QuizRunScreen(count: count, minutes: minutes);
        },
      ),
      GoRoute(
        path: '/cheatsheet',
        builder: (context, state) =>
            const CheatsheetSubjectPickerScreen(),
      ),
      GoRoute(
        path: '/cheatsheet/:id',
        builder: (context, state) => CheatsheetScreen(
          subjectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/pomodoro',
        builder: (context, state) => const PomodoroScreen(),
      ),
      GoRoute(
        path: '/certificate',
        builder: (context, state) => const CertificateScreen(),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncScreen(),
      ),
      GoRoute(
        path: '/generate',
        builder: (context, state) {
          final extra = state.extra;
          return GenerateScreen(
            prefill: extra is GeneratePrefill ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/source/:sourceId',
        builder: (context, state) {
          final sourceId = int.parse(state.pathParameters['sourceId']!);
          final topicId =
              int.tryParse(state.uri.queryParameters['topicId'] ?? '');
          final page =
              int.tryParse(state.uri.queryParameters['page'] ?? '');
          return PdfViewerScreen(
            sourceId: sourceId,
            topicId: topicId,
            page: page,
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
          destinations: _destinations(AppLocalizations.of(context)),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => const BrowseScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (context, state) => const StudyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

List<AppShellDestination> _destinations(AppLocalizations l10n) => [
      AppShellDestination(
        path: '/home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.navHome,
      ),
      AppShellDestination(
        path: '/browse',
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book,
        label: l10n.navBrowse,
      ),
      AppShellDestination(
        path: '/study',
        icon: Icons.school_outlined,
        selectedIcon: Icons.school,
        label: l10n.navStudy,
      ),
      AppShellDestination(
        path: '/stats',
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: l10n.navStats,
      ),
      AppShellDestination(
        path: '/settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.navSettings,
      ),
    ];
