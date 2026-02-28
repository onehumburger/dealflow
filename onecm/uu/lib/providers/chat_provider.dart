import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/repositories/chat_repository.dart';
import 'package:uu/services/ai/ai_provider.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(databaseProvider));
});

final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return const Stream.empty();
  return ref.watch(chatRepositoryProvider).watchMessagesForBaby(babyId);
});

/// Provider for the AIProvider instance.
/// Override this in tests with a fake implementation.
final aiProviderProvider = Provider<AIProvider>((ref) {
  throw UnimplementedError(
    'aiProviderProvider must be overridden with a real AIProvider implementation',
  );
});

/// Provider for the BabyContext builder results.
/// Override this in tests to avoid real database queries.
final babyContextProvider = FutureProvider<BabyContext?>((ref) async {
  final babyId = ref.watch(selectedBabyIdProvider);
  if (babyId == null) return null;
  // This will be overridden in the app with the real BabyContextBuilder
  return null;
});

/// Notifier that manages sending chat messages and getting AI responses.
class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _chatRepo;
  final AIProvider _aiProvider;
  final int babyId;
  final BabyContext? _context;

  ChatNotifier({
    required ChatRepository chatRepo,
    required AIProvider aiProvider,
    required this.babyId,
    required BabyContext? context,
  })  : _chatRepo = chatRepo,
        _aiProvider = aiProvider,
        _context = context,
        super(const AsyncData(null));

  bool get isSending => state is AsyncLoading;

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (state is AsyncLoading) return;

    state = const AsyncLoading();

    try {
      // 1. Persist user message
      await _chatRepo.addMessage(
        babyId: babyId,
        role: 'user',
        content: content.trim(),
      );

      // 2. Build conversation history from stored messages
      final storedMessages = await _chatRepo.getMessagesForBaby(babyId);
      // Keep only the most recent messages to stay within token limits
      final recentMessages = storedMessages.length > 50
          ? storedMessages.sublist(storedMessages.length - 50)
          : storedMessages;
      final aiMessages = recentMessages
          .map((m) => AIChatMessage(
                role: m.role,
                content: m.content,
                timestamp: m.createdAt,
              ))
          .toList();

      // 3. Get AI response
      final context = _context ??
          BabyContext(
            babyName: 'Baby',
            dateOfBirth: DateTime.now(),
            systemPrompt: 'You are a helpful baby care assistant.',
          );

      final response = await _aiProvider.chat(aiMessages, context);

      // 4. Persist assistant response
      await _chatRepo.addMessage(
        babyId: babyId,
        role: 'assistant',
        content: response,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      // Still persist an error message so the user sees something
      await _chatRepo.addMessage(
        babyId: babyId,
        role: 'assistant',
        content:
            'Sorry, I encountered an error. Please try again later.',
      );
      state = AsyncError(e, st);
    }
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<void>>((ref) {
  final babyId = ref.watch(selectedBabyIdProvider);
  final chatRepo = ref.watch(chatRepositoryProvider);
  final aiProvider = ref.watch(aiProviderProvider);
  final contextAsync = ref.watch(babyContextProvider);

  return ChatNotifier(
    chatRepo: chatRepo,
    aiProvider: aiProvider,
    babyId: babyId ?? 0,
    context: contextAsync.valueOrNull,
  );
});
