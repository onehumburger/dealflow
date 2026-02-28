import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/daily_log_repository.dart';
import 'package:uu/services/daily_summary_service.dart';

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  return DailyLogRepository(ref.watch(databaseProvider));
});

final todayLogsProvider = StreamProvider<List<DailyLog>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref
      .watch(dailyLogRepositoryProvider)
      .watchLogsForDay(babyId, DateTime.now());
});

final dailySummaryServiceProvider = Provider<DailySummaryService>((ref) {
  return DailySummaryService(ref.watch(dailyLogRepositoryProvider));
});

final todaySummaryProvider = FutureProvider<DailySummary>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return DailySummary();
  ref.watch(todayLogsProvider);
  return ref
      .watch(dailySummaryServiceProvider)
      .getSummary(babyId, DateTime.now());
});
