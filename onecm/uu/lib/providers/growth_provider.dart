import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/growth_repository.dart';

final growthRepositoryProvider = Provider<GrowthRepository>((ref) {
  return GrowthRepository(ref.watch(databaseProvider));
});

final growthRecordsProvider = StreamProvider<List<GrowthRecord>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(growthRepositoryProvider).watchRecordsForBaby(babyId);
});
