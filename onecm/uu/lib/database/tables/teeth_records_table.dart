import 'package:drift/drift.dart';

class TeethRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get toothPosition => text()(); // A-T dental notation
  DateTimeColumn get eruptedAt => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
