import 'package:drift/drift.dart';
import 'tables/babies_table.dart';
import 'tables/growth_records_table.dart';
import 'tables/daily_logs_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Babies, GrowthRecords, DailyLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
