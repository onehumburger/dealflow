import 'package:drift/drift.dart';
import 'package:uu/database/app_database.dart';

class ChatRepository {
  final AppDatabase _db;
  ChatRepository(this._db);

  Future<int> addMessage({
    required int babyId,
    required String role,
    required String content,
    String? contextData,
  }) {
    return _db.into(_db.chatMessages).insert(ChatMessagesCompanion.insert(
          babyId: babyId,
          role: role,
          content: content,
          contextData: contextData != null
              ? Value(contextData)
              : const Value.absent(),
        ));
  }

  Future<List<ChatMessage>> getMessagesForBaby(int babyId) {
    return (_db.select(_db.chatMessages)
          ..where((m) => m.babyId.equals(babyId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  Stream<List<ChatMessage>> watchMessagesForBaby(int babyId) {
    return (_db.select(_db.chatMessages)
          ..where((m) => m.babyId.equals(babyId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .watch();
  }

  Future<void> deleteMessagesForBaby(int babyId) {
    return (_db.delete(_db.chatMessages)
          ..where((m) => m.babyId.equals(babyId)))
        .go();
  }
}
