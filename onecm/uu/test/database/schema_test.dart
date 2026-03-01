import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => await db.close());

  group('Schema v3', () {
    test('can insert and read a milestone', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      await db.into(db.milestones).insert(MilestonesCompanion.insert(
            babyId: babyId,
            category: 'motor',
            title: 'First steps',
          ));
      final milestones = await (db.select(db.milestones)
            ..where((m) => m.babyId.equals(babyId)))
          .get();
      expect(milestones.length, 1);
      expect(milestones.first.title, 'First steps');
    });

    test('can insert and read a vaccination', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      await db.into(db.vaccinations).insert(VaccinationsCompanion.insert(
            babyId: babyId,
            vaccineName: 'DTaP',
          ));
      final records = await (db.select(db.vaccinations)
            ..where((v) => v.babyId.equals(babyId)))
          .get();
      expect(records.length, 1);
      expect(records.first.vaccineName, 'DTaP');
    });

    test('can insert and read a health event', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      await db.into(db.healthEvents).insert(HealthEventsCompanion.insert(
            babyId: babyId,
            type: 'doctor_visit',
            title: 'Checkup',
          ));
      final events = await (db.select(db.healthEvents)
            ..where((h) => h.babyId.equals(babyId)))
          .get();
      expect(events.length, 1);
    });

    test('can insert and read a food introduction', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      await db.into(db.foodIntroductions).insert(
            FoodIntroductionsCompanion.insert(
              babyId: babyId,
              foodName: 'Banana',
              category: 'fruit',
              firstTriedAt: DateTime(2025, 12, 1),
            ),
          );
      final foods = await (db.select(db.foodIntroductions)
            ..where((f) => f.babyId.equals(babyId)))
          .get();
      expect(foods.length, 1);
      expect(foods.first.foodName, 'Banana');
    });

    test('can insert and read a tooth record', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      await db.into(db.teethRecords).insert(TeethRecordsCompanion.insert(
            babyId: babyId,
            toothPosition: 'A',
            eruptedAt: DateTime(2025, 12, 1),
          ));
      final teeth = await (db.select(db.teethRecords)
            ..where((t) => t.babyId.equals(babyId)))
          .get();
      expect(teeth.length, 1);
    });

    test('can insert and read a chat message', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      await db.into(db.chatMessages).insert(ChatMessagesCompanion.insert(
            babyId: babyId,
            role: 'user',
            content: 'Is this normal?',
          ));
      final messages = await (db.select(db.chatMessages)
            ..where((c) => c.babyId.equals(babyId)))
          .get();
      expect(messages.length, 1);
      expect(messages.first.role, 'user');
    });

    test('can insert and read a media entry', () async {
      final babyId = await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      await db.into(db.mediaEntries).insert(MediaEntriesCompanion.insert(
            babyId: babyId,
            type: 'photo',
            storagePath: '/photos/1.jpg',
          ));
      final media = await (db.select(db.mediaEntries)
            ..where((m) => m.babyId.equals(babyId)))
          .get();
      expect(media.length, 1);
    });
  });
}
