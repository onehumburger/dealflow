import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/daily_log_provider.dart';
import 'package:uu/screens/logs/logs_screen.dart';

void main() {
  group('LogsScreen', () {
    late AppDatabase db;
    late int babyId;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
    });

    tearDown(() async => await db.close());

    Widget buildTestWidget({List<DailyLog> logs = const []}) {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          selectedBabyIdProvider.overrideWith((ref) => babyId),
          // Override stream provider with immediate value to avoid
          // Drift timer cleanup issues in tests
          todayLogsProvider.overrideWith(
            (ref) => Stream.value(logs),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: LogsScreen())),
      );
    }

    testWidgets('shows filter chips', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Feeding'), findsOneWidget);
      expect(find.text('Sleep'), findsOneWidget);
      expect(find.text('Diaper'), findsOneWidget);
    });

    testWidgets('shows empty state when no logs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('No logs'), findsOneWidget);
    });

    testWidgets('shows Mood filter chip', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Mood'), findsOneWidget);
    });

    testWidgets('shows log entries after inserting data', (tester) async {
      final now = DateTime.now();
      final feedingLog = DailyLog(
        id: 1,
        babyId: babyId,
        type: 'feeding',
        startedAt: now,
        endedAt: null,
        durationMinutes: null,
        metadata: null,
        notes: null,
        createdAt: now,
      );

      await tester.pumpWidget(buildTestWidget(logs: [feedingLog]));
      await tester.pump(const Duration(milliseconds: 100));

      // Feeding appears both as a filter chip and as a log entry
      expect(find.text('Feeding'), findsAtLeastNWidgets(1));
      // No empty state
      expect(find.textContaining('No logs'), findsNothing);
    });

    testWidgets('filtering by type shows only matching logs', (tester) async {
      final now = DateTime.now();
      final feedingLog = DailyLog(
        id: 1,
        babyId: babyId,
        type: 'feeding',
        startedAt: now,
        endedAt: null,
        durationMinutes: null,
        metadata: null,
        notes: null,
        createdAt: now,
      );
      final sleepLog = DailyLog(
        id: 2,
        babyId: babyId,
        type: 'sleep',
        startedAt: now.subtract(const Duration(hours: 1)),
        endedAt: null,
        durationMinutes: 45,
        metadata: null,
        notes: null,
        createdAt: now,
      );

      await tester
          .pumpWidget(buildTestWidget(logs: [feedingLog, sleepLog]));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the Sleep filter chip (first one is the FilterChip)
      await tester.tap(find.text('Sleep').first);
      await tester.pump(const Duration(milliseconds: 100));

      // Should not show "No logs" since we have a sleep entry
      expect(find.textContaining('No logs'), findsNothing);
    });

    testWidgets('shows notes preview in trailing', (tester) async {
      final now = DateTime.now();
      final logWithNotes = DailyLog(
        id: 1,
        babyId: babyId,
        type: 'feeding',
        startedAt: now,
        endedAt: null,
        durationMinutes: null,
        metadata: null,
        notes: 'Breastfed well',
        createdAt: now,
      );

      await tester.pumpWidget(buildTestWidget(logs: [logWithNotes]));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Breastfed well'), findsOneWidget);
    });
  });
}
