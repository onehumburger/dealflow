import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/repositories/baby_repository.dart';

final babyRepositoryProvider = Provider<BabyRepository>((ref) {
  return BabyRepository(ref.watch(databaseProvider));
});

final allBabiesProvider = FutureProvider<List<Baby>>((ref) {
  return ref.watch(babyRepositoryProvider).getAllBabies();
});

final selectedBabyIdProvider = StateProvider<int?>((ref) => null);
