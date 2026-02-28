import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/daily_log_repository.dart';
import 'package:uu/services/daily_summary_service.dart';

void main() {
  late AppDatabase db;
  late DailyLogRepository logRepo;
  late DailySummaryService service;
  late int babyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    logRepo = DailyLogRepository(db);
    service = DailySummaryService(logRepo);
    babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
          name: 'Luna',
          dateOfBirth: DateTime(2025, 6, 15),
        ));
  });

  tearDown(() async => await db.close());

  group('DailySummaryService', () {
    test('empty day returns zero counts', () async {
      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.feedingCount, 0);
      expect(summary.totalSleepMinutes, 0);
      expect(summary.diaperCount, 0);
    });

    test('counts feedings correctly', () async {
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 8, 0),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 11, 0),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 14, 0),
      );
      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.feedingCount, 3);
    });

    test('sums sleep duration', () async {
      await logRepo.createLog(
        babyId: babyId,
        type: 'sleep',
        startedAt: DateTime(2025, 7, 15, 13, 0),
        endedAt: DateTime(2025, 7, 15, 15, 0),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'sleep',
        startedAt: DateTime(2025, 7, 15, 20, 0),
        endedAt: DateTime(2025, 7, 15, 23, 0),
      );
      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.totalSleepMinutes, 300);
    });

    test('counts diapers correctly', () async {
      await logRepo.createLog(
        babyId: babyId,
        type: 'diaper',
        startedAt: DateTime(2025, 7, 15, 8, 0),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'diaper',
        startedAt: DateTime(2025, 7, 15, 12, 0),
      );
      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.diaperCount, 2);
    });

    test('finds last feeding time', () async {
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 8, 0),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime(2025, 7, 15, 14, 30),
      );
      final summary = await service.getSummary(babyId, DateTime(2025, 7, 15));
      expect(summary.lastFeedingAt, DateTime(2025, 7, 15, 14, 30));
    });
  });
}
