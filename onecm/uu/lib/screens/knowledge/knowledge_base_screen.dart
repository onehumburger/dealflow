import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/knowledge_base_provider.dart';
import 'package:uu/screens/knowledge/article_detail_screen.dart';
import 'package:uu/services/knowledge_base_service.dart';

class KnowledgeBaseScreen extends ConsumerStatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  ConsumerState<KnowledgeBaseScreen> createState() =>
      _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends ConsumerState<KnowledgeBaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  static const _tabLabels = [
    'All',
    'Sleep',
    'Feeding',
    'Development',
    'Health',
    'Safety',
    'Behavior',
  ];

  static const _tabKeys = <String?>[
    null,
    'sleep',
    'feeding',
    'development',
    'health',
    'safety',
    'behavior',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      ref.read(knowledgeBaseCategoryProvider.notifier).state =
          _tabKeys[_tabController.index];
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(filteredArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(knowledgeBaseSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                ref.read(knowledgeBaseSearchQueryProvider.notifier).state =
                    value;
                // Trigger rebuild to show/hide clear button
                setState(() {});
              },
            ),
          ),
          // Article list
          Expanded(
            child: articles.isEmpty
                ? const Center(
                    child: Text('No articles found.'),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return _ArticleCard(
                        article: articles[index],
                        onTap: () => _openArticle(articles[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openArticle(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(articleId: article.id),
      ),
    );
  }
}

// ── Article Card Widget ──────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                article.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              // Summary
              Text(
                article.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Badges row
              Row(
                children: [
                  _CategoryBadge(category: article.category),
                  const SizedBox(width: 8),
                  _AgeRangeBadge(
                    minMonths: article.minAgeMonths,
                    maxMonths: article.maxAgeMonths,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Badge ───────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, IconData icon) = _categoryStyle(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            category[0].toUpperCase() + category.substring(1),
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static (Color, Color, IconData) _categoryStyle(String category) {
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

// ── Age Range Badge ──────────────────────────────────────────────────

class _AgeRangeBadge extends StatelessWidget {
  final int minMonths;
  final int maxMonths;

  const _AgeRangeBadge({required this.minMonths, required this.maxMonths});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$minMonths-${maxMonths}mo',
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
