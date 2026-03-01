import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/sync_queue_repository.dart';

void main() {
  late AppDatabase db;
  late SyncQueueRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SyncQueueRepository(db);
  });

  tearDown(() async => await db.close());

  group('SyncQueueRepository', () {
    test('enqueue creates a pending item', () async {
      final id = await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna', 'date_of_birth': '2025-06-15'},
      );
      expect(id, greaterThan(0));

      final item = await repo.getById(id);
      expect(item, isNotNull);
      expect(item!.targetTable, 'babies');
      expect(item.recordId, 1);
      expect(item.operation, 'insert');
      expect(item.syncedAt, isNull);
      expect(item.retryCount, 0);
    });

    test('getPendingItems returns only unsynced items', () async {
      await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
      final id2 = await repo.enqueue(
        targetTable: 'babies',
        recordId: 2,
        operation: 'insert',
        data: {'name': 'Max'},
      );

      // Mark one as synced.
      await repo.markSynced(id2);

      final pending = await repo.getPendingItems();
      expect(pending.length, 1);
      expect(pending.first.recordId, 1);
    });

    test('getPendingItemsForTable filters by table', () async {
      await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
      await repo.enqueue(
        targetTable: 'growth_records',
        recordId: 1,
        operation: 'insert',
        data: {'weight_kg': 3.5},
      );

      final babyItems = await repo.getPendingItemsForTable('babies');
      expect(babyItems.length, 1);
      expect(babyItems.first.targetTable, 'babies');

      final growthItems = await repo.getPendingItemsForTable('growth_records');
      expect(growthItems.length, 1);
      expect(growthItems.first.targetTable, 'growth_records');
    });

    test('markSynced sets syncedAt timestamp', () async {
      final id = await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );

      await repo.markSynced(id);

      final item = await repo.getById(id);
      expect(item!.syncedAt, isNotNull);
    });

    test('incrementRetry bumps retry count', () async {
      final id = await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );

      await repo.incrementRetry(id);
      var item = await repo.getById(id);
      expect(item!.retryCount, 1);

      await repo.incrementRetry(id);
      item = await repo.getById(id);
      expect(item!.retryCount, 2);
    });

    test('incrementRetry does nothing for non-existent id', () async {
      // Should not throw.
      await repo.incrementRetry(9999);
    });

    test('clearSynced removes only synced items', () async {
      final id1 = await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
      await repo.enqueue(
        targetTable: 'babies',
        recordId: 2,
        operation: 'insert',
        data: {'name': 'Max'},
      );

      await repo.markSynced(id1);
      final cleared = await repo.clearSynced();
      expect(cleared, 1);

      final remaining = await repo.getPendingItems();
      expect(remaining.length, 1);
      expect(remaining.first.recordId, 2);
    });

    test('getPendingCount returns correct count', () async {
      expect(await repo.getPendingCount(), 0);

      await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
      await repo.enqueue(
        targetTable: 'babies',
        recordId: 2,
        operation: 'update',
        data: {'name': 'Luna Star'},
      );

      expect(await repo.getPendingCount(), 2);
    });

    test('getFailedItems returns items exceeding max retries', () async {
      final id = await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );

      // Bump retry count to 5.
      for (var i = 0; i < 5; i++) {
        await repo.incrementRetry(id);
      }

      final failed = await repo.getFailedItems(maxRetries: 5);
      expect(failed.length, 1);
      expect(failed.first.retryCount, 5);

      // Under the threshold — should not appear.
      final notFailed = await repo.getFailedItems(maxRetries: 6);
      expect(notFailed.length, 0);
    });

    test('deleteItem removes a specific item', () async {
      final id = await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );

      final deleted = await repo.deleteItem(id);
      expect(deleted, 1);

      final item = await repo.getById(id);
      expect(item, isNull);
    });

    test('enqueue preserves JSON payload', () async {
      final data = {
        'name': 'Luna',
        'date_of_birth': '2025-06-15T00:00:00.000',
        'gender': 'female',
        'nested': {'key': 'value'},
      };

      final id = await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: data,
      );

      final item = await repo.getById(id);
      expect(item!.payload, contains('"name":"Luna"'));
      expect(item.payload, contains('"nested"'));
    });

    test('getPendingItems returns items ordered by createdAt', () async {
      await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'First'},
      );
      // Add a small delay to ensure different timestamps.
      await Future.delayed(const Duration(milliseconds: 10));
      await repo.enqueue(
        targetTable: 'babies',
        recordId: 2,
        operation: 'insert',
        data: {'name': 'Second'},
      );

      final pending = await repo.getPendingItems();
      expect(pending.length, 2);
      expect(pending[0].recordId, 1);
      expect(pending[1].recordId, 2);
    });

    test('watchPendingItems emits updates when items change', () async {
      final stream = repo.watchPendingItems();

      // Should start empty.
      expectLater(
        stream,
        emitsInOrder([
          predicate<List<SyncQueueData>>((items) => items.isEmpty),
          predicate<List<SyncQueueData>>((items) => items.length == 1),
        ]),
      );

      await Future.delayed(const Duration(milliseconds: 50));
      await repo.enqueue(
        targetTable: 'babies',
        recordId: 1,
        operation: 'insert',
        data: {'name': 'Luna'},
      );
    });
  });
}
