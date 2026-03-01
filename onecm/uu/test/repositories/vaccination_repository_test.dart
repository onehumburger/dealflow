import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/vaccination_repository.dart';

void main() {
  late AppDatabase db;
  late VaccinationRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = VaccinationRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('VaccinationRepository', () {
    test('createVaccination inserts and returns a vaccination', () async {
      final vaccination = await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
        nextDueAt: DateTime(2026, 4, 1),
      );

      expect(vaccination.babyId, 1);
      expect(vaccination.vaccineName, 'Hepatitis B');
      expect(vaccination.doseNumber, 1);
      expect(vaccination.nextDueAt, DateTime(2026, 4, 1));
      expect(vaccination.administeredAt, isNull);
      expect(vaccination.provider, isNull);
      expect(vaccination.notes, isNull);
    });

    test('createVaccination with all fields', () async {
      final vaccination = await repo.createVaccination(
        babyId: 1,
        vaccineName: 'DTaP',
        doseNumber: 2,
        administeredAt: DateTime(2026, 3, 1),
        nextDueAt: DateTime(2026, 5, 1),
        provider: 'Dr. Smith',
        notes: 'No reaction observed',
      );

      expect(vaccination.vaccineName, 'DTaP');
      expect(vaccination.doseNumber, 2);
      expect(vaccination.administeredAt, DateTime(2026, 3, 1));
      expect(vaccination.nextDueAt, DateTime(2026, 5, 1));
      expect(vaccination.provider, 'Dr. Smith');
      expect(vaccination.notes, 'No reaction observed');
    });

    test('getVaccination returns null for non-existent id', () async {
      final result = await repo.getVaccination(999);
      expect(result, isNull);
    });

    test('getVaccinationsForBaby returns vaccinations for specific baby',
        () async {
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
      );
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'DTaP',
        doseNumber: 1,
      );
      await repo.createVaccination(
        babyId: 2,
        vaccineName: 'MMR',
        doseNumber: 1,
      );

      final vaccinations = await repo.getVaccinationsForBaby(1);
      expect(vaccinations.length, 2);
      expect(vaccinations.every((v) => v.babyId == 1), isTrue);
    });

    test('getVaccinationsForBaby orders by vaccineName then doseNumber',
        () async {
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'MMR',
        doseNumber: 1,
      );
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'DTaP',
        doseNumber: 2,
      );
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'DTaP',
        doseNumber: 1,
      );

      final vaccinations = await repo.getVaccinationsForBaby(1);
      expect(vaccinations[0].vaccineName, 'DTaP');
      expect(vaccinations[0].doseNumber, 1);
      expect(vaccinations[1].vaccineName, 'DTaP');
      expect(vaccinations[1].doseNumber, 2);
      expect(vaccinations[2].vaccineName, 'MMR');
    });

    test('markAdministered updates the administeredAt field', () async {
      final vaccination = await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
      );
      expect(vaccination.administeredAt, isNull);

      final adminDate = DateTime(2026, 3, 1);
      await repo.markAdministered(vaccination.id, adminDate);

      final updated = await repo.getVaccination(vaccination.id);
      expect(updated!.administeredAt, adminDate);
    });

    test('markAdministered with provider updates both fields', () async {
      final vaccination = await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
      );

      final adminDate = DateTime(2026, 3, 1);
      await repo.markAdministered(vaccination.id, adminDate,
          provider: 'Dr. Jones');

      final updated = await repo.getVaccination(vaccination.id);
      expect(updated!.administeredAt, adminDate);
      expect(updated.provider, 'Dr. Jones');
    });

    test('updateVaccination updates notes', () async {
      final vaccination = await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
      );

      await repo.updateVaccination(
        vaccination.id,
        notes: 'Mild fever after',
      );

      final updated = await repo.getVaccination(vaccination.id);
      expect(updated!.notes, 'Mild fever after');
    });

    test('updateVaccination updates nextDueAt', () async {
      final vaccination = await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
        nextDueAt: DateTime(2026, 4, 1),
      );

      final newDate = DateTime(2026, 5, 1);
      await repo.updateVaccination(
        vaccination.id,
        nextDueAt: newDate,
      );

      final updated = await repo.getVaccination(vaccination.id);
      expect(updated!.nextDueAt, newDate);
    });

    test('deleteVaccination removes the vaccination', () async {
      final vaccination = await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
      );

      await repo.deleteVaccination(vaccination.id);

      final result = await repo.getVaccination(vaccination.id);
      expect(result, isNull);
    });

    test('getAdministeredVaccinations returns only administered ones',
        () async {
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
        administeredAt: DateTime(2026, 1, 1),
      );
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'DTaP',
        doseNumber: 1,
      );
      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'MMR',
        doseNumber: 1,
        administeredAt: DateTime(2026, 2, 1),
      );

      final administered = await repo.getAdministeredVaccinations(1);
      expect(administered.length, 2);
      expect(administered.every((v) => v.administeredAt != null), isTrue);
    });

    test('watchVaccinationsForBaby emits updates', () async {
      final stream = repo.watchVaccinationsForBaby(1);

      final firstEmit = await stream.first;
      expect(firstEmit, isEmpty);

      await repo.createVaccination(
        babyId: 1,
        vaccineName: 'Hepatitis B',
        doseNumber: 1,
      );

      final secondEmit = await stream.first;
      expect(secondEmit.length, 1);
      expect(secondEmit.first.vaccineName, 'Hepatitis B');
    });
  });
}
