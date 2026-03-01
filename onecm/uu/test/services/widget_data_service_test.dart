import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/widget_data_service.dart';

DailyLog _log({
  required String type,
  required DateTime startedAt,
  DateTime? endedAt,
  int? durationMinutes,
}) {
  return DailyLog(
    id: 0,
    babyId: 1,
    type: type,
    startedAt: startedAt,
    endedAt: endedAt,
    durationMinutes: durationMinutes,
    createdAt: startedAt,
  );
}

void main() {
  group('WidgetDataService.computeWidgetData', () {
    test('returns null durations when logs are empty', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      final data = WidgetDataService.computeWidgetData([], now);

      expect(data.timeSinceLastFeed, isNull);
      expect(data.timeSinceLastDiaper, isNull);
      expect(data.estimatedNextNap, isNull);
      expect(data.lastFeedTime, isNull);
      expect(data.lastDiaperTime, isNull);
      expect(data.feedCountToday, 0);
      expect(data.diaperCountToday, 0);
    });

    test('computes time since last feed', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      final logs = [
        _log(type: 'feeding', startedAt: DateTime(2025, 7, 15, 11, 45)),
        _log(type: 'feeding', startedAt: DateTime(2025, 7, 15, 8, 0)),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      expect(data.timeSinceLastFeed, const Duration(hours: 2, minutes: 15));
      expect(data.lastFeedTime, DateTime(2025, 7, 15, 11, 45));
      expect(data.feedCountToday, 2);
    });

    test('computes time since last diaper', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      final logs = [
        _log(type: 'diaper', startedAt: DateTime(2025, 7, 15, 13, 15)),
        _log(type: 'diaper', startedAt: DateTime(2025, 7, 15, 10, 0)),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      expect(data.timeSinceLastDiaper, const Duration(minutes: 45));
      expect(data.lastDiaperTime, DateTime(2025, 7, 15, 13, 15));
      expect(data.diaperCountToday, 2);
    });

    test('estimates next nap from last sleep and average interval', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      // Two naps: 9:00-10:00, 12:00-13:00 => interval from end of first to start of second = 2h
      // Last nap ended at 13:00, so next nap estimated at 13:00 + 2h = 15:00
      // estimatedNextNap = 15:00 - 14:00 = 1h
      final logs = [
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 12, 0),
          endedAt: DateTime(2025, 7, 15, 13, 0),
          durationMinutes: 60,
        ),
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 9, 0),
          endedAt: DateTime(2025, 7, 15, 10, 0),
          durationMinutes: 60,
        ),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      expect(data.estimatedNextNap, const Duration(hours: 1));
    });

    test('returns zero estimated nap when nap is overdue', () {
      final now = DateTime(2025, 7, 15, 16, 0);
      // Two naps: 9-10, 12-13 => interval 2h, next at 15:00
      // now is 16:00, so overdue by 1h => estimatedNextNap = Duration.zero
      final logs = [
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 12, 0),
          endedAt: DateTime(2025, 7, 15, 13, 0),
          durationMinutes: 60,
        ),
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 9, 0),
          endedAt: DateTime(2025, 7, 15, 10, 0),
          durationMinutes: 60,
        ),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      expect(data.estimatedNextNap, Duration.zero);
    });

    test('uses default 2h interval with only one sleep log', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      // One nap ended at 13:00, default interval 2h => next at 15:00
      // estimatedNextNap = 15:00 - 14:00 = 1h
      final logs = [
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 12, 0),
          endedAt: DateTime(2025, 7, 15, 13, 0),
          durationMinutes: 60,
        ),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      expect(data.estimatedNextNap, const Duration(hours: 1));
    });

    test('returns null nap estimate with no sleep logs', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      final logs = [
        _log(type: 'feeding', startedAt: DateTime(2025, 7, 15, 12, 0)),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      expect(data.estimatedNextNap, isNull);
    });

    test('handles mixed log types correctly', () {
      final now = DateTime(2025, 7, 15, 15, 0);
      final logs = [
        _log(type: 'feeding', startedAt: DateTime(2025, 7, 15, 14, 0)),
        _log(type: 'diaper', startedAt: DateTime(2025, 7, 15, 13, 30)),
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 12, 0),
          endedAt: DateTime(2025, 7, 15, 13, 0),
          durationMinutes: 60,
        ),
        _log(type: 'feeding', startedAt: DateTime(2025, 7, 15, 10, 0)),
        _log(type: 'diaper', startedAt: DateTime(2025, 7, 15, 9, 0)),
        _log(type: 'mood', startedAt: DateTime(2025, 7, 15, 8, 0)),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      expect(data.timeSinceLastFeed, const Duration(hours: 1));
      expect(data.lastFeedTime, DateTime(2025, 7, 15, 14, 0));
      expect(data.feedCountToday, 2);
      expect(data.timeSinceLastDiaper, const Duration(hours: 1, minutes: 30));
      expect(data.lastDiaperTime, DateTime(2025, 7, 15, 13, 30));
      expect(data.diaperCountToday, 2);
    });

    test('handles sleep log without endedAt using startedAt as reference', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      // Sleep log with no endedAt — ongoing sleep; use startedAt + durationMinutes if available
      final logs = [
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 12, 0),
          durationMinutes: 60,
        ),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      // With durationMinutes=60, estimated end = 13:00, default interval 2h => next at 15:00
      expect(data.estimatedNextNap, const Duration(hours: 1));
    });

    test('uses startedAt when sleep has no endedAt and no durationMinutes', () {
      final now = DateTime(2025, 7, 15, 15, 0);
      final logs = [
        _log(
          type: 'sleep',
          startedAt: DateTime(2025, 7, 15, 12, 0),
        ),
      ];

      final data = WidgetDataService.computeWidgetData(logs, now);

      // Falls back to startedAt (12:00) + default 2h = 14:00
      // now is 15:00, so overdue => Duration.zero
      expect(data.estimatedNextNap, Duration.zero);
    });
  });

  group('WidgetData.feedStatus', () {
    test('returns green when feed was recent (< 2h)', () {
      final data = WidgetData(
        timeSinceLastFeed: const Duration(hours: 1, minutes: 30),
        feedCountToday: 1,
        diaperCountToday: 0,
      );
      expect(data.feedStatus, WidgetStatus.green);
    });

    test('returns yellow when feed is getting due (2-3h)', () {
      final data = WidgetData(
        timeSinceLastFeed: const Duration(hours: 2, minutes: 30),
        feedCountToday: 1,
        diaperCountToday: 0,
      );
      expect(data.feedStatus, WidgetStatus.yellow);
    });

    test('returns red when feed is overdue (>3h)', () {
      final data = WidgetData(
        timeSinceLastFeed: const Duration(hours: 3, minutes: 30),
        feedCountToday: 1,
        diaperCountToday: 0,
      );
      expect(data.feedStatus, WidgetStatus.red);
    });

    test('returns green when no feed data', () {
      final data = WidgetData(
        feedCountToday: 0,
        diaperCountToday: 0,
      );
      expect(data.feedStatus, WidgetStatus.green);
    });
  });

  group('WidgetData.diaperStatus', () {
    test('returns green when diaper was recent (< 2h)', () {
      final data = WidgetData(
        timeSinceLastDiaper: const Duration(hours: 1),
        feedCountToday: 0,
        diaperCountToday: 1,
      );
      expect(data.diaperStatus, WidgetStatus.green);
    });

    test('returns yellow when diaper is getting due (2-3h)', () {
      final data = WidgetData(
        timeSinceLastDiaper: const Duration(hours: 2, minutes: 30),
        feedCountToday: 0,
        diaperCountToday: 1,
      );
      expect(data.diaperStatus, WidgetStatus.yellow);
    });

    test('returns red when diaper is overdue (>3h)', () {
      final data = WidgetData(
        timeSinceLastDiaper: const Duration(hours: 4),
        feedCountToday: 0,
        diaperCountToday: 1,
      );
      expect(data.diaperStatus, WidgetStatus.red);
    });
  });

  group('WidgetData.napStatus', () {
    test('returns green when nap is not due soon (>30m)', () {
      final data = WidgetData(
        estimatedNextNap: const Duration(hours: 1),
        feedCountToday: 0,
        diaperCountToday: 0,
      );
      expect(data.napStatus, WidgetStatus.green);
    });

    test('returns yellow when nap is approaching (15-30m)', () {
      final data = WidgetData(
        estimatedNextNap: const Duration(minutes: 20),
        feedCountToday: 0,
        diaperCountToday: 0,
      );
      expect(data.napStatus, WidgetStatus.yellow);
    });

    test('returns red when nap is overdue (0m)', () {
      final data = WidgetData(
        estimatedNextNap: Duration.zero,
        feedCountToday: 0,
        diaperCountToday: 0,
      );
      expect(data.napStatus, WidgetStatus.red);
    });
  });

  group('WidgetData.formatDuration', () {
    test('formats hours and minutes', () {
      expect(WidgetData.formatDuration(const Duration(hours: 2, minutes: 15)),
          '2h 15m');
    });

    test('formats hours only', () {
      expect(WidgetData.formatDuration(const Duration(hours: 3)), '3h');
    });

    test('formats minutes only', () {
      expect(WidgetData.formatDuration(const Duration(minutes: 45)), '45m');
    });

    test('formats zero duration', () {
      expect(WidgetData.formatDuration(Duration.zero), '0m');
    });

    test('returns dash for null', () {
      expect(WidgetData.formatDuration(null), '--');
    });
  });
}
