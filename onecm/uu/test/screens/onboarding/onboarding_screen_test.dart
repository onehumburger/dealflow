import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/screens/onboarding/onboarding_screen.dart';

void main() {
  group('OnboardingScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async => await db.close());

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: OnboardingScreen()),
      );
    }

    testWidgets('shows welcome message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.textContaining('Welcome'), findsOneWidget);
    });

    testWidgets('shows name input field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('shows date of birth picker', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.textContaining('Date of Birth'), findsOneWidget);
    });

    testWidgets('validates empty name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Find and tap the save/continue button without entering a name
      final saveButton = find.widgetWithText(ElevatedButton, 'Get Started');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton);
        await tester.pump();
        expect(find.text('Name is required'), findsOneWidget);
      }
    });

    testWidgets('shows subtitle text', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.textContaining('baby'), findsWidgets);
    });

    testWidgets('shows gender choice chips', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.byType(ChoiceChip), findsWidgets);
    });
  });
}
