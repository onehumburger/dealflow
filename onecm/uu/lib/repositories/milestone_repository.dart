import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class MilestoneRepository {
  final AppDatabase _db;
  MilestoneRepository(this._db);

  Future<Milestone> createMilestone({
    required int babyId,
    required String category,
    required String title,
    String? description,
    DateTime? achievedAt,
    int? expectedAgeMonths,
  }) async {
    final id = await _db.into(_db.milestones).insert(
          MilestonesCompanion.insert(
            babyId: babyId,
            category: category,
            title: title,
            description: Value(description),
            achievedAt: Value(achievedAt),
            expectedAgeMonths: Value(expectedAgeMonths),
          ),
        );
    return (await getMilestone(id))!;
  }

  Future<Milestone?> getMilestone(int id) {
    return (_db.select(_db.milestones)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Milestone>> getMilestonesForBaby(int babyId, {String? category}) {
    final query = _db.select(_db.milestones)
      ..where((m) => m.babyId.equals(babyId))
      ..orderBy([(m) => OrderingTerm.asc(m.expectedAgeMonths)]);
    if (category != null) {
      query.where((m) => m.category.equals(category));
    }
    return query.get();
  }

  Stream<List<Milestone>> watchMilestonesForBaby(int babyId) {
    return (_db.select(_db.milestones)
          ..where((m) => m.babyId.equals(babyId))
          ..orderBy([(m) => OrderingTerm.asc(m.expectedAgeMonths)]))
        .watch();
  }

  Future<void> markAchieved(int id, DateTime achievedAt) {
    return (_db.update(_db.milestones)..where((m) => m.id.equals(id)))
        .write(MilestonesCompanion(achievedAt: Value(achievedAt)));
  }

  Future<void> updateMilestone(
    int id, {
    String? description,
    DateTime? achievedAt,
  }) {
    return (_db.update(_db.milestones)..where((m) => m.id.equals(id))).write(
      MilestonesCompanion(
        description: description != null
            ? Value(description)
            : const Value.absent(),
        achievedAt:
            achievedAt != null ? Value(achievedAt) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteMilestone(int id) {
    return (_db.delete(_db.milestones)..where((m) => m.id.equals(id))).go();
  }
}
