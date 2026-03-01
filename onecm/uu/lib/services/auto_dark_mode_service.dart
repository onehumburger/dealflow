/// Schedule definition for automatic dark mode switching.
class DarkModeSchedule {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const DarkModeSchedule({
    required this.enabled,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  /// Default schedule: dark mode from 8 PM to 7 AM.
  static const defaultSchedule = DarkModeSchedule(
    enabled: true,
    startHour: 20,
    startMinute: 0,
    endHour: 7,
    endMinute: 0,
  );

  DarkModeSchedule copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return DarkModeSchedule(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }
}

/// Pure-logic service for determining whether dark mode should be active
/// based on the current time and a configured schedule.
class AutoDarkModeService {
  AutoDarkModeService._();

  /// Returns true if dark mode should be used given the [schedule] and [now].
  ///
  /// Handles overnight schedules that cross midnight (e.g. 20:00 - 07:00).
  /// The dark window includes [startHour:startMinute] and excludes
  /// [endHour:endMinute].
  static bool shouldUseDarkMode(DarkModeSchedule schedule, DateTime now) {
    if (!schedule.enabled) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = schedule.startHour * 60 + schedule.startMinute;
    final endMinutes = schedule.endHour * 60 + schedule.endMinute;

    if (startMinutes == endMinutes) {
      // Same start and end means always active (24-hour window).
      return true;
    }

    if (startMinutes < endMinutes) {
      // No midnight crossing: e.g. 09:00 - 17:00
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // Overnight crossing: e.g. 20:00 - 07:00
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }
}
