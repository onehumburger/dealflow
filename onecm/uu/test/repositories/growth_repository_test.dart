import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/growth_repository.dart';

void main() {
  late AppDatabase db;
  late GrowthRepository repo;
  late int babyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = GrowthRepository(db);
    babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
          name: 'Luna',
          dateOfBirth: DateTime(2025, 6, 15),
        ));
  });

  tearDown(() async => await db.close());

  group('GrowthRepository', () {
    test('addRecord and getRecordsForBaby', () async {
      await repo.addRecord(
          babyId: babyId,
          date: DateTime(2025, 7, 15),
          weightKg: 4.5,
          heightCm: 55.0,
          headCircumferenceCm: 37.0);
      final records = await repo.getRecordsForBaby(babyId);
      expect(records.length, 1);
      expect(records.first.weightKg, 4.5);
      expect(records.first.heightCm, 55.0);
    });

    test('getLatestRecord returns most recent', () async {
      await repo.addRecord(
          babyId: babyId, date: DateTime(2025, 7, 1), weightKg: 4.0);
      await repo.addRecord(
          babyId: babyId, date: DateTime(2025, 8, 1), weightKg: 5.0);
      final latest = await repo.getLatestRecord(babyId);
      expect(latest?.weightKg, 5.0);
    });

    test('watchRecordsForBaby emits on new entry', () async {
      final stream = repo.watchRecordsForBaby(babyId);
      expectLater(stream, emitsInOrder([hasLength(0), hasLength(1)]));
      await Future.delayed(const Duration(milliseconds: 50));
      await repo.addRecord(
          babyId: babyId, date: DateTime(2025, 7, 15), weightKg: 4.5);
    });
  });
}
