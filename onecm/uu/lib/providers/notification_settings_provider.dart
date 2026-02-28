import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';

final notificationSettingsProvider =
    FutureProvider<List<NotificationSetting>>((ref) async {
  final db = ref.watch(databaseProvider);
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return [];
  return (db.select(db.notificationSettings)
        ..where((t) => t.babyId.equals(babyId)))
      .get();
});

final notificationSettingsActionsProvider =
    Provider<NotificationSettingsActions>((ref) {
  return NotificationSettingsActions(ref.watch(databaseProvider));
});

class NotificationSettingsActions {
  final AppDatabase _db;

  NotificationSettingsActions(this._db);

  Future<void> upsertSetting({
    required int babyId,
    required String type,
    required bool enabled,
    required int intervalMinutes,
  }) async {
    final existing = await (_db.select(_db.notificationSettings)
          ..where((t) => t.babyId.equals(babyId) & t.type.equals(type)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.notificationSettings)
            ..where((t) => t.id.equals(existing.id)))
          .write(NotificationSettingsCompanion(
        enabled: Value(enabled),
        intervalMinutes: Value(intervalMinutes),
      ));
    } else {
      await _db.into(_db.notificationSettings).insert(
            NotificationSettingsCompanion.insert(
              babyId: babyId,
              type: type,
              enabled: Value(enabled),
              intervalMinutes: Value(intervalMinutes),
            ),
          );
    }
  }
}
