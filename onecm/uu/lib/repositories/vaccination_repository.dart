import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class VaccinationRepository {
  final AppDatabase _db;
  VaccinationRepository(this._db);

  Future<Vaccination> createVaccination({
    required int babyId,
    required String vaccineName,
    int? doseNumber,
    DateTime? administeredAt,
    DateTime? nextDueAt,
    String? provider,
    String? notes,
  }) async {
    final id = await _db.into(_db.vaccinations).insert(
          VaccinationsCompanion.insert(
            babyId: babyId,
            vaccineName: vaccineName,
            doseNumber: Value(doseNumber),
            administeredAt: Value(administeredAt),
            nextDueAt: Value(nextDueAt),
            provider: Value(provider),
            notes: Value(notes),
          ),
        );
    return (await getVaccination(id))!;
  }

  Future<Vaccination?> getVaccination(int id) {
    return (_db.select(_db.vaccinations)..where((v) => v.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Vaccination>> getVaccinationsForBaby(int babyId) {
    return (_db.select(_db.vaccinations)
          ..where((v) => v.babyId.equals(babyId))
          ..orderBy([
            (v) => OrderingTerm.asc(v.vaccineName),
            (v) => OrderingTerm.asc(v.doseNumber),
          ]))
        .get();
  }

  Stream<List<Vaccination>> watchVaccinationsForBaby(int babyId) {
    return (_db.select(_db.vaccinations)
          ..where((v) => v.babyId.equals(babyId))
          ..orderBy([
            (v) => OrderingTerm.asc(v.vaccineName),
            (v) => OrderingTerm.asc(v.doseNumber),
          ]))
        .watch();
  }

  Future<List<Vaccination>> getAdministeredVaccinations(int babyId) {
    return (_db.select(_db.vaccinations)
          ..where(
              (v) => v.babyId.equals(babyId) & v.administeredAt.isNotNull())
          ..orderBy([(v) => OrderingTerm.desc(v.administeredAt)]))
        .get();
  }

  Future<void> markAdministered(int id, DateTime administeredAt,
      {String? provider}) {
    return (_db.update(_db.vaccinations)..where((v) => v.id.equals(id))).write(
      VaccinationsCompanion(
        administeredAt: Value(administeredAt),
        provider:
            provider != null ? Value(provider) : const Value.absent(),
      ),
    );
  }

  Future<void> updateVaccination(
    int id, {
    String? notes,
    DateTime? nextDueAt,
    String? provider,
  }) {
    return (_db.update(_db.vaccinations)..where((v) => v.id.equals(id))).write(
      VaccinationsCompanion(
        notes: notes != null ? Value(notes) : const Value.absent(),
        nextDueAt:
            nextDueAt != null ? Value(nextDueAt) : const Value.absent(),
        provider:
            provider != null ? Value(provider) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteVaccination(int id) {
    return (_db.delete(_db.vaccinations)..where((v) => v.id.equals(id))).go();
  }
}
