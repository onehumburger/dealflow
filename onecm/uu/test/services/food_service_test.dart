import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/food_service.dart';

void main() {
  late FoodService service;

  setUp(() {
    service = FoodService();
  });

  group('CommonFood data class', () {
    test('has required fields', () {
      const f = CommonFood(
        name: 'Banana',
        category: 'fruit',
      );
      expect(f.name, 'Banana');
      expect(f.category, 'fruit');
      expect(f.isAllergen, false);
    });

    test('allergen flag can be set', () {
      const f = CommonFood(
        name: 'Peanuts',
        category: 'allergen',
        isAllergen: true,
      );
      expect(f.isAllergen, true);
    });
  });

  group('allCommonFoods', () {
    test('contains foods for all six categories', () {
      final foods = service.allCommonFoods;
      final categories = foods.map((f) => f.category).toSet();
      expect(categories,
          containsAll(['fruit', 'vegetable', 'grain', 'protein', 'dairy', 'allergen']));
    });

    test('has at least 5 foods per category', () {
      final foods = service.allCommonFoods;
      for (final cat in ['fruit', 'vegetable', 'grain', 'protein', 'dairy']) {
        final count = foods.where((f) => f.category == cat).length;
        expect(count, greaterThanOrEqualTo(5),
            reason: '$cat should have at least 5 foods');
      }
    });

    test('allergen category has all 8 common allergens', () {
      final allergens = service.getCommonFoodsByCategory('allergen');
      expect(allergens.length, 8);
      final names = allergens.map((f) => f.name.toLowerCase()).toSet();
      expect(names, containsAll([
        'milk', 'eggs', 'peanuts', 'tree nuts',
        'wheat', 'soy', 'fish', 'shellfish',
      ]));
    });

    test('all allergen-category foods have isAllergen=true', () {
      final allergens = service.getCommonFoodsByCategory('allergen');
      for (final f in allergens) {
        expect(f.isAllergen, true, reason: '${f.name} should be marked as allergen');
      }
    });

    test('non-allergen categories have isAllergen=false', () {
      final foods = service.allCommonFoods;
      final nonAllergenFoods =
          foods.where((f) => f.category != 'allergen').toList();
      for (final f in nonAllergenFoods) {
        expect(f.isAllergen, false,
            reason: '${f.name} should not be marked as allergen');
      }
    });
  });

  group('getCommonFoodsByCategory', () {
    test('returns only foods from the requested category', () {
      final fruits = service.getCommonFoodsByCategory('fruit');
      expect(fruits, isNotEmpty);
      for (final f in fruits) {
        expect(f.category, 'fruit');
      }
    });

    test('returns empty list for unknown category', () {
      final unknown = service.getCommonFoodsByCategory('unknown');
      expect(unknown, isEmpty);
    });
  });

  group('allergenFoods', () {
    test('returns only foods with isAllergen=true', () {
      final allergens = service.allergenFoods;
      expect(allergens, isNotEmpty);
      for (final f in allergens) {
        expect(f.isAllergen, true);
      }
    });

    test('includes all 8 common allergens', () {
      final allergens = service.allergenFoods;
      expect(allergens.length, 8);
    });
  });

  group('categories', () {
    test('returns all 6 categories', () {
      expect(service.categories, [
        'fruit', 'vegetable', 'grain', 'protein', 'dairy', 'allergen',
      ]);
    });
  });

  group('categoryDisplayName', () {
    test('returns correct display names', () {
      expect(service.categoryDisplayName('fruit'), 'Fruits');
      expect(service.categoryDisplayName('vegetable'), 'Vegetables');
      expect(service.categoryDisplayName('grain'), 'Grains');
      expect(service.categoryDisplayName('protein'), 'Proteins');
      expect(service.categoryDisplayName('dairy'), 'Dairy');
      expect(service.categoryDisplayName('allergen'), 'Common Allergens');
    });

    test('returns raw category name for unknown category', () {
      expect(service.categoryDisplayName('unknown'), 'unknown');
    });
  });

  group('checkWaitRule', () {
    test('returns canIntroduce=true when no last food', () {
      final status = service.checkWaitRule();
      expect(status.canIntroduce, true);
      expect(status.daysRemaining, 0);
    });

    test('returns canIntroduce=false when food was introduced today', () {
      final now = DateTime(2026, 3, 1, 12, 0);
      final status = service.checkWaitRule(
        lastIntroducedAt: now,
        lastFoodName: 'Banana',
        now: now,
      );
      expect(status.canIntroduce, false);
      expect(status.lastFoodName, 'Banana');
      expect(status.daysRemaining, 3);
    });

    test('returns canIntroduce=false when 1 day since last food', () {
      final introduced = DateTime(2026, 3, 1, 10, 0);
      final now = DateTime(2026, 3, 2, 10, 0);
      final status = service.checkWaitRule(
        lastIntroducedAt: introduced,
        lastFoodName: 'Apple',
        now: now,
      );
      expect(status.canIntroduce, false);
      expect(status.daysRemaining, 2);
    });

    test('returns canIntroduce=false when 2 days since last food', () {
      final introduced = DateTime(2026, 3, 1, 10, 0);
      final now = DateTime(2026, 3, 3, 10, 0);
      final status = service.checkWaitRule(
        lastIntroducedAt: introduced,
        lastFoodName: 'Apple',
        now: now,
      );
      expect(status.canIntroduce, false);
      expect(status.daysRemaining, 1);
    });

    test('returns canIntroduce=true when exactly 3 days since last food', () {
      final introduced = DateTime(2026, 3, 1, 10, 0);
      final now = DateTime(2026, 3, 4, 10, 0);
      final status = service.checkWaitRule(
        lastIntroducedAt: introduced,
        lastFoodName: 'Apple',
        now: now,
      );
      expect(status.canIntroduce, true);
    });

    test('returns canIntroduce=true when more than 3 days since last food',
        () {
      final introduced = DateTime(2026, 3, 1, 10, 0);
      final now = DateTime(2026, 3, 10, 10, 0);
      final status = service.checkWaitRule(
        lastIntroducedAt: introduced,
        lastFoodName: 'Apple',
        now: now,
      );
      expect(status.canIntroduce, true);
    });

    test('waitUntil is set correctly when waiting', () {
      final introduced = DateTime(2026, 3, 1, 10, 0);
      final now = DateTime(2026, 3, 2, 10, 0);
      final status = service.checkWaitRule(
        lastIntroducedAt: introduced,
        lastFoodName: 'Carrot',
        now: now,
      );
      expect(status.waitUntil, DateTime(2026, 3, 4, 10, 0));
    });

    test('lastIntroducedAt is preserved in status', () {
      final introduced = DateTime(2026, 3, 1, 10, 0);
      final now = DateTime(2026, 3, 2, 10, 0);
      final status = service.checkWaitRule(
        lastIntroducedAt: introduced,
        lastFoodName: 'Carrot',
        now: now,
      );
      expect(status.lastIntroducedAt, introduced);
    });
  });

  group('isKnownAllergen', () {
    test('identifies known allergens (case-insensitive)', () {
      expect(service.isKnownAllergen('Milk'), true);
      expect(service.isKnownAllergen('milk'), true);
      expect(service.isKnownAllergen('EGGS'), true);
      expect(service.isKnownAllergen('Peanuts'), true);
      expect(service.isKnownAllergen('Tree Nuts'), true);
      expect(service.isKnownAllergen('Wheat'), true);
      expect(service.isKnownAllergen('Soy'), true);
      expect(service.isKnownAllergen('Fish'), true);
      expect(service.isKnownAllergen('Shellfish'), true);
    });

    test('returns false for non-allergen foods', () {
      expect(service.isKnownAllergen('Banana'), false);
      expect(service.isKnownAllergen('Carrot'), false);
      expect(service.isKnownAllergen('Rice Cereal'), false);
    });

    test('returns false for unknown foods', () {
      expect(service.isKnownAllergen('Dragon Fruit'), false);
    });
  });

  group('waitDays constant', () {
    test('is 3', () {
      expect(FoodService.waitDays, 3);
    });
  });
}
