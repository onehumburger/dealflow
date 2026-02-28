import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/who_growth_standards.dart';

void main() {
  group('WHOGrowthStandards', () {
    test('calculates weight-for-age percentile for a newborn boy', () {
      final percentile = WHOGrowthStandards.percentile(
        measurement: 3.3,
        ageMonths: 0,
        gender: Gender.male,
        type: MeasurementType.weight,
      );
      expect(percentile, closeTo(50, 10));
    });

    test('higher weight gives higher percentile', () {
      final p1 = WHOGrowthStandards.percentile(
        measurement: 3.0,
        ageMonths: 0,
        gender: Gender.male,
        type: MeasurementType.weight,
      );
      final p2 = WHOGrowthStandards.percentile(
        measurement: 4.0,
        ageMonths: 0,
        gender: Gender.male,
        type: MeasurementType.weight,
      );
      expect(p2, greaterThan(p1));
    });

    test('returns percentile curves for charting', () {
      final curves = WHOGrowthStandards.getCurves(
        gender: Gender.male,
        type: MeasurementType.weight,
        percentiles: [3, 15, 50, 85, 97],
      );
      expect(curves.keys, containsAll([3, 15, 50, 85, 97]));
      expect(curves[50]!.length, greaterThanOrEqualTo(37));
    });

    test('female height-for-age at 12 months', () {
      final percentile = WHOGrowthStandards.percentile(
        measurement: 74.0,
        ageMonths: 12,
        gender: Gender.female,
        type: MeasurementType.height,
      );
      expect(percentile, closeTo(50, 15));
    });
  });
}
