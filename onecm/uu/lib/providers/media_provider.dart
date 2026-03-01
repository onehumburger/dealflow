import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/repositories/media_repository.dart';
import 'package:uu/services/media_service.dart';

/// Provider for [MediaRepository].
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(ref.watch(databaseProvider));
});

/// Provider for [MediaService].
final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService();
});

/// Stream of all media entries for the selected baby.
final mediaForBabyProvider = StreamProvider<List<MediaEntry>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(mediaRepositoryProvider).watchMediaForBaby(babyId);
});

/// Future provider for media count for the selected baby.
final mediaCountProvider = FutureProvider<int>((ref) async {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return 0;
  return ref.watch(mediaRepositoryProvider).getMediaCountForBaby(babyId);
});

/// Future provider for media linked to a specific record.
final mediaForRecordProvider =
    FutureProvider.family<List<MediaEntry>, ({String recordType, int recordId})>(
  (ref, params) {
    return ref
        .watch(mediaRepositoryProvider)
        .getMediaForRecord(params.recordType, params.recordId);
  },
);

/// State provider for gallery view mode (grid or timeline).
enum GalleryViewMode { grid, timeline }

final galleryViewModeProvider = StateProvider<GalleryViewMode>((ref) {
  return GalleryViewMode.grid;
});

/// State provider for optional filter by linked record type.
final mediaFilterTypeProvider = StateProvider<String?>((ref) => null);
