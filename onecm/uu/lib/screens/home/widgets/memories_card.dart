import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/memories_provider.dart';
import 'package:uu/services/memories_service.dart';

/// "On This Day" memories card shown on the home screen.
///
/// Displays a horizontal scrollable row of thumbnails from previous
/// years/months that share the same calendar date as today.
/// Hidden when no memories exist for today.
class MemoriesCard extends ConsumerWidget {
  const MemoriesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesProvider);

    return memoriesAsync.when(
      data: (memories) {
        if (memories.isEmpty) return const SizedBox.shrink();
        return _MemoriesContent(memories: memories);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MemoriesContent extends StatelessWidget {
  final List<MemoryItem> memories;

  const _MemoriesContent({required this.memories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.tertiaryContainer.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'On This Day',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Look back at your memories',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: memories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _MemoryTile(memory: memories[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  final MemoryItem memory;

  const _MemoryTile({required this.memory});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imagePath =
        memory.media.thumbnailPath ?? memory.media.storagePath;
    final file = File(imagePath);
    final fileExists = file.existsSync();

    return GestureDetector(
      onTap: () {
        // Navigate to full media view (future enhancement)
      },
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 110,
                child: fileExists
                    ? Image.file(
                        file,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PlaceholderImage(type: memory.media.type),
                      )
                    : _PlaceholderImage(type: memory.media.type),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              memory.timeAgo,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String type;

  const _PlaceholderImage({required this.type});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          type == 'video' ? Icons.videocam : Icons.photo,
          size: 32,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
