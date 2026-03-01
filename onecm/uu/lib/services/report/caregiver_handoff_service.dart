import 'package:intl/intl.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/services/daily_summary_service.dart';

/// Data transfer object for caregiver handoff notes.
class CaregiverHandoffData {
  final Baby baby;
  final DailySummary? recentSummary;
  final List<HealthEvent> activeHealthEvents;
  final List<String> allergies;
  final List<String> medications;
  final String? emergencyContact;
  final String? doctorInfo;
  final String? parentNotes;

  const CaregiverHandoffData({
    required this.baby,
    this.recentSummary,
    this.activeHealthEvents = const [],
    this.allergies = const [],
    this.medications = const [],
    this.emergencyContact,
    this.doctorInfo,
    this.parentNotes,
  });
}

/// Service that generates plain-text caregiver handoff notes.
///
/// The output is a formatted string suitable for sharing via messaging apps.
class CaregiverHandoffService {
  /// Generates a formatted text summary for a caregiver.
  String generateHandoff(CaregiverHandoffData data) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final ageText = _formatAge(data.baby.dateOfBirth, now);

    // ── Header ──
    buffer.writeln('CAREGIVER NOTES for ${data.baby.name}');
    buffer.writeln('${'=' * 40}');
    buffer.writeln();

    // ── Baby Basics ──
    buffer.writeln('BABY INFO');
    buffer.writeln('Name: ${data.baby.name}');
    buffer.writeln('Age: $ageText');
    buffer.writeln('DOB: ${dateFormat.format(data.baby.dateOfBirth)}');
    if (data.baby.gender != null) {
      buffer.writeln('Gender: ${data.baby.gender}');
    }
    if (data.baby.bloodType != null) {
      buffer.writeln('Blood Type: ${data.baby.bloodType}');
    }
    buffer.writeln();

    // ── Allergies / Health Conditions ──
    buffer.writeln('ALLERGIES & HEALTH CONDITIONS');
    if (data.allergies.isEmpty && data.activeHealthEvents.isEmpty) {
      buffer.writeln('None known');
    } else {
      if (data.allergies.isNotEmpty) {
        for (final allergy in data.allergies) {
          buffer.writeln('- $allergy');
        }
      }
      if (data.activeHealthEvents.isNotEmpty) {
        buffer.writeln('Active conditions:');
        for (final event in data.activeHealthEvents) {
          buffer.writeln('- ${event.title} (${_formatEventType(event.type)})'
              '${event.description != null ? ": ${event.description}" : ""}');
        }
      }
    }
    buffer.writeln();

    // ── Feeding Schedule ──
    buffer.writeln('FEEDING');
    if (data.recentSummary != null) {
      buffer.writeln(
          'Typical feedings per day: ${data.recentSummary!.feedingCount}');
      if (data.recentSummary!.lastFeedingAt != null) {
        buffer.writeln(
            'Last feed: ${timeFormat.format(data.recentSummary!.lastFeedingAt!)}');
      }
    } else {
      buffer.writeln('No recent feeding data available.');
    }
    buffer.writeln();

    // ── Sleep Schedule ──
    buffer.writeln('SLEEP');
    if (data.recentSummary != null) {
      final hours = data.recentSummary!.totalSleepMinutes / 60;
      buffer.writeln('Typical daily sleep: ${hours.toStringAsFixed(1)} hours');
    } else {
      buffer.writeln('No recent sleep data available.');
    }
    buffer.writeln();

    // ── Medications ──
    buffer.writeln('MEDICATIONS');
    if (data.medications.isEmpty) {
      buffer.writeln('None');
    } else {
      for (final med in data.medications) {
        buffer.writeln('- $med');
      }
    }
    buffer.writeln();

    // ── Emergency Contact ──
    buffer.writeln('EMERGENCY CONTACT');
    buffer.writeln(data.emergencyContact ?? 'Not provided');
    buffer.writeln();

    // ── Doctor Info ──
    buffer.writeln('DOCTOR');
    buffer.writeln(data.doctorInfo ?? 'Not provided');
    buffer.writeln();

    // ── Parent Notes ──
    if (data.parentNotes != null && data.parentNotes!.isNotEmpty) {
      buffer.writeln('IMPORTANT NOTES FROM PARENT');
      buffer.writeln(data.parentNotes);
      buffer.writeln();
    }

    // ── Footer ──
    buffer.writeln('${'─' * 40}');
    buffer.writeln('Generated ${dateFormat.format(now)} via UU Baby Tracker');

    return buffer.toString();
  }

  String _formatAge(DateTime dob, DateTime now) {
    final months = (now.year - dob.year) * 12 + now.month - dob.month;
    if (months < 1) {
      final days = now.difference(dob).inDays;
      return '$days day${days == 1 ? '' : 's'}';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years > 0) {
      return '$years yr${years == 1 ? '' : 's'}'
          '${remainingMonths > 0 ? ' $remainingMonths mo' : ''}';
    }
    return '$months mo';
  }

  String _formatEventType(String type) {
    switch (type) {
      case 'illness':
        return 'Illness';
      case 'medication':
        return 'Medication';
      case 'doctor_visit':
        return 'Doctor Visit';
      default:
        return type;
    }
  }
}
