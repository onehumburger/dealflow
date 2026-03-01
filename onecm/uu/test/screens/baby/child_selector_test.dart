import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/screens/baby/child_selector.dart';

void main() {
  group('ChildSelector', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    Widget buildTestWidget({
      int? selectedBabyId,
      List<Baby> babies = const [],
    }) {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          allBabiesProvider.overrideWith((ref) => Future.value(babies)),
          if (selectedBabyId != null)
            selectedBabyIdProvider.overrideWith((ref) => selectedBabyId),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const ChildSelector(),
            ),
            body: const SizedBox(),
          ),
        ),
      );
    }

    testWidgets('shows selected baby name', (tester) async {
      final baby = Baby(
        id: 1,
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
        gender: 'female',
        bloodType: null,
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        selectedBabyId: 1,
        babies: [baby],
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Luna'), findsOneWidget);
    });

    testWidgets('shows dropdown icon', (tester) async {
      final baby = Baby(
        id: 1,
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
        gender: null,
        bloodType: null,
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        selectedBabyId: 1,
        babies: [baby],
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('tapping opens bottom sheet with all babies', (tester) async {
      final babies = [
        Baby(
          id: 1,
          name: 'Luna',
          dateOfBirth: DateTime(2025, 6, 15),
          gender: 'female',
          bloodType: null,
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Baby(
          id: 2,
          name: 'Max',
          dateOfBirth: DateTime(2024, 3, 10),
          gender: 'male',
          bloodType: null,
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildTestWidget(
        selectedBabyId: 1,
        babies: babies,
      ));
      await tester.pump();
      await tester.pump();

      // Tap the selector
      await tester.tap(find.byType(ChildSelector));
      await tester.pumpAndSettle();

      // Both babies should appear in the bottom sheet
      expect(find.text('Luna'), findsWidgets);
      expect(find.text('Max'), findsOneWidget);
    });

    testWidgets('bottom sheet shows "Add Child" option', (tester) async {
      final baby = Baby(
        id: 1,
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
        gender: null,
        bloodType: null,
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        selectedBabyId: 1,
        babies: [baby],
      ));
      await tester.pump();
      await tester.pump();

      // Tap the selector
      await tester.tap(find.byType(ChildSelector));
      await tester.pumpAndSettle();

      expect(find.text('Add Child'), findsOneWidget);
    });

    testWidgets('selecting a different baby updates provider', (tester) async {
      final babies = [
        Baby(
          id: 1,
          name: 'Luna',
          dateOfBirth: DateTime(2025, 6, 15),
          gender: 'female',
          bloodType: null,
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Baby(
          id: 2,
          name: 'Max',
          dateOfBirth: DateTime(2024, 3, 10),
          gender: 'male',
          bloodType: null,
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            allBabiesProvider.overrideWith((ref) => Future.value(babies)),
            selectedBabyIdProvider.overrideWith((ref) => 1),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return Scaffold(
                  appBar: AppBar(
                    title: const ChildSelector(),
                  ),
                  body: const SizedBox(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Tap the selector
      await tester.tap(find.byType(ChildSelector));
      await tester.pumpAndSettle();

      // Tap on Max
      await tester.tap(find.text('Max'));
      await tester.pumpAndSettle();

      // Verify the provider was updated
      expect(capturedRef.read(selectedBabyIdProvider), equals(2));
    });

    testWidgets('shows child avatar icon with gender color', (tester) async {
      final baby = Baby(
        id: 1,
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
        gender: 'female',
        bloodType: null,
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(
        selectedBabyId: 1,
        babies: [baby],
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.child_care), findsOneWidget);
    });

    testWidgets('shows placeholder when no baby selected', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        babies: [],
      ));
      await tester.pump();
      await tester.pump();

      // When no baby is selected, should show a fallback
      expect(find.text('Select Child'), findsOneWidget);
    });

    testWidgets('shows check mark next to selected baby in sheet',
        (tester) async {
      final babies = [
        Baby(
          id: 1,
          name: 'Luna',
          dateOfBirth: DateTime(2025, 6, 15),
          gender: 'female',
          bloodType: null,
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Baby(
          id: 2,
          name: 'Max',
          dateOfBirth: DateTime(2024, 3, 10),
          gender: 'male',
          bloodType: null,
          photoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(buildTestWidget(
        selectedBabyId: 1,
        babies: babies,
      ));
      await tester.pump();
      await tester.pump();

      // Tap the selector
      await tester.tap(find.byType(ChildSelector));
      await tester.pumpAndSettle();

      // Should show check icon for selected baby
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
