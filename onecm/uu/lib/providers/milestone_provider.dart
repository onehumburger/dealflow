import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/milestone_repository.dart';
import 'package:uu/services/milestone_service.dart';

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return MilestoneRepository(ref.watch(databaseProvider));
});

final milestonesProvider = StreamProvider<List<Milestone>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(milestoneRepositoryProvider).watchMilestonesForBaby(babyId);
});

final milestoneServiceProvider = Provider<MilestoneService>((ref) {
  return MilestoneService();
});
