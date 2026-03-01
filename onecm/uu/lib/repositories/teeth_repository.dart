import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class TeethRepository {
  final AppDatabase _db;
  TeethRepository(this._db);

  /// Record a tooth eruption.
  Future<TeethRecord> markErupted({
    required int babyId,
    required String toothPosition,
    required DateTime eruptedAt,
    String? notes,
  }) async {
    final id = await _db.into(_db.teethRecords).insert(
          TeethRecordsCompanion.insert(
            babyId: babyId,
            toothPosition: toothPosition,
            eruptedAt: eruptedAt,
            notes: Value(notes),
          ),
        );
    return (await getTeethRecord(id))!;
  }

  /// Get a single teeth record by id.
  Future<TeethRecord?> getTeethRecord(int id) {
    return (_db.select(_db.teethRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all teeth records for a baby.
  Future<List<TeethRecord>> getTeethForBaby(int babyId) {
    return (_db.select(_db.teethRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..orderBy([(t) => OrderingTerm.asc(t.eruptedAt)]))
        .get();
  }

  /// Watch all teeth records for a baby (reactive stream).
  Stream<List<TeethRecord>> watchTeethForBaby(int babyId) {
    return (_db.select(_db.teethRecords)
          ..where((t) => t.babyId.equals(babyId))
          ..orderBy([(t) => OrderingTerm.asc(t.eruptedAt)]))
        .watch();
  }

  /// Update the eruption date for a tooth record.
  Future<void> updateEruptionDate(int id, DateTime eruptedAt) {
    return (_db.update(_db.teethRecords)..where((t) => t.id.equals(id)))
        .write(TeethRecordsCompanion(eruptedAt: Value(eruptedAt)));
  }

  /// Update notes for a tooth record.
  Future<void> updateNotes(int id, String? notes) {
    return (_db.update(_db.teethRecords)..where((t) => t.id.equals(id)))
        .write(TeethRecordsCompanion(notes: Value(notes)));
  }

  /// Remove a tooth eruption record (undo marking).
  Future<void> clearEruption(int id) {
    return (_db.delete(_db.teethRecords)..where((t) => t.id.equals(id))).go();
  }

  /// Find a tooth record by baby and position.
  Future<TeethRecord?> getToothByPosition(int babyId, String toothPosition) {
    return (_db.select(_db.teethRecords)
          ..where((t) =>
              t.babyId.equals(babyId) &
              t.toothPosition.equals(toothPosition)))
        .getSingleOrNull();
  }
}
