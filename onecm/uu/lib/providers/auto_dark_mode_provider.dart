import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/theme_provider.dart';
import 'package:uu/services/auto_dark_mode_service.dart';

/// Holds the current dark mode schedule configuration.
final darkModeScheduleProvider =
    StateProvider<DarkModeSchedule>((ref) => DarkModeSchedule.defaultSchedule);

/// Computes the effective theme mode by combining:
/// - the user's manual [themeModeProvider] choice, and
/// - the auto dark-mode [darkModeScheduleProvider] schedule.
///
/// If the schedule is disabled, the user's manual choice is returned.
/// If the schedule is enabled and the current time falls in the dark window,
/// [ThemeMode.dark] is returned; otherwise [ThemeMode.light].
final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final schedule = ref.watch(darkModeScheduleProvider);
  final manualMode = ref.watch(themeModeProvider);

  if (!schedule.enabled) {
    return manualMode;
  }

  final now = DateTime.now();
  if (AutoDarkModeService.shouldUseDarkMode(schedule, now)) {
    return ThemeMode.dark;
  }
  return ThemeMode.light;
});
