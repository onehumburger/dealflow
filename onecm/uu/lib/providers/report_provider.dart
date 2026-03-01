import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/daily_log_provider.dart';
import 'package:uu/providers/growth_provider.dart';
import 'package:uu/providers/health_provider.dart';
import 'package:uu/providers/milestone_provider.dart';
import 'package:uu/services/report/doctor_report_service.dart';
import 'package:uu/services/report/caregiver_handoff_service.dart';
import 'package:uu/services/who_growth_standards.dart' as who;

final doctorReportServiceProvider = Provider<DoctorReportService>((ref) {
  return DoctorReportService();
});

final caregiverHandoffServiceProvider =
    Provider<CaregiverHandoffService>((ref) {
  return CaregiverHandoffService();
});

/// Generates a doctor visit PDF report for the currently selected baby.
///
/// Returns the PDF bytes, or null if no baby is selected.
final doctorReportProvider = FutureProvider<Uint8List?>((ref) async {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return null;

  final babies = await ref.watch(allBabiesProvider.future);
  final baby = babies.where((b) => b.id == babyId).firstOrNull;
  if (baby == null) return null;

  final growthRecords = await ref.watch(growthRecordsProvider.future);
  final latestGrowth =
      growthRecords.isNotEmpty ? growthRecords.last : null;

  // Calculate percentiles if we have growth data
  Map<String, double>? percentiles;
  if (latestGrowth != null && baby.gender != null) {
    final ageMonths =
        (DateTime.now().year - baby.dateOfBirth.year) * 12 +
            DateTime.now().month - baby.dateOfBirth.month;
    if (ageMonths >= 0 && ageMonths <= 36) {
      final gender = baby.gender?.toLowerCase() == 'male'
          ? who.Gender.male
          : who.Gender.female;
      percentiles = {};
      if (latestGrowth.weightKg != null) {
        percentiles['weight'] = who.WHOGrowthStandards.percentile(
          measurement: latestGrowth.weightKg!,
          ageMonths: ageMonths,
          gender: gender,
          type: who.MeasurementType.weight,
        );
      }
      if (latestGrowth.heightCm != null) {
        percentiles['height'] = who.WHOGrowthStandards.percentile(
          measurement: latestGrowth.heightCm!,
          ageMonths: ageMonths,
          gender: gender,
          type: who.MeasurementType.height,
        );
      }
      if (latestGrowth.headCircumferenceCm != null) {
        percentiles['headCircumference'] =
            who.WHOGrowthStandards.percentile(
          measurement: latestGrowth.headCircumferenceCm!,
          ageMonths: ageMonths,
          gender: gender,
          type: who.MeasurementType.headCircumference,
        );
      }
    }
  }

  final summary = await ref.watch(todaySummaryProvider.future);
  final vaccinations = await ref.watch(vaccinationsProvider.future);
  final healthEvents = await ref.watch(healthEventsProvider.future);
  final milestones = await ref.watch(milestonesProvider.future);

  final data = DoctorReportData(
    baby: baby,
    latestGrowth: latestGrowth,
    percentiles: percentiles,
    recentSummary: summary,
    vaccinations: vaccinations,
    recentHealthEvents: healthEvents.take(5).toList(),
    milestones: milestones,
  );

  return ref.watch(doctorReportServiceProvider).generatePdf(data);
});

/// Generates caregiver handoff text for the currently selected baby.
///
/// Returns the formatted text, or null if no baby is selected.
final caregiverHandoffProvider = FutureProvider<String?>((ref) async {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return null;

  final babies = await ref.watch(allBabiesProvider.future);
  final baby = babies.where((b) => b.id == babyId).firstOrNull;
  if (baby == null) return null;

  final summary = await ref.watch(todaySummaryProvider.future);
  final healthEvents = await ref.watch(healthEventsProvider.future);
  final activeEvents = healthEvents.where((e) => e.endedAt == null).toList();

  final data = CaregiverHandoffData(
    baby: baby,
    recentSummary: summary,
    activeHealthEvents: activeEvents,
  );

  return ref.watch(caregiverHandoffServiceProvider).generateHandoff(data);
});
