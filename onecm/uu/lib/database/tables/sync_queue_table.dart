import 'package:drift/drift.dart';

/// Local queue that tracks changes to be pushed to Supabase.
///
/// Each row represents one local write (insert, update, or delete)
/// that has not yet been synced to the remote database.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  IntColumn get recordId => integer()();
  TextColumn get operation => text()(); // 'insert', 'update', 'delete'
  TextColumn get payload => text()(); // JSON-serialized data
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}
