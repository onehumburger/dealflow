import 'dart:math';

import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/family_repository.dart';

/// Result of a family operation that can succeed or fail with a message.
class FamilyResult<T> {
  final T? data;
  final String? error;

  const FamilyResult.success(this.data) : error = null;
  const FamilyResult.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Service layer for family management and invitation logic.
///
/// Coordinates between the local [FamilyRepository] and provides
/// business rules for invite codes, invitations, and membership.
class FamilyService {
  final FamilyRepository _repo;

  FamilyService(this._repo);

  /// Characters used for generating invite codes (no ambiguous chars).
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _codeLength = 8;

  /// Generate a random invite code.
  static String generateInviteCode() {
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        _codeLength,
        (_) => _codeChars.codeUnitAt(random.nextInt(_codeChars.length)),
      ),
    );
  }

  /// Create a new family.
  ///
  /// The current user becomes the admin. An invite code is auto-generated.
  Future<FamilyResult<Family>> createFamily({
    required String name,
    required String userId,
    required String userEmail,
  }) async {
    if (name.trim().isEmpty) {
      return const FamilyResult.failure('Family name cannot be empty.');
    }

    try {
      final inviteCode = generateInviteCode();
      final family = await _repo.createFamily(
        name: name.trim(),
        inviteCode: inviteCode,
        createdBy: userId,
        creatorEmail: userEmail,
      );
      return FamilyResult.success(family);
    } catch (e) {
      return FamilyResult.failure('Failed to create family: $e');
    }
  }

  /// Invite a user by email to a family.
  ///
  /// Only admins can invite new members.
  Future<FamilyResult<FamilyMember>> inviteMember({
    required int familyId,
    required String email,
    required String invitedByUserId,
  }) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      return const FamilyResult.failure('Please enter a valid email address.');
    }

    try {
      // Verify the inviter is an admin.
      final isAdmin = await _repo.isAdmin(familyId, invitedByUserId);
      if (!isAdmin) {
        return const FamilyResult.failure(
          'Only family admins can invite members.',
        );
      }

      // Check if this email is already a member.
      final existingMembers = await _repo.getMembersForFamily(familyId);
      final alreadyMember = existingMembers.any(
        (m) =>
            m.email.toLowerCase() == email.trim().toLowerCase() &&
            m.status != 'declined',
      );
      if (alreadyMember) {
        return const FamilyResult.failure(
          'This email has already been invited.',
        );
      }

      final member = await _repo.addMember(
        familyId: familyId,
        email: email.trim().toLowerCase(),
      );
      return FamilyResult.success(member);
    } catch (e) {
      return FamilyResult.failure('Failed to invite member: $e');
    }
  }

  /// Accept an invitation by invite code.
  ///
  /// Looks up the family by invite code, finds the pending invitation
  /// for the user's email, and accepts it.
  Future<FamilyResult<Family>> acceptInviteByCode({
    required String inviteCode,
    required String userId,
    required String userEmail,
  }) async {
    if (inviteCode.trim().isEmpty) {
      return const FamilyResult.failure('Please enter an invite code.');
    }

    try {
      final family =
          await _repo.getFamilyByInviteCode(inviteCode.trim().toUpperCase());
      if (family == null) {
        return const FamilyResult.failure(
          'Invalid invite code. Please check and try again.',
        );
      }

      // Check if user is already a member.
      final members = await _repo.getMembersForFamily(family.id);
      final existingMember = members.where(
        (m) => m.userId == userId && m.status == 'accepted',
      );
      if (existingMember.isNotEmpty) {
        return const FamilyResult.failure(
          'You are already a member of this family.',
        );
      }

      // Check for pending invite for this email.
      final pendingInvite = members.where(
        (m) =>
            m.email.toLowerCase() == userEmail.toLowerCase() &&
            m.status == 'pending',
      );

      if (pendingInvite.isNotEmpty) {
        // Accept the existing pending invite.
        await _repo.acceptInvitation(pendingInvite.first.id, userId);
      } else {
        // No pending invite -- join directly via the invite code.
        await _repo.addMember(
          familyId: family.id,
          email: userEmail,
          userId: userId,
          role: 'member',
        );
        // Find the just-added member and accept it.
        final newMembers = await _repo.getMembersForFamily(family.id);
        final newMember = newMembers.lastWhere(
          (m) => m.email.toLowerCase() == userEmail.toLowerCase(),
        );
        await _repo.acceptInvitation(newMember.id, userId);
      }

      return FamilyResult.success(family);
    } catch (e) {
      return FamilyResult.failure('Failed to join family: $e');
    }
  }

  /// Get pending invitations for a user's email.
  Future<List<FamilyMember>> getPendingInvitations(String email) {
    return _repo.getPendingInvitesForEmail(email.toLowerCase());
  }

  /// Accept a specific pending invitation by member ID.
  Future<FamilyResult<void>> acceptInvitation({
    required int memberId,
    required String userId,
  }) async {
    try {
      await _repo.acceptInvitation(memberId, userId);
      return const FamilyResult.success(null);
    } catch (e) {
      return FamilyResult.failure('Failed to accept invitation: $e');
    }
  }

  /// Decline a specific pending invitation.
  Future<FamilyResult<void>> declineInvitation(int memberId) async {
    try {
      await _repo.declineInvitation(memberId);
      return const FamilyResult.success(null);
    } catch (e) {
      return FamilyResult.failure('Failed to decline invitation: $e');
    }
  }

  /// Remove a member from a family. Only admins can remove members.
  Future<FamilyResult<void>> removeMember({
    required int familyId,
    required int memberId,
    required String requestedByUserId,
  }) async {
    try {
      final isAdmin = await _repo.isAdmin(familyId, requestedByUserId);
      if (!isAdmin) {
        return const FamilyResult.failure(
          'Only family admins can remove members.',
        );
      }

      // Don't allow removing the last admin.
      final member = await _repo.getMember(memberId);
      if (member == null) {
        return const FamilyResult.failure('Member not found.');
      }
      if (member.role == 'admin') {
        final admins = (await _repo.getAcceptedMembers(familyId))
            .where((m) => m.role == 'admin')
            .toList();
        if (admins.length <= 1) {
          return const FamilyResult.failure(
            'Cannot remove the only admin. Transfer admin role first.',
          );
        }
      }

      await _repo.removeMember(memberId);
      return const FamilyResult.success(null);
    } catch (e) {
      return FamilyResult.failure('Failed to remove member: $e');
    }
  }

  /// Get all families for a user.
  Future<List<Family>> getFamiliesForUser(String userId) {
    return _repo.getFamiliesForUser(userId);
  }

  /// Get all members of a family.
  Future<List<FamilyMember>> getMembersForFamily(int familyId) {
    return _repo.getMembersForFamily(familyId);
  }

  /// Get a family by ID.
  Future<Family?> getFamily(int familyId) {
    return _repo.getFamily(familyId);
  }
}
