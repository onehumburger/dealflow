import 'package:drift/drift.dart';
import 'tables/babies_table.dart';
import 'tables/growth_records_table.dart';
import 'tables/daily_logs_table.dart';
import 'tables/notification_settings_table.dart';
import 'tables/milestones_table.dart';
import 'tables/vaccinations_table.dart';
import 'tables/health_events_table.dart';
import 'tables/food_introductions_table.dart';
import 'tables/teeth_records_table.dart';
import 'tables/chat_messages_table.dart';
import 'tables/media_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Babies,
  GrowthRecords,
  DailyLogs,
  NotificationSettings,
  Milestones,
  Vaccinations,
  HealthEvents,
  FoodIntroductions,
  TeethRecords,
  ChatMessages,
  MediaEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(notificationSettings);
          }
          if (from < 3) {
            await m.createTable(milestones);
            await m.createTable(vaccinations);
            await m.createTable(healthEvents);
            await m.createTable(foodIntroductions);
            await m.createTable(teethRecords);
            await m.createTable(chatMessages);
            await m.createTable(mediaEntries);
          }
        },
      );
}
