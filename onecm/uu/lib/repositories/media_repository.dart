import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class MediaRepository {
  final AppDatabase _db;
  MediaRepository(this._db);

  /// Insert a new media entry and return it.
  Future<MediaEntry> addMedia({
    required int babyId,
    required String type,
    required String storagePath,
    String? thumbnailPath,
    String? caption,
    DateTime? takenAt,
    String? linkedRecordType,
    int? linkedRecordId,
  }) async {
    final id = await _db.into(_db.mediaEntries).insert(
          MediaEntriesCompanion.insert(
            babyId: babyId,
            type: type,
            storagePath: storagePath,
            thumbnailPath: Value(thumbnailPath),
            caption: Value(caption),
            takenAt: Value(takenAt),
            linkedRecordType: Value(linkedRecordType),
            linkedRecordId: Value(linkedRecordId),
          ),
        );
    return (await getMedia(id))!;
  }

  /// Get a single media entry by id.
  Future<MediaEntry?> getMedia(int id) {
    return (_db.select(_db.mediaEntries)
          ..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all media for a baby, ordered by createdAt descending.
  Future<List<MediaEntry>> getMediaForBaby(int babyId) {
    return (_db.select(_db.mediaEntries)
          ..where((m) => m.babyId.equals(babyId))
          ..orderBy([
            (m) => OrderingTerm.desc(m.createdAt),
            (m) => OrderingTerm.desc(m.id),
          ]))
        .get();
  }

  /// Watch all media for a baby, ordered by createdAt descending.
  Stream<List<MediaEntry>> watchMediaForBaby(int babyId) {
    return (_db.select(_db.mediaEntries)
          ..where((m) => m.babyId.equals(babyId))
          ..orderBy([
            (m) => OrderingTerm.desc(m.createdAt),
            (m) => OrderingTerm.desc(m.id),
          ]))
        .watch();
  }

  /// Get media linked to a specific record (e.g., milestone, growth).
  Future<List<MediaEntry>> getMediaForRecord(
    String recordType,
    int recordId,
  ) {
    return (_db.select(_db.mediaEntries)
          ..where((m) =>
              m.linkedRecordType.equals(recordType) &
              m.linkedRecordId.equals(recordId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get();
  }

  /// Update the storage path (e.g., after uploading to Supabase).
  Future<void> updateStoragePath(int id, String newPath) {
    return (_db.update(_db.mediaEntries)
          ..where((m) => m.id.equals(id)))
        .write(MediaEntriesCompanion(storagePath: Value(newPath)));
  }

  /// Update the thumbnail path.
  Future<void> updateThumbnailPath(int id, String? thumbnailPath) {
    return (_db.update(_db.mediaEntries)
          ..where((m) => m.id.equals(id)))
        .write(MediaEntriesCompanion(thumbnailPath: Value(thumbnailPath)));
  }

  /// Update the caption.
  Future<void> updateCaption(int id, String? caption) {
    return (_db.update(_db.mediaEntries)
          ..where((m) => m.id.equals(id)))
        .write(MediaEntriesCompanion(caption: Value(caption)));
  }

  /// Delete a media entry by id.
  Future<void> deleteMedia(int id) {
    return (_db.delete(_db.mediaEntries)
          ..where((m) => m.id.equals(id)))
        .go();
  }

  /// Count all media entries for a baby.
  Future<int> getMediaCountForBaby(int babyId) async {
    final count = _db.mediaEntries.id.count();
    final query = _db.selectOnly(_db.mediaEntries)
      ..addColumns([count])
      ..where(_db.mediaEntries.babyId.equals(babyId));
    final result = await query.getSingle();
    return result.read(count)!;
  }
}
