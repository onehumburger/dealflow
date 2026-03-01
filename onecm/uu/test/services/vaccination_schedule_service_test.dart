import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/vaccination_schedule_service.dart';

void main() {
  late VaccinationScheduleService service;

  setUp(() {
    service = VaccinationScheduleService();
  });

  group('ScheduledVaccine data class', () {
    test('has required fields', () {
      const v = ScheduledVaccine(
        name: 'Hepatitis B',
        doseNumber: 1,
        ageMonths: 0,
        description: 'First dose at birth',
      );
      expect(v.name, 'Hepatitis B');
      expect(v.doseNumber, 1);
      expect(v.ageMonths, 0);
      expect(v.description, 'First dose at birth');
    });

    test('key is combination of name and dose', () {
      const v = ScheduledVaccine(
        name: 'DTaP',
        doseNumber: 3,
        ageMonths: 6,
        description: 'Third dose',
      );
      expect(v.key, 'DTaP#3');
    });
  });

  group('fullSchedule', () {
    test('contains vaccines for all 10 CDC vaccine types', () {
      final schedule = service.fullSchedule;
      final vaccineNames = schedule.map((v) => v.name).toSet();
      expect(vaccineNames, containsAll([
        'Hepatitis B',
        'Rotavirus',
        'DTaP',
        'Hib',
        'PCV13',
        'IPV',
        'Influenza',
        'MMR',
        'Varicella',
        'Hepatitis A',
      ]));
    });

    test('Hepatitis B has 3 doses at birth, 1mo, 6mo', () {
      final hepB = service.fullSchedule
          .where((v) => v.name == 'Hepatitis B')
          .toList();
      expect(hepB.length, 3);
      expect(hepB.map((v) => v.ageMonths).toList(), containsAll([0, 1, 6]));
      expect(hepB.map((v) => v.doseNumber).toList(), containsAll([1, 2, 3]));
    });

    test('Rotavirus has 3 doses at 2, 4, 6 months', () {
      final rv = service.fullSchedule
          .where((v) => v.name == 'Rotavirus')
          .toList();
      expect(rv.length, 3);
      expect(rv.map((v) => v.ageMonths).toList(), containsAll([2, 4, 6]));
    });

    test('DTaP has 4 doses at 2, 4, 6, 15 months', () {
      final dtap = service.fullSchedule
          .where((v) => v.name == 'DTaP')
          .toList();
      expect(dtap.length, 4);
      expect(
          dtap.map((v) => v.ageMonths).toList(), containsAll([2, 4, 6, 15]));
    });

    test('MMR has 1 dose at 12 months', () {
      final mmr = service.fullSchedule
          .where((v) => v.name == 'MMR')
          .toList();
      expect(mmr.length, 1);
      expect(mmr.first.ageMonths, 12);
      expect(mmr.first.doseNumber, 1);
    });

    test('schedule is sorted by ageMonths', () {
      final schedule = service.fullSchedule;
      for (int i = 1; i < schedule.length; i++) {
        expect(schedule[i].ageMonths,
            greaterThanOrEqualTo(schedule[i - 1].ageMonths));
      }
    });

    test('all doses cover 0-18 months range', () {
      final schedule = service.fullSchedule;
      final ages = schedule.map((v) => v.ageMonths).toSet();
      expect(ages.any((a) => a == 0), isTrue,
          reason: 'Should have birth vaccines');
      expect(ages.any((a) => a >= 12), isTrue,
          reason: 'Should have 12+ month vaccines');
    });
  });

  group('getScheduleForAge', () {
    test('returns vaccines due up to the given age', () {
      final vaccines = service.getScheduleForAge(6);
      expect(vaccines, isNotEmpty);
      for (final v in vaccines) {
        expect(v.ageMonths, lessThanOrEqualTo(6));
      }
    });

    test('returns more vaccines for older age', () {
      final at2 = service.getScheduleForAge(2);
      final at12 = service.getScheduleForAge(12);
      expect(at12.length, greaterThan(at2.length));
    });

    test('returns birth vaccines for age 0', () {
      final atBirth = service.getScheduleForAge(0);
      expect(atBirth, isNotEmpty);
      expect(atBirth.every((v) => v.ageMonths == 0), isTrue);
      expect(atBirth.any((v) => v.name == 'Hepatitis B'), isTrue);
    });

    test('returns all vaccines for age 36', () {
      final all = service.getScheduleForAge(36);
      expect(all.length, service.fullSchedule.length);
    });
  });

  group('getUpcomingVaccinations', () {
    test('returns next due vaccines within 2 months', () {
      final upcoming = service.getUpcomingVaccinations(1);
      expect(upcoming, isNotEmpty);
      for (final v in upcoming) {
        expect(v.ageMonths, greaterThan(1));
        expect(v.ageMonths, lessThanOrEqualTo(3));
      }
    });

    test('returns 2-month vaccines when baby is newborn', () {
      final upcoming = service.getUpcomingVaccinations(0);
      expect(upcoming, isNotEmpty);
      // Should include the 1-month and 2-month vaccines
      expect(upcoming.any((v) => v.ageMonths <= 2), isTrue);
    });

    test('returns empty for very old age with no more vaccines', () {
      final upcoming = service.getUpcomingVaccinations(36);
      expect(upcoming, isEmpty);
    });
  });

  group('getOverdueVaccinations', () {
    test('returns overdue vaccines not yet administered', () {
      // Baby is 6 months old, nothing administered
      final overdue = service.getOverdueVaccinations(6, {});
      expect(overdue, isNotEmpty);
      for (final v in overdue) {
        expect(v.ageMonths, lessThan(6));
      }
    });

    test('excludes administered vaccines', () {
      final allOverdue = service.getOverdueVaccinations(6, {});
      // Administer some
      final administered = {allOverdue.first.key};
      final filtered = service.getOverdueVaccinations(6, administered);
      expect(filtered.length, allOverdue.length - 1);
    });

    test('returns empty when all are administered', () {
      final allDue = service.getScheduleForAge(6);
      final allKeys = allDue.map((v) => v.key).toSet();
      final overdue = service.getOverdueVaccinations(6, allKeys);
      expect(overdue, isEmpty);
    });

    test('returns empty for newborn (nothing overdue yet)', () {
      final overdue = service.getOverdueVaccinations(0, {});
      expect(overdue, isEmpty);
    });

    test('does not include current month vaccines as overdue', () {
      // At 2 months, 2-month vaccines are due but not overdue
      final overdue = service.getOverdueVaccinations(2, {});
      for (final v in overdue) {
        expect(v.ageMonths, lessThan(2));
      }
    });
  });

  group('getVaccineStatus', () {
    test('returns administered for given vaccines', () {
      final status = service.getVaccineStatus(
        ageMonths: 6,
        administeredKeys: {'Hepatitis B#1'},
      );
      final hepB1 = status.firstWhere((s) => s.vaccine.key == 'Hepatitis B#1');
      expect(hepB1.status, VaccineStatus.administered);
    });

    test('returns overdue for past-due unadministered vaccines', () {
      final status = service.getVaccineStatus(
        ageMonths: 6,
        administeredKeys: {},
      );
      final hepB1 = status.firstWhere((s) => s.vaccine.key == 'Hepatitis B#1');
      expect(hepB1.status, VaccineStatus.overdue);
    });

    test('returns upcoming for near-future vaccines', () {
      final status = service.getVaccineStatus(
        ageMonths: 5,
        administeredKeys: {},
      );
      final upcoming = status.where((s) => s.status == VaccineStatus.upcoming);
      expect(upcoming, isNotEmpty);
    });

    test('returns future for far-future vaccines', () {
      final status = service.getVaccineStatus(
        ageMonths: 0,
        administeredKeys: {},
      );
      final future = status.where((s) => s.status == VaccineStatus.future);
      expect(future, isNotEmpty);
    });
  });
}
