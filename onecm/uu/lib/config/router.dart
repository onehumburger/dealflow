import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uu/providers/onboarding_provider.dart';
import 'package:uu/screens/onboarding/onboarding_screen.dart';
import 'package:uu/screens/shell/app_shell.dart';
import 'package:uu/screens/home/home_screen.dart';
import 'package:uu/screens/logs/logs_screen.dart';
import 'package:uu/screens/chat/chat_screen.dart';
import 'package:uu/screens/me/me_screen.dart';
import 'package:uu/screens/growth/growth_chart_screen.dart';

GoRouter createRouter({OnboardingNotifier? onboardingNotifier}) {
  final notifier = onboardingNotifier ?? OnboardingNotifier();

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!notifier.hasCompleted && !isOnboarding) {
        return '/onboarding';
      }

      if (notifier.hasCompleted && isOnboarding) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/logs',
              builder: (context, state) => const LogsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/add',
              builder: (context, state) => const SizedBox(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/me',
              builder: (context, state) => const MeScreen(),
              routes: [
                GoRoute(
                  path: 'growth-charts',
                  builder: (context, state) => const GrowthChartScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}

/// Riverpod provider for the GoRouter instance.
/// Uses [onboardingNotifierProvider] for redirect logic.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(onboardingNotifierProvider);
  return createRouter(onboardingNotifier: notifier);
});
