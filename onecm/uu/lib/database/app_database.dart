import 'package:drift/drift.dart';
import 'tables/babies_table.dart';
import 'tables/growth_records_table.dart';
import 'tables/daily_logs_table.dart';
import 'tables/notification_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Babies, GrowthRecords, DailyLogs, NotificationSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(notificationSettings);
          }
        },
      );
}
