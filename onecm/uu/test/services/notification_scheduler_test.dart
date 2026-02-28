import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/notification_scheduler.dart';

void main() {
  group('NotificationScheduler', () {
    test('calculates next notification time from last log', () {
      final lastLogTime = DateTime(2025, 7, 15, 14, 0); // 2:00 PM
      final now = DateTime(2025, 7, 15, 15, 0); // 3:00 PM (before target)
      const intervalMinutes = 120; // every 2 hours

      final nextTime = NotificationScheduler.nextNotificationTime(
        lastEventTime: lastLogTime,
        intervalMinutes: intervalMinutes,
        now: now,
      );

      expect(nextTime, DateTime(2025, 7, 15, 16, 0)); // 4:00 PM
    });

    test('returns now + interval if no last log', () {
      final now = DateTime(2025, 7, 15, 14, 0);
      final nextTime = NotificationScheduler.nextNotificationTime(
        lastEventTime: null,
        intervalMinutes: 120,
        now: now,
      );
      expect(nextTime, DateTime(2025, 7, 15, 16, 0));
    });

    test(
        'returns now + interval if last log time + interval is in the past',
        () {
      final lastLogTime = DateTime(2025, 7, 15, 10, 0); // 10 AM
      final now =
          DateTime(2025, 7, 15, 14, 0); // 2 PM (past the 12 PM target)

      final nextTime = NotificationScheduler.nextNotificationTime(
        lastEventTime: lastLogTime,
        intervalMinutes: 120,
        now: now,
      );
      // Should schedule from now, not in the past
      expect(nextTime, DateTime(2025, 7, 15, 16, 0));
    });

    test('generates reminder message for feeding', () {
      final message = NotificationScheduler.reminderMessage('feeding', 120);
      expect(message, contains('feeding'));
    });

    test('generates reminder message for diaper', () {
      final message = NotificationScheduler.reminderMessage('diaper', 180);
      expect(message, contains('diaper'));
    });
  });
}
