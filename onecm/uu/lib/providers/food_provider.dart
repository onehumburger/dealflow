import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/food_repository.dart';
import 'package:uu/services/food_service.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository(ref.watch(databaseProvider));
});

final foodServiceProvider = Provider<FoodService>((ref) {
  return FoodService();
});

/// Stream of all food introductions for the selected baby.
final foodIntroductionsProvider = StreamProvider<List<FoodIntroduction>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(foodRepositoryProvider).watchFoodIntroductionsForBaby(babyId);
});

/// 3-day wait rule status for the selected baby.
final waitRuleStatusProvider = FutureProvider<WaitRuleStatus>((ref) async {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) {
    return const WaitRuleStatus(canIntroduce: true);
  }
  final repo = ref.watch(foodRepositoryProvider);
  final service = ref.watch(foodServiceProvider);
  final lastFood = await repo.getLastIntroducedFood(babyId);
  return service.checkWaitRule(
    lastIntroducedAt: lastFood?.firstTriedAt,
    lastFoodName: lastFood?.foodName,
  );
});
