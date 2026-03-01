import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide Family; // hide Riverpod's Family to use our Drift-generated Family
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/auth_provider.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/repositories/family_repository.dart';
import 'package:uu/services/family_service.dart';

/// Provider for the [FamilyRepository].
final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(ref.watch(databaseProvider));
});

/// Provider for the [FamilyService].
final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService(ref.watch(familyRepositoryProvider));
});

/// Provider for the list of families the current user belongs to.
///
/// Returns an empty list if the user is not authenticated.
final userFamiliesProvider = StreamProvider<List<Family>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final repo = ref.watch(familyRepositoryProvider);
  return repo.watchFamiliesForUser(user.id);
});

/// Provider for the currently selected family ID.
final selectedFamilyIdProvider = StateProvider<int?>((ref) => null);

/// Provider for members of the selected family.
final familyMembersProvider =
    StreamProvider<List<FamilyMember>>((ref) {
  final familyId = ref.watch(selectedFamilyIdProvider);
  if (familyId == null) return Stream.value([]);

  final repo = ref.watch(familyRepositoryProvider);
  return repo.watchMembersForFamily(familyId);
});

/// Provider for pending invitations for the current user's email.
final pendingInvitationsProvider =
    FutureProvider<List<FamilyMember>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.email == null) return [];

  final service = ref.watch(familyServiceProvider);
  return service.getPendingInvitations(user.email!);
});
