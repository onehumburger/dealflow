import 'dart:math' as math;

import 'package:uu/database/app_database.dart';
import 'package:uu/services/who_growth_standards.dart';

/// Severity levels for growth alerts.
enum AlertSeverity { info, warning, urgent }

/// A growth anomaly alert with severity and recommendation.
class GrowthAlert {
  final AlertSeverity severity;
  final MeasurementType measurementType;
  final String message;
  final String recommendation;

  const GrowthAlert({
    required this.severity,
    required this.measurementType,
    required this.message,
    required this.recommendation,
  });

  @override
  String toString() =>
      'GrowthAlert($severity, $measurementType, "$message")';
}

/// Analyzes a baby's growth records for anomalies.
///
/// Detects three types of anomalies:
/// 1. **Percentile crossing** - measurement jumps across major percentile bands
/// 2. **Trend deviation** - measurement deviates >1 SD from baby's own trend
/// 3. **Weight loss/stagnation** - sudden weight drop or no gain over time
class GrowthAnalyzer {
  /// Minimum percentile drop to trigger a warning (e.g., 50th -> 20th = 30).
  static const double _percentileDropWarning = 25.0;

  /// Minimum percentile drop to trigger an urgent alert.
  static const double _percentileDropUrgent = 40.0;

  /// Weight loss percentage threshold to trigger a warning (after newborn period).
  static const double _weightLossWarningPercent = 5.0;

  /// Weight loss percentage threshold to trigger an urgent alert.
  static const double _weightLossUrgentPercent = 10.0;

  /// Maximum age in days where minor weight loss is considered normal (newborn).
  static const int _newbornPeriodDays = 14;

  /// Minimum weight gain percentage per month to avoid stagnation alert.
  /// Below this over 2+ consecutive months signals stagnation.
  static const double _minMonthlyGainPercent = 1.0;

  /// Maximum age in months supported by WHO data.
  static const int _maxAgeMonths = 36;

  /// Analyze growth records and return any detected anomalies.
  ///
  /// Records are sorted by date internally. The [baby] provides date of birth
  /// and gender for percentile calculations.
  List<GrowthAlert> analyze({
    required Baby baby,
    required List<GrowthRecord> records,
  }) {
    if (records.length < 2) return [];

    // Sort by date ascending.
    final sorted = List<GrowthRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final gender = _parseGender(baby.gender);
    final alerts = <GrowthAlert>[];

    // Run each detection for each measurement type.
    for (final type in MeasurementType.values) {
      final values = _extractValues(sorted, type);
      if (values.length < 2) continue;

      alerts.addAll(_detectPercentileCrossing(values, baby, gender, type));
      alerts.addAll(_detectWeightChange(values, baby, type));
      alerts.addAll(_detectTrendDeviation(values, type));
    }

    return alerts;
  }

  // ── Percentile crossing detection ──────────────────────────────────

  List<GrowthAlert> _detectPercentileCrossing(
    List<_TimedValue> values,
    Baby baby,
    Gender gender,
    MeasurementType type,
  ) {
    final alerts = <GrowthAlert>[];

    // Compare the most recent measurement's percentile to the earlier baseline.
    // Use the average of the first few measurements as baseline.
    final baselineCount = math.min(3, values.length - 1);
    double baselinePercentileSum = 0;
    int baselineValidCount = 0;

    for (int i = 0; i < baselineCount; i++) {
      final ageMonths = _ageInMonths(baby.dateOfBirth, values[i].date);
      if (ageMonths < 0 || ageMonths > _maxAgeMonths) continue;
      baselinePercentileSum += WHOGrowthStandards.percentile(
        measurement: values[i].value,
        ageMonths: ageMonths,
        gender: gender,
        type: type,
      );
      baselineValidCount++;
    }

    if (baselineValidCount == 0) return alerts;
    final baselinePercentile = baselinePercentileSum / baselineValidCount;

    final latest = values.last;
    final latestAgeMonths = _ageInMonths(baby.dateOfBirth, latest.date);
    if (latestAgeMonths < 0 || latestAgeMonths > _maxAgeMonths) return alerts;

    final latestPercentile = WHOGrowthStandards.percentile(
      measurement: latest.value,
      ageMonths: latestAgeMonths,
      gender: gender,
      type: type,
    );

    final drop = baselinePercentile - latestPercentile;
    final typeName = _typeName(type);

    if (drop >= _percentileDropUrgent) {
      alerts.add(GrowthAlert(
        severity: AlertSeverity.urgent,
        measurementType: type,
        message: '$typeName percentile dropped from '
            '${baselinePercentile.round()}th to ${latestPercentile.round()}th',
        recommendation:
            'Schedule an appointment with your pediatrician as soon as '
            'possible to evaluate the significant change in $typeName.',
      ));
    } else if (drop >= _percentileDropWarning) {
      alerts.add(GrowthAlert(
        severity: AlertSeverity.warning,
        measurementType: type,
        message: '$typeName percentile dropped from '
            '${baselinePercentile.round()}th to ${latestPercentile.round()}th',
        recommendation:
            'Monitor $typeName closely and mention this at the next '
            'pediatric visit.',
      ));
    }

    return alerts;
  }

  // ── Weight loss / stagnation detection ─────────────────────────────

  List<GrowthAlert> _detectWeightChange(
    List<_TimedValue> values,
    Baby baby,
    MeasurementType type,
  ) {
    // Only check weight for loss/stagnation.
    if (type != MeasurementType.weight) return [];

    final alerts = <GrowthAlert>[];

    // --- Sudden weight loss ---
    final previous = values[values.length - 2];
    final latest = values.last;
    final daysSinceBirth =
        latest.date.difference(baby.dateOfBirth).inDays;

    if (latest.value < previous.value) {
      final lossPercent =
          (previous.value - latest.value) / previous.value * 100;

      // During the newborn period, minor loss is normal.
      if (daysSinceBirth <= _newbornPeriodDays) {
        // Only flag if extreme loss (>10%) even in newborn period
        if (lossPercent >= _weightLossUrgentPercent) {
          alerts.add(GrowthAlert(
            severity: AlertSeverity.warning,
            measurementType: type,
            message: 'Weight loss of ${lossPercent.toStringAsFixed(1)}% '
                'detected in newborn period',
            recommendation:
                'While some weight loss after birth is normal, this amount '
                'may warrant a check-up. Ensure adequate feeding.',
          ));
        }
      } else {
        if (lossPercent >= _weightLossUrgentPercent) {
          alerts.add(GrowthAlert(
            severity: AlertSeverity.urgent,
            measurementType: type,
            message: 'Significant weight loss of '
                '${lossPercent.toStringAsFixed(1)}% detected',
            recommendation:
                'Seek medical attention promptly. Weight loss at this age '
                'requires evaluation.',
          ));
        } else if (lossPercent >= _weightLossWarningPercent) {
          alerts.add(GrowthAlert(
            severity: AlertSeverity.warning,
            measurementType: type,
            message: 'Weight loss of ${lossPercent.toStringAsFixed(1)}% '
                'detected',
            recommendation:
                'Monitor feeding patterns and weight closely. Discuss with '
                'pediatrician if loss continues.',
          ));
        }
      }
    }

    // --- Weight stagnation ---
    if (values.length >= 3) {
      // Check last 2 intervals for minimal gain.
      int stagnantIntervals = 0;
      for (int i = values.length - 2; i < values.length; i++) {
        final prev = values[i - 1];
        final curr = values[i];
        final gainPercent =
            (curr.value - prev.value) / prev.value * 100;
        if (gainPercent < _minMonthlyGainPercent) {
          stagnantIntervals++;
        }
      }

      if (stagnantIntervals >= 2) {
        alerts.add(GrowthAlert(
          severity: AlertSeverity.warning,
          measurementType: type,
          message: 'Weight stagnation detected over the last '
              '$stagnantIntervals measurement intervals',
          recommendation:
              'Weight gain has been minimal. Consider reviewing nutrition '
              'and discussing with your pediatrician.',
        ));
      }
    }

    return alerts;
  }

  // ── Trend deviation detection ──────────────────────────────────────

  List<GrowthAlert> _detectTrendDeviation(
    List<_TimedValue> values,
    MeasurementType type,
  ) {
    // Need at least 3 points to establish a trend.
    if (values.length < 3) return [];

    final alerts = <GrowthAlert>[];
    final typeName = _typeName(type);

    // Use all points except the last to build a linear trend,
    // then check if the last point deviates significantly.
    final trendPoints = values.sublist(0, values.length - 1);
    final latest = values.last;

    // Convert dates to days since first measurement for regression.
    final firstDate = trendPoints.first.date;
    final xs =
        trendPoints.map((v) => v.date.difference(firstDate).inDays.toDouble()).toList();
    final ys = trendPoints.map((v) => v.value).toList();

    final regression = _linearRegression(xs, ys);
    final latestX = latest.date.difference(firstDate).inDays.toDouble();
    final predicted = regression.slope * latestX + regression.intercept;

    // Calculate residual standard deviation from the trend points.
    double sumSquaredResiduals = 0;
    for (int i = 0; i < xs.length; i++) {
      final residual = ys[i] - (regression.slope * xs[i] + regression.intercept);
      sumSquaredResiduals += residual * residual;
    }
    final rawSD = math.sqrt(sumSquaredResiduals / xs.length);

    // Use a minimum SD floor of 5% of the mean value to avoid false
    // positives when the trend is nearly linear (which is common for
    // normal growth that follows a smooth curve).
    final meanValue = ys.reduce((a, b) => a + b) / ys.length;
    final sdFloor = meanValue * 0.05;
    final residualSD = math.max(rawSD, sdFloor);

    // If even with the floor the SD is negligible, skip.
    if (residualSD < 0.001) return alerts;

    final deviation = (latest.value - predicted).abs();
    final zScore = deviation / residualSD;

    if (zScore > 2.0) {
      final direction = latest.value > predicted ? 'above' : 'below';
      alerts.add(GrowthAlert(
        severity: AlertSeverity.warning,
        measurementType: type,
        message: '$typeName deviates significantly from baby\'s own trend '
            '(${zScore.toStringAsFixed(1)} SD $direction expected)',
        recommendation:
            'The latest $typeName measurement is unusually different from '
            'your baby\'s growth pattern. Verify the measurement and discuss '
            'with your pediatrician if confirmed.',
      ));
    } else if (zScore > 1.0) {
      final direction = latest.value > predicted ? 'above' : 'below';
      alerts.add(GrowthAlert(
        severity: AlertSeverity.info,
        measurementType: type,
        message: '$typeName shows a mild trend deviation '
            '(${zScore.toStringAsFixed(1)} SD $direction expected)',
        recommendation:
            'Continue monitoring $typeName at regular intervals.',
      ));
    }

    return alerts;
  }

  // ── Helpers ────────────────────────────────────────────────────────

  /// Parse the gender string from the Baby model into the Gender enum.
  Gender _parseGender(String? gender) {
    if (gender == null) return Gender.male;
    switch (gender.toLowerCase()) {
      case 'female':
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  /// Calculate age in whole months from date of birth to measurement date.
  int _ageInMonths(DateTime dateOfBirth, DateTime measurementDate) {
    final years = measurementDate.year - dateOfBirth.year;
    final months = measurementDate.month - dateOfBirth.month;
    final dayOffset = measurementDate.day >= dateOfBirth.day ? 0 : -1;
    return (years * 12 + months + dayOffset).clamp(0, 36);
  }

  /// Extract non-null measurement values of a given type with their dates.
  List<_TimedValue> _extractValues(
    List<GrowthRecord> records,
    MeasurementType type,
  ) {
    final result = <_TimedValue>[];
    for (final record in records) {
      final value = _getValue(record, type);
      if (value != null) {
        result.add(_TimedValue(record.date, value));
      }
    }
    return result;
  }

  /// Get the measurement value for a given type from a record.
  double? _getValue(GrowthRecord record, MeasurementType type) {
    switch (type) {
      case MeasurementType.weight:
        return record.weightKg;
      case MeasurementType.height:
        return record.heightCm;
      case MeasurementType.headCircumference:
        return record.headCircumferenceCm;
    }
  }

  /// Human-readable name for a measurement type.
  String _typeName(MeasurementType type) {
    switch (type) {
      case MeasurementType.weight:
        return 'Weight';
      case MeasurementType.height:
        return 'Height';
      case MeasurementType.headCircumference:
        return 'Head circumference';
    }
  }

  /// Simple linear regression returning slope and intercept.
  _LinearResult _linearRegression(List<double> xs, List<double> ys) {
    assert(xs.length == ys.length && xs.isNotEmpty);
    final n = xs.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX += xs[i];
      sumY += ys[i];
      sumXY += xs[i] * ys[i];
      sumX2 += xs[i] * xs[i];
    }
    final denom = n * sumX2 - sumX * sumX;
    if (denom.abs() < 1e-10) {
      // All x values are the same - return flat line at mean y.
      return _LinearResult(0, sumY / n);
    }
    final slope = (n * sumXY - sumX * sumY) / denom;
    final intercept = (sumY - slope * sumX) / n;
    return _LinearResult(slope, intercept);
  }
}

/// A measurement value at a specific date.
class _TimedValue {
  final DateTime date;
  final double value;
  const _TimedValue(this.date, this.value);
}

/// Result of a linear regression.
class _LinearResult {
  final double slope;
  final double intercept;
  const _LinearResult(this.slope, this.intercept);
}
