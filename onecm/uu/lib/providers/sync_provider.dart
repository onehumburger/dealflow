import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/config/supabase_config.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/repositories/sync_queue_repository.dart';
import 'package:uu/services/sync/sync_service.dart';

/// Provider for the [SyncQueueRepository].
final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository(ref.watch(databaseProvider));
});

/// Provider for the [SyncService].
///
/// Creates a single instance that coordinates push/pull sync
/// and realtime subscriptions.
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    client: SupabaseConfig.clientOrNull,
    syncQueueRepo: ref.watch(syncQueueRepositoryProvider),
    db: ref.watch(databaseProvider),
  );

  ref.onDispose(() => service.dispose());

  return service;
});

/// Provider that exposes the current [SyncStatus] as a stream.
///
/// UI can watch this to show sync indicators (spinner, error icon, etc.).
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.statusStream;
});

/// Provider for the count of pending sync items.
///
/// Useful for showing a badge on sync status indicators.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(syncQueueRepositoryProvider);
  return repo.watchPendingItems().map((items) => items.length);
});
