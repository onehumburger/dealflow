import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/screens/settings/notification_settings_screen.dart';

void main() {
  group('NotificationSettingsScreen', () {
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
        ],
        child: const MaterialApp(home: NotificationSettingsScreen()),
      );
    }

    testWidgets('shows feeding reminder toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Feeding'), findsOneWidget);
    });

    testWidgets('shows diaper reminder toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Diaper'), findsOneWidget);
    });

    testWidgets('shows interval selector', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('interval'), findsWidgets);
    });
  });
}
