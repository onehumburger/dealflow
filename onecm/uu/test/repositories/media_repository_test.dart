import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/media_repository.dart';

void main() {
  late AppDatabase db;
  late MediaRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MediaRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MediaRepository', () {
    test('addMedia inserts and returns a media entry', () async {
      final media = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1.jpg',
        takenAt: DateTime(2026, 3, 1, 10, 30),
      );

      expect(media.babyId, 1);
      expect(media.type, 'photo');
      expect(media.storagePath, '/local/photos/baby1.jpg');
      expect(media.takenAt, DateTime(2026, 3, 1, 10, 30));
      expect(media.thumbnailPath, isNull);
      expect(media.caption, isNull);
      expect(media.linkedRecordType, isNull);
      expect(media.linkedRecordId, isNull);
    });

    test('addMedia with all optional fields', () async {
      final media = await repo.addMedia(
        babyId: 1,
        type: 'video',
        storagePath: '/local/videos/baby1.mp4',
        thumbnailPath: '/local/thumbnails/baby1_thumb.jpg',
        caption: 'First steps!',
        takenAt: DateTime(2026, 3, 1),
        linkedRecordType: 'milestone',
        linkedRecordId: 42,
      );

      expect(media.type, 'video');
      expect(media.thumbnailPath, '/local/thumbnails/baby1_thumb.jpg');
      expect(media.caption, 'First steps!');
      expect(media.linkedRecordType, 'milestone');
      expect(media.linkedRecordId, 42);
    });

    test('getMedia returns media by id', () async {
      final created = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1.jpg',
      );

      final fetched = await repo.getMedia(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, created.id);
      expect(fetched.storagePath, '/local/photos/baby1.jpg');
    });

    test('getMedia returns null for non-existent id', () async {
      final result = await repo.getMedia(999);
      expect(result, isNull);
    });

    test('getMediaForBaby returns only media for specified baby', () async {
      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1_a.jpg',
      );
      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1_b.jpg',
      );
      await repo.addMedia(
        babyId: 2,
        type: 'photo',
        storagePath: '/local/photos/baby2_a.jpg',
      );

      final media = await repo.getMediaForBaby(1);
      expect(media.length, 2);
      expect(media.every((m) => m.babyId == 1), isTrue);
    });

    test('getMediaForBaby orders by createdAt descending', () async {
      // Insert in order — createdAt defaults to currentDateAndTime,
      // but we can rely on auto-increment id for in-memory DB ordering.
      final first = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/first.jpg',
        takenAt: DateTime(2026, 1, 1),
      );
      final second = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/second.jpg',
        takenAt: DateTime(2026, 2, 1),
      );
      final third = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/third.jpg',
        takenAt: DateTime(2026, 3, 1),
      );

      final media = await repo.getMediaForBaby(1);
      // Most recent created first
      expect(media[0].id, third.id);
      expect(media[1].id, second.id);
      expect(media[2].id, first.id);
    });

    test('watchMediaForBaby emits updates', () async {
      final stream = repo.watchMediaForBaby(1);

      final firstEmit = await stream.first;
      expect(firstEmit, isEmpty);

      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1.jpg',
      );

      final secondEmit = await stream.first;
      expect(secondEmit.length, 1);
      expect(secondEmit.first.storagePath, '/local/photos/baby1.jpg');
    });

    test('getMediaForRecord returns linked media', () async {
      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/milestone1.jpg',
        linkedRecordType: 'milestone',
        linkedRecordId: 10,
      );
      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/milestone2.jpg',
        linkedRecordType: 'milestone',
        linkedRecordId: 10,
      );
      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/growth1.jpg',
        linkedRecordType: 'growth',
        linkedRecordId: 5,
      );
      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/unlinked.jpg',
      );

      final milestoneMedia = await repo.getMediaForRecord('milestone', 10);
      expect(milestoneMedia.length, 2);
      expect(
        milestoneMedia.every((m) => m.linkedRecordType == 'milestone'),
        isTrue,
      );
      expect(
        milestoneMedia.every((m) => m.linkedRecordId == 10),
        isTrue,
      );

      final growthMedia = await repo.getMediaForRecord('growth', 5);
      expect(growthMedia.length, 1);
    });

    test('updateStoragePath updates the storagePath field', () async {
      final media = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1.jpg',
      );

      await repo.updateStoragePath(media.id, '/remote/photos/baby1.jpg');

      final updated = await repo.getMedia(media.id);
      expect(updated!.storagePath, '/remote/photos/baby1.jpg');
    });

    test('updateThumbnailPath updates the thumbnailPath field', () async {
      final media = await repo.addMedia(
        babyId: 1,
        type: 'video',
        storagePath: '/local/videos/baby1.mp4',
      );

      await repo.updateThumbnailPath(media.id, '/local/thumbs/baby1.jpg');

      final updated = await repo.getMedia(media.id);
      expect(updated!.thumbnailPath, '/local/thumbs/baby1.jpg');
    });

    test('updateCaption updates the caption field', () async {
      final media = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1.jpg',
      );

      await repo.updateCaption(media.id, 'Cute smile!');

      final updated = await repo.getMedia(media.id);
      expect(updated!.caption, 'Cute smile!');
    });

    test('deleteMedia removes the entry', () async {
      final media = await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/baby1.jpg',
      );

      await repo.deleteMedia(media.id);

      final result = await repo.getMedia(media.id);
      expect(result, isNull);
    });

    test('getMediaCountForBaby returns correct count', () async {
      await repo.addMedia(
        babyId: 1,
        type: 'photo',
        storagePath: '/local/photos/a.jpg',
      );
      await repo.addMedia(
        babyId: 1,
        type: 'video',
        storagePath: '/local/videos/b.mp4',
      );
      await repo.addMedia(
        babyId: 2,
        type: 'photo',
        storagePath: '/local/photos/c.jpg',
      );

      final count = await repo.getMediaCountForBaby(1);
      expect(count, 2);

      final count2 = await repo.getMediaCountForBaby(2);
      expect(count2, 1);

      final count3 = await repo.getMediaCountForBaby(999);
      expect(count3, 0);
    });
  });
}
