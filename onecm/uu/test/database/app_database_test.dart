import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('can create and read a baby', () async {
      final id = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));

      final baby = await (db.select(db.babies)
            ..where((b) => b.id.equals(id)))
          .getSingle();

      expect(baby.name, 'Luna');
      expect(baby.dateOfBirth, DateTime(2025, 6, 15));
    });

    test('can create and read a growth record', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));

      await db.into(db.growthRecords).insert(GrowthRecordsCompanion.insert(
            babyId: babyId,
            date: DateTime(2025, 7, 15),
            weightKg: const Value(4.5),
            heightCm: const Value(55.0),
            headCircumferenceCm: const Value(37.0),
          ));

      final records = await (db.select(db.growthRecords)
            ..where((r) => r.babyId.equals(babyId)))
          .get();

      expect(records.length, 1);
      expect(records.first.weightKg, 4.5);
    });

    test('can create and read a daily log', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));

      await db.into(db.dailyLogs).insert(DailyLogsCompanion.insert(
            babyId: babyId,
            type: 'feeding',
            startedAt: DateTime(2025, 7, 15, 8, 0),
          ));

      final logs = await (db.select(db.dailyLogs)
            ..where((l) => l.babyId.equals(babyId)))
          .get();

      expect(logs.length, 1);
      expect(logs.first.type, 'feeding');
    });
  });
}
