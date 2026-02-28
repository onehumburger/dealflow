import 'package:drift/drift.dart';

class DailyLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get type => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get metadata => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
