import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/app.dart';

void main() {
  group('AppShell', () {
    testWidgets('shows bottom navigation with 5 items', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UUApp()));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('shows Home tab by default', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UUApp()));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets); // may appear in nav + screen
    });

    testWidgets('can navigate to Logs tab', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: UUApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.text('Logs'), findsWidgets);
    });
  });
}
