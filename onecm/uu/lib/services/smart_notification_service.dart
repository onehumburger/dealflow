import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/analysis/interval_analyzer.dart';

/// Service that uses [IntervalAnalyzer] to calculate AI-suggested notification
/// intervals from recent logs and persists them in notification_settings.
class SmartNotificationService {
  final AppDatabase _db;
  final IntervalAnalyzer _analyzer;

  SmartNotificationService(this._db, {IntervalAnalyzer? analyzer})
      : _analyzer = analyzer ?? IntervalAnalyzer();

  /// Analyze the last [days] of logs for [type] ('feeding' or 'diaper') and
  /// return an [IntervalSuggestion], or null if insufficient data.
  Future<IntervalSuggestion?> analyzeInterval({
    required int babyId,
    required String type,
    int days = 7,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final start = currentTime.subtract(Duration(days: days));

    final logs = await (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.type.equals(type) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(currentTime))
          ..orderBy([(l) => OrderingTerm.asc(l.startedAt)]))
        .get();

    return _analyzer.analyze(logs);
  }

  /// Analyze intervals and persist the suggestion in notification_settings.
  ///
  /// Returns the [IntervalSuggestion] if analysis succeeded, null otherwise.
  Future<IntervalSuggestion?> updateSuggestedInterval({
    required int babyId,
    required String type,
    int days = 7,
    DateTime? now,
  }) async {
    final suggestion = await analyzeInterval(
      babyId: babyId,
      type: type,
      days: days,
      now: now,
    );

    if (suggestion == null) return null;

    // Find or create the notification setting row
    final existing = await (_db.select(_db.notificationSettings)
          ..where((t) => t.babyId.equals(babyId) & t.type.equals(type)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.notificationSettings)
            ..where((t) => t.id.equals(existing.id)))
          .write(NotificationSettingsCompanion(
        aiSuggestedInterval: Value(suggestion.suggestedIntervalMinutes),
      ));
    } else {
      await _db.into(_db.notificationSettings).insert(
            NotificationSettingsCompanion.insert(
              babyId: babyId,
              type: type,
              aiSuggestedInterval:
                  Value(suggestion.suggestedIntervalMinutes),
            ),
          );
    }

    return suggestion;
  }

  /// Convenience method to update suggestions for all trackable types.
  Future<Map<String, IntervalSuggestion?>> updateAllSuggestions({
    required int babyId,
    int days = 7,
    DateTime? now,
  }) async {
    final results = <String, IntervalSuggestion?>{};
    for (final type in ['feeding', 'diaper']) {
      results[type] = await updateSuggestedInterval(
        babyId: babyId,
        type: type,
        days: days,
        now: now,
      );
    }
    return results;
  }
}
