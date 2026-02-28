import 'package:drift/drift.dart';

class Vaccinations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get vaccineName => text()();
  IntColumn get doseNumber => integer().nullable()();
  DateTimeColumn get administeredAt => dateTime().nullable()();
  DateTimeColumn get nextDueAt => dateTime().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
