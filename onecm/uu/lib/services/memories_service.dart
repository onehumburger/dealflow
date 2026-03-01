import 'package:uu/database/app_database.dart';
import 'package:uu/services/notification_service.dart';

/// A single "On This Day" memory item.
class MemoryItem {
  final MediaEntry media;

  /// Human-readable label, e.g. "6 months ago" or "1 year ago".
  final String timeAgo;

  const MemoryItem({required this.media, required this.timeAgo});
}

/// Pure-logic service that finds media taken on the same calendar day
/// (month + day) in previous months or years.
class MemoriesService {
  /// Notification ID reserved for the daily "On This Day" reminder.
  static const memoriesNotificationId = 9001;
  /// Returns [MemoryItem]s whose [MediaEntry.takenAt] shares the same
  /// month and day as [now], but from a different month/year.
  ///
  /// Results are ordered most-recent first.
  List<MemoryItem> getMemoriesForToday({
    required List<MediaEntry> allMedia,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final todayMonth = today.month;
    final todayDay = today.day;

    final matches = <MemoryItem>[];

    for (final entry in allMedia) {
      final takenAt = entry.takenAt;
      if (takenAt == null) continue;

      // Same calendar day (month + day) but not the same month+year.
      if (takenAt.day != todayDay || takenAt.month != todayMonth) continue;
      if (takenAt.year == today.year && takenAt.month == today.month) continue;

      final label = _timeAgoLabel(takenAt, today);
      matches.add(MemoryItem(media: entry, timeAgo: label));
    }

    // Sort most-recent first (largest takenAt first).
    matches.sort((a, b) => b.media.takenAt!.compareTo(a.media.takenAt!));

    return matches;
  }

  /// Schedule a push notification at 9 AM if memories exist today.
  ///
  /// Sends an immediate notification via [NotificationService] for
  /// the daily "On This Day" reminder. In production, this would use
  /// `zonedSchedule` to fire at exactly 9 AM; for now it mirrors
  /// the existing `scheduleReminder` pattern.
  Future<void> scheduleMemoriesNotification(List<MemoryItem> memories) async {
    if (memories.isEmpty) return;

    final count = memories.length;
    final noun = count == 1 ? 'memory' : 'memories';
    final oldest = memories.last.timeAgo;

    await NotificationService.scheduleReminder(
      id: memoriesNotificationId,
      title: 'On This Day',
      body: 'You have $count $noun from this date — going back $oldest!',
      scheduledTime: _today9am(),
    );
  }

  /// Returns today at 9:00 AM.
  DateTime _today9am() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 9);
  }

  /// Builds a human-readable "X months ago" or "X years ago" label.
  String _timeAgoLabel(DateTime takenAt, DateTime now) {
    final totalMonths =
        (now.year - takenAt.year) * 12 + (now.month - takenAt.month);

    if (totalMonths >= 12) {
      final years = totalMonths ~/ 12;
      return '$years year${years == 1 ? '' : 's'} ago';
    }

    return '$totalMonths month${totalMonths == 1 ? '' : 's'} ago';
  }
}
