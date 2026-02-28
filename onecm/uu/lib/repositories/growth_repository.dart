import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class GrowthRepository {
  final AppDatabase _db;
  GrowthRepository(this._db);

  Future<void> addRecord({
    required int babyId,
    required DateTime date,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    String? notes,
  }) {
    return _db.into(_db.growthRecords).insert(GrowthRecordsCompanion.insert(
          babyId: babyId,
          date: date,
          weightKg: Value(weightKg),
          heightCm: Value(heightCm),
          headCircumferenceCm: Value(headCircumferenceCm),
          notes: Value(notes),
        ));
  }

  Future<List<GrowthRecord>> getRecordsForBaby(int babyId) {
    return (_db.select(_db.growthRecords)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([(r) => OrderingTerm.asc(r.date)]))
        .get();
  }

  Future<GrowthRecord?> getLatestRecord(int babyId) {
    return (_db.select(_db.growthRecords)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([(r) => OrderingTerm.desc(r.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<GrowthRecord>> watchRecordsForBaby(int babyId) {
    return (_db.select(_db.growthRecords)
          ..where((r) => r.babyId.equals(babyId))
          ..orderBy([(r) => OrderingTerm.asc(r.date)]))
        .watch();
  }
}
