import 'package:drift/drift.dart';

class MediaEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get type => text()(); // photo, video
  TextColumn get storagePath => text()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  TextColumn get linkedRecordType => text().nullable()();
  IntColumn get linkedRecordId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
