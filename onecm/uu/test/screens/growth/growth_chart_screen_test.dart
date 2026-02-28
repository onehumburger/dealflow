import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/growth_provider.dart';
import 'package:uu/screens/growth/growth_chart_screen.dart';

void main() {
  group('GrowthChartScreen', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
    });

    tearDown(() async => await db.close());

    Widget buildTestWidget({List<GrowthRecord> records = const []}) {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          selectedBabyIdProvider.overrideWith((ref) => 1),
          // Override stream provider with immediate value to avoid
          // Drift timer cleanup issues in tests
          growthRecordsProvider.overrideWith(
            (ref) => Stream.value(records),
          ),
        ],
        child: const MaterialApp(home: GrowthChartScreen()),
      );
    }

    testWidgets('shows measurement type tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Head'), findsOneWidget);
    });

    testWidgets('shows add measurement FAB', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows empty state message when no data', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('No measurements'), findsOneWidget);
    });

    testWidgets('FAB opens bottom sheet for adding measurements',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(const Duration(milliseconds: 300));

      // The bottom sheet should show form fields
      expect(find.text('Add Measurement'), findsOneWidget);
    });

    testWidgets('can switch between tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Height tab
      await tester.tap(find.text('Height'));
      await tester.pump(const Duration(milliseconds: 100));

      // Should still show the screen without errors
      expect(find.text('Height'), findsOneWidget);
    });
  });
}
