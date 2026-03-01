import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/media_provider.dart';
import 'package:uu/services/media_service.dart';

class MediaGalleryScreen extends ConsumerWidget {
  const MediaGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babyId = ref.watch(selectedBabyIdProvider);
    if (babyId == null) {
      return const Center(child: Text('Please select a baby first.'));
    }

    final mediaAsync = ref.watch(mediaForBabyProvider);
    final viewMode = ref.watch(galleryViewModeProvider);
    final filterType = ref.watch(mediaFilterTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Gallery'),
        actions: [
          // View mode toggle
          IconButton(
            icon: Icon(
              viewMode == GalleryViewMode.grid
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
            tooltip: viewMode == GalleryViewMode.grid
                ? 'Switch to timeline'
                : 'Switch to grid',
            onPressed: () {
              ref.read(galleryViewModeProvider.notifier).state =
                  viewMode == GalleryViewMode.grid
                      ? GalleryViewMode.timeline
                      : GalleryViewMode.grid;
            },
          ),
          // Filter popup
          PopupMenuButton<String?>(
            icon: Icon(
              Icons.filter_list,
              color: filterType != null
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: 'Filter by type',
            onSelected: (value) {
              ref.read(mediaFilterTypeProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Media'),
              ),
              const PopupMenuItem(
                value: 'photo',
                child: Text('Photos Only'),
              ),
              const PopupMenuItem(
                value: 'video',
                child: Text('Videos Only'),
              ),
            ],
          ),
        ],
      ),
      body: mediaAsync.when(
        data: (mediaList) {
          // Apply filter
          final filtered = filterType != null
              ? mediaList.where((m) => m.type == filterType).toList()
              : mediaList;

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No media yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add photos or videos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return viewMode == GalleryViewMode.grid
              ? _GridView(mediaList: filtered)
              : _TimelineView(mediaList: filtered);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMediaSheet(context, ref, babyId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMediaSheet(BuildContext context, WidgetRef ref, int babyId) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(context, ref, babyId, 'photo', ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(context, ref, babyId, 'photo', ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(context, ref, babyId, 'video', ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose Video'),
              onTap: () {
                Navigator.pop(ctx);
                _addMedia(context, ref, babyId, 'video', ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMedia(
    BuildContext context,
    WidgetRef ref,
    int babyId,
    String type,
    ImageSource source,
  ) async {
    final service = ref.read(mediaServiceProvider);
    final repo = ref.read(mediaRepositoryProvider);

    // Pick file
    XFile? picked;
    if (type == 'photo') {
      picked = await service.pickImage(source: source);
    } else {
      picked = await service.pickVideo(source: source);
    }

    if (picked == null) return;

    // Save locally
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = service.generateFileName(type);
    final localPath = await service.saveLocally(
      sourceFilePath: picked.path,
      baseDir: appDir.path,
      fileName: fileName,
    );

    // Generate thumbnail for video (placeholder — returns null)
    String? thumbnailPath;
    if (type == 'video') {
      thumbnailPath = await service.generateThumbnail(localPath);
    }

    // Show caption dialog
    String? caption;
    if (context.mounted) {
      caption = await _showCaptionDialog(context);
    }

    // Save to database
    await repo.addMedia(
      babyId: babyId,
      type: type,
      storagePath: localPath,
      thumbnailPath: thumbnailPath,
      caption: caption,
      takenAt: DateTime.now(),
    );

    // Try uploading to Supabase in the background
    service.uploadToSupabase(
      localPath: localPath,
      babyId: babyId,
      fileName: fileName,
    );

    // Invalidate count
    ref.invalidate(mediaCountProvider);
  }

  Future<String?> _showCaptionDialog(BuildContext context) async {
    String? caption;
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Caption'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Write a caption (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => caption = v.isEmpty ? null : v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, caption),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    return result;
  }
}

// ── Grid View ────────────────────────────────────────────────────────────

class _GridView extends StatelessWidget {
  final List<MediaEntry> mediaList;

  const _GridView({required this.mediaList});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        final media = mediaList[index];
        return _MediaGridTile(
          media: media,
          onTap: () => _showMediaDetail(context, media),
        );
      },
    );
  }

  void _showMediaDetail(BuildContext context, MediaEntry media) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MediaDetailScreen(media: media),
      ),
    );
  }
}

class _MediaGridTile extends StatelessWidget {
  final MediaEntry media;
  final VoidCallback onTap;

  const _MediaGridTile({required this.media, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(media.thumbnailPath ?? media.storagePath);
    final isLocalFile = file.existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail or placeholder
          if (MediaService.isPhoto(media.type) && isLocalFile)
            Image.file(file, fit: BoxFit.cover)
          else
            Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(
                MediaService.isVideo(media.type)
                    ? Icons.videocam
                    : Icons.photo,
                color: theme.colorScheme.onSurfaceVariant,
                size: 36,
              ),
            ),
          // Video indicator
          if (MediaService.isVideo(media.type))
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
              ),
            ),
          // Sync status indicator
          Positioned(
            top: 4,
            right: 4,
            child: _SyncStatusBadge(storagePath: media.storagePath),
          ),
        ],
      ),
    );
  }
}

// ── Timeline View ────────────────────────────────────────────────────────

class _TimelineView extends StatelessWidget {
  final List<MediaEntry> mediaList;

  const _TimelineView({required this.mediaList});

  @override
  Widget build(BuildContext context) {
    // Group media by date
    final grouped = <String, List<MediaEntry>>{};
    final dateFormat = DateFormat('MMMM d, yyyy');

    for (final media in mediaList) {
      final dateKey = dateFormat.format(media.takenAt ?? media.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(media);
    }

    final dateKeys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final items = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 16),
            // Date header
            Text(
              dateKey,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            // Media items for this date
            ...items.map(
              (media) => _TimelineMediaItem(
                media: media,
                onTap: () => _showMediaDetail(context, media),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMediaDetail(BuildContext context, MediaEntry media) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MediaDetailScreen(media: media),
      ),
    );
  }
}

class _TimelineMediaItem extends StatelessWidget {
  final MediaEntry media;
  final VoidCallback onTap;

  const _TimelineMediaItem({required this.media, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(media.thumbnailPath ?? media.storagePath);
    final isLocalFile = file.existsSync();
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 80,
              height: 80,
              child: MediaService.isPhoto(media.type) && isLocalFile
                  ? Image.file(file, fit: BoxFit.cover)
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        MediaService.isVideo(media.type)
                            ? Icons.videocam
                            : Icons.photo,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          MediaService.isPhoto(media.type)
                              ? Icons.photo
                              : Icons.videocam,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          media.type == 'photo' ? 'Photo' : 'Video',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeFormat.format(media.takenAt ?? media.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (media.caption != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        media.caption!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (media.linkedRecordType != null) ...[
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(media.linkedRecordType!),
                        labelStyle: theme.textTheme.labelSmall,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Sync status
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _SyncStatusBadge(storagePath: media.storagePath),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sync Status Badge ───────────────────────────────────────────────────

class _SyncStatusBadge extends StatelessWidget {
  final String storagePath;

  const _SyncStatusBadge({required this.storagePath});

  @override
  Widget build(BuildContext context) {
    // A simple heuristic: if the path starts with '/' it's local only.
    // Remote paths from Supabase would be like 'babyId/filename'.
    final isLocalOnly = storagePath.startsWith('/');

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isLocalOnly ? Colors.orange.shade100 : Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isLocalOnly ? Icons.phone_android : Icons.cloud_done,
        size: 12,
        color: isLocalOnly ? Colors.orange.shade700 : Colors.green.shade700,
      ),
    );
  }
}

// ── Media Detail Screen ─────────────────────────────────────────────────

class _MediaDetailScreen extends ConsumerWidget {
  final MediaEntry media;

  const _MediaDetailScreen({required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final file = File(media.storagePath);
    final isLocalFile = file.existsSync();
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final dateTime = media.takenAt ?? media.createdAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(media.type == 'photo' ? 'Photo' : 'Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Full-size media
          Expanded(
            child: Center(
              child: MediaService.isPhoto(media.type) && isLocalFile
                  ? InteractiveViewer(
                      child: Image.file(file),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          MediaService.isVideo(media.type)
                              ? Icons.videocam
                              : Icons.photo,
                          size: 80,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          MediaService.isVideo(media.type)
                              ? 'Video playback not yet available'
                              : 'Image not available',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          // Info section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      dateFormat.format(dateTime),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeFormat.format(dateTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _SyncStatusBadge(storagePath: media.storagePath),
                    const SizedBox(width: 4),
                    Text(
                      media.storagePath.startsWith('/')
                          ? 'Local'
                          : 'Synced',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (media.caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    media.caption!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (media.linkedRecordType != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.link, size: 16),
                    label: Text(
                      'Linked to ${media.linkedRecordType} #${media.linkedRecordId}',
                    ),
                    labelStyle: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text(
          'Are you sure you want to delete this? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(mediaRepositoryProvider).deleteMedia(media.id);
      ref.invalidate(mediaCountProvider);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
