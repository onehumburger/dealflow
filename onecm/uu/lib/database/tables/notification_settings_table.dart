import 'package:drift/drift.dart';

class NotificationSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get type => text()(); // 'feeding', 'diaper'
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get intervalMinutes =>
      integer().withDefault(const Constant(120))();
  IntColumn get aiSuggestedInterval => integer().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
