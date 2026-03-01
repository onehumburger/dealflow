import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/analysis/growth_analyzer.dart';
import 'package:uu/services/who_growth_standards.dart';

void main() {
  // Helper to create a Baby for testing.
  Baby _makeBaby({
    String gender = 'male',
    DateTime? dateOfBirth,
  }) {
    return Baby(
      id: 1,
      name: 'Test Baby',
      dateOfBirth: dateOfBirth ?? DateTime(2025, 1, 1),
      gender: gender,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  // Helper to create a GrowthRecord.
  GrowthRecord _makeRecord({
    required DateTime date,
    double? weightKg,
    double? heightCm,
    double? headCircumferenceCm,
    int id = 1,
  }) {
    return GrowthRecord(
      id: id,
      babyId: 1,
      date: date,
      weightKg: weightKg,
      heightCm: heightCm,
      headCircumferenceCm: headCircumferenceCm,
      createdAt: date,
    );
  }

  group('GrowthAlert', () {
    test('has severity, type, message, and recommendation', () {
      const alert = GrowthAlert(
        severity: AlertSeverity.warning,
        measurementType: MeasurementType.weight,
        message: 'Weight dropped significantly',
        recommendation: 'Consult pediatrician',
      );

      expect(alert.severity, AlertSeverity.warning);
      expect(alert.measurementType, MeasurementType.weight);
      expect(alert.message, 'Weight dropped significantly');
      expect(alert.recommendation, 'Consult pediatrician');
    });

    test('AlertSeverity has three levels', () {
      expect(AlertSeverity.values, hasLength(3));
      expect(AlertSeverity.values, contains(AlertSeverity.info));
      expect(AlertSeverity.values, contains(AlertSeverity.warning));
      expect(AlertSeverity.values, contains(AlertSeverity.urgent));
    });
  });

  group('GrowthAnalyzer', () {
    late GrowthAnalyzer analyzer;

    setUp(() {
      analyzer = GrowthAnalyzer();
    });

    group('analyze()', () {
      test('returns empty list when fewer than 2 records', () {
        final baby = _makeBaby();
        final records = [
          _makeRecord(
            date: DateTime(2025, 1, 1),
            weightKg: 3.3,
          ),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        expect(alerts, isEmpty);
      });

      test('returns empty list for empty records', () {
        final baby = _makeBaby();
        final alerts = analyzer.analyze(baby: baby, records: []);
        expect(alerts, isEmpty);
      });

      test('returns empty list for normal growth', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        // Normal 50th percentile boy weight trajectory
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 6.4, id: 4),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        // No alerts for normal growth
        expect(
          alerts.where((a) =>
              a.severity == AlertSeverity.warning ||
              a.severity == AlertSeverity.urgent),
          isEmpty,
        );
      });
    });

    group('percentile crossing detection', () {
      test('detects weight dropping across percentile bands', () {
        // Boy born at 50th percentile weight, then drops to very low
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          // ~50th percentile at birth
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          // ~50th percentile at 1 month
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
          // ~50th percentile at 2 months
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          // Drop to well below 5th percentile at 3 months
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 4.5, id: 4),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        final weightAlerts = alerts
            .where((a) => a.measurementType == MeasurementType.weight)
            .toList();
        expect(weightAlerts, isNotEmpty);
        // Should have at least a warning-level alert
        expect(
          weightAlerts.any((a) =>
              a.severity == AlertSeverity.warning ||
              a.severity == AlertSeverity.urgent),
          isTrue,
        );
      });

      test('detects height percentile crossing', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          // Normal height trajectory then sudden drop
          _makeRecord(date: DateTime(2025, 1, 1), heightCm: 49.9, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), heightCm: 54.7, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), heightCm: 58.4, id: 3),
          // Drop to very short for 3 months (way below 3rd percentile)
          _makeRecord(date: DateTime(2025, 4, 1), heightCm: 54.0, id: 4),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        final heightAlerts = alerts
            .where((a) => a.measurementType == MeasurementType.height)
            .toList();
        expect(heightAlerts, isNotEmpty);
      });

      test('does not flag minor percentile fluctuations', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        // Small fluctuations around the 50th percentile
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.4, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.5, id: 3),
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 6.3, id: 4),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        final crossingAlerts = alerts
            .where((a) =>
                a.severity == AlertSeverity.warning ||
                a.severity == AlertSeverity.urgent)
            .toList();
        expect(crossingAlerts, isEmpty);
      });
    });

    group('weight loss / stagnation detection', () {
      test('detects sudden weight loss', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          // Weight drops by over 5% from previous
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 5.0, id: 4),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        final lossAlerts = alerts
            .where((a) =>
                a.measurementType == MeasurementType.weight &&
                a.message.toLowerCase().contains('loss'))
            .toList();
        expect(lossAlerts, isNotEmpty);
        expect(
          lossAlerts.any((a) =>
              a.severity == AlertSeverity.warning ||
              a.severity == AlertSeverity.urgent),
          isTrue,
        );
      });

      test('detects weight stagnation over multiple months', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          // No gain for 2 months (stagnation)
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 5.65, id: 4),
          _makeRecord(date: DateTime(2025, 5, 1), weightKg: 5.7, id: 5),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        final stagnationAlerts = alerts
            .where((a) =>
                a.measurementType == MeasurementType.weight &&
                a.message.toLowerCase().contains('stagnation'))
            .toList();
        expect(stagnationAlerts, isNotEmpty);
      });

      test('does not flag normal newborn weight loss in first days', () {
        // Newborns often lose up to 7% weight in first days - that's normal
        // But since we work with monthly granularity, this test ensures
        // we don't flag tiny variations at birth month
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          // Slight dip within first month, then normal
          _makeRecord(date: DateTime(2025, 1, 5), weightKg: 3.15, id: 2),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        // Within first 2 weeks, minor weight loss is expected
        final urgentAlerts = alerts
            .where((a) => a.severity == AlertSeverity.urgent)
            .toList();
        expect(urgentAlerts, isEmpty);
      });
    });

    group('trend deviation detection', () {
      test('detects measurement deviating from baby own trend', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        // Build a consistent trend then deviate sharply
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 6.4, id: 4),
          _makeRecord(date: DateTime(2025, 5, 1), weightKg: 7.0, id: 5),
          // Suddenly way above the trend
          _makeRecord(date: DateTime(2025, 6, 1), weightKg: 10.0, id: 6),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        final deviationAlerts = alerts
            .where((a) =>
                a.measurementType == MeasurementType.weight &&
                a.message.toLowerCase().contains('trend'))
            .toList();
        expect(deviationAlerts, isNotEmpty);
      });

      test('needs at least 3 data points to establish trend', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 8.0, id: 2),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        // With only 2 records, no trend deviation alert should fire
        final deviationAlerts = alerts
            .where((a) => a.message.toLowerCase().contains('trend'))
            .toList();
        expect(deviationAlerts, isEmpty);
      });
    });

    group('multiple measurement types', () {
      test('analyzes weight, height, and head circumference independently', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          _makeRecord(
            date: DateTime(2025, 1, 1),
            weightKg: 3.3,
            heightCm: 49.9,
            headCircumferenceCm: 34.5,
            id: 1,
          ),
          _makeRecord(
            date: DateTime(2025, 2, 1),
            weightKg: 4.5,
            heightCm: 54.7,
            headCircumferenceCm: 37.3,
            id: 2,
          ),
          _makeRecord(
            date: DateTime(2025, 3, 1),
            weightKg: 5.6,
            heightCm: 58.4,
            headCircumferenceCm: 39.1,
            id: 3,
          ),
          // Weight drops, height and head stay normal
          _makeRecord(
            date: DateTime(2025, 4, 1),
            weightKg: 4.5,
            heightCm: 61.4,
            headCircumferenceCm: 40.5,
            id: 4,
          ),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        final weightAlerts = alerts
            .where((a) => a.measurementType == MeasurementType.weight)
            .toList();
        // Weight should have alerts
        expect(weightAlerts, isNotEmpty);
        // Height and head circ should NOT have warning/urgent alerts
        final heightUrgent = alerts
            .where((a) =>
                a.measurementType == MeasurementType.height &&
                (a.severity == AlertSeverity.warning ||
                    a.severity == AlertSeverity.urgent))
            .toList();
        expect(heightUrgent, isEmpty);
      });

      test('handles records with partial measurements', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(
              date: DateTime(2025, 2, 1),
              weightKg: 4.5,
              heightCm: 54.7,
              id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 6.4, id: 4),
        ];

        // Should not throw and should analyze available data
        final alerts = analyzer.analyze(baby: baby, records: records);
        expect(alerts, isA<List<GrowthAlert>>());
      });
    });

    group('gender handling', () {
      test('works with female babies', () {
        final baby = _makeBaby(
          gender: 'female',
          dateOfBirth: DateTime(2025, 1, 1),
        );
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.2, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.2, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.1, id: 3),
          // Normal female weight at 3 months
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 5.8, id: 4),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        // Normal growth - no warning/urgent alerts
        expect(
          alerts.where((a) =>
              a.severity == AlertSeverity.warning ||
              a.severity == AlertSeverity.urgent),
          isEmpty,
        );
      });

      test('defaults to male when gender is null', () {
        final baby = _makeBaby(gender: 'male');
        final babyNoGender = Baby(
          id: 1,
          name: 'Test',
          dateOfBirth: DateTime(2025, 1, 1),
          createdAt: DateTime(2025, 1, 1),
        );
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
        ];

        // Should not throw
        final alerts =
            analyzer.analyze(baby: babyNoGender, records: records);
        expect(alerts, isA<List<GrowthAlert>>());
      });
    });

    group('edge cases', () {
      test('sorts records by date before analysis', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        // Records given out of order
        final records = [
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 6.4, id: 4),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
        ];

        // Should not throw and should produce consistent results
        final alerts = analyzer.analyze(baby: baby, records: records);
        expect(alerts, isA<List<GrowthAlert>>());
      });

      test('handles age beyond 36 months gracefully', () {
        // Baby is 40 months old - beyond WHO data range
        final baby = _makeBaby(dateOfBirth: DateTime(2021, 9, 1));
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 14.0, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 14.2, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 14.4, id: 3),
        ];

        // Should not throw - just skip percentile analysis for out-of-range
        final alerts = analyzer.analyze(baby: baby, records: records);
        expect(alerts, isA<List<GrowthAlert>>());
      });

      test('alert recommendations are non-empty strings', () {
        final baby = _makeBaby(dateOfBirth: DateTime(2025, 1, 1));
        final records = [
          _makeRecord(date: DateTime(2025, 1, 1), weightKg: 3.3, id: 1),
          _makeRecord(date: DateTime(2025, 2, 1), weightKg: 4.5, id: 2),
          _makeRecord(date: DateTime(2025, 3, 1), weightKg: 5.6, id: 3),
          _makeRecord(date: DateTime(2025, 4, 1), weightKg: 4.5, id: 4),
        ];

        final alerts = analyzer.analyze(baby: baby, records: records);
        for (final alert in alerts) {
          expect(alert.recommendation, isNotEmpty);
          expect(alert.message, isNotEmpty);
        }
      });
    });
  });
}
