import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class HealthEventRepository {
  final AppDatabase _db;
  HealthEventRepository(this._db);

  Future<HealthEvent> createHealthEvent({
    required int babyId,
    required String type,
    required String title,
    String? description,
    DateTime? startedAt,
    DateTime? endedAt,
    String? metadata,
  }) async {
    final id = await _db.into(_db.healthEvents).insert(
          HealthEventsCompanion.insert(
            babyId: babyId,
            type: type,
            title: title,
            description: Value(description),
            startedAt: Value(startedAt),
            endedAt: Value(endedAt),
            metadata: Value(metadata),
          ),
        );
    return (await getHealthEvent(id))!;
  }

  Future<HealthEvent?> getHealthEvent(int id) {
    return (_db.select(_db.healthEvents)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<HealthEvent>> getHealthEventsForBaby(int babyId) {
    return (_db.select(_db.healthEvents)
          ..where((e) => e.babyId.equals(babyId))
          ..orderBy([(e) => OrderingTerm.desc(e.startedAt)]))
        .get();
  }

  Stream<List<HealthEvent>> watchHealthEventsForBaby(int babyId) {
    return (_db.select(_db.healthEvents)
          ..where((e) => e.babyId.equals(babyId))
          ..orderBy([(e) => OrderingTerm.desc(e.startedAt)]))
        .watch();
  }

  Future<List<HealthEvent>> getHealthEventsByType(int babyId, String type) {
    return (_db.select(_db.healthEvents)
          ..where((e) => e.babyId.equals(babyId) & e.type.equals(type))
          ..orderBy([(e) => OrderingTerm.desc(e.startedAt)]))
        .get();
  }

  Future<List<HealthEvent>> getActiveHealthEvents(int babyId) {
    return (_db.select(_db.healthEvents)
          ..where((e) => e.babyId.equals(babyId) & e.endedAt.isNull())
          ..orderBy([(e) => OrderingTerm.desc(e.startedAt)]))
        .get();
  }

  Future<void> updateHealthEvent(
    int id, {
    String? description,
    DateTime? endedAt,
    String? metadata,
  }) {
    return (_db.update(_db.healthEvents)..where((e) => e.id.equals(id))).write(
      HealthEventsCompanion(
        description:
            description != null ? Value(description) : const Value.absent(),
        endedAt: endedAt != null ? Value(endedAt) : const Value.absent(),
        metadata:
            metadata != null ? Value(metadata) : const Value.absent(),
      ),
    );
  }

  Future<void> markResolved(int id, DateTime resolvedAt) {
    return (_db.update(_db.healthEvents)..where((e) => e.id.equals(id)))
        .write(HealthEventsCompanion(endedAt: Value(resolvedAt)));
  }

  Future<void> deleteHealthEvent(int id) {
    return (_db.delete(_db.healthEvents)..where((e) => e.id.equals(id))).go();
  }
}
