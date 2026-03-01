/// A pre-populated food item that babies can be introduced to.
class CommonFood {
  final String name;
  final String category; // fruit, vegetable, grain, protein, dairy, allergen
  final bool isAllergen;

  const CommonFood({
    required this.name,
    required this.category,
    this.isAllergen = false,
  });
}

/// Result of checking the 3-day wait rule.
class WaitRuleStatus {
  /// Whether it is safe to introduce a new food.
  final bool canIntroduce;

  /// If not safe, the name of the last introduced food.
  final String? lastFoodName;

  /// If not safe, when the last food was introduced.
  final DateTime? lastIntroducedAt;

  /// If not safe, when the wait period ends.
  final DateTime? waitUntil;

  /// Number of days remaining in the wait period (0 if can introduce).
  final int daysRemaining;

  const WaitRuleStatus({
    required this.canIntroduce,
    this.lastFoodName,
    this.lastIntroducedAt,
    this.waitUntil,
    this.daysRemaining = 0,
  });
}

/// Pure logic service for food introduction tracking.
///
/// Provides a pre-populated list of common baby foods by category,
/// 3-day wait rule checking, and allergen identification.
class FoodService {
  /// The number of days to wait between introducing new foods.
  static const int waitDays = 3;

  /// All common baby foods organized by category.
  List<CommonFood> get allCommonFoods => _allFoods;

  /// Get common foods filtered by category.
  List<CommonFood> getCommonFoodsByCategory(String category) {
    return _allFoods.where((f) => f.category == category).toList();
  }

  /// Get all common allergen foods (across all categories).
  List<CommonFood> get allergenFoods {
    return _allFoods.where((f) => f.isAllergen).toList();
  }

  /// All available food categories.
  List<String> get categories =>
      const ['fruit', 'vegetable', 'grain', 'protein', 'dairy', 'allergen'];

  /// Display name for a category.
  String categoryDisplayName(String category) {
    switch (category) {
      case 'fruit':
        return 'Fruits';
      case 'vegetable':
        return 'Vegetables';
      case 'grain':
        return 'Grains';
      case 'protein':
        return 'Proteins';
      case 'dairy':
        return 'Dairy';
      case 'allergen':
        return 'Common Allergens';
      default:
        return category;
    }
  }

  /// Check the 3-day wait rule.
  ///
  /// Given the date the last new food was introduced, determine whether
  /// it is safe to introduce another new food now.
  WaitRuleStatus checkWaitRule({
    DateTime? lastIntroducedAt,
    String? lastFoodName,
    DateTime? now,
  }) {
    if (lastIntroducedAt == null) {
      return const WaitRuleStatus(canIntroduce: true);
    }

    final currentTime = now ?? DateTime.now();
    final waitUntil = lastIntroducedAt.add(const Duration(days: waitDays));
    final daysSince = currentTime.difference(lastIntroducedAt).inDays;
    final daysRemaining = waitDays - daysSince;

    if (daysSince >= waitDays) {
      return const WaitRuleStatus(canIntroduce: true);
    }

    return WaitRuleStatus(
      canIntroduce: false,
      lastFoodName: lastFoodName,
      lastIntroducedAt: lastIntroducedAt,
      waitUntil: waitUntil,
      daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
    );
  }

  /// Check if a food name matches a known common allergen.
  bool isKnownAllergen(String foodName) {
    final lower = foodName.toLowerCase();
    return _allFoods.any(
      (f) => f.isAllergen && f.name.toLowerCase() == lower,
    );
  }

  // ── Pre-populated food data ──────────────────────────────────────

  static const _allFoods = <CommonFood>[
    // ── Fruits ──
    CommonFood(name: 'Banana', category: 'fruit'),
    CommonFood(name: 'Avocado', category: 'fruit'),
    CommonFood(name: 'Apple', category: 'fruit'),
    CommonFood(name: 'Pear', category: 'fruit'),
    CommonFood(name: 'Mango', category: 'fruit'),
    CommonFood(name: 'Peach', category: 'fruit'),
    CommonFood(name: 'Blueberry', category: 'fruit'),
    CommonFood(name: 'Strawberry', category: 'fruit'),

    // ── Vegetables ──
    CommonFood(name: 'Sweet Potato', category: 'vegetable'),
    CommonFood(name: 'Butternut Squash', category: 'vegetable'),
    CommonFood(name: 'Carrot', category: 'vegetable'),
    CommonFood(name: 'Peas', category: 'vegetable'),
    CommonFood(name: 'Green Beans', category: 'vegetable'),
    CommonFood(name: 'Broccoli', category: 'vegetable'),
    CommonFood(name: 'Spinach', category: 'vegetable'),
    CommonFood(name: 'Zucchini', category: 'vegetable'),

    // ── Grains ──
    CommonFood(name: 'Rice Cereal', category: 'grain'),
    CommonFood(name: 'Oatmeal', category: 'grain'),
    CommonFood(name: 'Barley', category: 'grain'),
    CommonFood(name: 'Quinoa', category: 'grain'),
    CommonFood(name: 'Pasta', category: 'grain'),
    CommonFood(name: 'Bread', category: 'grain'),

    // ── Proteins ──
    CommonFood(name: 'Chicken', category: 'protein'),
    CommonFood(name: 'Turkey', category: 'protein'),
    CommonFood(name: 'Beef', category: 'protein'),
    CommonFood(name: 'Lentils', category: 'protein'),
    CommonFood(name: 'Beans', category: 'protein'),
    CommonFood(name: 'Tofu', category: 'protein'),

    // ── Dairy ──
    CommonFood(name: 'Yogurt', category: 'dairy'),
    CommonFood(name: 'Cheese', category: 'dairy'),
    CommonFood(name: 'Cottage Cheese', category: 'dairy'),
    CommonFood(name: 'Butter', category: 'dairy'),
    CommonFood(name: 'Cream Cheese', category: 'dairy'),

    // ── Common Allergens ──
    CommonFood(name: 'Milk', category: 'allergen', isAllergen: true),
    CommonFood(name: 'Eggs', category: 'allergen', isAllergen: true),
    CommonFood(name: 'Peanuts', category: 'allergen', isAllergen: true),
    CommonFood(name: 'Tree Nuts', category: 'allergen', isAllergen: true),
    CommonFood(name: 'Wheat', category: 'allergen', isAllergen: true),
    CommonFood(name: 'Soy', category: 'allergen', isAllergen: true),
    CommonFood(name: 'Fish', category: 'allergen', isAllergen: true),
    CommonFood(name: 'Shellfish', category: 'allergen', isAllergen: true),
  ];
}
