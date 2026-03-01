import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/repositories/family_repository.dart';

void main() {
  late AppDatabase db;
  late FamilyRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FamilyRepository(db);
  });

  tearDown(() async => await db.close());

  group('FamilyRepository', () {
    group('createFamily', () {
      test('creates family and adds creator as admin', () async {
        final family = await repo.createFamily(
          name: 'The Smiths',
          inviteCode: 'ABCD1234',
          createdBy: 'user-123',
          creatorEmail: 'admin@example.com',
        );

        expect(family.id, greaterThan(0));
        expect(family.name, 'The Smiths');
        expect(family.inviteCode, 'ABCD1234');
        expect(family.createdBy, 'user-123');

        // Creator should be an admin member.
        final members = await repo.getMembersForFamily(family.id);
        expect(members.length, 1);
        expect(members.first.email, 'admin@example.com');
        expect(members.first.role, 'admin');
        expect(members.first.status, 'accepted');
        expect(members.first.userId, 'user-123');
      });
    });

    group('getFamily', () {
      test('returns null for non-existent id', () async {
        final family = await repo.getFamily(999);
        expect(family, isNull);
      });

      test('returns family by id', () async {
        final created = await repo.createFamily(
          name: 'Test Family',
          inviteCode: 'TEST0001',
          createdBy: 'user-1',
          creatorEmail: 'test@example.com',
        );

        final fetched = await repo.getFamily(created.id);
        expect(fetched, isNotNull);
        expect(fetched!.name, 'Test Family');
      });
    });

    group('getFamilyByInviteCode', () {
      test('returns null for invalid code', () async {
        final family = await repo.getFamilyByInviteCode('INVALID');
        expect(family, isNull);
      });

      test('returns family by invite code', () async {
        await repo.createFamily(
          name: 'Code Family',
          inviteCode: 'FIND1234',
          createdBy: 'user-1',
          creatorEmail: 'test@example.com',
        );

        final found = await repo.getFamilyByInviteCode('FIND1234');
        expect(found, isNotNull);
        expect(found!.name, 'Code Family');
      });
    });

    group('getFamiliesForUser', () {
      test('returns empty for user with no families', () async {
        final families = await repo.getFamiliesForUser('no-families');
        expect(families, isEmpty);
      });

      test('returns families user belongs to', () async {
        final family1 = await repo.createFamily(
          name: 'Family 1',
          inviteCode: 'FAM10001',
          createdBy: 'user-1',
          creatorEmail: 'user1@example.com',
        );

        await repo.createFamily(
          name: 'Family 2',
          inviteCode: 'FAM20002',
          createdBy: 'user-2',
          creatorEmail: 'user2@example.com',
        );

        // user-1 is only in Family 1
        final families = await repo.getFamiliesForUser('user-1');
        expect(families.length, 1);
        expect(families.first.id, family1.id);
      });
    });

    group('addMember', () {
      test('adds member with pending status', () async {
        final family = await repo.createFamily(
          name: 'Test',
          inviteCode: 'ADD10001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final member = await repo.addMember(
          familyId: family.id,
          email: 'member@example.com',
        );

        expect(member.email, 'member@example.com');
        expect(member.role, 'member');
        expect(member.status, 'pending');
        expect(member.userId, isNull);
      });
    });

    group('acceptInvitation', () {
      test('updates status to accepted and sets userId', () async {
        final family = await repo.createFamily(
          name: 'Accept Test',
          inviteCode: 'ACPT0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final member = await repo.addMember(
          familyId: family.id,
          email: 'new@example.com',
        );

        await repo.acceptInvitation(member.id, 'new-user-id');

        final updated = await repo.getMember(member.id);
        expect(updated!.status, 'accepted');
        expect(updated.userId, 'new-user-id');
        expect(updated.joinedAt, isNotNull);
      });
    });

    group('declineInvitation', () {
      test('updates status to declined', () async {
        final family = await repo.createFamily(
          name: 'Decline Test',
          inviteCode: 'DCLN0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final member = await repo.addMember(
          familyId: family.id,
          email: 'nope@example.com',
        );

        await repo.declineInvitation(member.id);

        final updated = await repo.getMember(member.id);
        expect(updated!.status, 'declined');
      });
    });

    group('removeMember', () {
      test('removes member from family', () async {
        final family = await repo.createFamily(
          name: 'Remove Test',
          inviteCode: 'RMVE0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final member = await repo.addMember(
          familyId: family.id,
          email: 'remove@example.com',
        );

        await repo.removeMember(member.id);

        final removed = await repo.getMember(member.id);
        expect(removed, isNull);
      });
    });

    group('isAdmin', () {
      test('returns true for admin', () async {
        final family = await repo.createFamily(
          name: 'Admin Test',
          inviteCode: 'ADMN0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final result = await repo.isAdmin(family.id, 'admin-1');
        expect(result, isTrue);
      });

      test('returns false for non-admin member', () async {
        final family = await repo.createFamily(
          name: 'Admin Test',
          inviteCode: 'ADMN0002',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final member = await repo.addMember(
          familyId: family.id,
          email: 'member@example.com',
          userId: 'member-1',
        );
        await repo.acceptInvitation(member.id, 'member-1');

        final result = await repo.isAdmin(family.id, 'member-1');
        expect(result, isFalse);
      });

      test('returns false for non-member', () async {
        final family = await repo.createFamily(
          name: 'Admin Test',
          inviteCode: 'ADMN0003',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final result = await repo.isAdmin(family.id, 'stranger');
        expect(result, isFalse);
      });
    });

    group('getPendingInvitesForEmail', () {
      test('returns pending invites for email', () async {
        final family = await repo.createFamily(
          name: 'Pending Test',
          inviteCode: 'PEND0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        await repo.addMember(
          familyId: family.id,
          email: 'pending@example.com',
        );

        final invites =
            await repo.getPendingInvitesForEmail('pending@example.com');
        expect(invites.length, 1);
        expect(invites.first.email, 'pending@example.com');
      });

      test('returns empty for email with no pending invites', () async {
        final invites =
            await repo.getPendingInvitesForEmail('none@example.com');
        expect(invites, isEmpty);
      });
    });

    group('getAcceptedMembers', () {
      test('returns only accepted members', () async {
        final family = await repo.createFamily(
          name: 'Accepted Test',
          inviteCode: 'ACPT0002',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        // Add a pending member
        await repo.addMember(
          familyId: family.id,
          email: 'pending@example.com',
        );

        // Admin is already accepted from createFamily
        final accepted = await repo.getAcceptedMembers(family.id);
        expect(accepted.length, 1);
        expect(accepted.first.role, 'admin');
      });
    });

    group('deleteFamily', () {
      test('deletes family and all members', () async {
        final family = await repo.createFamily(
          name: 'Delete Test',
          inviteCode: 'DELT0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        await repo.addMember(
          familyId: family.id,
          email: 'member@example.com',
        );

        await repo.deleteFamily(family.id);

        final deleted = await repo.getFamily(family.id);
        expect(deleted, isNull);

        final members = await repo.getMembersForFamily(family.id);
        expect(members, isEmpty);
      });
    });

    group('updateFamily', () {
      test('updates family name', () async {
        final family = await repo.createFamily(
          name: 'Old Name',
          inviteCode: 'UPDT0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        await repo.updateFamily(family.id, name: 'New Name');

        final updated = await repo.getFamily(family.id);
        expect(updated!.name, 'New Name');
      });
    });

    group('watchMembersForFamily', () {
      test('emits updates when members change', () async {
        final family = await repo.createFamily(
          name: 'Watch Test',
          inviteCode: 'WTCH0001',
          createdBy: 'admin-1',
          creatorEmail: 'admin@example.com',
        );

        final stream = repo.watchMembersForFamily(family.id);

        expectLater(
          stream,
          emitsInOrder([
            // Initial: just the admin
            predicate<List<FamilyMember>>((m) => m.length == 1),
            // After adding a member
            predicate<List<FamilyMember>>((m) => m.length == 2),
          ]),
        );

        await Future.delayed(const Duration(milliseconds: 50));
        await repo.addMember(
          familyId: family.id,
          email: 'watched@example.com',
        );
      });
    });
  });
}
