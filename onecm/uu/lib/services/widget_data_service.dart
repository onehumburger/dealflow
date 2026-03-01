import 'package:uu/database/app_database.dart';

enum WidgetStatus { green, yellow, red }

class WidgetData {
  final Duration? timeSinceLastFeed;
  final Duration? timeSinceLastDiaper;
  final Duration? estimatedNextNap;
  final DateTime? lastFeedTime;
  final DateTime? lastDiaperTime;
  final int feedCountToday;
  final int diaperCountToday;

  const WidgetData({
    this.timeSinceLastFeed,
    this.timeSinceLastDiaper,
    this.estimatedNextNap,
    this.lastFeedTime,
    this.lastDiaperTime,
    required this.feedCountToday,
    required this.diaperCountToday,
  });

  /// Feed status: green < 2h, yellow 2-3h, red > 3h.
  WidgetStatus get feedStatus {
    if (timeSinceLastFeed == null) return WidgetStatus.green;
    if (timeSinceLastFeed!.inMinutes < 120) return WidgetStatus.green;
    if (timeSinceLastFeed!.inMinutes < 180) return WidgetStatus.yellow;
    return WidgetStatus.red;
  }

  /// Diaper status: green < 2h, yellow 2-3h, red > 3h.
  WidgetStatus get diaperStatus {
    if (timeSinceLastDiaper == null) return WidgetStatus.green;
    if (timeSinceLastDiaper!.inMinutes < 120) return WidgetStatus.green;
    if (timeSinceLastDiaper!.inMinutes < 180) return WidgetStatus.yellow;
    return WidgetStatus.red;
  }

  /// Nap status: green > 30m away, yellow 15-30m, red <= 15m or overdue.
  WidgetStatus get napStatus {
    if (estimatedNextNap == null) return WidgetStatus.green;
    if (estimatedNextNap!.inMinutes > 30) return WidgetStatus.green;
    if (estimatedNextNap!.inMinutes > 15) return WidgetStatus.yellow;
    return WidgetStatus.red;
  }

  /// Format a duration for display. Returns '--' for null.
  static String formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }
}

class WidgetDataService {
  /// Default wake window when we only have one sleep log (2 hours).
  static const _defaultWakeWindow = Duration(hours: 2);

  /// Pure function: compute widget display data from today's logs.
  ///
  /// [logs] should be sorted descending by startedAt (most recent first),
  /// matching the order from DailyLogRepository.getLogsForDay.
  static WidgetData computeWidgetData(List<DailyLog> logs, DateTime now) {
    final feedings = logs.where((l) => l.type == 'feeding').toList();
    final diapers = logs.where((l) => l.type == 'diaper').toList();
    final sleeps = logs.where((l) => l.type == 'sleep').toList();

    // Time since last feed
    final lastFeed = feedings.isNotEmpty ? feedings.first : null;
    final timeSinceLastFeed =
        lastFeed != null ? now.difference(lastFeed.startedAt) : null;

    // Time since last diaper
    final lastDiaper = diapers.isNotEmpty ? diapers.first : null;
    final timeSinceLastDiaper =
        lastDiaper != null ? now.difference(lastDiaper.startedAt) : null;

    // Estimate next nap
    final estimatedNextNap = _estimateNextNap(sleeps, now);

    return WidgetData(
      timeSinceLastFeed: timeSinceLastFeed,
      timeSinceLastDiaper: timeSinceLastDiaper,
      estimatedNextNap: estimatedNextNap,
      lastFeedTime: lastFeed?.startedAt,
      lastDiaperTime: lastDiaper?.startedAt,
      feedCountToday: feedings.length,
      diaperCountToday: diapers.length,
    );
  }

  /// Estimate the time until the next nap.
  ///
  /// With 2+ sleep logs: compute average wake window (time between end of one
  /// nap and start of the next), then estimate when the next nap should start.
  /// With 1 sleep log: use default 2h wake window.
  /// With 0 sleep logs: return null (no estimate possible).
  static Duration? _estimateNextNap(List<DailyLog> sleeps, DateTime now) {
    if (sleeps.isEmpty) return null;

    // Sleeps are desc by startedAt; reverse for chronological order
    final chronological = sleeps.reversed.toList();

    // Get the effective end time of the last sleep
    final lastSleep = chronological.last;
    final lastSleepEnd = _sleepEndTime(lastSleep);

    Duration wakeWindow;

    if (chronological.length >= 2) {
      // Calculate average wake window between consecutive naps
      int totalWakeMinutes = 0;
      int intervals = 0;

      for (int i = 0; i < chronological.length - 1; i++) {
        final currentEnd = _sleepEndTime(chronological[i]);
        final nextStart = chronological[i + 1].startedAt;
        final wake = nextStart.difference(currentEnd);
        if (!wake.isNegative) {
          totalWakeMinutes += wake.inMinutes;
          intervals++;
        }
      }

      wakeWindow = intervals > 0
          ? Duration(minutes: totalWakeMinutes ~/ intervals)
          : _defaultWakeWindow;
    } else {
      wakeWindow = _defaultWakeWindow;
    }

    final nextNapTime = lastSleepEnd.add(wakeWindow);
    final timeUntilNap = nextNapTime.difference(now);

    return timeUntilNap.isNegative ? Duration.zero : timeUntilNap;
  }

  /// Get the effective end time of a sleep log.
  static DateTime _sleepEndTime(DailyLog sleep) {
    if (sleep.endedAt != null) return sleep.endedAt!;
    if (sleep.durationMinutes != null) {
      return sleep.startedAt.add(Duration(minutes: sleep.durationMinutes!));
    }
    return sleep.startedAt;
  }
}
