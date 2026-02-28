import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/daily_log_provider.dart';
import 'package:uu/providers/growth_provider.dart';
import 'package:uu/screens/home/home_screen.dart';
import 'package:uu/services/daily_summary_service.dart';

void main() {
  group('HomeScreen', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
    });

    tearDown(() async => await db.close());

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          selectedBabyIdProvider.overrideWith((ref) => 1),
          // Override stream/future providers with immediate values to avoid
          // Drift timer cleanup issues and CircularProgressIndicator animations
          todayLogsProvider.overrideWith(
            (ref) => Stream.value(<DailyLog>[]),
          ),
          growthRecordsProvider.overrideWith(
            (ref) => Stream.value(<GrowthRecord>[]),
          ),
          todaySummaryProvider.overrideWith(
            (ref) async => DailySummary(
              feedingCount: 3,
              totalSleepMinutes: 120,
              diaperCount: 5,
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
    }

    testWidgets('shows quick-log buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Fed'), findsOneWidget);
      expect(find.text('Diaper'), findsAtLeastNWidgets(1));
      expect(find.text('Sleep'), findsAtLeastNWidgets(1));
      expect(find.text('Mood'), findsOneWidget);
    });

    testWidgets('shows today summary section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Summary'), findsOneWidget);
    });

    testWidgets('shows baby name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Luna'), findsOneWidget);
    });

    testWidgets('shows growth snapshot section', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('Growth Snapshot'), findsOneWidget);
    });

    testWidgets('shows summary data from provider', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.text('3'), findsOneWidget); // feedingCount
      expect(find.text('5'), findsOneWidget); // diaperCount
      expect(find.text('2h'), findsOneWidget); // 120 min = 2h
    });
  });
}
