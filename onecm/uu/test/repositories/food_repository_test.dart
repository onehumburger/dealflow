import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/food_repository.dart';

void main() {
  late AppDatabase db;
  late FoodRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FoodRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('FoodRepository', () {
    test('createFoodIntroduction inserts and returns a food', () async {
      final food = await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );

      expect(food.babyId, 1);
      expect(food.foodName, 'Banana');
      expect(food.category, 'fruit');
      expect(food.isAllergen, false);
      expect(food.firstTriedAt, DateTime(2026, 3, 1));
      expect(food.reaction, isNull);
      expect(food.reactionSeverity, isNull);
      expect(food.notes, isNull);
    });

    test('createFoodIntroduction with allergen flag', () async {
      final food = await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Peanuts',
        category: 'allergen',
        isAllergen: true,
        firstTriedAt: DateTime(2026, 3, 1),
      );

      expect(food.isAllergen, true);
      expect(food.category, 'allergen');
    });

    test('createFoodIntroduction with reaction and notes', () async {
      final food = await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Eggs',
        category: 'allergen',
        isAllergen: true,
        firstTriedAt: DateTime(2026, 3, 1),
        reaction: 'Rash on face',
        reactionSeverity: 'mild',
        notes: 'Small amount in scrambled form',
      );

      expect(food.reaction, 'Rash on face');
      expect(food.reactionSeverity, 'mild');
      expect(food.notes, 'Small amount in scrambled form');
    });

    test('getFoodIntroduction returns null for non-existent id', () async {
      final result = await repo.getFoodIntroduction(999);
      expect(result, isNull);
    });

    test('getFoodIntroductionsForBaby returns foods for specific baby',
        () async {
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Apple',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 2, 28),
      );
      await repo.createFoodIntroduction(
        babyId: 2,
        foodName: 'Carrot',
        category: 'vegetable',
        firstTriedAt: DateTime(2026, 3, 1),
      );

      final foods = await repo.getFoodIntroductionsForBaby(1);
      expect(foods.length, 2);
      expect(foods.every((f) => f.babyId == 1), isTrue);
    });

    test('getFoodIntroductionsForBaby orders by firstTriedAt descending',
        () async {
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Apple',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 2, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Carrot',
        category: 'vegetable',
        firstTriedAt: DateTime(2026, 2, 15),
      );

      final foods = await repo.getFoodIntroductionsForBaby(1);
      expect(foods[0].foodName, 'Banana');
      expect(foods[1].foodName, 'Carrot');
      expect(foods[2].foodName, 'Apple');
    });

    test('getFoodIntroductionsByCategory filters correctly', () async {
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Carrot',
        category: 'vegetable',
        firstTriedAt: DateTime(2026, 3, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Apple',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 2, 28),
      );

      final fruits =
          await repo.getFoodIntroductionsByCategory(1, 'fruit');
      expect(fruits.length, 2);
      expect(fruits.every((f) => f.category == 'fruit'), isTrue);
    });

    test('getFoodIntroductionsByCategory orders by foodName', () async {
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Pear',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Apple',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );

      final fruits =
          await repo.getFoodIntroductionsByCategory(1, 'fruit');
      expect(fruits[0].foodName, 'Apple');
      expect(fruits[1].foodName, 'Banana');
      expect(fruits[2].foodName, 'Pear');
    });

    test('updateReaction updates reaction fields', () async {
      final food = await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Eggs',
        category: 'allergen',
        isAllergen: true,
        firstTriedAt: DateTime(2026, 3, 1),
      );

      await repo.updateReaction(
        food.id,
        reaction: 'Hives on arms',
        reactionSeverity: 'moderate',
      );

      final updated = await repo.getFoodIntroduction(food.id);
      expect(updated!.reaction, 'Hives on arms');
      expect(updated.reactionSeverity, 'moderate');
    });

    test('updateReaction can clear reaction', () async {
      final food = await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Milk',
        category: 'allergen',
        isAllergen: true,
        firstTriedAt: DateTime(2026, 3, 1),
        reaction: 'Upset stomach',
        reactionSeverity: 'mild',
      );

      await repo.updateReaction(food.id, reaction: null, reactionSeverity: null);

      final updated = await repo.getFoodIntroduction(food.id);
      expect(updated!.reaction, isNull);
      expect(updated.reactionSeverity, isNull);
    });

    test('updateNotes updates notes field', () async {
      final food = await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );

      await repo.updateNotes(food.id, 'Loved it!');

      final updated = await repo.getFoodIntroduction(food.id);
      expect(updated!.notes, 'Loved it!');
    });

    test('deleteFoodIntroduction removes the food', () async {
      final food = await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );

      await repo.deleteFoodIntroduction(food.id);

      final result = await repo.getFoodIntroduction(food.id);
      expect(result, isNull);
    });

    test('getLastIntroducedFood returns most recent food', () async {
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Apple',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 2, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Carrot',
        category: 'vegetable',
        firstTriedAt: DateTime(2026, 2, 15),
      );

      final last = await repo.getLastIntroducedFood(1);
      expect(last, isNotNull);
      expect(last!.foodName, 'Banana');
    });

    test('getLastIntroducedFood returns null when no foods exist', () async {
      final last = await repo.getLastIntroducedFood(1);
      expect(last, isNull);
    });

    test('getLastIntroducedFood only considers foods for the given baby',
        () async {
      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Apple',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 2, 1),
      );
      await repo.createFoodIntroduction(
        babyId: 2,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );

      final last = await repo.getLastIntroducedFood(1);
      expect(last!.foodName, 'Apple');
    });

    test('watchFoodIntroductionsForBaby emits updates', () async {
      final stream = repo.watchFoodIntroductionsForBaby(1);

      final firstEmit = await stream.first;
      expect(firstEmit, isEmpty);

      await repo.createFoodIntroduction(
        babyId: 1,
        foodName: 'Banana',
        category: 'fruit',
        firstTriedAt: DateTime(2026, 3, 1),
      );

      final secondEmit = await stream.first;
      expect(secondEmit.length, 1);
      expect(secondEmit.first.foodName, 'Banana');
    });
  });
}
