import 'package:drift/drift.dart';

/// Local Drift table for families.
///
/// A family groups users together so they can share baby data.
/// The user who creates the family is automatically the admin.
class Families extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Invite code used to join the family (short alphanumeric string).
  TextColumn get inviteCode => text().withLength(min: 6, max: 20)();

  /// The user ID (Supabase auth.uid) of the family creator/admin.
  TextColumn get createdBy => text()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
