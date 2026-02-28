import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/baby_repository.dart';

void main() {
  late AppDatabase db;
  late BabyRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = BabyRepository(db);
  });

  tearDown(() async => await db.close());

  group('BabyRepository', () {
    test('createBaby returns the new baby with id', () async {
      final baby = await repo.createBaby(
        name: 'Luna',
        dateOfBirth: DateTime(2025, 6, 15),
        gender: 'female',
      );
      expect(baby.id, greaterThan(0));
      expect(baby.name, 'Luna');
      expect(baby.gender, 'female');
    });

    test('getBaby returns null for non-existent id', () async {
      final baby = await repo.getBaby(999);
      expect(baby, isNull);
    });

    test('getAllBabies returns all created babies', () async {
      await repo.createBaby(name: 'Luna', dateOfBirth: DateTime(2025, 6, 15));
      await repo.createBaby(name: 'Max', dateOfBirth: DateTime(2024, 1, 10));
      final babies = await repo.getAllBabies();
      expect(babies.length, 2);
    });

    test('updateBaby changes the name', () async {
      final baby = await repo.createBaby(
          name: 'Luna', dateOfBirth: DateTime(2025, 6, 15));
      await repo.updateBaby(baby.id, name: 'Luna Star');
      final updated = await repo.getBaby(baby.id);
      expect(updated?.name, 'Luna Star');
    });

    test('watchBaby emits updates', () async {
      final baby = await repo.createBaby(
          name: 'Luna', dateOfBirth: DateTime(2025, 6, 15));
      final stream = repo.watchBaby(baby.id);
      expectLater(
        stream,
        emitsInOrder([
          predicate<Baby>((b) => b.name == 'Luna'),
          predicate<Baby>((b) => b.name == 'Luna Updated'),
        ]),
      );
      await Future.delayed(const Duration(milliseconds: 50));
      await repo.updateBaby(baby.id, name: 'Luna Updated');
    });
  });
}
