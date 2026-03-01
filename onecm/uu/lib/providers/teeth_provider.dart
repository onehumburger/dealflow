import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/teeth_repository.dart';
import 'package:uu/services/teeth_service.dart';

final teethRepositoryProvider = Provider<TeethRepository>((ref) {
  return TeethRepository(ref.watch(databaseProvider));
});

final teethRecordsProvider = StreamProvider<List<TeethRecord>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(teethRepositoryProvider).watchTeethForBaby(babyId);
});

final teethServiceProvider = Provider<TeethService>((ref) {
  return TeethService();
});
