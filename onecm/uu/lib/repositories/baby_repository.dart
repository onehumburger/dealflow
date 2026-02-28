import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class BabyRepository {
  final AppDatabase _db;
  BabyRepository(this._db);

  Future<Baby> createBaby({
    required String name,
    required DateTime dateOfBirth,
    String? gender,
    String? bloodType,
    String? photoUrl,
  }) async {
    final id = await _db.into(_db.babies).insert(BabiesCompanion.insert(
          name: name,
          dateOfBirth: dateOfBirth,
          gender: Value(gender),
          bloodType: Value(bloodType),
          photoUrl: Value(photoUrl),
        ));
    return (await getBaby(id))!;
  }

  Future<Baby?> getBaby(int id) {
    return (_db.select(_db.babies)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Baby>> getAllBabies() => _db.select(_db.babies).get();

  Future<void> updateBaby(int id,
      {String? name, String? gender, String? photoUrl}) {
    return (_db.update(_db.babies)..where((b) => b.id.equals(id))).write(
      BabiesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        gender: gender != null ? Value(gender) : const Value.absent(),
        photoUrl: photoUrl != null ? Value(photoUrl) : const Value.absent(),
      ),
    );
  }

  Stream<Baby> watchBaby(int id) {
    return (_db.select(_db.babies)..where((b) => b.id.equals(id)))
        .watchSingle();
  }
}
