import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/baby_repository.dart';
import 'package:uu/repositories/daily_log_repository.dart';
import 'package:uu/repositories/growth_repository.dart';
import 'package:uu/services/ai/ai_provider.dart';
import 'package:uu/services/ai/baby_context_builder.dart';

void main() {
  late AppDatabase db;
  late BabyRepository babyRepo;
  late DailyLogRepository logRepo;
  late GrowthRepository growthRepo;
  late BabyContextBuilder builder;
  late int babyId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    babyRepo = BabyRepository(db);
    logRepo = DailyLogRepository(db);
    growthRepo = GrowthRepository(db);
    builder = BabyContextBuilder(
      babyRepo: babyRepo,
      growthRepo: growthRepo,
      db: db,
    );

    final baby = await babyRepo.createBaby(
      name: 'Luna',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 180)),
      gender: 'female',
    );
    babyId = baby.id;
  });

  tearDown(() async => await db.close());

  group('BabyContextBuilder', () {
    test('builds context with baby profile', () async {
      final context = await builder.build(babyId);

      expect(context.babyName, 'Luna');
      expect(context.gender, 'female');
      expect(context.ageInMonths, greaterThanOrEqualTo(5));
      expect(context.systemPrompt, contains('Luna'));
      expect(context.systemPrompt, contains('Baby Profile'));
    });

    test('throws for non-existent baby', () async {
      expect(
        () => builder.build(9999),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('includes age information in system prompt', () async {
      final context = await builder.build(babyId);
      // Baby is ~6 months old
      expect(context.systemPrompt, contains('months'));
      expect(context.systemPrompt, contains('days'));
    });

    test('includes gender in system prompt', () async {
      final context = await builder.build(babyId);
      expect(context.systemPrompt, contains('female'));
    });

    test('includes recent activity when logs exist', () async {
      final now = DateTime.now();
      // Add some logs in the last 7 days
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: now.subtract(const Duration(days: 1, hours: 2)),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: now.subtract(const Duration(days: 1, hours: 5)),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'diaper',
        startedAt: now.subtract(const Duration(days: 1, hours: 3)),
      );
      await logRepo.createLog(
        babyId: babyId,
        type: 'sleep',
        startedAt: now.subtract(const Duration(days: 1, hours: 8)),
        endedAt: now.subtract(const Duration(days: 1, hours: 6)),
      );

      final context = await builder.build(babyId);

      expect(context.systemPrompt, contains('Recent Activity'));
      expect(context.systemPrompt, contains('Feedings logged: 2'));
      expect(context.systemPrompt, contains('Diaper changes: 1'));
      expect(context.systemPrompt, contains('Total sleep'));
    });

    test('does not include activity section when no logs', () async {
      final context = await builder.build(babyId);
      expect(context.systemPrompt, isNot(contains('Recent Activity')));
    });

    test('includes growth data with percentiles', () async {
      await growthRepo.addRecord(
        babyId: babyId,
        date: DateTime.now().subtract(const Duration(days: 2)),
        weightKg: 7.3,
        heightCm: 65.7,
        headCircumferenceCm: 42.2,
      );

      final context = await builder.build(babyId);

      expect(context.systemPrompt, contains('Latest Growth Data'));
      expect(context.systemPrompt, contains('7.30 kg'));
      expect(context.systemPrompt, contains('65.7 cm'));
      expect(context.systemPrompt, contains('42.2 cm'));
      expect(context.systemPrompt, contains('percentile'));
    });

    test('includes milestones when they exist', () async {
      await db.into(db.milestones).insert(MilestonesCompanion.insert(
            babyId: babyId,
            category: 'motor',
            title: 'Rolls over',
            achievedAt: Value(DateTime.now().subtract(const Duration(days: 10))),
          ));

      final context = await builder.build(babyId);

      expect(context.systemPrompt, contains('Recent Milestones'));
      expect(context.systemPrompt, contains('Rolls over'));
      expect(context.systemPrompt, contains('motor'));
    });

    test('includes health events when they exist', () async {
      await db.into(db.healthEvents).insert(HealthEventsCompanion.insert(
            babyId: babyId,
            type: 'illness',
            title: 'Mild cold',
          ));

      final context = await builder.build(babyId);

      expect(context.systemPrompt, contains('Recent Health Events'));
      expect(context.systemPrompt, contains('Mild cold'));
      expect(context.systemPrompt, contains('illness'));
    });

    test('includes guidelines and medical disclaimer reference', () async {
      final context = await builder.build(babyId);

      expect(context.systemPrompt, contains('Guidelines'));
      expect(context.systemPrompt, contains('pediatrician'));
      expect(context.systemPrompt, contains(medicalDisclaimer));
    });

    test('includes role description', () async {
      final context = await builder.build(babyId);

      expect(context.systemPrompt, contains('baby care assistant'));
    });

    test('only includes last 7 days of logs', () async {
      // Log from 10 days ago - should NOT be included
      await logRepo.createLog(
        babyId: babyId,
        type: 'feeding',
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
      );

      final context = await builder.build(babyId);

      // With only an old log, the activity section should not appear
      // (the log is outside the 7-day window)
      expect(context.systemPrompt, isNot(contains('Recent Activity')));
    });

    test('handles baby without gender', () async {
      final baby2 = await babyRepo.createBaby(
        name: 'Alex',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 90)),
      );

      final context = await builder.build(baby2.id);

      expect(context.babyName, 'Alex');
      expect(context.gender, isNull);
      expect(context.systemPrompt, contains('Alex'));
      // Should not crash and should not include gender line
    });

    test('sleep minutes calculated correctly in activity summary', () async {
      final now = DateTime.now();
      // Add 2-hour sleep yesterday
      await logRepo.createLog(
        babyId: babyId,
        type: 'sleep',
        startedAt: now.subtract(const Duration(days: 1, hours: 4)),
        endedAt: now.subtract(const Duration(days: 1, hours: 2)),
      );
      // Add 3-hour sleep yesterday
      await logRepo.createLog(
        babyId: babyId,
        type: 'sleep',
        startedAt: now.subtract(const Duration(days: 1, hours: 10)),
        endedAt: now.subtract(const Duration(days: 1, hours: 7)),
      );

      final context = await builder.build(babyId);

      // Total should be 5 hours
      expect(context.systemPrompt, contains('5.0 hours'));
    });

    test('dateOfBirth is set correctly in context', () async {
      final context = await builder.build(babyId);
      final expectedDob = DateTime.now().subtract(const Duration(days: 180));

      // Should be within a day tolerance (since setUp runs at test time)
      expect(
        context.dateOfBirth.difference(expectedDob).inDays.abs(),
        lessThanOrEqualTo(1),
      );
    });
  });
}
