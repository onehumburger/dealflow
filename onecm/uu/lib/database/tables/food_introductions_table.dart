import 'package:drift/drift.dart';

class FoodIntroductions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get babyId => integer()();
  TextColumn get foodName => text()();
  TextColumn get category => text()(); // fruit, vegetable, grain, protein, dairy, allergen
  BoolColumn get isAllergen => boolean().withDefault(const Constant(false))();
  DateTimeColumn get firstTriedAt => dateTime()();
  TextColumn get reaction => text().nullable()();
  TextColumn get reactionSeverity => text().nullable()(); // none, mild, moderate, severe
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
