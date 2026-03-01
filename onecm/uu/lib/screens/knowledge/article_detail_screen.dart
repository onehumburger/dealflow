import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/knowledge_base_provider.dart';
import 'package:uu/services/knowledge_base_service.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final String articleId;

  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(knowledgeBaseServiceProvider);
    final article = service.getArticleById(articleId);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: const Center(child: Text('Article not found.')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              article.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailCategoryBadge(category: article.category),
                _DetailAgeRangeBadge(
                  minMonths: article.minAgeMonths,
                  maxMonths: article.maxAgeMonths,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                article.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Full article content
            Text(
              article.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            // Tags
            if (article.tags.isNotEmpty) ...[
              Text(
                'Related Topics',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: article.tags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          tag,
                          style: theme.textTheme.labelSmall,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Detail badges (slightly larger than the list card badges) ────────

class _DetailCategoryBadge extends StatelessWidget {
  final String category;

  const _DetailCategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = _style(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            category[0].toUpperCase() + category.substring(1),
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color, IconData) _style(String category) {
    switch (category) {
      case 'sleep':
        return (Colors.indigo.shade50, Colors.indigo.shade700, Icons.bedtime);
      case 'feeding':
        return (
          Colors.green.shade50,
          Colors.green.shade700,
          Icons.restaurant
        );
      case 'development':
        return (
          Colors.purple.shade50,
          Colors.purple.shade700,
          Icons.psychology
        );
      case 'health':
        return (Colors.red.shade50, Colors.red.shade700, Icons.favorite);
      case 'safety':
        return (
          Colors.orange.shade50,
          Colors.orange.shade700,
          Icons.shield
        );
      case 'behavior':
        return (Colors.teal.shade50, Colors.teal.shade700, Icons.mood);
      default:
        return (Colors.grey.shade100, Colors.grey.shade700, Icons.article);
    }
  }
}

class _DetailAgeRangeBadge extends StatelessWidget {
  final int minMonths;
  final int maxMonths;

  const _DetailAgeRangeBadge({
    required this.minMonths,
    required this.maxMonths,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.child_care,
              size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '$minMonths-$maxMonths months',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
