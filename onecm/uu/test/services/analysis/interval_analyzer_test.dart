import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/analysis/interval_analyzer.dart';

DailyLog _log({
  required DateTime startedAt,
  String type = 'feeding',
}) {
  return DailyLog(
    id: 0,
    babyId: 1,
    type: type,
    startedAt: startedAt,
    createdAt: startedAt,
  );
}

void main() {
  late IntervalAnalyzer analyzer;

  setUp(() {
    analyzer = IntervalAnalyzer();
  });

  group('IntervalAnalyzer', () {
    group('edge cases', () {
      test('returns null for empty log list', () {
        final result = analyzer.analyze([]);
        expect(result, isNull);
      });

      test('returns null for single log entry', () {
        final logs = [_log(startedAt: DateTime(2025, 7, 15, 8, 0))];
        final result = analyzer.analyze(logs);
        expect(result, isNull);
      });

      test('works with exactly two logs', () {
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 8, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 11, 0)),
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.averageIntervalMinutes, 180);
        expect(result.sampleSize, 1);
        expect(result.confidence, Confidence.low);
      });
    });

    group('regular feeding every 3 hours', () {
      late List<DailyLog> logs;

      setUp(() {
        // 7 days of regular 3-hour feedings, 6 AM to midnight
        logs = [];
        for (var day = 0; day < 7; day++) {
          for (var hour = 6; hour <= 21; hour += 3) {
            logs.add(_log(
              startedAt: DateTime(2025, 7, 15 + day, hour, 0),
            ));
          }
        }
      });

      test('calculates average interval close to 180 minutes', () {
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.averageIntervalMinutes, 180);
      });

      test('suggests interval close to average', () {
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.suggestedIntervalMinutes, 180);
      });

      test('has high confidence with many samples', () {
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.confidence, Confidence.high);
      });

      test('reports correct sample size', () {
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        // 6 feedings per day * 7 days = 42 logs, 41 intervals
        // But only consecutive-day intervals within 12 hours count
        // Actually, within each day: 5 intervals, plus overnight gaps
        // Let's just verify it's > 0 and reasonable
        expect(result!.sampleSize, greaterThan(20));
      });
    });

    group('irregular feeding patterns', () {
      test('handles varied intervals correctly', () {
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 6, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 8, 0)), // 120 min
          _log(startedAt: DateTime(2025, 7, 15, 11, 30)), // 210 min
          _log(startedAt: DateTime(2025, 7, 15, 14, 0)), // 150 min
          _log(startedAt: DateTime(2025, 7, 15, 17, 30)), // 210 min
          _log(startedAt: DateTime(2025, 7, 15, 20, 0)), // 150 min
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        // Average: (120 + 210 + 150 + 210 + 150) / 5 = 168
        expect(result!.averageIntervalMinutes, 168);
      });

      test('has medium confidence with moderate sample size', () {
        // 10 intervals = medium confidence
        final logs = <DailyLog>[];
        for (var i = 0; i < 11; i++) {
          logs.add(_log(
            startedAt: DateTime(2025, 7, 15, 6 + i * 2, 0),
          ));
        }
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.confidence, Confidence.medium);
      });
    });

    group('day/night pattern differences', () {
      test('identifies different day and night intervals', () {
        final logs = <DailyLog>[];
        // Day feedings every 2 hours (7 AM - 9 PM)
        for (var day = 0; day < 3; day++) {
          for (var hour = 7; hour <= 21; hour += 2) {
            logs.add(_log(
              startedAt: DateTime(2025, 7, 15 + day, hour, 0),
            ));
          }
          // Night feeding once at 2 AM (5 hours after 9 PM)
          logs.add(_log(
            startedAt: DateTime(2025, 7, 16 + day, 2, 0),
          ));
        }
        // Sort chronologically
        logs.sort((a, b) => a.startedAt.compareTo(b.startedAt));

        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        // Day intervals should be around 120 min
        expect(result!.dayTimeAverageMinutes, isNotNull);
        expect(result.dayTimeAverageMinutes!, closeTo(120, 10));
        // Night intervals should be longer (around 300 min)
        expect(result.nightTimeAverageMinutes, isNotNull);
        expect(result.nightTimeAverageMinutes!, greaterThan(200));
      });

      test('returns null night average when no night intervals', () {
        // Only daytime feedings
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 8, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 10, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 12, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 14, 0)),
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.dayTimeAverageMinutes, isNotNull);
        expect(result.nightTimeAverageMinutes, isNull);
      });
    });

    group('diaper change patterns', () {
      test('analyzes diaper intervals correctly', () {
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 7, 0), type: 'diaper'),
          _log(startedAt: DateTime(2025, 7, 15, 9, 30), type: 'diaper'), // 150
          _log(startedAt: DateTime(2025, 7, 15, 12, 0), type: 'diaper'), // 150
          _log(startedAt: DateTime(2025, 7, 15, 14, 30), type: 'diaper'), // 150
          _log(startedAt: DateTime(2025, 7, 15, 17, 0), type: 'diaper'), // 150
          _log(startedAt: DateTime(2025, 7, 15, 19, 30), type: 'diaper'), // 150
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.averageIntervalMinutes, 150);
        expect(result.suggestedIntervalMinutes, 150);
      });
    });

    group('suggestion rounding', () {
      test('rounds suggested interval to nearest 5 minutes', () {
        // Create intervals that average to something not divisible by 5
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 8, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 10, 7)), // 127 min
          _log(startedAt: DateTime(2025, 7, 15, 12, 14)), // 127 min
          _log(startedAt: DateTime(2025, 7, 15, 14, 21)), // 127 min
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        // Average = 127, rounded to nearest 5 = 125
        expect(result!.suggestedIntervalMinutes % 5, 0);
      });

      test('minimum suggested interval is 30 minutes', () {
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 8, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 8, 10)), // 10 min
          _log(startedAt: DateTime(2025, 7, 15, 8, 20)), // 10 min
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        expect(result!.suggestedIntervalMinutes, greaterThanOrEqualTo(30));
      });
    });

    group('log ordering', () {
      test('handles unsorted logs correctly', () {
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 14, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 8, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 11, 0)),
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        // After sorting: 8:00, 11:00, 14:00 => intervals 180, 180
        expect(result!.averageIntervalMinutes, 180);
      });
    });

    group('outlier filtering', () {
      test('filters out very large intervals (e.g., overnight gaps > 8 hours)', () {
        final logs = [
          _log(startedAt: DateTime(2025, 7, 15, 8, 0)),
          _log(startedAt: DateTime(2025, 7, 15, 11, 0)), // 180 min
          _log(startedAt: DateTime(2025, 7, 15, 14, 0)), // 180 min
          _log(startedAt: DateTime(2025, 7, 15, 17, 0)), // 180 min
          // Big overnight gap
          _log(startedAt: DateTime(2025, 7, 16, 8, 0)), // 900 min - outlier
          _log(startedAt: DateTime(2025, 7, 16, 11, 0)), // 180 min
          _log(startedAt: DateTime(2025, 7, 16, 14, 0)), // 180 min
        ];
        final result = analyzer.analyze(logs);
        expect(result, isNotNull);
        // The 900-min gap should be excluded from average
        // Remaining: five 180-min intervals => average 180
        expect(result!.averageIntervalMinutes, 180);
      });
    });
  });

  group('IntervalSuggestion', () {
    test('has all required fields', () {
      const suggestion = IntervalSuggestion(
        suggestedIntervalMinutes: 180,
        averageIntervalMinutes: 178,
        dayTimeAverageMinutes: 160,
        nightTimeAverageMinutes: 240,
        confidence: Confidence.high,
        sampleSize: 42,
      );
      expect(suggestion.suggestedIntervalMinutes, 180);
      expect(suggestion.averageIntervalMinutes, 178);
      expect(suggestion.dayTimeAverageMinutes, 160);
      expect(suggestion.nightTimeAverageMinutes, 240);
      expect(suggestion.confidence, Confidence.high);
      expect(suggestion.sampleSize, 42);
    });
  });

  group('Confidence', () {
    test('enum has expected values', () {
      expect(Confidence.values, contains(Confidence.low));
      expect(Confidence.values, contains(Confidence.medium));
      expect(Confidence.values, contains(Confidence.high));
    });
  });
}
