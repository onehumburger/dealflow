import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class FoodRepository {
  final AppDatabase _db;
  FoodRepository(this._db);

  Future<FoodIntroduction> createFoodIntroduction({
    required int babyId,
    required String foodName,
    required String category,
    bool isAllergen = false,
    required DateTime firstTriedAt,
    String? reaction,
    String? reactionSeverity,
    String? notes,
  }) async {
    final id = await _db.into(_db.foodIntroductions).insert(
          FoodIntroductionsCompanion.insert(
            babyId: babyId,
            foodName: foodName,
            category: category,
            isAllergen: Value(isAllergen),
            firstTriedAt: firstTriedAt,
            reaction: Value(reaction),
            reactionSeverity: Value(reactionSeverity),
            notes: Value(notes),
          ),
        );
    return (await getFoodIntroduction(id))!;
  }

  Future<FoodIntroduction?> getFoodIntroduction(int id) {
    return (_db.select(_db.foodIntroductions)
          ..where((f) => f.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<FoodIntroduction>> getFoodIntroductionsForBaby(int babyId) {
    return (_db.select(_db.foodIntroductions)
          ..where((f) => f.babyId.equals(babyId))
          ..orderBy([(f) => OrderingTerm.desc(f.firstTriedAt)]))
        .get();
  }

  Future<List<FoodIntroduction>> getFoodIntroductionsByCategory(
    int babyId,
    String category,
  ) {
    return (_db.select(_db.foodIntroductions)
          ..where((f) =>
              f.babyId.equals(babyId) & f.category.equals(category))
          ..orderBy([(f) => OrderingTerm.asc(f.foodName)]))
        .get();
  }

  Stream<List<FoodIntroduction>> watchFoodIntroductionsForBaby(int babyId) {
    return (_db.select(_db.foodIntroductions)
          ..where((f) => f.babyId.equals(babyId))
          ..orderBy([(f) => OrderingTerm.desc(f.firstTriedAt)]))
        .watch();
  }

  Future<void> updateReaction(
    int id, {
    String? reaction,
    String? reactionSeverity,
  }) {
    return (_db.update(_db.foodIntroductions)
          ..where((f) => f.id.equals(id)))
        .write(
      FoodIntroductionsCompanion(
        reaction: Value(reaction),
        reactionSeverity: Value(reactionSeverity),
      ),
    );
  }

  Future<void> updateNotes(int id, String? notes) {
    return (_db.update(_db.foodIntroductions)
          ..where((f) => f.id.equals(id)))
        .write(FoodIntroductionsCompanion(notes: Value(notes)));
  }

  Future<void> deleteFoodIntroduction(int id) {
    return (_db.delete(_db.foodIntroductions)
          ..where((f) => f.id.equals(id)))
        .go();
  }

  /// Returns the most recently introduced food for a baby (by firstTriedAt).
  Future<FoodIntroduction?> getLastIntroducedFood(int babyId) {
    return (_db.select(_db.foodIntroductions)
          ..where((f) => f.babyId.equals(babyId))
          ..orderBy([(f) => OrderingTerm.desc(f.firstTriedAt)])
          ..limit(1))
        .getSingleOrNull();
  }
}
