import 'package:drift/drift.dart';

class Babies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get gender => text().nullable()();
  TextColumn get bloodType => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
