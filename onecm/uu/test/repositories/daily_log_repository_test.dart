import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/daily_log_repository.dart';

void main() {
  late AppDatabase db;
  late DailyLogRepository repo;
  late int babyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DailyLogRepository(db);
    babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
          name: 'Luna',
          dateOfBirth: DateTime(2025, 6, 15),
        ));
  });

  tearDown(() async => await db.close());

  group('DailyLogRepository', () {
    test('quickLog creates a log with just type and timestamp', () async {
      final log = await repo.quickLog(babyId: babyId, type: 'diaper');
      expect(log.type, 'diaper');
      expect(log.startedAt, isNotNull);
    });

    test('createLog with metadata stores JSON', () async {
      final log = await repo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 8, 0),
        metadata: {'method': 'breast', 'side': 'left'},
      );
      final decoded = jsonDecode(log.metadata!);
      expect(decoded['method'], 'breast');
      expect(decoded['side'], 'left');
    });

    test('getLogsForDay returns only logs from that day', () async {
      await repo.createLog(
          babyId: babyId,
          type: 'feeding',
          startedAt: DateTime(2025, 7, 15, 8, 0));
      await repo.createLog(
          babyId: babyId,
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 20, 0));
      await repo.createLog(
          babyId: babyId,
          type: 'feeding',
          startedAt: DateTime(2025, 7, 16, 8, 0));
      final logs = await repo.getLogsForDay(babyId, DateTime(2025, 7, 15));
      expect(logs.length, 2);
    });

    test('getLogsForDayByType filters correctly', () async {
      await repo.createLog(
          babyId: babyId,
          type: 'feeding',
          startedAt: DateTime(2025, 7, 15, 8, 0));
      await repo.createLog(
          babyId: babyId,
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 20, 0));
      final feedings = await repo.getLogsForDayByType(
          babyId, DateTime(2025, 7, 15), 'feeding');
      expect(feedings.length, 1);
      expect(feedings.first.type, 'feeding');
    });

    test('endLog sets endedAt and calculates duration', () async {
      final log = await repo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 8, 0),
      );
      await repo.endLog(log.id, DateTime(2025, 7, 15, 8, 25));
      final updated = await repo.getLog(log.id);
      expect(updated?.endedAt, DateTime(2025, 7, 15, 8, 25));
      expect(updated?.durationMinutes, 25);
    });
  });
}
