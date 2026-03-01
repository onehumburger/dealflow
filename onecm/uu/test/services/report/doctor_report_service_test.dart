import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/daily_summary_service.dart';
import 'package:uu/services/report/doctor_report_service.dart';

void main() {
  late DoctorReportService service;

  setUp(() {
    service = DoctorReportService();
  });

  Baby _makeBaby({
    String name = 'Luna',
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return Baby(
      id: 1,
      name: name,
      dateOfBirth: dateOfBirth ?? DateTime(2025, 6, 15),
      gender: gender,
      createdAt: DateTime(2025, 6, 15),
      updatedAt: DateTime(2025, 6, 15),
    );
  }

  GrowthRecord _makeGrowthRecord({
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
  }) {
    return GrowthRecord(
      id: 1,
      babyId: 1,
      date: DateTime(2025, 12, 1),
      weightKg: weightKg,
      heightCm: heightCm,
      headCircumferenceCm: headCircumferenceCm,
      createdAt: DateTime(2025, 12, 1),
      updatedAt: DateTime(2025, 12, 1),
    );
  }

  Vaccination _makeVaccination({
    required String name,
    int? doseNumber,
    DateTime? administeredAt,
    DateTime? nextDueAt,
  }) {
    return Vaccination(
      id: 1,
      babyId: 1,
      vaccineName: name,
      doseNumber: doseNumber,
      administeredAt: administeredAt,
      nextDueAt: nextDueAt,
      createdAt: DateTime(2025, 12, 1),
    );
  }

  HealthEvent _makeHealthEvent({
    required String type,
    required String title,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return HealthEvent(
      id: 1,
      babyId: 1,
      type: type,
      title: title,
      startedAt: startedAt,
      endedAt: endedAt,
      createdAt: DateTime(2025, 12, 1),
    );
  }

  Milestone _makeMilestone({
    required String title,
    String category = 'motor',
    DateTime? achievedAt,
    int? expectedAgeMonths,
  }) {
    return Milestone(
      id: 1,
      babyId: 1,
      category: category,
      title: title,
      achievedAt: achievedAt,
      expectedAgeMonths: expectedAgeMonths,
      createdAt: DateTime(2025, 12, 1),
    );
  }

  group('DoctorReportService', () {
    test('generates a valid PDF with minimal data', () async {
      final data = DoctorReportData(baby: _makeBaby());

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
      // PDF files start with %PDF
      expect(String.fromCharCodes(pdfBytes.take(5)), startsWith('%PDF'));
    });

    test('generates PDF with full data', () async {
      final data = DoctorReportData(
        baby: _makeBaby(gender: 'Male'),
        latestGrowth: _makeGrowthRecord(
          weightKg: 8.5,
          heightCm: 72.0,
          headCircumferenceCm: 44.5,
        ),
        percentiles: {
          'weight': 65.0,
          'height': 50.0,
          'headCircumference': 55.0,
        },
        recentSummary: DailySummary(
          feedingCount: 6,
          totalSleepMinutes: 720,
          diaperCount: 8,
        ),
        vaccinations: [
          _makeVaccination(
            name: 'HepB',
            doseNumber: 1,
            administeredAt: DateTime(2025, 6, 15),
          ),
          _makeVaccination(
            name: 'DTaP',
            doseNumber: 1,
            nextDueAt: DateTime(2026, 1, 15),
          ),
        ],
        recentHealthEvents: [
          _makeHealthEvent(
            type: 'illness',
            title: 'Cold',
            startedAt: DateTime(2025, 11, 20),
            endedAt: DateTime(2025, 11, 25),
          ),
        ],
        milestones: [
          _makeMilestone(
            title: 'Rolls over',
            achievedAt: DateTime(2025, 10, 1),
          ),
          _makeMilestone(
            title: 'Sits without support',
            expectedAgeMonths: 6,
          ),
        ],
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), startsWith('%PDF'));
      // PDF should be a reasonable size (at least a few KB for all sections)
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('generates PDF with null growth record', () async {
      final data = DoctorReportData(
        baby: _makeBaby(),
        latestGrowth: null,
        percentiles: null,
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), startsWith('%PDF'));
    });

    test('generates PDF with empty vaccinations and milestones', () async {
      final data = DoctorReportData(
        baby: _makeBaby(),
        vaccinations: [],
        milestones: [],
        recentHealthEvents: [],
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), startsWith('%PDF'));
    });

    test('generates PDF with active health events', () async {
      final data = DoctorReportData(
        baby: _makeBaby(),
        recentHealthEvents: [
          _makeHealthEvent(
            type: 'medication',
            title: 'Amoxicillin',
            startedAt: DateTime(2025, 11, 28),
            // endedAt is null - still active
          ),
        ],
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), startsWith('%PDF'));
    });

    test('generates PDF with only administered vaccinations', () async {
      final data = DoctorReportData(
        baby: _makeBaby(),
        vaccinations: [
          _makeVaccination(
            name: 'HepB',
            doseNumber: 1,
            administeredAt: DateTime(2025, 6, 15),
          ),
          _makeVaccination(
            name: 'HepB',
            doseNumber: 2,
            administeredAt: DateTime(2025, 7, 15),
          ),
        ],
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
    });

    test('generates PDF with partial growth measurements', () async {
      final data = DoctorReportData(
        baby: _makeBaby(),
        latestGrowth: _makeGrowthRecord(
          weightKg: 8.5,
          // heightCm and headCircumferenceCm are null
        ),
        percentiles: {'weight': 65.0},
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
      expect(String.fromCharCodes(pdfBytes.take(5)), startsWith('%PDF'));
    });

    test('generates PDF for very young baby (days old)', () async {
      final now = DateTime.now();
      final data = DoctorReportData(
        baby: _makeBaby(
          dateOfBirth: now.subtract(const Duration(days: 10)),
        ),
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
    });

    test('generates PDF for older baby (over 1 year)', () async {
      final data = DoctorReportData(
        baby: _makeBaby(
          dateOfBirth: DateTime(2024, 1, 1),
        ),
      );

      final pdfBytes = await service.generatePdf(data);

      expect(pdfBytes, isNotEmpty);
    });
  });
}
