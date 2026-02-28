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
  testWidgets('UUApp renders smoke test', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        todayLogsProvider.overrideWith((ref) => Stream.value(<DailyLog>[])),
        growthRecordsProvider
            .overrideWith((ref) => Stream.value(<GrowthRecord>[])),
        todaySummaryProvider.overrideWith((ref) async => DailySummary()),
      ],
      child: const UUApp(),
    ));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
