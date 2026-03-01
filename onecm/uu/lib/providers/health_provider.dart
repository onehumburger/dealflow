import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/vaccination_repository.dart';
import 'package:uu/repositories/health_event_repository.dart';
import 'package:uu/services/vaccination_schedule_service.dart';

final vaccinationRepositoryProvider = Provider<VaccinationRepository>((ref) {
  return VaccinationRepository(ref.watch(databaseProvider));
});

final healthEventRepositoryProvider = Provider<HealthEventRepository>((ref) {
  return HealthEventRepository(ref.watch(databaseProvider));
});

final vaccinationScheduleServiceProvider =
    Provider<VaccinationScheduleService>((ref) {
  return VaccinationScheduleService();
});

final vaccinationsProvider = StreamProvider<List<Vaccination>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(vaccinationRepositoryProvider).watchVaccinationsForBaby(babyId);
});

final healthEventsProvider = StreamProvider<List<HealthEvent>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref
      .watch(healthEventRepositoryProvider)
      .watchHealthEventsForBaby(babyId);
});
