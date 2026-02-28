import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uu/database/app_database.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/chat_provider.dart';
import 'package:uu/providers/database_provider.dart';
import 'package:uu/repositories/chat_repository.dart';
import 'package:uu/screens/chat/chat_screen.dart';
import 'package:uu/screens/chat/widgets/chat_bubble.dart';
import 'package:uu/screens/chat/widgets/quick_concern_chips.dart';
import 'package:uu/services/ai/ai_provider.dart';

/// A fake AIProvider for testing that returns canned responses.
class FakeAIProvider implements AIProvider {
  String nextResponse = 'Test AI response.\n\n$medicalDisclaimer';
  bool chatCalled = false;
  List<AIChatMessage>? lastMessages;
  BabyContext? lastContext;
  bool shouldThrow = false;

  @override
  Future<String> chat(List<AIChatMessage> messages, BabyContext context) async {
    chatCalled = true;
    lastMessages = messages;
    lastContext = context;
    if (shouldThrow) {
      throw Exception('AI service unavailable');
    }
    return nextResponse;
  }

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    return AnalysisResult(summary: 'Test analysis');
  }
}

void main() {
  group('ChatBubble', () {
    testWidgets('renders user message with right alignment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              content: 'Hello from user',
              role: 'user',
              timestamp: DateTime(2026, 3, 1, 10, 30),
            ),
          ),
        ),
      );

      expect(find.text('Hello from user'), findsOneWidget);
      // User messages should NOT show 'AI Assistant' label
      expect(find.text('AI Assistant'), findsNothing);
      // Should show timestamp
      expect(find.text('10:30'), findsOneWidget);
    });

    testWidgets('renders assistant message with left alignment and label',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              content: 'Hello from assistant',
              role: 'assistant',
              timestamp: DateTime(2026, 3, 1, 10, 31),
            ),
          ),
        ),
      );

      expect(find.text('Hello from assistant'), findsOneWidget);
      expect(find.text('AI Assistant'), findsOneWidget);
      expect(find.text('10:31'), findsOneWidget);
    });

    testWidgets('shows medical disclaimer in a styled box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ChatBubble(
                content: 'Some advice.\n\n$medicalDisclaimer',
                role: 'assistant',
                timestamp: DateTime(2026, 3, 1, 10, 32),
              ),
            ),
          ),
        ),
      );

      // The main content should be visible
      expect(find.text('Some advice.'), findsOneWidget);
      // The disclaimer should be visible in its own box
      expect(find.text(medicalDisclaimer), findsOneWidget);
      // Info icon for disclaimer
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('user message does not show disclaimer box', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatBubble(
              content: 'Just a user message',
              role: 'user',
              timestamp: DateTime(2026, 3, 1, 10, 33),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsNothing);
    });
  });

  group('QuickConcernChips', () {
    testWidgets('displays all 5 concern chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickConcernChips(
              onConcernTapped: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Sleep'), findsOneWidget);
      expect(find.text('Feeding'), findsOneWidget);
      expect(find.text('Skin/Rash'), findsOneWidget);
      expect(find.text('Behavior'), findsOneWidget);
      expect(find.text('Growth'), findsOneWidget);
      expect(find.text('Quick concerns'), findsOneWidget);
    });

    testWidgets('tapping a chip calls onConcernTapped with message',
        (tester) async {
      String? tappedMessage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickConcernChips(
              onConcernTapped: (msg) => tappedMessage = msg,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sleep'));
      await tester.pump();

      expect(tappedMessage, isNotNull);
      expect(tappedMessage, contains('sleep'));
    });

    testWidgets('tapping Feeding chip generates feeding concern',
        (tester) async {
      String? tappedMessage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickConcernChips(
              onConcernTapped: (msg) => tappedMessage = msg,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Feeding'));
      await tester.pump();

      expect(tappedMessage, contains('feeding'));
    });

    testWidgets('tapping Skin/Rash chip generates skin concern',
        (tester) async {
      String? tappedMessage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickConcernChips(
              onConcernTapped: (msg) => tappedMessage = msg,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Skin/Rash'));
      await tester.pump();

      expect(tappedMessage, contains('skin/rash'));
    });
  });

  group('ChatScreen', () {
    late AppDatabase db;
    late FakeAIProvider fakeAI;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      fakeAI = FakeAIProvider();
    });

    tearDown(() async => await db.close());

    Widget buildTestWidget({
      int? babyId = 1,
      List<ChatMessage> overrideMessages = const [],
    }) {
      return ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          selectedBabyIdProvider.overrideWith((ref) => babyId),
          aiProviderProvider.overrideWithValue(fakeAI),
          babyContextProvider.overrideWith((ref) async => BabyContext(
                babyName: 'Luna',
                dateOfBirth: DateTime(2025, 6, 15),
                systemPrompt: 'You are a test assistant.',
              )),
          // Always override to avoid Drift timer issues in tests
          chatMessagesProvider.overrideWith(
            (ref) => Stream.value(overrideMessages),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ChatScreen()),
        ),
      );
    }

    testWidgets('shows "select baby" message when no baby selected',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(babyId: null));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please select a baby first.'), findsOneWidget);
    });

    testWidgets('shows quick concern chips', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Quick concerns'), findsOneWidget);
      expect(find.text('Sleep'), findsOneWidget);
      expect(find.text('Feeding'), findsOneWidget);
    });

    testWidgets('shows empty state when no messages', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(
          find.text('Ask me anything about your baby!'), findsOneWidget);
      expect(
        find.text('Tap a quick concern above or type a message below.'),
        findsOneWidget,
      );
    });

    testWidgets('shows text input field and send button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows messages from database', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(buildTestWidget(
        overrideMessages: [
          ChatMessage(
            id: 1,
            babyId: 1,
            role: 'user',
            content: 'How is my baby doing?',
            createdAt: now,
          ),
          ChatMessage(
            id: 2,
            babyId: 1,
            role: 'assistant',
            content: 'Your baby Luna is doing great!\n\n$medicalDisclaimer',
            createdAt: now.add(const Duration(seconds: 1)),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('How is my baby doing?'), findsOneWidget);
      expect(find.text('Your baby Luna is doing great!'), findsOneWidget);
      expect(find.text(medicalDisclaimer), findsOneWidget);
      expect(find.text('AI Assistant'), findsOneWidget);
    });

    testWidgets('sending a message clears the text field', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Type a message
      await tester.enterText(find.byType(TextField), 'Hello baby assistant');
      await tester.pump();

      // Tap send
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 100));

      // Text field should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('sending a message calls AI provider', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Type and send
      await tester.enterText(
          find.byType(TextField), 'Is my baby eating enough?');
      await tester.tap(find.byIcon(Icons.send));

      // Let the async operations complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      expect(fakeAI.chatCalled, isTrue);
    });

    testWidgets('tapping a quick concern chip sends a message',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the Sleep concern chip
      await tester.tap(find.text('Sleep'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Should have called the AI
      expect(fakeAI.chatCalled, isTrue);
      // The message should contain 'sleep'
      expect(
        fakeAI.lastMessages?.any((m) => m.content.contains('sleep')),
        isTrue,
      );
    });

    testWidgets('shows messages persisted to database after send',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Type and send
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byIcon(Icons.send));

      // Wait for async operations (persist + AI call + persist response)
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify messages were persisted to DB
      final messages = await db.select(db.chatMessages).get();
      expect(messages.length, greaterThanOrEqualTo(2));
      expect(messages.first.role, 'user');
      expect(messages.first.content, 'Test message');
      expect(messages.last.role, 'assistant');
    });

    testWidgets('empty message is not sent', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Try to send empty message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeAI.chatCalled, isFalse);
    });

    testWidgets('whitespace-only message is not sent', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeAI.chatCalled, isFalse);
    });

    testWidgets('multiple messages display in order', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(buildTestWidget(
        overrideMessages: [
          ChatMessage(
            id: 1,
            babyId: 1,
            role: 'user',
            content: 'First message',
            createdAt: now,
          ),
          ChatMessage(
            id: 2,
            babyId: 1,
            role: 'assistant',
            content: 'First response',
            createdAt: now.add(const Duration(seconds: 1)),
          ),
          ChatMessage(
            id: 3,
            babyId: 1,
            role: 'user',
            content: 'Second message',
            createdAt: now.add(const Duration(seconds: 2)),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('First message'), findsOneWidget);
      expect(find.text('First response'), findsOneWidget);
      expect(find.text('Second message'), findsOneWidget);
    });

    testWidgets('chat bubble shows correct alignment', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(buildTestWidget(
        overrideMessages: [
          ChatMessage(
            id: 1,
            babyId: 1,
            role: 'user',
            content: 'User message here',
            createdAt: now,
          ),
          ChatMessage(
            id: 2,
            babyId: 1,
            role: 'assistant',
            content: 'Assistant message here',
            createdAt: now.add(const Duration(seconds: 1)),
          ),
        ],
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Find ChatBubble widgets
      final bubbles = tester.widgetList<ChatBubble>(
        find.byType(ChatBubble),
      );
      expect(bubbles.length, 2);

      final userWidget = bubbles.first;
      expect(userWidget.role, 'user');
      expect(userWidget.isUser, isTrue);

      final assistantWidget = bubbles.last;
      expect(assistantWidget.role, 'assistant');
      expect(assistantWidget.isUser, isFalse);
    });
  });

  group('ChatRepository integration', () {
    late AppDatabase db;
    late ChatRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      repo = ChatRepository(db);
    });

    tearDown(() async => await db.close());

    test('addMessage persists to database', () async {
      await repo.addMessage(
        babyId: 1,
        role: 'user',
        content: 'Test message',
      );

      final messages = await db.select(db.chatMessages).get();
      expect(messages.length, 1);
      expect(messages.first.role, 'user');
      expect(messages.first.content, 'Test message');
      expect(messages.first.babyId, 1);
    });

    test('getMessagesForBaby returns messages in order', () async {
      await repo.addMessage(babyId: 1, role: 'user', content: 'First');
      // Small delay so createdAt is different
      await Future.delayed(const Duration(milliseconds: 10));
      await repo.addMessage(
          babyId: 1, role: 'assistant', content: 'Second');

      final messages = await repo.getMessagesForBaby(1);
      expect(messages.length, 2);
      expect(messages[0].content, 'First');
      expect(messages[1].content, 'Second');
    });

    test('getMessagesForBaby filters by babyId', () async {
      // Insert a second baby
      await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Stella',
            dateOfBirth: DateTime(2025, 9, 1),
          ));

      await repo.addMessage(babyId: 1, role: 'user', content: 'Luna msg');
      await repo.addMessage(babyId: 2, role: 'user', content: 'Stella msg');

      final lunaMessages = await repo.getMessagesForBaby(1);
      expect(lunaMessages.length, 1);
      expect(lunaMessages.first.content, 'Luna msg');

      final stellaMessages = await repo.getMessagesForBaby(2);
      expect(stellaMessages.length, 1);
      expect(stellaMessages.first.content, 'Stella msg');
    });

    test('deleteMessagesForBaby removes only that baby messages', () async {
      await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Stella',
            dateOfBirth: DateTime(2025, 9, 1),
          ));

      await repo.addMessage(babyId: 1, role: 'user', content: 'Luna msg');
      await repo.addMessage(babyId: 2, role: 'user', content: 'Stella msg');

      await repo.deleteMessagesForBaby(1);

      final lunaMessages = await repo.getMessagesForBaby(1);
      expect(lunaMessages, isEmpty);

      final stellaMessages = await repo.getMessagesForBaby(2);
      expect(stellaMessages.length, 1);
    });

    test('watchMessagesForBaby emits updates', () async {
      final stream = repo.watchMessagesForBaby(1);

      // First emission should be empty
      final firstEmission = await stream.first;
      expect(firstEmission, isEmpty);
    });
  });

  group('ChatNotifier', () {
    late AppDatabase db;
    late FakeAIProvider fakeAI;
    late ChatRepository repo;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.babies).insert(BabiesCompanion.insert(
            name: 'Luna',
            dateOfBirth: DateTime(2025, 6, 15),
          ));
      fakeAI = FakeAIProvider();
      repo = ChatRepository(db);
    });

    tearDown(() async => await db.close());

    test('sendMessage persists user and assistant messages', () async {
      final notifier = ChatNotifier(
        chatRepo: repo,
        aiProvider: fakeAI,
        babyId: 1,
        context: BabyContext(
          babyName: 'Luna',
          dateOfBirth: DateTime(2025, 6, 15),
          systemPrompt: 'Test prompt',
        ),
      );

      await notifier.sendMessage('Hello');

      final messages = await repo.getMessagesForBaby(1);
      expect(messages.length, 2);
      expect(messages[0].role, 'user');
      expect(messages[0].content, 'Hello');
      expect(messages[1].role, 'assistant');
      expect(messages[1].content, fakeAI.nextResponse);
    });

    test('sendMessage ignores empty content', () async {
      final notifier = ChatNotifier(
        chatRepo: repo,
        aiProvider: fakeAI,
        babyId: 1,
        context: null,
      );

      await notifier.sendMessage('');
      await notifier.sendMessage('   ');

      final messages = await repo.getMessagesForBaby(1);
      expect(messages, isEmpty);
      expect(fakeAI.chatCalled, isFalse);
    });

    test('sendMessage persists error response on AI failure', () async {
      fakeAI.shouldThrow = true;
      final notifier = ChatNotifier(
        chatRepo: repo,
        aiProvider: fakeAI,
        babyId: 1,
        context: null,
      );

      await notifier.sendMessage('Hello');

      final messages = await repo.getMessagesForBaby(1);
      expect(messages.length, 2);
      expect(messages[0].role, 'user');
      expect(messages[1].role, 'assistant');
      expect(messages[1].content, contains('error'));
    });
  });
}
