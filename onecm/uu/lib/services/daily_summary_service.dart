import 'package:uu/repositories/daily_log_repository.dart';

class DailySummary {
  final int feedingCount;
  final int totalSleepMinutes;
  final int diaperCount;
  final int moodCount;
  final DateTime? lastFeedingAt;
  final DateTime? lastDiaperAt;

  DailySummary({
    this.feedingCount = 0,
    this.totalSleepMinutes = 0,
    this.diaperCount = 0,
    this.moodCount = 0,
    this.lastFeedingAt,
    this.lastDiaperAt,
  });
}

class DailySummaryService {
  final DailyLogRepository _logRepo;
  DailySummaryService(this._logRepo);

  Future<DailySummary> getSummary(int babyId, DateTime day) async {
    final logs = await _logRepo.getLogsForDay(babyId, day);
    final feedings = logs.where((l) => l.type == 'feeding').toList();
    final sleeps = logs.where((l) => l.type == 'sleep').toList();
    final diapers = logs.where((l) => l.type == 'diaper').toList();
    final moods = logs.where((l) => l.type == 'mood').toList();

    final totalSleep = sleeps.fold<int>(0, (sum, log) {
      if (log.endedAt != null) {
        return sum + log.endedAt!.difference(log.startedAt).inMinutes;
      }
      return sum + (log.durationMinutes ?? 0);
    });

    return DailySummary(
      feedingCount: feedings.length,
      totalSleepMinutes: totalSleep,
      diaperCount: diapers.length,
      moodCount: moods.length,
      lastFeedingAt: feedings.isNotEmpty ? feedings.first.startedAt : null,
      lastDiaperAt: diapers.isNotEmpty ? diapers.first.startedAt : null,
    );
  }
}
