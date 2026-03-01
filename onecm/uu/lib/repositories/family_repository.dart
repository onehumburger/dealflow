import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

/// Repository for managing families and family members in the local Drift database.
class FamilyRepository {
  final AppDatabase _db;
  FamilyRepository(this._db);

  // ── Family CRUD ──────────────────────────────────────────────────────

  /// Create a new family and add the creator as admin.
  Future<Family> createFamily({
    required String name,
    required String inviteCode,
    required String createdBy,
    required String creatorEmail,
  }) async {
    return _db.transaction(() async {
      final familyId = await _db.into(_db.families).insert(
            FamiliesCompanion.insert(
              name: name,
              inviteCode: inviteCode,
              createdBy: createdBy,
            ),
          );

      // Add the creator as an admin member with accepted status.
      await _db.into(_db.familyMembers).insert(
            FamilyMembersCompanion.insert(
              familyId: familyId,
              email: creatorEmail,
              role: const Value('admin'),
              status: const Value('accepted'),
              userId: Value(createdBy),
              joinedAt: Value(DateTime.now()),
            ),
          );

      return (await getFamily(familyId))!;
    });
  }

  /// Get a family by its ID.
  Future<Family?> getFamily(int id) {
    return (_db.select(_db.families)..where((f) => f.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get a family by its invite code.
  Future<Family?> getFamilyByInviteCode(String inviteCode) {
    return (_db.select(_db.families)
          ..where((f) => f.inviteCode.equals(inviteCode)))
        .getSingleOrNull();
  }

  /// Get all families the user belongs to (by user ID).
  Future<List<Family>> getFamiliesForUser(String userId) async {
    final memberRows = await (_db.select(_db.familyMembers)
          ..where((m) =>
              m.userId.equals(userId) & m.status.equals('accepted')))
        .get();

    if (memberRows.isEmpty) return [];

    final familyIds = memberRows.map((m) => m.familyId).toList();
    return (_db.select(_db.families)
          ..where((f) => f.id.isIn(familyIds)))
        .get();
  }

  /// Update family name.
  Future<void> updateFamily(int id, {required String name}) {
    return (_db.update(_db.families)..where((f) => f.id.equals(id))).write(
      FamiliesCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a family and all its members.
  Future<void> deleteFamily(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.familyMembers)
            ..where((m) => m.familyId.equals(id)))
          .go();
      await (_db.delete(_db.families)..where((f) => f.id.equals(id))).go();
    });
  }

  // ── Family Member CRUD ───────────────────────────────────────────────

  /// Add a member to a family (invitation — status defaults to 'pending').
  Future<FamilyMember> addMember({
    required int familyId,
    required String email,
    String role = 'member',
    String? userId,
  }) async {
    final id = await _db.into(_db.familyMembers).insert(
          FamilyMembersCompanion.insert(
            familyId: familyId,
            email: email,
            role: Value(role),
            userId: Value(userId),
          ),
        );
    return (await getMember(id))!;
  }

  /// Get a family member by ID.
  Future<FamilyMember?> getMember(int id) {
    return (_db.select(_db.familyMembers)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all members of a family.
  Future<List<FamilyMember>> getMembersForFamily(int familyId) {
    return (_db.select(_db.familyMembers)
          ..where((m) => m.familyId.equals(familyId))
          ..orderBy([(m) => OrderingTerm.asc(m.invitedAt)]))
        .get();
  }

  /// Get accepted members of a family.
  Future<List<FamilyMember>> getAcceptedMembers(int familyId) {
    return (_db.select(_db.familyMembers)
          ..where((m) =>
              m.familyId.equals(familyId) & m.status.equals('accepted')))
        .get();
  }

  /// Get pending invitations for a specific email.
  Future<List<FamilyMember>> getPendingInvitesForEmail(String email) {
    return (_db.select(_db.familyMembers)
          ..where(
              (m) => m.email.equals(email) & m.status.equals('pending')))
        .get();
  }

  /// Accept an invitation: set status to 'accepted', record user ID and join time.
  Future<void> acceptInvitation(int memberId, String userId) {
    return (_db.update(_db.familyMembers)
          ..where((m) => m.id.equals(memberId)))
        .write(
      FamilyMembersCompanion(
        userId: Value(userId),
        status: const Value('accepted'),
        joinedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Decline an invitation.
  Future<void> declineInvitation(int memberId) {
    return (_db.update(_db.familyMembers)
          ..where((m) => m.id.equals(memberId)))
        .write(
      const FamilyMembersCompanion(
        status: Value('declined'),
      ),
    );
  }

  /// Remove a member from a family.
  Future<int> removeMember(int memberId) {
    return (_db.delete(_db.familyMembers)
          ..where((m) => m.id.equals(memberId)))
        .go();
  }

  /// Check if a user is an admin of a family.
  Future<bool> isAdmin(int familyId, String userId) async {
    final member = await (_db.select(_db.familyMembers)
          ..where((m) =>
              m.familyId.equals(familyId) &
              m.userId.equals(userId) &
              m.role.equals('admin') &
              m.status.equals('accepted')))
        .getSingleOrNull();
    return member != null;
  }

  /// Watch all members of a family as a stream.
  Stream<List<FamilyMember>> watchMembersForFamily(int familyId) {
    return (_db.select(_db.familyMembers)
          ..where((m) => m.familyId.equals(familyId))
          ..orderBy([(m) => OrderingTerm.asc(m.invitedAt)]))
        .watch();
  }

  /// Watch families for a user as a stream.
  Stream<List<Family>> watchFamiliesForUser(String userId) {
    // We use a custom select to join families with family_members.
    final query = _db.select(_db.familyMembers)
      ..where((m) =>
          m.userId.equals(userId) & m.status.equals('accepted'));

    return query.watch().asyncMap((members) async {
      if (members.isEmpty) return <Family>[];
      final familyIds = members.map((m) => m.familyId).toList();
      return (_db.select(_db.families)
            ..where((f) => f.id.isIn(familyIds)))
          .get();
    });
  }
}
