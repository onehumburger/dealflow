import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uu/screens/shell/app_shell.dart';
import 'package:uu/screens/home/home_screen.dart';
import 'package:uu/screens/logs/logs_screen.dart';
import 'package:uu/screens/chat/chat_screen.dart';
import 'package:uu/screens/me/me_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
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
          ),
        ]),
      ],
    ),
  ],
);
