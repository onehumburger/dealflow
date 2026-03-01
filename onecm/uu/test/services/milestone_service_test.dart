import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/milestone_service.dart';

void main() {
  late MilestoneService service;

  setUp(() {
    service = MilestoneService();
  });

  group('ExpectedMilestone data class', () {
    test('has required fields', () {
      const m = ExpectedMilestone(
        category: 'motor',
        title: 'Head control',
        description: 'Holds head steady when upright',
        expectedAgeMonths: 2,
      );
      expect(m.category, 'motor');
      expect(m.title, 'Head control');
      expect(m.description, 'Holds head steady when upright');
      expect(m.expectedAgeMonths, 2);
    });
  });

  group('allExpectedMilestones', () {
    test('contains milestones for all four categories', () {
      final milestones = service.allExpectedMilestones;
      final categories = milestones.map((m) => m.category).toSet();
      expect(categories, containsAll(['motor', 'language', 'social', 'cognitive']));
    });

    test('has at least 5 milestones per category', () {
      final milestones = service.allExpectedMilestones;
      for (final cat in ['motor', 'language', 'social', 'cognitive']) {
        final count = milestones.where((m) => m.category == cat).length;
        expect(count, greaterThanOrEqualTo(5),
            reason: '$cat should have at least 5 milestones');
      }
    });

    test('milestones cover the 0-36 month range', () {
      final milestones = service.allExpectedMilestones;
      final ages = milestones.map((m) => m.expectedAgeMonths).toList();
      expect(ages.any((a) => a <= 3), isTrue,
          reason: 'Should have early milestones (0-3 months)');
      expect(ages.any((a) => a >= 24), isTrue,
          reason: 'Should have late milestones (24+ months)');
    });

    test('milestones are sorted by expectedAgeMonths within each category', () {
      final milestones = service.allExpectedMilestones;
      for (final cat in ['motor', 'language', 'social', 'cognitive']) {
        final catMilestones =
            milestones.where((m) => m.category == cat).toList();
        for (int i = 1; i < catMilestones.length; i++) {
          expect(catMilestones[i].expectedAgeMonths,
              greaterThanOrEqualTo(catMilestones[i - 1].expectedAgeMonths),
              reason: '$cat milestones should be sorted by age');
        }
      }
    });
  });

  group('getExpectedMilestonesForAge', () {
    test('returns milestones up to the given age', () {
      final milestones = service.getExpectedMilestonesForAge(6);
      expect(milestones, isNotEmpty);
      for (final m in milestones) {
        expect(m.expectedAgeMonths, lessThanOrEqualTo(6));
      }
    });

    test('returns more milestones for older age', () {
      final at6 = service.getExpectedMilestonesForAge(6);
      final at18 = service.getExpectedMilestonesForAge(18);
      expect(at18.length, greaterThan(at6.length));
    });

    test('returns empty for age 0 (no milestones expected at birth)', () {
      // Age 0 means just born, so milestones expected at age 0 only
      final milestones = service.getExpectedMilestonesForAge(0);
      for (final m in milestones) {
        expect(m.expectedAgeMonths, 0);
      }
    });

    test('can filter by category', () {
      final motorOnly =
          service.getExpectedMilestonesForAge(12, category: 'motor');
      for (final m in motorOnly) {
        expect(m.category, 'motor');
        expect(m.expectedAgeMonths, lessThanOrEqualTo(12));
      }
    });
  });

  group('getUpcomingMilestones', () {
    test('returns milestones expected within the next 1-2 months', () {
      final upcoming = service.getUpcomingMilestones(
        babyAgeMonths: 6,
        achievedTitles: {},
      );
      expect(upcoming, isNotEmpty);
      for (final m in upcoming) {
        // Upcoming means expected at age 7 or 8 (current age + 1 to +2)
        expect(m.expectedAgeMonths, greaterThan(6));
        expect(m.expectedAgeMonths, lessThanOrEqualTo(8));
      }
    });

    test('excludes already achieved milestones', () {
      final allUpcoming = service.getUpcomingMilestones(
        babyAgeMonths: 6,
        achievedTitles: {},
      );
      if (allUpcoming.isEmpty) return; // Skip if no upcoming at this age

      final firstTitle = allUpcoming.first.title;
      final filtered = service.getUpcomingMilestones(
        babyAgeMonths: 6,
        achievedTitles: {firstTitle},
      );
      expect(filtered.length, allUpcoming.length - 1);
    });

    test('returns empty if all upcoming milestones are achieved', () {
      final allUpcoming = service.getUpcomingMilestones(
        babyAgeMonths: 6,
        achievedTitles: {},
      );
      final allTitles = allUpcoming.map((m) => m.title).toSet();
      final filtered = service.getUpcomingMilestones(
        babyAgeMonths: 6,
        achievedTitles: allTitles,
      );
      expect(filtered, isEmpty);
    });
  });

  group('getOverdueMilestones', () {
    test('returns milestones past expected age + buffer that are not achieved', () {
      // Buffer is typically 2 months
      // If baby is 6 months old, milestones expected at 4 months or earlier
      // that aren't achieved are overdue (expected + buffer <= current age)
      final overdue = service.getOverdueMilestones(
        babyAgeMonths: 6,
        achievedTitles: {},
        bufferMonths: 2,
      );
      expect(overdue, isNotEmpty);
      for (final m in overdue) {
        expect(m.expectedAgeMonths + 2, lessThanOrEqualTo(6));
      }
    });

    test('does not include achieved milestones', () {
      final allOverdue = service.getOverdueMilestones(
        babyAgeMonths: 12,
        achievedTitles: {},
        bufferMonths: 2,
      );
      final allTitles = allOverdue.map((m) => m.title).toSet();
      final filtered = service.getOverdueMilestones(
        babyAgeMonths: 12,
        achievedTitles: allTitles,
        bufferMonths: 2,
      );
      expect(filtered, isEmpty);
    });

    test('larger buffer means fewer overdue milestones', () {
      final withSmallBuffer = service.getOverdueMilestones(
        babyAgeMonths: 12,
        achievedTitles: {},
        bufferMonths: 1,
      );
      final withLargeBuffer = service.getOverdueMilestones(
        babyAgeMonths: 12,
        achievedTitles: {},
        bufferMonths: 3,
      );
      expect(withLargeBuffer.length, lessThanOrEqualTo(withSmallBuffer.length));
    });

    test('returns empty for very young baby', () {
      final overdue = service.getOverdueMilestones(
        babyAgeMonths: 1,
        achievedTitles: {},
        bufferMonths: 2,
      );
      // At 1 month old with a 2-month buffer, nothing should be overdue
      expect(overdue, isEmpty);
    });
  });

  group('getDelayAlerts', () {
    test('returns gentle alerts for significantly delayed milestones', () {
      // Baby is 18 months old and has achieved nothing
      final alerts = service.getDelayAlerts(
        babyAgeMonths: 18,
        achievedTitles: {},
      );
      expect(alerts, isNotEmpty);
      for (final alert in alerts) {
        expect(alert.milestone, isNotNull);
        expect(alert.message, isNotEmpty);
        expect(alert.severity, isIn(['info', 'gentle', 'concern']));
      }
    });

    test('returns no alerts when all milestones are achieved', () {
      final allExpected = service.getExpectedMilestonesForAge(18);
      final allTitles = allExpected.map((m) => m.title).toSet();
      final alerts = service.getDelayAlerts(
        babyAgeMonths: 18,
        achievedTitles: allTitles,
      );
      expect(alerts, isEmpty);
    });

    test('severity increases with delay', () {
      // Baby is 36 months old and has no 2-month milestones achieved
      final alerts = service.getDelayAlerts(
        babyAgeMonths: 36,
        achievedTitles: {},
      );
      // At least some should be 'concern' level since they're very delayed
      final concernAlerts =
          alerts.where((a) => a.severity == 'concern').toList();
      expect(concernAlerts, isNotEmpty);
    });

    test('returns empty for newborn', () {
      final alerts = service.getDelayAlerts(
        babyAgeMonths: 0,
        achievedTitles: {},
      );
      expect(alerts, isEmpty);
    });
  });

  group('calculateBabyAgeMonths', () {
    test('calculates age correctly', () {
      final dob = DateTime(2025, 1, 15);
      final now = DateTime(2025, 7, 15);
      expect(MilestoneService.calculateBabyAgeMonths(dob, now), 6);
    });

    test('handles partial months', () {
      final dob = DateTime(2025, 1, 15);
      final now = DateTime(2025, 7, 10);
      // 5 months and 25 days => 5 months
      expect(MilestoneService.calculateBabyAgeMonths(dob, now), 5);
    });

    test('returns 0 for same month', () {
      final dob = DateTime(2025, 6, 1);
      final now = DateTime(2025, 6, 20);
      expect(MilestoneService.calculateBabyAgeMonths(dob, now), 0);
    });

    test('handles year boundary', () {
      final dob = DateTime(2024, 11, 15);
      final now = DateTime(2025, 2, 15);
      expect(MilestoneService.calculateBabyAgeMonths(dob, now), 3);
    });
  });
}
