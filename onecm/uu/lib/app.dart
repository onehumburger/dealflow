import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/config/router.dart';
import 'package:uu/config/theme.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/onboarding_provider.dart';
import 'package:uu/providers/auto_dark_mode_provider.dart';

class UUApp extends ConsumerStatefulWidget {
  const UUApp({super.key});

  @override
  ConsumerState<UUApp> createState() => _UUAppState();
}

class _UUAppState extends ConsumerState<UUApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final notifier = ref.read(onboardingNotifierProvider);
    // Skip DB check if already marked as completed (e.g. in tests)
    if (!notifier.hasCompleted) {
      try {
        final babies = await ref.read(allBabiesProvider.future);
        notifier.hasCompleted = babies.isNotEmpty;
      } catch (_) {
        // If DB isn't ready yet, leave as not completed (will show onboarding)
      }
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(effectiveThemeModeProvider);

    if (!_initialized) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'UU',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
