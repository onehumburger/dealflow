import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class DailyLogRepository {
  final AppDatabase _db;
  DailyLogRepository(this._db);

  Future<DailyLog> quickLog({required int babyId, required String type}) {
    return createLog(babyId: babyId, type: type, startedAt: DateTime.now());
  }

  Future<DailyLog> createLog({
    required int babyId,
    required String type,
    required DateTime startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metadata,
    String? notes,
  }) async {
    final durationMinutes =
        endedAt != null ? endedAt.difference(startedAt).inMinutes : null;
    final id = await _db.into(_db.dailyLogs).insert(DailyLogsCompanion.insert(
          babyId: babyId,
          type: type,
          startedAt: startedAt,
          endedAt: Value(endedAt),
          durationMinutes: Value(durationMinutes),
          metadata: Value(metadata != null ? jsonEncode(metadata) : null),
          notes: Value(notes),
        ));
    return (await getLog(id))!;
  }

  Future<DailyLog?> getLog(int id) {
    return (_db.select(_db.dailyLogs)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<DailyLog>> getLogsForDay(int babyId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.startedAt)]))
        .get();
  }

  Future<List<DailyLog>> getLogsForDayByType(
      int babyId, DateTime day, String type) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.type.equals(type) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.startedAt)]))
        .get();
  }

  Future<void> endLog(int id, DateTime endedAt) async {
    final log = await getLog(id);
    if (log == null) return;
    final duration = endedAt.difference(log.startedAt).inMinutes;
    await (_db.update(_db.dailyLogs)..where((l) => l.id.equals(id))).write(
      DailyLogsCompanion(
          endedAt: Value(endedAt), durationMinutes: Value(duration)),
    );
  }

  Stream<List<DailyLog>> watchLogsForDay(int babyId, DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.dailyLogs)
          ..where((l) =>
              l.babyId.equals(babyId) &
              l.startedAt.isBiggerOrEqualValue(start) &
              l.startedAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.startedAt)]))
        .watch();
  }
}
