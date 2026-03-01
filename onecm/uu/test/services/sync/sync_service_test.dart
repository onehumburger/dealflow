import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/sync_queue_repository.dart';
import 'package:uu/services/sync/sync_service.dart';

// --- Mocks ---

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

// --- Helpers ---

User fakeUser({
  String id = 'test-user-id',
  String? email = 'test@example.com',
}) {
  return User(
    id: id,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2025-01-01T00:00:00Z',
    email: email,
  );
}

void main() {
  late AppDatabase db;
  late SyncQueueRepository syncQueueRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    syncQueueRepo = SyncQueueRepository(db);
  });

  tearDown(() async => await db.close());

  group('SyncService (no client)', () {
    late SyncService service;

    setUp(() {
      service = SyncService(
        client: null,
        syncQueueRepo: syncQueueRepo,
        db: db,
      );
    });

    tearDown(() => service.dispose());

    test('isConfigured returns false when no client', () {
      expect(service.isConfigured, isFalse);
    });

    test('isAuthenticated returns false when no client', () {
      expect(service.isAuthenticated, isFalse);
    });

    test('status starts as idle', () {
      expect(service.status, SyncStatus.idle);
    });

    test('pushPendingChanges returns 0 and sets offline when no client',
        () async {
      final result = await service.pushPendingChanges();
      expect(result, 0);
      expect(service.status, SyncStatus.offline);
    });

    test('pullRemoteChanges returns 0 and sets offline when no client',
        () async {
      final result = await service.pullRemoteChanges('babies');
      expect(result, 0);
      expect(service.status, SyncStatus.offline);
    });

    test('fullSync sets offline when no client', () async {
      await service.fullSync();
      expect(service.status, SyncStatus.offline);
    });

    test('startRealtimeSubscriptions does nothing when no client', () {
      service.startRealtimeSubscriptions();
    });

    test('stopRealtimeSubscriptions does nothing when no client', () async {
      await service.stopRealtimeSubscriptions();
    });

    test('dispose completes without error', () async {
      await service.dispose();
      // Calling again should also be safe since the stream is already closed.
    });
  });

  group('SyncService (with mock client, not authenticated)', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late SyncService service;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(null);

      service = SyncService(
        client: mockClient,
        syncQueueRepo: syncQueueRepo,
        db: db,
      );
    });

    tearDown(() => service.dispose());

    test('isConfigured returns true when client exists', () {
      expect(service.isConfigured, isTrue);
    });

    test('isAuthenticated returns false when no user', () {
      expect(service.isAuthenticated, isFalse);
    });

    test('pushPendingChanges returns 0 when not authenticated', () async {
      await syncQueueRepo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );

      final result = await service.pushPendingChanges();
      expect(result, 0);
      expect(service.status, SyncStatus.offline);
    });

    test('pullRemoteChanges returns 0 when not authenticated', () async {
      final result = await service.pullRemoteChanges('babies');
      expect(result, 0);
      expect(service.status, SyncStatus.offline);
    });

    test('fullSync sets offline when not authenticated', () async {
      await service.fullSync();
      expect(service.status, SyncStatus.offline);
    });

    test('startRealtimeSubscriptions does nothing when not authenticated', () {
      service.startRealtimeSubscriptions();
    });
  });

  group('SyncService (with mock client, authenticated)', () {
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late SyncService service;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(fakeUser());

      service = SyncService(
        client: mockClient,
        syncQueueRepo: syncQueueRepo,
        db: db,
      );
    });

    tearDown(() => service.dispose());

    test('isAuthenticated returns true when user exists', () {
      expect(service.isAuthenticated, isTrue);
    });

    test('pushPendingChanges returns 0 when queue is empty', () async {
      final result = await service.pushPendingChanges();
      expect(result, 0);
      expect(service.status, SyncStatus.idle);
    });

    test('enqueueChange creates a sync queue entry', () async {
      await service.enqueueChange(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna', 'date_of_birth': '2025-06-15'},
      );

      final pending = await syncQueueRepo.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.targetTable, 'babies');
      expect(pending.first.operation, 'insert');
    });

    test('cleanupSyncedItems removes synced entries', () async {
      final id = await syncQueueRepo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
      await syncQueueRepo.markSynced(id);

      final cleaned = await service.cleanupSyncedItems();
      expect(cleaned, 1);
    });

    test('statusStream emits status changes', () async {
      final statuses = <SyncStatus>[];
      final sub = service.statusStream.listen(statuses.add);

      // Push with empty queue triggers syncing -> idle
      await service.pushPendingChanges();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(statuses, contains(SyncStatus.idle));

      await sub.cancel();
    });

    test('pushPendingChanges skips items at max retries', () async {
      final id = await syncQueueRepo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
      for (var i = 0; i < SyncService.maxRetries; i++) {
        await syncQueueRepo.incrementRetry(id);
      }

      final result = await service.pushPendingChanges();
      expect(result, 0);

      // from() should NOT be called at all because item is skipped.
      verifyNever(() => mockClient.from(any()));
    });

    test('pushPendingChanges increments retry on failure', () async {
      await syncQueueRepo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );

      when(() => mockClient.from(any())).thenThrow(Exception('Network error'));

      final result = await service.pushPendingChanges();
      expect(result, 0);

      final pending = await syncQueueRepo.getPendingItems();
      expect(pending.first.retryCount, 1);
    });

    test('pushPendingChanges sets error status on partial failure', () async {
      await syncQueueRepo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );

      when(() => mockClient.from(any())).thenThrow(Exception('Network error'));

      await service.pushPendingChanges();
      expect(service.status, SyncStatus.error);
    });

    test('syncedTables includes babies and growth_records', () {
      expect(SyncService.syncedTables, contains('babies'));
      expect(SyncService.syncedTables, contains('growth_records'));
    });

    test('enqueueChange stores JSON payload correctly', () async {
      final data = {
        'name': 'Luna',
        'date_of_birth': '2025-06-15',
        'local_id': 1,
      };

      await service.enqueueChange(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: data,
      );

      final pending = await syncQueueRepo.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.payload, contains('"name":"Luna"'));
      expect(pending.first.payload, contains('"local_id":1'));
    });

    test('multiple enqueueChange calls create multiple entries', () async {
      await service.enqueueChange(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
      await service.enqueueChange(
        targetTable: 'growth_records',
        recordId: 1,
        operation: 'insert',
        data: {'weight_kg': 3.5},
      );

      final pending = await syncQueueRepo.getPendingItems();
      expect(pending.length, 2);
    });

    test('pullRemoteChanges returns 0 on network error', () async {
      when(() => mockClient.from('babies'))
          .thenThrow(Exception('Network error'));

      final result = await service.pullRemoteChanges('babies');
      expect(result, 0);
      expect(service.status, SyncStatus.error);
    });

    test('pushPendingChanges processes multiple items and retries each independently',
        () async {
      await syncQueueRepo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'First'},
      );
      await syncQueueRepo.enqueue(
        targetTable: 'babies',
        recordId: 2,
        operation: 'insert',
        data: {'name': 'Second'},
      );

      // Both will fail since from() throws.
      when(() => mockClient.from(any())).thenThrow(Exception('Network error'));

      await service.pushPendingChanges();

      // Both items should have retryCount = 1.
      final pending = await syncQueueRepo.getPendingItems();
      expect(pending.length, 2);
      expect(pending[0].retryCount, 1);
      expect(pending[1].retryCount, 1);
    });

    test('maxRetries constant is 5', () {
      expect(SyncService.maxRetries, 5);
    });
  });

  group('SyncStatus', () {
    test('has all expected values', () {
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.error));
      expect(SyncStatus.values, contains(SyncStatus.offline));
      expect(SyncStatus.values.length, 4);
    });
  });
}
