class NotificationScheduler {
  NotificationScheduler._();

  static DateTime nextNotificationTime({
    required DateTime? lastEventTime,
    required int intervalMinutes,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    if (lastEventTime == null) {
      return currentTime.add(Duration(minutes: intervalMinutes));
    }
    final scheduled = lastEventTime.add(Duration(minutes: intervalMinutes));
    if (scheduled.isBefore(currentTime)) {
      return currentTime.add(Duration(minutes: intervalMinutes));
    }
    return scheduled;
  }

  static String reminderMessage(String type, int intervalMinutes) {
    final hours = intervalMinutes ~/ 60;
    final mins = intervalMinutes % 60;
    final timeStr = hours > 0
        ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
        : '${mins}m';
    return "It's been $timeStr since the last $type. Time for another?";
  }
}
