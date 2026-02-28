import 'package:drift/drift.dart';

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get role => text()(); // user, assistant
  TextColumn get content => text()();
  TextColumn get contextData => text().nullable()(); // JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
