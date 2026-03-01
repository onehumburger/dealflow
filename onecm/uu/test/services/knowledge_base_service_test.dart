import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/knowledge_base_service.dart';

void main() {
  late KnowledgeBaseService service;

  setUp(() {
    service = KnowledgeBaseService();
  });

  group('Article data class', () {
    test('has all required fields', () {
      const article = Article(
        id: 'test-1',
        title: 'Test Article',
        category: 'sleep',
        summary: 'A test summary',
        content: 'Full article content here.',
        minAgeMonths: 0,
        maxAgeMonths: 6,
        tags: ['test', 'sample'],
      );
      expect(article.id, 'test-1');
      expect(article.title, 'Test Article');
      expect(article.category, 'sleep');
      expect(article.summary, 'A test summary');
      expect(article.content, 'Full article content here.');
      expect(article.minAgeMonths, 0);
      expect(article.maxAgeMonths, 6);
      expect(article.tags, ['test', 'sample']);
    });
  });

  group('getAllArticles', () {
    test('returns at least 18 articles', () {
      final articles = service.getAllArticles();
      expect(articles.length, greaterThanOrEqualTo(18));
    });

    test('contains articles for all six categories', () {
      final articles = service.getAllArticles();
      final categories = articles.map((a) => a.category).toSet();
      expect(categories, containsAll([
        'sleep',
        'feeding',
        'development',
        'health',
        'safety',
        'behavior',
      ]));
    });

    test('has at least 3 articles per category', () {
      final articles = service.getAllArticles();
      for (final cat in [
        'sleep',
        'feeding',
        'development',
        'health',
        'safety',
        'behavior',
      ]) {
        final count = articles.where((a) => a.category == cat).length;
        expect(count, greaterThanOrEqualTo(3),
            reason: '$cat should have at least 3 articles');
      }
    });

    test('all articles have unique ids', () {
      final articles = service.getAllArticles();
      final ids = articles.map((a) => a.id).toSet();
      expect(ids.length, articles.length,
          reason: 'All article IDs should be unique');
    });

    test('all articles have non-empty content fields', () {
      final articles = service.getAllArticles();
      for (final a in articles) {
        expect(a.id, isNotEmpty, reason: 'ID should not be empty');
        expect(a.title, isNotEmpty, reason: 'Title should not be empty');
        expect(a.summary, isNotEmpty, reason: 'Summary should not be empty');
        expect(a.content, isNotEmpty, reason: 'Content should not be empty');
        expect(a.tags, isNotEmpty, reason: 'Tags should not be empty');
      }
    });

    test('all articles have valid age ranges', () {
      final articles = service.getAllArticles();
      for (final a in articles) {
        expect(a.minAgeMonths, greaterThanOrEqualTo(0),
            reason: '${a.title}: minAgeMonths should be >= 0');
        expect(a.maxAgeMonths, greaterThan(a.minAgeMonths),
            reason: '${a.title}: maxAgeMonths should be > minAgeMonths');
        expect(a.maxAgeMonths, lessThanOrEqualTo(36),
            reason: '${a.title}: maxAgeMonths should be <= 36');
      }
    });

    test('articles cover the 0-36 month range', () {
      final articles = service.getAllArticles();
      final hasEarly = articles.any((a) => a.minAgeMonths == 0);
      final hasLate = articles.any((a) => a.maxAgeMonths >= 36);
      expect(hasEarly, isTrue,
          reason: 'Should have articles starting at 0 months');
      expect(hasLate, isTrue,
          reason: 'Should have articles covering up to 36 months');
    });
  });

  group('getArticleById', () {
    test('returns article when id exists', () {
      final articles = service.getAllArticles();
      final first = articles.first;
      final found = service.getArticleById(first.id);
      expect(found, isNotNull);
      expect(found!.id, first.id);
      expect(found.title, first.title);
    });

    test('returns null when id does not exist', () {
      final found = service.getArticleById('nonexistent-id');
      expect(found, isNull);
    });
  });

  group('getArticlesByCategory', () {
    test('returns only articles of the specified category', () {
      final sleepArticles = service.getArticlesByCategory('sleep');
      expect(sleepArticles, isNotEmpty);
      for (final a in sleepArticles) {
        expect(a.category, 'sleep');
      }
    });

    test('returns empty list for unknown category', () {
      final articles = service.getArticlesByCategory('unknown');
      expect(articles, isEmpty);
    });

    test('returns different articles for different categories', () {
      final sleep = service.getArticlesByCategory('sleep');
      final feeding = service.getArticlesByCategory('feeding');
      final sleepIds = sleep.map((a) => a.id).toSet();
      final feedingIds = feeding.map((a) => a.id).toSet();
      expect(sleepIds.intersection(feedingIds), isEmpty,
          reason: 'Sleep and feeding articles should not overlap');
    });
  });

  group('getArticlesForAge', () {
    test('returns articles relevant to the given age', () {
      final articles = service.getArticlesForAge(3);
      expect(articles, isNotEmpty);
      for (final a in articles) {
        expect(a.minAgeMonths, lessThanOrEqualTo(3),
            reason: '${a.title}: minAge should be <= 3');
        expect(a.maxAgeMonths, greaterThanOrEqualTo(3),
            reason: '${a.title}: maxAge should be >= 3');
      }
    });

    test('returns more articles for middle-range ages', () {
      // Age 0 should have fewer articles than age 12 (which is in many ranges)
      final atZero = service.getArticlesForAge(0);
      final atTwelve = service.getArticlesForAge(12);
      expect(atTwelve.length, greaterThanOrEqualTo(atZero.length),
          reason: 'Age 12 should have at least as many articles as age 0');
    });

    test('returns articles from multiple categories', () {
      final articles = service.getArticlesForAge(6);
      final categories = articles.map((a) => a.category).toSet();
      expect(categories.length, greaterThan(1),
          reason: 'Articles at age 6 should span multiple categories');
    });

    test('returns empty for age beyond all article ranges', () {
      final articles = service.getArticlesForAge(100);
      expect(articles, isEmpty,
          reason: 'No articles should cover age 100 months');
    });
  });

  group('searchArticles', () {
    test('finds articles by title keyword', () {
      final articles = service.getAllArticles();
      // Use a word from the first article's title
      final firstTitle = articles.first.title;
      final keyword = firstTitle.split(' ').first;
      final results = service.searchArticles(keyword);
      expect(results, isNotEmpty);
      expect(results.any((a) => a.title.contains(keyword)), isTrue);
    });

    test('search is case-insensitive', () {
      final upper = service.searchArticles('SLEEP');
      final lower = service.searchArticles('sleep');
      expect(upper.length, lower.length);
    });

    test('finds articles by tag', () {
      final articles = service.getAllArticles();
      // Find a tag from the first article
      final tag = articles.first.tags.first;
      final results = service.searchArticles(tag);
      expect(results, isNotEmpty);
    });

    test('finds articles by content keyword', () {
      // Search for a common parenting term that should appear in content
      final results = service.searchArticles('baby');
      expect(results, isNotEmpty);
    });

    test('returns empty for nonsense query', () {
      final results = service.searchArticles('xyzzy12345nonsense');
      expect(results, isEmpty);
    });

    test('finds articles by summary text', () {
      final articles = service.getAllArticles();
      // Use a word from the first article's summary
      final summaryWord = articles.first.summary.split(' ').last;
      if (summaryWord.length > 3) {
        final results = service.searchArticles(summaryWord);
        expect(results, isNotEmpty);
      }
    });

    test('returns empty for empty query', () {
      final results = service.searchArticles('');
      expect(results, isEmpty);
    });
  });
}
