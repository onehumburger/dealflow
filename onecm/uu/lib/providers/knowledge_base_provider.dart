import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/services/knowledge_base_service.dart';

/// Provides the singleton [KnowledgeBaseService] instance.
final knowledgeBaseServiceProvider = Provider<KnowledgeBaseService>((ref) {
  return KnowledgeBaseService();
});

/// The currently selected category tab filter (null = "All").
final knowledgeBaseCategoryProvider = StateProvider<String?>((ref) {
  return null;
});

/// The current search query entered by the user.
final knowledgeBaseSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Filtered articles based on the current category and search query.
final filteredArticlesProvider = Provider<List<Article>>((ref) {
  final service = ref.watch(knowledgeBaseServiceProvider);
  final category = ref.watch(knowledgeBaseCategoryProvider);
  final query = ref.watch(knowledgeBaseSearchQueryProvider);

  List<Article> articles;

  if (query.isNotEmpty) {
    articles = service.searchArticles(query);
  } else if (category != null) {
    articles = service.getArticlesByCategory(category);
  } else {
    articles = service.getAllArticles();
  }

  // If both search and category are active, intersect results.
  if (query.isNotEmpty && category != null) {
    articles = articles.where((a) => a.category == category).toList();
  }

  return articles;
});
