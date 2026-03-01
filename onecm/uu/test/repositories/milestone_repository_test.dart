import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/milestone_repository.dart';

void main() {
  late AppDatabase db;
  late MilestoneRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MilestoneRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MilestoneRepository', () {
    test('createMilestone inserts and returns a milestone', () async {
      final milestone = await repo.createMilestone(
        babyId: 1,
        category: 'motor',
        title: 'Head control',
        description: 'Holds head steady',
        expectedAgeMonths: 2,
      );

      expect(milestone.babyId, 1);
      expect(milestone.category, 'motor');
      expect(milestone.title, 'Head control');
      expect(milestone.description, 'Holds head steady');
      expect(milestone.expectedAgeMonths, 2);
      expect(milestone.achievedAt, isNull);
    });

    test('createMilestone with achievedAt', () async {
      final achieved = DateTime(2026, 1, 15);
      final milestone = await repo.createMilestone(
        babyId: 1,
        category: 'language',
        title: 'Cooing',
        achievedAt: achieved,
        expectedAgeMonths: 2,
      );

      expect(milestone.achievedAt, achieved);
    });

    test('getMilestone returns null for non-existent id', () async {
      final result = await repo.getMilestone(999);
      expect(result, isNull);
    });

    test('getMilestonesForBaby returns milestones for specific baby', () async {
      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'A', expectedAgeMonths: 2);
      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'B', expectedAgeMonths: 4);
      await repo.createMilestone(
          babyId: 2, category: 'motor', title: 'C', expectedAgeMonths: 2);

      final milestones = await repo.getMilestonesForBaby(1);
      expect(milestones.length, 2);
      expect(milestones.every((m) => m.babyId == 1), isTrue);
    });

    test('getMilestonesForBaby filters by category', () async {
      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'A', expectedAgeMonths: 2);
      await repo.createMilestone(
          babyId: 1, category: 'language', title: 'B', expectedAgeMonths: 2);
      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'C', expectedAgeMonths: 4);

      final motorOnly =
          await repo.getMilestonesForBaby(1, category: 'motor');
      expect(motorOnly.length, 2);
      expect(motorOnly.every((m) => m.category == 'motor'), isTrue);
    });

    test('getMilestonesForBaby orders by expectedAgeMonths', () async {
      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'Walking', expectedAgeMonths: 12);
      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'Head control', expectedAgeMonths: 2);
      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'Sitting', expectedAgeMonths: 6);

      final milestones = await repo.getMilestonesForBaby(1);
      expect(milestones[0].title, 'Head control');
      expect(milestones[1].title, 'Sitting');
      expect(milestones[2].title, 'Walking');
    });

    test('markAchieved updates the achievedAt field', () async {
      final milestone = await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'A', expectedAgeMonths: 2);
      expect(milestone.achievedAt, isNull);

      final achievedDate = DateTime(2026, 3, 1);
      await repo.markAchieved(milestone.id, achievedDate);

      final updated = await repo.getMilestone(milestone.id);
      expect(updated!.achievedAt, achievedDate);
    });

    test('updateMilestone updates description', () async {
      final milestone = await repo.createMilestone(
        babyId: 1,
        category: 'motor',
        title: 'A',
        description: 'Original',
        expectedAgeMonths: 2,
      );

      await repo.updateMilestone(milestone.id, description: 'Updated');

      final updated = await repo.getMilestone(milestone.id);
      expect(updated!.description, 'Updated');
    });

    test('deleteMilestone removes the milestone', () async {
      final milestone = await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'A', expectedAgeMonths: 2);

      await repo.deleteMilestone(milestone.id);

      final result = await repo.getMilestone(milestone.id);
      expect(result, isNull);
    });

    test('watchMilestonesForBaby emits updates', () async {
      final stream = repo.watchMilestonesForBaby(1);

      final firstEmit = await stream.first;
      expect(firstEmit, isEmpty);

      await repo.createMilestone(
          babyId: 1, category: 'motor', title: 'A', expectedAgeMonths: 2);

      final secondEmit = await stream.first;
      expect(secondEmit.length, 1);
    });
  });
}
