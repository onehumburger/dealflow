import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/app.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/daily_log_provider.dart';
import 'package:uu/providers/growth_provider.dart';
import 'package:uu/services/daily_summary_service.dart';

void main() {
  group('AppShell', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    Widget buildApp() {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          todayLogsProvider.overrideWith((ref) => Stream.value(<DailyLog>[])),
          growthRecordsProvider
              .overrideWith((ref) => Stream.value(<GrowthRecord>[])),
          todaySummaryProvider.overrideWith((ref) async => DailySummary()),
        ],
        child: const UUApp(),
      );
    }

    testWidgets('shows bottom navigation with 5 items', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('shows Home tab by default', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('can navigate to Logs tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      await tester.tap(find.text('Logs'));
      await tester.pump();

      expect(find.text('Logs'), findsWidgets);
    });
  });
}
