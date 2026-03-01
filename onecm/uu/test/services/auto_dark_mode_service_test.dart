import 'package:flutter_test/flutter_test.dart';
import 'package:uu/services/auto_dark_mode_service.dart';

void main() {
  group('DarkModeSchedule', () {
    test('defaultSchedule is 20:00 to 07:00 and enabled', () {
      final schedule = DarkModeSchedule.defaultSchedule;
      expect(schedule.enabled, true);
      expect(schedule.startHour, 20);
      expect(schedule.startMinute, 0);
      expect(schedule.endHour, 7);
      expect(schedule.endMinute, 0);
    });

    test('copyWith creates modified copy', () {
      final schedule = DarkModeSchedule.defaultSchedule;
      final modified = schedule.copyWith(enabled: false, startHour: 21);
      expect(modified.enabled, false);
      expect(modified.startHour, 21);
      expect(modified.startMinute, 0);
      expect(modified.endHour, 7);
      expect(modified.endMinute, 0);
    });

    test('copyWith with no args returns identical values', () {
      final schedule = DarkModeSchedule.defaultSchedule;
      final copy = schedule.copyWith();
      expect(copy.enabled, schedule.enabled);
      expect(copy.startHour, schedule.startHour);
      expect(copy.startMinute, schedule.startMinute);
      expect(copy.endHour, schedule.endHour);
      expect(copy.endMinute, schedule.endMinute);
    });
  });

  group('AutoDarkModeService.shouldUseDarkMode', () {
    group('overnight schedule (20:00 - 07:00)', () {
      final schedule = DarkModeSchedule.defaultSchedule;

      test('returns true at 20:00 (start time)', () {
        final now = DateTime(2026, 3, 1, 20, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns true at 23:59 (late night)', () {
        final now = DateTime(2026, 3, 1, 23, 59);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns true at 00:00 (midnight)', () {
        final now = DateTime(2026, 3, 2, 0, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns true at 03:00 (early morning)', () {
        final now = DateTime(2026, 3, 2, 3, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns true at 06:59 (just before end)', () {
        final now = DateTime(2026, 3, 2, 6, 59);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns false at 07:00 (end time)', () {
        final now = DateTime(2026, 3, 2, 7, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });

      test('returns false at 12:00 (midday)', () {
        final now = DateTime(2026, 3, 1, 12, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });

      test('returns false at 19:59 (just before start)', () {
        final now = DateTime(2026, 3, 1, 19, 59);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });

      test('returns false at 07:01 (just after end)', () {
        final now = DateTime(2026, 3, 1, 7, 1);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });
    });

    group('daytime schedule (09:00 - 17:00, no midnight crossing)', () {
      final schedule = DarkModeSchedule(
        enabled: true,
        startHour: 9,
        startMinute: 0,
        endHour: 17,
        endMinute: 0,
      );

      test('returns true at 09:00 (start time)', () {
        final now = DateTime(2026, 3, 1, 9, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns true at 12:00 (midday)', () {
        final now = DateTime(2026, 3, 1, 12, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns true at 16:59 (just before end)', () {
        final now = DateTime(2026, 3, 1, 16, 59);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns false at 17:00 (end time)', () {
        final now = DateTime(2026, 3, 1, 17, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });

      test('returns false at 08:59 (just before start)', () {
        final now = DateTime(2026, 3, 1, 8, 59);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });

      test('returns false at 20:00 (evening)', () {
        final now = DateTime(2026, 3, 1, 20, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });
    });

    group('schedule with minutes (21:30 - 06:45)', () {
      final schedule = DarkModeSchedule(
        enabled: true,
        startHour: 21,
        startMinute: 30,
        endHour: 6,
        endMinute: 45,
      );

      test('returns false at 21:29 (just before start)', () {
        final now = DateTime(2026, 3, 1, 21, 29);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });

      test('returns true at 21:30 (start time)', () {
        final now = DateTime(2026, 3, 1, 21, 30);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns true at 06:44 (just before end)', () {
        final now = DateTime(2026, 3, 2, 6, 44);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), true);
      });

      test('returns false at 06:45 (end time)', () {
        final now = DateTime(2026, 3, 2, 6, 45);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });
    });

    group('disabled schedule', () {
      test('returns false regardless of time when disabled', () {
        final schedule = DarkModeSchedule(
          enabled: false,
          startHour: 20,
          startMinute: 0,
          endHour: 7,
          endMinute: 0,
        );
        final now = DateTime(2026, 3, 1, 22, 0);
        expect(AutoDarkModeService.shouldUseDarkMode(schedule, now), false);
      });
    });

    group('edge cases', () {
      test('same start and end time means always active when enabled', () {
        final schedule = DarkModeSchedule(
          enabled: true,
          startHour: 12,
          startMinute: 0,
          endHour: 12,
          endMinute: 0,
        );
        // When start == end, the window is 24 hours (always dark)
        expect(
          AutoDarkModeService.shouldUseDarkMode(
              schedule, DateTime(2026, 3, 1, 12, 0)),
          true,
        );
        expect(
          AutoDarkModeService.shouldUseDarkMode(
              schedule, DateTime(2026, 3, 1, 0, 0)),
          true,
        );
      });
    });
  });
}
