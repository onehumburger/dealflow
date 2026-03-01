import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/daily_summary_service.dart';
import 'package:uu/services/report/caregiver_handoff_service.dart';

void main() {
  late CaregiverHandoffService service;

  setUp(() {
    service = CaregiverHandoffService();
  });

  Baby _makeBaby({
    String name = 'Luna',
    DateTime? dateOfBirth,
    String? gender,
    String? bloodType,
  }) {
    return Baby(
      id: 1,
      name: name,
      dateOfBirth: dateOfBirth ?? DateTime(2025, 6, 15),
      gender: gender,
      bloodType: bloodType,
      createdAt: DateTime(2025, 6, 15),
      updatedAt: DateTime(2025, 6, 15),
    );
  }

  HealthEvent _makeHealthEvent({
    required String type,
    required String title,
    String? description,
    DateTime? startedAt,
  }) {
    return HealthEvent(
      id: 1,
      babyId: 1,
      type: type,
      title: title,
      description: description,
      startedAt: startedAt,
      createdAt: DateTime(2025, 12, 1),
    );
  }

  group('CaregiverHandoffService', () {
    test('generates handoff text with minimal data', () {
      final data = CaregiverHandoffData(baby: _makeBaby());

      final result = service.generateHandoff(data);

      expect(result, contains('CAREGIVER NOTES for Luna'));
      expect(result, contains('Name: Luna'));
      expect(result, contains('DOB:'));
      expect(result, contains('None known'));
      expect(result, contains('FEEDING'));
      expect(result, contains('SLEEP'));
      expect(result, contains('MEDICATIONS'));
      expect(result, contains('None'));
      expect(result, contains('EMERGENCY CONTACT'));
      expect(result, contains('Not provided'));
      expect(result, contains('DOCTOR'));
      expect(result, contains('UU Baby Tracker'));
    });

    test('includes baby gender and blood type when available', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(gender: 'Female', bloodType: 'O+'),
      );

      final result = service.generateHandoff(data);

      expect(result, contains('Gender: Female'));
      expect(result, contains('Blood Type: O+'));
    });

    test('includes allergies', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        allergies: ['Peanuts', 'Dairy'],
      );

      final result = service.generateHandoff(data);

      expect(result, contains('- Peanuts'));
      expect(result, contains('- Dairy'));
      expect(result, isNot(contains('None known')));
    });

    test('includes active health events', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        activeHealthEvents: [
          _makeHealthEvent(
            type: 'illness',
            title: 'Ear infection',
            description: 'Left ear, started 3 days ago',
          ),
        ],
      );

      final result = service.generateHandoff(data);

      expect(result, contains('Ear infection (Illness)'));
      expect(result, contains('Left ear, started 3 days ago'));
    });

    test('includes feeding summary', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        recentSummary: DailySummary(
          feedingCount: 6,
          totalSleepMinutes: 720,
          diaperCount: 8,
          lastFeedingAt: DateTime(2025, 12, 1, 14, 30),
        ),
      );

      final result = service.generateHandoff(data);

      expect(result, contains('Typical feedings per day: 6'));
      expect(result, contains('Last feed:'));
      expect(result, contains('2:30 PM'));
    });

    test('includes sleep summary', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        recentSummary: DailySummary(
          feedingCount: 6,
          totalSleepMinutes: 720,
          diaperCount: 8,
        ),
      );

      final result = service.generateHandoff(data);

      expect(result, contains('Typical daily sleep: 12.0 hours'));
    });

    test('includes medications', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        medications: ['Amoxicillin 5ml twice daily', 'Vitamin D drops'],
      );

      final result = service.generateHandoff(data);

      expect(result, contains('- Amoxicillin 5ml twice daily'));
      expect(result, contains('- Vitamin D drops'));
      // Should not contain "None" when medications exist
      final medSection = result.split('MEDICATIONS')[1].split('\n');
      expect(medSection.where((l) => l.trim() == 'None'), isEmpty);
    });

    test('includes emergency contact', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        emergencyContact: 'Mom: 555-1234, Dad: 555-5678',
      );

      final result = service.generateHandoff(data);

      expect(result, contains('Mom: 555-1234, Dad: 555-5678'));
    });

    test('includes doctor info', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        doctorInfo: 'Dr. Smith, ABC Pediatrics, 555-9999',
      );

      final result = service.generateHandoff(data);

      expect(result, contains('Dr. Smith, ABC Pediatrics, 555-9999'));
    });

    test('includes parent notes when provided', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        parentNotes:
            'Luna likes to be rocked to sleep. Use the white noise machine.',
      );

      final result = service.generateHandoff(data);

      expect(result, contains('IMPORTANT NOTES FROM PARENT'));
      expect(result, contains('Luna likes to be rocked to sleep'));
    });

    test('omits parent notes section when empty', () {
      final data = CaregiverHandoffData(baby: _makeBaby());

      final result = service.generateHandoff(data);

      expect(result, isNot(contains('IMPORTANT NOTES FROM PARENT')));
    });

    test('generates complete handoff with all fields populated', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(gender: 'Female', bloodType: 'A+'),
        recentSummary: DailySummary(
          feedingCount: 5,
          totalSleepMinutes: 660,
          diaperCount: 7,
          lastFeedingAt: DateTime(2025, 12, 1, 10, 0),
        ),
        activeHealthEvents: [
          _makeHealthEvent(type: 'illness', title: 'Cold'),
        ],
        allergies: ['Eggs'],
        medications: ['Ibuprofen as needed'],
        emergencyContact: 'Parent: 555-0000',
        doctorInfo: 'Dr. Lee, 555-1111',
        parentNotes: 'Nap at 1pm.',
      );

      final result = service.generateHandoff(data);

      expect(result, contains('Luna'));
      expect(result, contains('Gender: Female'));
      expect(result, contains('Blood Type: A+'));
      expect(result, contains('- Eggs'));
      expect(result, contains('Cold (Illness)'));
      expect(result, contains('Typical feedings per day: 5'));
      expect(result, contains('11.0 hours'));
      expect(result, contains('- Ibuprofen as needed'));
      expect(result, contains('Parent: 555-0000'));
      expect(result, contains('Dr. Lee, 555-1111'));
      expect(result, contains('Nap at 1pm.'));
    });

    test('handles no recent summary gracefully', () {
      final data = CaregiverHandoffData(
        baby: _makeBaby(),
        recentSummary: null,
      );

      final result = service.generateHandoff(data);

      expect(result, contains('No recent feeding data available.'));
      expect(result, contains('No recent sleep data available.'));
    });
  });
}
