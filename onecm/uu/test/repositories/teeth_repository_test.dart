import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/teeth_repository.dart';

void main() {
  late AppDatabase db;
  late TeethRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TeethRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TeethRepository', () {
    test('markErupted inserts and returns a teeth record', () async {
      final record = await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );

      expect(record.babyId, 1);
      expect(record.toothPosition, 'A');
      expect(record.eruptedAt, DateTime(2026, 3, 1));
      expect(record.notes, isNull);
    });

    test('markErupted with notes', () async {
      final record = await repo.markErupted(
        babyId: 1,
        toothPosition: 'K',
        eruptedAt: DateTime(2026, 2, 15),
        notes: 'First tooth!',
      );

      expect(record.notes, 'First tooth!');
    });

    test('getTeethRecord returns null for non-existent id', () async {
      final result = await repo.getTeethRecord(999);
      expect(result, isNull);
    });

    test('getTeethForBaby returns records for specific baby', () async {
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'K',
        eruptedAt: DateTime(2026, 2, 15),
      );
      await repo.markErupted(
        babyId: 2,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );

      final records = await repo.getTeethForBaby(1);
      expect(records.length, 2);
      expect(records.every((r) => r.babyId == 1), isTrue);
    });

    test('getTeethForBaby orders by eruptedAt ascending', () async {
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'B',
        eruptedAt: DateTime(2026, 3, 1),
      );
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'K',
        eruptedAt: DateTime(2026, 1, 15),
      );
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 2, 10),
      );

      final records = await repo.getTeethForBaby(1);
      expect(records[0].toothPosition, 'K');
      expect(records[1].toothPosition, 'A');
      expect(records[2].toothPosition, 'B');
    });

    test('getTeethForBaby returns empty list when no records', () async {
      final records = await repo.getTeethForBaby(1);
      expect(records, isEmpty);
    });

    test('updateEruptionDate updates the date', () async {
      final record = await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );

      await repo.updateEruptionDate(record.id, DateTime(2026, 2, 28));

      final updated = await repo.getTeethRecord(record.id);
      expect(updated!.eruptedAt, DateTime(2026, 2, 28));
    });

    test('updateNotes updates the notes field', () async {
      final record = await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );

      await repo.updateNotes(record.id, 'Noticed some fussiness');

      final updated = await repo.getTeethRecord(record.id);
      expect(updated!.notes, 'Noticed some fussiness');
    });

    test('updateNotes can clear notes', () async {
      final record = await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
        notes: 'Original note',
      );

      await repo.updateNotes(record.id, null);

      final updated = await repo.getTeethRecord(record.id);
      expect(updated!.notes, isNull);
    });

    test('clearEruption removes the record', () async {
      final record = await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );

      await repo.clearEruption(record.id);

      final result = await repo.getTeethRecord(record.id);
      expect(result, isNull);
    });

    test('getToothByPosition finds a record', () async {
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'K',
        eruptedAt: DateTime(2026, 2, 15),
      );

      final result = await repo.getToothByPosition(1, 'K');
      expect(result, isNotNull);
      expect(result!.toothPosition, 'K');
      expect(result.eruptedAt, DateTime(2026, 2, 15));
    });

    test('getToothByPosition returns null for non-existent position', () async {
      final result = await repo.getToothByPosition(1, 'A');
      expect(result, isNull);
    });

    test('getToothByPosition scoped to baby', () async {
      await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );
      await repo.markErupted(
        babyId: 2,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 5),
      );

      final result = await repo.getToothByPosition(2, 'A');
      expect(result!.eruptedAt, DateTime(2026, 3, 5));
    });

    test('watchTeethForBaby emits updates', () async {
      final stream = repo.watchTeethForBaby(1);

      final firstEmit = await stream.first;
      expect(firstEmit, isEmpty);

      await repo.markErupted(
        babyId: 1,
        toothPosition: 'A',
        eruptedAt: DateTime(2026, 3, 1),
      );

      final secondEmit = await stream.first;
      expect(secondEmit.length, 1);
      expect(secondEmit.first.toothPosition, 'A');
    });
  });
}
