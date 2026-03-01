import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

/// Repository for managing the local sync queue.
///
/// The sync queue tracks local changes (inserts, updates, deletes)
/// that need to be pushed to Supabase. Each entry contains the
/// table name, record ID, operation type, and a JSON payload.
class SyncQueueRepository {
  final AppDatabase _db;
  SyncQueueRepository(this._db);

  /// Enqueue a change to be synced later.
  ///
  /// [targetTable] is the Supabase table name (e.g. 'babies').
  /// [recordId] is the local Drift row ID.
  /// [operation] is one of 'insert', 'update', 'delete'.
  /// [data] is the row data as a Map, which gets JSON-encoded.
  Future<int> enqueue({
    required String targetTable,
    required int recordId,
    required String operation,
    required Map<String, dynamic> data,
  }) {
    return _db.into(_db.syncQueue).insert(
          SyncQueueCompanion.insert(
            targetTable: targetTable,
            recordId: recordId,
            operation: operation,
            payload: jsonEncode(data),
          ),
        );
  }

  /// Get all pending (unsynced) items, ordered by creation time.
  Future<List<SyncQueueData>> getPendingItems() {
    return (_db.select(_db.syncQueue)
          ..where((q) => q.syncedAt.isNull())
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
  }

  /// Get pending items for a specific table.
  Future<List<SyncQueueData>> getPendingItemsForTable(String targetTable) {
    return (_db.select(_db.syncQueue)
          ..where(
              (q) => q.syncedAt.isNull() & q.targetTable.equals(targetTable))
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
  }

  /// Mark a queue item as synced (sets syncedAt to now).
  Future<void> markSynced(int id) {
    return (_db.update(_db.syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// Increment the retry count for a failed sync attempt.
  Future<void> incrementRetry(int id) async {
    final item = await (_db.select(_db.syncQueue)
          ..where((q) => q.id.equals(id)))
        .getSingleOrNull();
    if (item == null) return;

    await (_db.update(_db.syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(retryCount: Value(item.retryCount + 1)),
    );
  }

  /// Remove all synced items (where syncedAt is not null).
  Future<int> clearSynced() {
    return (_db.delete(_db.syncQueue)
          ..where((q) => q.syncedAt.isNotNull()))
        .go();
  }

  /// Get the count of pending items.
  Future<int> getPendingCount() async {
    final items = await getPendingItems();
    return items.length;
  }

  /// Get a single queue item by ID.
  Future<SyncQueueData?> getById(int id) {
    return (_db.select(_db.syncQueue)..where((q) => q.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get items that have exceeded the max retry count.
  Future<List<SyncQueueData>> getFailedItems({int maxRetries = 5}) {
    return (_db.select(_db.syncQueue)
          ..where((q) =>
              q.syncedAt.isNull() &
              q.retryCount.isBiggerOrEqualValue(maxRetries))
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .get();
  }

  /// Delete a specific queue item.
  Future<int> deleteItem(int id) {
    return (_db.delete(_db.syncQueue)..where((q) => q.id.equals(id))).go();
  }

  /// Watch pending items as a stream (useful for UI indicators).
  Stream<List<SyncQueueData>> watchPendingItems() {
    return (_db.select(_db.syncQueue)
          ..where((q) => q.syncedAt.isNull())
          ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
        .watch();
  }
}
