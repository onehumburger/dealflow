import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/health_event_repository.dart';

void main() {
  late AppDatabase db;
  late HealthEventRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HealthEventRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('HealthEventRepository', () {
    test('createHealthEvent inserts and returns a health event', () async {
      final event = await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Common Cold',
        startedAt: DateTime(2026, 3, 1),
      );

      expect(event.babyId, 1);
      expect(event.type, 'illness');
      expect(event.title, 'Common Cold');
      expect(event.startedAt, DateTime(2026, 3, 1));
      expect(event.description, isNull);
      expect(event.endedAt, isNull);
      expect(event.metadata, isNull);
    });

    test('createHealthEvent with all fields', () async {
      final event = await repo.createHealthEvent(
        babyId: 1,
        type: 'medication',
        title: 'Tylenol',
        description: 'Infant drops for fever',
        startedAt: DateTime(2026, 3, 1),
        endedAt: DateTime(2026, 3, 3),
        metadata: '{"dosage":"2.5ml","frequency":"every 4 hours"}',
      );

      expect(event.type, 'medication');
      expect(event.title, 'Tylenol');
      expect(event.description, 'Infant drops for fever');
      expect(event.startedAt, DateTime(2026, 3, 1));
      expect(event.endedAt, DateTime(2026, 3, 3));
      expect(event.metadata,
          '{"dosage":"2.5ml","frequency":"every 4 hours"}');
    });

    test('getHealthEvent returns null for non-existent id', () async {
      final result = await repo.getHealthEvent(999);
      expect(result, isNull);
    });

    test('getHealthEventsForBaby returns events for specific baby', () async {
      await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 2, 1),
      );
      await repo.createHealthEvent(
        babyId: 1,
        type: 'doctor_visit',
        title: 'Checkup',
        startedAt: DateTime(2026, 3, 1),
      );
      await repo.createHealthEvent(
        babyId: 2,
        type: 'illness',
        title: 'Flu',
        startedAt: DateTime(2026, 3, 1),
      );

      final events = await repo.getHealthEventsForBaby(1);
      expect(events.length, 2);
      expect(events.every((e) => e.babyId == 1), isTrue);
    });

    test('getHealthEventsForBaby orders by startedAt descending', () async {
      await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 1, 1),
      );
      await repo.createHealthEvent(
        babyId: 1,
        type: 'doctor_visit',
        title: 'Checkup',
        startedAt: DateTime(2026, 3, 1),
      );
      await repo.createHealthEvent(
        babyId: 1,
        type: 'medication',
        title: 'Tylenol',
        startedAt: DateTime(2026, 2, 1),
      );

      final events = await repo.getHealthEventsForBaby(1);
      expect(events[0].title, 'Checkup');
      expect(events[1].title, 'Tylenol');
      expect(events[2].title, 'Cold');
    });

    test('getHealthEventsByType filters correctly', () async {
      await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 2, 1),
      );
      await repo.createHealthEvent(
        babyId: 1,
        type: 'doctor_visit',
        title: 'Checkup',
        startedAt: DateTime(2026, 3, 1),
      );
      await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Flu',
        startedAt: DateTime(2026, 3, 5),
      );

      final illnesses = await repo.getHealthEventsByType(1, 'illness');
      expect(illnesses.length, 2);
      expect(illnesses.every((e) => e.type == 'illness'), isTrue);
    });

    test('updateHealthEvent updates description and endedAt', () async {
      final event = await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 3, 1),
      );

      await repo.updateHealthEvent(
        event.id,
        description: 'Runny nose and cough',
        endedAt: DateTime(2026, 3, 5),
      );

      final updated = await repo.getHealthEvent(event.id);
      expect(updated!.description, 'Runny nose and cough');
      expect(updated.endedAt, DateTime(2026, 3, 5));
    });

    test('updateHealthEvent updates metadata', () async {
      final event = await repo.createHealthEvent(
        babyId: 1,
        type: 'medication',
        title: 'Tylenol',
        startedAt: DateTime(2026, 3, 1),
      );

      await repo.updateHealthEvent(
        event.id,
        metadata: '{"dosage":"5ml"}',
      );

      final updated = await repo.getHealthEvent(event.id);
      expect(updated!.metadata, '{"dosage":"5ml"}');
    });

    test('markResolved sets the endedAt date', () async {
      final event = await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 3, 1),
      );
      expect(event.endedAt, isNull);

      final resolvedDate = DateTime(2026, 3, 5);
      await repo.markResolved(event.id, resolvedDate);

      final updated = await repo.getHealthEvent(event.id);
      expect(updated!.endedAt, resolvedDate);
    });

    test('deleteHealthEvent removes the event', () async {
      final event = await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 3, 1),
      );

      await repo.deleteHealthEvent(event.id);

      final result = await repo.getHealthEvent(event.id);
      expect(result, isNull);
    });

    test('getActiveHealthEvents returns events without endedAt', () async {
      await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 3, 1),
      );
      await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Flu',
        startedAt: DateTime(2026, 2, 1),
        endedAt: DateTime(2026, 2, 10),
      );
      await repo.createHealthEvent(
        babyId: 1,
        type: 'medication',
        title: 'Tylenol',
        startedAt: DateTime(2026, 3, 1),
      );

      final active = await repo.getActiveHealthEvents(1);
      expect(active.length, 2);
      expect(active.every((e) => e.endedAt == null), isTrue);
    });

    test('watchHealthEventsForBaby emits updates', () async {
      final stream = repo.watchHealthEventsForBaby(1);

      final firstEmit = await stream.first;
      expect(firstEmit, isEmpty);

      await repo.createHealthEvent(
        babyId: 1,
        type: 'illness',
        title: 'Cold',
        startedAt: DateTime(2026, 3, 1),
      );

      final secondEmit = await stream.first;
      expect(secondEmit.length, 1);
      expect(secondEmit.first.title, 'Cold');
    });
  });
}
