import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/sync_queue_repository.dart';

/// Status of the sync engine.
enum SyncStatus {
  idle,
  syncing,
  error,
  offline,
}

/// Coordinates bidirectional sync between the local Drift database
/// and the remote Supabase database.
///
/// All local reads go through Drift. Writes are queued in [SyncQueue]
/// and pushed to Supabase when online and authenticated.
///
/// Conflict resolution: last-write-wins using the `updated_at` timestamp.
class SyncService {
  final SupabaseClient? _client;
  final SyncQueueRepository _syncQueueRepo;
  final AppDatabase _db;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  /// Stream controller for status changes.
  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Active realtime channels, keyed by table name.
  final Map<String, RealtimeChannel> _channels = {};

  /// Maximum retries before giving up on a queue item.
  static const int maxRetries = 5;

  /// Tables that support sync, with their Supabase table name.
  /// Add more tables here as sync support expands.
  static const List<String> syncedTables = ['babies', 'growth_records'];

  SyncService({
    required SupabaseClient? client,
    required SyncQueueRepository syncQueueRepo,
    required AppDatabase db,
  })  : _client = client,
        _syncQueueRepo = syncQueueRepo,
        _db = db;

  /// Whether we have a configured Supabase client.
  bool get isConfigured => _client != null;

  /// Whether the current user is authenticated.
  bool get isAuthenticated {
    return _client?.auth.currentUser != null;
  }

  void _setStatus(SyncStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
    }
  }

  // ---------------------------------------------------------------------------
  // Push: local -> remote
  // ---------------------------------------------------------------------------

  /// Push all pending changes from the sync queue to Supabase.
  ///
  /// Returns the number of items successfully synced.
  Future<int> pushPendingChanges() async {
    if (!isConfigured || !isAuthenticated) {
      _setStatus(SyncStatus.offline);
      return 0;
    }

    _setStatus(SyncStatus.syncing);

    final pending = await _syncQueueRepo.getPendingItems();
    if (pending.isEmpty) {
      _setStatus(SyncStatus.idle);
      return 0;
    }

    int syncedCount = 0;

    for (final item in pending) {
      if (item.retryCount >= maxRetries) continue;

      try {
        await _pushItem(item);
        await _syncQueueRepo.markSynced(item.id);
        syncedCount++;
      } catch (e) {
        await _syncQueueRepo.incrementRetry(item.id);
        // Continue with next item — don't fail the whole batch.
      }
    }

    _setStatus(syncedCount == pending.length
        ? SyncStatus.idle
        : SyncStatus.error);

    return syncedCount;
  }

  /// Push a single sync queue item to Supabase.
  Future<void> _pushItem(SyncQueueData item) async {
    final client = _client;
    if (client == null) return;

    final payload = jsonDecode(item.payload) as Map<String, dynamic>;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    // Attach the user_id for RLS.
    payload['user_id'] = userId;

    switch (item.operation) {
      case 'insert':
        await client.from(item.targetTable).upsert(payload);
        break;
      case 'update':
        await client.from(item.targetTable).upsert(payload);
        break;
      case 'delete':
        // For delete, we need a way to identify the remote row.
        // We use a combination of user_id + local_id.
        await client
            .from(item.targetTable)
            .delete()
            .eq('user_id', userId)
            .eq('local_id', item.recordId);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Pull: remote -> local
  // ---------------------------------------------------------------------------

  /// Pull changes from Supabase for the given table since the last sync.
  ///
  /// [tableName] is the Supabase table name.
  /// [since] is the timestamp to fetch changes from. If null, fetches all.
  ///
  /// Returns the number of records pulled.
  Future<int> pullRemoteChanges(String tableName, {DateTime? since}) async {
    final client = _client;
    if (client == null || !isAuthenticated) {
      _setStatus(SyncStatus.offline);
      return 0;
    }

    _setStatus(SyncStatus.syncing);

    try {
      var query = client.from(tableName).select();

      if (since != null) {
        query = query.gt('updated_at', since.toIso8601String());
      }

      final rows = await query;

      int count = 0;
      for (final row in rows) {
        await _applyRemoteRow(tableName, row);
        count++;
      }

      _setStatus(SyncStatus.idle);
      return count;
    } catch (e) {
      _setStatus(SyncStatus.error);
      return 0;
    }
  }

  /// Apply a single remote row to the local database.
  ///
  /// Uses last-write-wins: if the remote row has a newer `updated_at`
  /// than the local row, overwrite. Otherwise, skip.
  Future<void> _applyRemoteRow(
    String tableName,
    Map<String, dynamic> row,
  ) async {
    switch (tableName) {
      case 'babies':
        await _applyRemoteBaby(row);
        break;
      case 'growth_records':
        await _applyRemoteGrowthRecord(row);
        break;
    }
  }

  Future<void> _applyRemoteBaby(Map<String, dynamic> row) async {
    final localId = row['local_id'] as int?;
    if (localId == null) return;

    final existing = await (_db.select(_db.babies)
          ..where((b) => b.id.equals(localId)))
        .getSingleOrNull();

    final remoteUpdatedAt = DateTime.tryParse(row['updated_at'] ?? '');

    // Last-write-wins: compare local updatedAt against remote updated_at.
    if (existing != null && remoteUpdatedAt != null) {
      if (existing.updatedAt.isAfter(remoteUpdatedAt)) {
        return; // Local is newer — skip.
      }
    }

    if (existing != null) {
      await (_db.update(_db.babies)..where((b) => b.id.equals(localId))).write(
        BabiesCompanion(
          name: Value(row['name'] as String),
          dateOfBirth: Value(DateTime.parse(row['date_of_birth'] as String)),
          gender: Value(row['gender'] as String?),
          bloodType: Value(row['blood_type'] as String?),
          photoUrl: Value(row['photo_url'] as String?),
          updatedAt: Value(remoteUpdatedAt ?? DateTime.now()),
        ),
      );
    } else {
      await _db.into(_db.babies).insert(
            BabiesCompanion.insert(
              name: row['name'] as String,
              dateOfBirth: DateTime.parse(row['date_of_birth'] as String),
              gender: Value(row['gender'] as String?),
              bloodType: Value(row['blood_type'] as String?),
              photoUrl: Value(row['photo_url'] as String?),
            ),
          );
    }
  }

  Future<void> _applyRemoteGrowthRecord(Map<String, dynamic> row) async {
    final localId = row['local_id'] as int?;
    if (localId == null) return;

    final existing = await (_db.select(_db.growthRecords)
          ..where((r) => r.id.equals(localId)))
        .getSingleOrNull();

    final remoteUpdatedAt = DateTime.tryParse(row['updated_at'] ?? '');

    // Last-write-wins: compare local updatedAt against remote updated_at.
    if (existing != null && remoteUpdatedAt != null) {
      if (existing.updatedAt.isAfter(remoteUpdatedAt)) {
        return; // Local is newer — skip.
      }
    }

    if (existing != null) {
      await (_db.update(_db.growthRecords)
            ..where((r) => r.id.equals(localId)))
          .write(
        GrowthRecordsCompanion(
          babyId: Value(row['baby_id'] as int),
          date: Value(DateTime.parse(row['date'] as String)),
          weightKg: Value((row['weight_kg'] as num?)?.toDouble()),
          heightCm: Value((row['height_cm'] as num?)?.toDouble()),
          headCircumferenceCm:
              Value((row['head_circumference_cm'] as num?)?.toDouble()),
          notes: Value(row['notes'] as String?),
          photoUrl: Value(row['photo_url'] as String?),
          updatedAt: Value(remoteUpdatedAt ?? DateTime.now()),
        ),
      );
    } else {
      await _db.into(_db.growthRecords).insert(
            GrowthRecordsCompanion.insert(
              babyId: row['baby_id'] as int,
              date: DateTime.parse(row['date'] as String),
              weightKg: Value((row['weight_kg'] as num?)?.toDouble()),
              heightCm: Value((row['height_cm'] as num?)?.toDouble()),
              headCircumferenceCm:
                  Value((row['head_circumference_cm'] as num?)?.toDouble()),
              notes: Value(row['notes'] as String?),
              photoUrl: Value(row['photo_url'] as String?),
            ),
          );
    }
  }

  // ---------------------------------------------------------------------------
  // Realtime subscriptions
  // ---------------------------------------------------------------------------

  /// Start listening for realtime changes on all synced tables.
  void startRealtimeSubscriptions() {
    if (!isConfigured || !isAuthenticated) return;

    for (final table in syncedTables) {
      _subscribeToTable(table);
    }
  }

  /// Subscribe to Postgres changes on a single table.
  void _subscribeToTable(String tableName) {
    final client = _client;
    if (client == null) return;

    // Don't subscribe twice.
    if (_channels.containsKey(tableName)) return;

    final channel = client
        .channel('sync_$tableName')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          callback: (payload) {
            _handleRealtimeChange(tableName, payload);
          },
        )
        .subscribe();

    _channels[tableName] = channel;
  }

  /// Handle an incoming realtime change from Supabase.
  void _handleRealtimeChange(
    String tableName,
    PostgresChangePayload payload,
  ) {
    final newRecord = payload.newRecord;
    if (newRecord.isNotEmpty) {
      // Apply the change to the local DB.
      _applyRemoteRow(tableName, newRecord);
    }
  }

  /// Stop all realtime subscriptions.
  Future<void> stopRealtimeSubscriptions() async {
    final client = _client;
    if (client == null) return;

    for (final entry in _channels.entries) {
      await client.removeChannel(entry.value);
    }
    _channels.clear();
  }

  // ---------------------------------------------------------------------------
  // Full sync cycle
  // ---------------------------------------------------------------------------

  /// Run a full sync cycle: push pending, then pull remote changes.
  Future<void> fullSync() async {
    if (!isConfigured || !isAuthenticated) {
      _setStatus(SyncStatus.offline);
      return;
    }

    await pushPendingChanges();

    for (final table in syncedTables) {
      await pullRemoteChanges(table);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers for repositories
  // ---------------------------------------------------------------------------

  /// Convenience method for repositories to enqueue a change after a local write.
  ///
  /// Example usage in BabyRepository:
  /// ```dart
  /// final baby = await createBaby(...);
  /// await syncService.enqueueChange('babies', baby.id, 'insert', { ... });
  /// ```
  Future<void> enqueueChange({
    required String targetTable,
    required int recordId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    await _syncQueueRepo.enqueue(
      targetTable: targetTable,
      recordId: recordId,
      operation: operation,
      data: data,
    );
  }

  /// Clean up synced items from the queue.
  Future<int> cleanupSyncedItems() async {
    return _syncQueueRepo.clearSynced();
  }

  /// Dispose the sync service and clean up resources.
  Future<void> dispose() async {
    await stopRealtimeSubscriptions();
    await _statusController.close();
  }
}
