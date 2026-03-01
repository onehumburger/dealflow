import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/family_repository.dart';
import 'package:uu/services/family_service.dart';

void main() {
  late AppDatabase db;
  late FamilyRepository repo;
  late FamilyService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FamilyRepository(db);
    service = FamilyService(repo);
  });

  tearDown(() async => await db.close());

  group('FamilyService', () {
    group('generateInviteCode', () {
      test('generates code of correct length', () {
        final code = FamilyService.generateInviteCode();
        expect(code.length, 8);
      });

      test('generates unique codes', () {
        final codes = List.generate(20, (_) => FamilyService.generateInviteCode());
        final uniqueCodes = codes.toSet();
        // With 8 chars from 32 possible, collisions in 20 codes are extremely unlikely.
        expect(uniqueCodes.length, 20);
      });

      test('contains only allowed characters', () {
        final code = FamilyService.generateInviteCode();
        final allowed = RegExp(r'^[A-HJ-NP-Z2-9]+$');
        expect(allowed.hasMatch(code), isTrue,
            reason: 'Code "$code" contains invalid characters');
      });
    });

    group('createFamily', () {
      test('creates family successfully', () async {
        final result = await service.createFamily(
          name: 'Test Family',
          userId: 'user-1',
          userEmail: 'user@example.com',
        );

        expect(result.isSuccess, isTrue);
        expect(result.data!.name, 'Test Family');
        expect(result.data!.inviteCode.length, 8);
      });

      test('fails with empty name', () async {
        final result = await service.createFamily(
          name: '',
          userId: 'user-1',
          userEmail: 'user@example.com',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('empty'));
      });

      test('fails with whitespace-only name', () async {
        final result = await service.createFamily(
          name: '   ',
          userId: 'user-1',
          userEmail: 'user@example.com',
        );

        expect(result.isFailure, isTrue);
      });
    });

    group('inviteMember', () {
      late Family family;

      setUp(() async {
        final result = await service.createFamily(
          name: 'Invite Test',
          userId: 'admin-1',
          userEmail: 'admin@example.com',
        );
        family = result.data!;
      });

      test('invites member successfully', () async {
        final result = await service.inviteMember(
          familyId: family.id,
          email: 'new@example.com',
          invitedByUserId: 'admin-1',
        );

        expect(result.isSuccess, isTrue);
        expect(result.data!.email, 'new@example.com');
        expect(result.data!.status, 'pending');
      });

      test('fails with invalid email', () async {
        final result = await service.inviteMember(
          familyId: family.id,
          email: 'not-an-email',
          invitedByUserId: 'admin-1',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('email'));
      });

      test('fails with empty email', () async {
        final result = await service.inviteMember(
          familyId: family.id,
          email: '',
          invitedByUserId: 'admin-1',
        );

        expect(result.isFailure, isTrue);
      });

      test('fails when inviter is not admin', () async {
        // Add a regular member first
        final member = await repo.addMember(
          familyId: family.id,
          email: 'member@example.com',
          userId: 'member-1',
        );
        await repo.acceptInvitation(member.id, 'member-1');

        final result = await service.inviteMember(
          familyId: family.id,
          email: 'another@example.com',
          invitedByUserId: 'member-1',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('admin'));
      });

      test('fails when email already invited', () async {
        await service.inviteMember(
          familyId: family.id,
          email: 'duplicate@example.com',
          invitedByUserId: 'admin-1',
        );

        final result = await service.inviteMember(
          familyId: family.id,
          email: 'duplicate@example.com',
          invitedByUserId: 'admin-1',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('already'));
      });
    });

    group('acceptInviteByCode', () {
      late Family family;

      setUp(() async {
        final result = await service.createFamily(
          name: 'Join Test',
          userId: 'admin-1',
          userEmail: 'admin@example.com',
        );
        family = result.data!;
      });

      test('joins family with valid invite code', () async {
        final result = await service.acceptInviteByCode(
          inviteCode: family.inviteCode,
          userId: 'joiner-1',
          userEmail: 'joiner@example.com',
        );

        expect(result.isSuccess, isTrue);
        expect(result.data!.id, family.id);

        // Verify the new member is accepted
        final members = await repo.getAcceptedMembers(family.id);
        expect(members.length, 2);
      });

      test('accepts existing pending invite via code', () async {
        // Pre-invite the email
        await service.inviteMember(
          familyId: family.id,
          email: 'preinvited@example.com',
          invitedByUserId: 'admin-1',
        );

        final result = await service.acceptInviteByCode(
          inviteCode: family.inviteCode,
          userId: 'joiner-2',
          userEmail: 'preinvited@example.com',
        );

        expect(result.isSuccess, isTrue);

        final members = await repo.getAcceptedMembers(family.id);
        expect(members.length, 2);
        final joined = members.firstWhere((m) => m.userId == 'joiner-2');
        expect(joined.email, 'preinvited@example.com');
      });

      test('fails with invalid invite code', () async {
        final result = await service.acceptInviteByCode(
          inviteCode: 'INVALID0',
          userId: 'user-1',
          userEmail: 'user@example.com',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('Invalid'));
      });

      test('fails with empty invite code', () async {
        final result = await service.acceptInviteByCode(
          inviteCode: '',
          userId: 'user-1',
          userEmail: 'user@example.com',
        );

        expect(result.isFailure, isTrue);
      });

      test('fails when already a member', () async {
        // Join once
        await service.acceptInviteByCode(
          inviteCode: family.inviteCode,
          userId: 'joiner-3',
          userEmail: 'joiner3@example.com',
        );

        // Try to join again
        final result = await service.acceptInviteByCode(
          inviteCode: family.inviteCode,
          userId: 'joiner-3',
          userEmail: 'joiner3@example.com',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('already'));
      });
    });

    group('removeMember', () {
      late Family family;

      setUp(() async {
        final result = await service.createFamily(
          name: 'Remove Test',
          userId: 'admin-1',
          userEmail: 'admin@example.com',
        );
        family = result.data!;
      });

      test('admin can remove a member', () async {
        final memberResult = await service.inviteMember(
          familyId: family.id,
          email: 'remove@example.com',
          invitedByUserId: 'admin-1',
        );
        final memberId = memberResult.data!.id;
        await repo.acceptInvitation(memberId, 'remove-user');

        final result = await service.removeMember(
          familyId: family.id,
          memberId: memberId,
          requestedByUserId: 'admin-1',
        );

        expect(result.isSuccess, isTrue);
      });

      test('non-admin cannot remove a member', () async {
        // Add and accept a regular member
        final member = await repo.addMember(
          familyId: family.id,
          email: 'regular@example.com',
          userId: 'regular-1',
        );
        await repo.acceptInvitation(member.id, 'regular-1');

        // Add another member to try to remove
        final target = await repo.addMember(
          familyId: family.id,
          email: 'target@example.com',
          userId: 'target-1',
        );
        await repo.acceptInvitation(target.id, 'target-1');

        final result = await service.removeMember(
          familyId: family.id,
          memberId: target.id,
          requestedByUserId: 'regular-1',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('admin'));
      });

      test('cannot remove last admin', () async {
        // Get the admin member
        final members = await repo.getMembersForFamily(family.id);
        final admin = members.firstWhere((m) => m.role == 'admin');

        final result = await service.removeMember(
          familyId: family.id,
          memberId: admin.id,
          requestedByUserId: 'admin-1',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, contains('only admin'));
      });
    });

    group('getPendingInvitations', () {
      test('returns pending invitations for email', () async {
        final familyResult = await service.createFamily(
          name: 'Pending Test',
          userId: 'admin-1',
          userEmail: 'admin@example.com',
        );

        await service.inviteMember(
          familyId: familyResult.data!.id,
          email: 'pending@example.com',
          invitedByUserId: 'admin-1',
        );

        final invites =
            await service.getPendingInvitations('pending@example.com');
        expect(invites.length, 1);
      });
    });

    group('acceptInvitation', () {
      test('accepts a pending invitation', () async {
        final familyResult = await service.createFamily(
          name: 'Accept Direct Test',
          userId: 'admin-1',
          userEmail: 'admin@example.com',
        );

        final inviteResult = await service.inviteMember(
          familyId: familyResult.data!.id,
          email: 'acceptme@example.com',
          invitedByUserId: 'admin-1',
        );

        final result = await service.acceptInvitation(
          memberId: inviteResult.data!.id,
          userId: 'acceptme-user',
        );

        expect(result.isSuccess, isTrue);

        final member = await repo.getMember(inviteResult.data!.id);
        expect(member!.status, 'accepted');
        expect(member.userId, 'acceptme-user');
      });
    });

    group('declineInvitation', () {
      test('declines a pending invitation', () async {
        final familyResult = await service.createFamily(
          name: 'Decline Test',
          userId: 'admin-1',
          userEmail: 'admin@example.com',
        );

        final inviteResult = await service.inviteMember(
          familyId: familyResult.data!.id,
          email: 'nope@example.com',
          invitedByUserId: 'admin-1',
        );

        final result =
            await service.declineInvitation(inviteResult.data!.id);

        expect(result.isSuccess, isTrue);

        final member = await repo.getMember(inviteResult.data!.id);
        expect(member!.status, 'declined');
      });
    });

    group('getFamiliesForUser', () {
      test('returns families the user belongs to', () async {
        await service.createFamily(
          name: 'My Family',
          userId: 'user-1',
          userEmail: 'user1@example.com',
        );

        final families = await service.getFamiliesForUser('user-1');
        expect(families.length, 1);
        expect(families.first.name, 'My Family');
      });
    });
  });
}
