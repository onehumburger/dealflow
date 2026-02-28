import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/providers/theme_provider.dart';

void main() {
  group('ThemeProvider', () {
    test('defaults to system theme mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final mode = container.read(themeModeProvider);
      expect(mode, ThemeMode.system);
    });

    test('can switch to dark mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(themeModeProvider.notifier).state = ThemeMode.dark;
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
