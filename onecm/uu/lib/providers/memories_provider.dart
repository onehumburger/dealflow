import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/media_provider.dart';
import 'package:uu/services/memories_service.dart';

/// Provider for [MemoriesService].
final memoriesServiceProvider = Provider<MemoriesService>((ref) {
  return MemoriesService();
});

/// Provider that returns today's "On This Day" memory items for the
/// currently selected baby.
///
/// Watches the media stream so it updates automatically when new media
/// is added. Also schedules a daily push notification when memories
/// are found.
final memoriesProvider = Provider<AsyncValue<List<MemoryItem>>>((ref) {
  final mediaAsync = ref.watch(mediaForBabyProvider);

  return mediaAsync.when(
    data: (allMedia) {
      final service = ref.read(memoriesServiceProvider);
      final memories = service.getMemoriesForToday(allMedia: allMedia);

      // Fire-and-forget: schedule a 9 AM notification when memories exist.
      if (memories.isNotEmpty) {
        service.scheduleMemoriesNotification(memories);
      }

      return AsyncValue.data(memories);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
