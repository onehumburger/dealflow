import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/config/theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme has expected primary color', () {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, isNotNull);
    });

    test('dark theme has dark brightness', () {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
    });

    test('both themes use the same font family', () {
      expect(
        AppTheme.light.textTheme.bodyLarge?.fontFamily,
        AppTheme.dark.textTheme.bodyLarge?.fontFamily,
      );
    });
  });
}
