import 'package:drift/drift.dart';
import 'families_table.dart';

/// Local Drift table for family members.
///
/// Links a user to a family with a role (admin or member).
/// Also tracks invitation state: pending, accepted, or declined.
class FamilyMembers extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to the families table.
  IntColumn get familyId =>
      integer().references(Families, #id)();

  /// The Supabase user ID of the member (null if invite is pending).
  TextColumn get userId => text().nullable()();

  /// The email address used for the invitation.
  TextColumn get email => text()();

  /// Role within the family: 'admin' or 'member'.
  TextColumn get role => text().withDefault(const Constant('member'))();

  /// Invitation status: 'pending', 'accepted', or 'declined'.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  DateTimeColumn get invitedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get joinedAt => dateTime().nullable()();
}
