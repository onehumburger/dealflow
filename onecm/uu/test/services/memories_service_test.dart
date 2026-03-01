import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/memories_service.dart';

/// Helper to build a [MediaEntry] with sensible defaults.
MediaEntry _media({
  int id = 1,
  int babyId = 1,
  String type = 'photo',
  String storagePath = '/img.jpg',
  DateTime? takenAt,
  DateTime? createdAt,
}) {
  return MediaEntry(
    id: id,
    babyId: babyId,
    type: type,
    storagePath: storagePath,
    takenAt: takenAt,
    createdAt: createdAt ?? DateTime(2025, 1, 1),
  );
}

void main() {
  late MemoriesService service;

  setUp(() {
    service = MemoriesService();
  });

  group('MemoryItem data class', () {
    test('holds media and timeAgo label', () {
      final media = _media(takenAt: DateTime(2025, 3, 1));
      final item = MemoryItem(media: media, timeAgo: '1 year ago');
      expect(item.media, media);
      expect(item.timeAgo, '1 year ago');
    });
  });

  group('getMemoriesForToday', () {
    test('returns empty list when no media matches today', () {
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 4, 15)),
        _media(id: 2, takenAt: DateTime(2025, 6, 20)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, isEmpty);
    });

    test('finds media from same calendar date in a previous year', () {
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 3, 1, 10, 30)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, hasLength(1));
      expect(result.first.media.id, 1);
      expect(result.first.timeAgo, '1 year ago');
    });

    test('does not match same day number in a different month', () {
      // Jan 1 should NOT match March 1 (different month)
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: DateTime(2026, 1, 1, 14, 0)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, isEmpty);
    });

    test('excludes media from today (same month+year)', () {
      final today = DateTime(2026, 3, 1, 12, 0);
      final media = [
        _media(id: 1, takenAt: DateTime(2026, 3, 1, 8, 0)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, isEmpty);
    });

    test('excludes media with different day', () {
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 3, 2)),
        _media(id: 2, takenAt: DateTime(2025, 3, 15)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, isEmpty);
    });

    test('skips media with null takenAt', () {
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: null),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, isEmpty);
    });

    test('groups multiple matches from different years', () {
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 3, 1, 10, 0)),
        _media(id: 2, takenAt: DateTime(2024, 3, 1, 14, 0)),
        _media(id: 3, takenAt: DateTime(2023, 3, 1, 8, 0)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, hasLength(3));

      final labels = result.map((m) => m.timeAgo).toList();
      expect(labels, contains('1 year ago'));
      expect(labels, contains('2 years ago'));
      expect(labels, contains('3 years ago'));
    });

    test('orders results from most recent to oldest', () {
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: DateTime(2024, 3, 1)),
        _media(id: 2, takenAt: DateTime(2025, 3, 1)),
        _media(id: 3, takenAt: DateTime(2023, 3, 1)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, hasLength(3));
      // Most recent first
      expect(result[0].media.id, 2); // 1 year ago
      expect(result[1].media.id, 1); // 2 years ago
      expect(result[2].media.id, 3); // 3 years ago
    });

    test('returns empty list for empty media list', () {
      final today = DateTime(2026, 3, 1);
      final result = service.getMemoriesForToday(
        allMedia: [],
        now: today,
      );

      expect(result, isEmpty);
    });

    test('labels "1 year ago" correctly for exactly 12 months', () {
      final today = DateTime(2026, 3, 1);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 3, 1)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, hasLength(1));
      expect(result.first.timeAgo, '1 year ago');
    });

    test('handles leap year Feb 29 gracefully', () {
      // 2024 is a leap year with Feb 29
      final today = DateTime(2024, 2, 29);
      // Media from previous leap year's Feb 29
      final media = [
        _media(id: 1, takenAt: DateTime(2020, 2, 29)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, hasLength(1));
      expect(result.first.timeAgo, '4 years ago');
    });

    test('uses years label for multiple years', () {
      final today = DateTime(2026, 6, 15);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 6, 15)), // exactly 12 months
        _media(id: 2, takenAt: DateTime(2024, 6, 15)), // exactly 24 months
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, hasLength(2));
      expect(result[0].timeAgo, '1 year ago');
      expect(result[1].timeAgo, '2 years ago');
    });

    test('excludes media from different month even with same day', () {
      // Nov 15 should NOT match March 15
      final today = DateTime(2026, 3, 15);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 11, 15)),
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, isEmpty);
    });

    test('matches same month+day across multiple years', () {
      final today = DateTime(2026, 7, 4);
      final media = [
        _media(id: 1, takenAt: DateTime(2025, 7, 4)),
        _media(id: 2, takenAt: DateTime(2024, 7, 4)),
        _media(id: 3, takenAt: DateTime(2025, 7, 5)), // different day
        _media(id: 4, takenAt: DateTime(2025, 8, 4)), // different month
      ];

      final result = service.getMemoriesForToday(
        allMedia: media,
        now: today,
      );

      expect(result, hasLength(2));
      expect(result[0].media.id, 1);
      expect(result[0].timeAgo, '1 year ago');
      expect(result[1].media.id, 2);
      expect(result[1].timeAgo, '2 years ago');
    });
  });
}
