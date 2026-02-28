import 'package:uu/database/app_database.dart';

enum Confidence { low, medium, high }

class IntervalSuggestion {
  final int suggestedIntervalMinutes;
  final int averageIntervalMinutes;
  final int? dayTimeAverageMinutes;
  final int? nightTimeAverageMinutes;
  final Confidence confidence;
  final int sampleSize;

  const IntervalSuggestion({
    required this.suggestedIntervalMinutes,
    required this.averageIntervalMinutes,
    this.dayTimeAverageMinutes,
    this.nightTimeAverageMinutes,
    required this.confidence,
    required this.sampleSize,
  });
}

/// Pure analysis service that calculates interval suggestions from daily logs.
///
/// Takes a list of [DailyLog] records (feeding or diaper), computes average
/// intervals between consecutive events, identifies day/night patterns,
/// and suggests an optimal reminder interval.
class IntervalAnalyzer {
  /// Hour when "day time" starts (inclusive). Default: 6 AM.
  final int dayStartHour;

  /// Hour when "night time" starts (inclusive). Default: 10 PM.
  final int nightStartHour;

  /// Intervals longer than this are considered outliers and excluded.
  /// Default: 480 minutes (8 hours).
  final int maxIntervalMinutes;

  /// Minimum suggested interval in minutes. Default: 30.
  static const int _minSuggestedInterval = 30;

  IntervalAnalyzer({
    this.dayStartHour = 6,
    this.nightStartHour = 22,
    this.maxIntervalMinutes = 480,
  });

  /// Analyze a list of logs and return an [IntervalSuggestion], or null
  /// if there is insufficient data (fewer than 2 logs).
  IntervalSuggestion? analyze(List<DailyLog> logs) {
    if (logs.length < 2) return null;

    // Sort chronologically
    final sorted = List<DailyLog>.from(logs)
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    // Calculate intervals between consecutive events
    final allIntervals = <_Interval>[];
    for (var i = 1; i < sorted.length; i++) {
      final minutes =
          sorted[i].startedAt.difference(sorted[i - 1].startedAt).inMinutes;
      allIntervals.add(_Interval(
        minutes: minutes,
        midpoint: sorted[i - 1].startedAt.add(
          Duration(minutes: minutes ~/ 2),
        ),
      ));
    }

    // Filter out outliers (intervals > maxIntervalMinutes)
    final intervals = allIntervals
        .where((i) => i.minutes <= maxIntervalMinutes)
        .toList();

    if (intervals.isEmpty) return null;

    // Overall average
    final totalMinutes = intervals.fold<int>(0, (sum, i) => sum + i.minutes);
    final averageInterval = totalMinutes ~/ intervals.length;

    // Day/night split
    final dayIntervals = intervals.where((i) => _isDaytime(i.midpoint)).toList();
    final nightIntervals =
        intervals.where((i) => !_isDaytime(i.midpoint)).toList();

    final dayAverage = dayIntervals.isNotEmpty
        ? dayIntervals.fold<int>(0, (sum, i) => sum + i.minutes) ~/
            dayIntervals.length
        : null;
    final nightAverage = nightIntervals.isNotEmpty
        ? nightIntervals.fold<int>(0, (sum, i) => sum + i.minutes) ~/
            nightIntervals.length
        : null;

    // Suggested interval: round average to nearest 5, enforce minimum
    final rounded = _roundToNearest5(averageInterval);
    final suggested = rounded < _minSuggestedInterval
        ? _minSuggestedInterval
        : rounded;

    return IntervalSuggestion(
      suggestedIntervalMinutes: suggested,
      averageIntervalMinutes: averageInterval,
      dayTimeAverageMinutes: dayAverage,
      nightTimeAverageMinutes: nightAverage,
      confidence: _confidence(intervals.length),
      sampleSize: intervals.length,
    );
  }

  bool _isDaytime(DateTime time) {
    final hour = time.hour;
    return hour >= dayStartHour && hour < nightStartHour;
  }

  Confidence _confidence(int sampleSize) {
    if (sampleSize >= 20) return Confidence.high;
    if (sampleSize >= 7) return Confidence.medium;
    return Confidence.low;
  }

  int _roundToNearest5(int value) {
    return ((value + 2) ~/ 5) * 5;
  }
}

class _Interval {
  final int minutes;
  final DateTime midpoint;

  const _Interval({required this.minutes, required this.midpoint});
}
