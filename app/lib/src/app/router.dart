// Application route table built around a [StatefulShellRoute] so the bottom
// navigation bar preserves per-tab state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/browse/browse_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/study/study_screen.dart';
import '../features/study/topic_study_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
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
        path: '/study/topic/:id',
        builder: (context, state) => TopicStudyScreen(
          topicId: int.parse(state.pathParameters['id']!),
        ),
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
