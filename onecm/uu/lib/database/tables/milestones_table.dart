import 'package:drift/drift.dart';

class Milestones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get category => text()(); // motor, language, social, cognitive
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get achievedAt => dateTime().nullable()();
  IntColumn get expectedAgeMonths => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
