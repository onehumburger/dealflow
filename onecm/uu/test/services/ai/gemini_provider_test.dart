import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uu/services/ai/ai_provider.dart';
import 'package:uu/services/ai/gemini_provider.dart';

class MockGenerativeModelWrapper extends Mock
    implements GenerativeModelWrapper {}

void main() {
  late MockGenerativeModelWrapper mockModel;
  late GeminiProvider provider;
  late BabyContext testContext;

  setUp(() {
    mockModel = MockGenerativeModelWrapper();
    provider = GeminiProvider.withModel(mockModel);
    testContext = BabyContext(
      babyName: 'Luna',
      dateOfBirth: DateTime.now().subtract(const Duration(days: 180)),
      gender: 'female',
      systemPrompt: 'You are a helpful baby care assistant for Luna.',
    );
  });

  group('AIProvider interface contract', () {
    test('GeminiProvider implements AIProvider', () {
      expect(provider, isA<AIProvider>());
    });

    test('AIChatMessage stores role, content, and timestamp', () {
      final now = DateTime.now();
      final msg = AIChatMessage(
        role: 'user',
        content: 'Hello',
        timestamp: now,
      );
      expect(msg.role, 'user');
      expect(msg.content, 'Hello');
      expect(msg.timestamp, now);
    });

    test('AIChatMessage defaults timestamp to now', () {
      final before = DateTime.now();
      final msg = AIChatMessage(role: 'user', content: 'Hi');
      final after = DateTime.now();
      expect(
        msg.timestamp
            .isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        msg.timestamp.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('BabyContext computes ageInDays', () {
      final ctx = BabyContext(
        babyName: 'Test',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 100)),
        systemPrompt: '',
      );
      expect(ctx.ageInDays, closeTo(100, 1));
    });

    test('BabyContext computes ageInMonths', () {
      final ctx = BabyContext(
        babyName: 'Test',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 180)),
        systemPrompt: '',
      );
      // ~5.9 months
      expect(ctx.ageInMonths, greaterThanOrEqualTo(5));
      expect(ctx.ageInMonths, lessThanOrEqualTo(6));
    });

    test('AnalysisResult includes medical disclaimer by default', () {
      final result = AnalysisResult(summary: 'All good');
      expect(result.disclaimer, medicalDisclaimer);
    });

    test('AnalysisResult can have custom disclaimer', () {
      final result = AnalysisResult(
        summary: 'All good',
        disclaimer: 'Custom disclaimer',
      );
      expect(result.disclaimer, 'Custom disclaimer');
    });

    test('AnalysisRequest holds type, data, and context', () {
      final request = AnalysisRequest(
        type: AnalysisType.growthTrend,
        data: {'weight': [3.5, 4.2, 5.1]},
        context: testContext,
      );
      expect(request.type, AnalysisType.growthTrend);
      expect(request.data['weight'], [3.5, 4.2, 5.1]);
      expect(request.context.babyName, 'Luna');
    });
  });

  group('GeminiProvider.chat', () {
    test('throws ArgumentError for empty messages', () {
      expect(
        () => provider.chat([], testContext),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('returns response text with disclaimer', () async {
      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          [
            Candidate(
              Content('model', [TextPart('Luna is doing great!')]),
              null,
              null,
              null,
              null,
            ),
          ],
          null,
        ),
      );

      final response = await provider.chat(
        [AIChatMessage(role: 'user', content: 'How is Luna doing?')],
        testContext,
      );

      expect(response, contains('Luna is doing great!'));
      expect(response, contains(medicalDisclaimer));
    });

    test('does not duplicate disclaimer if already present', () async {
      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          [
            Candidate(
              Content('model', [
                TextPart('Luna is doing great!\n\n$medicalDisclaimer'),
              ]),
              null,
              null,
              null,
              null,
            ),
          ],
          null,
        ),
      );

      final response = await provider.chat(
        [AIChatMessage(role: 'user', content: 'How is Luna doing?')],
        testContext,
      );

      // Should appear exactly once
      final occurrences = medicalDisclaimer.allMatches(response).length;
      expect(occurrences, 1);
    });

    test('handles empty response text gracefully', () async {
      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          [
            Candidate(
              Content('model', [TextPart('')]),
              null,
              null,
              null,
              null,
            ),
          ],
          null,
        ),
      );

      final response = await provider.chat(
        [AIChatMessage(role: 'user', content: 'Hello')],
        testContext,
      );

      expect(response, contains('try again'));
    });

    test('handles GenerativeAIException gracefully', () async {
      when(() => mockModel.generateContent(any())).thenThrow(
        ServerException('Service unavailable'),
      );

      final response = await provider.chat(
        [AIChatMessage(role: 'user', content: 'Hello')],
        testContext,
      );

      expect(response, contains('trouble connecting'));
    });

    test('handles unexpected exceptions gracefully', () async {
      when(() => mockModel.generateContent(any())).thenThrow(
        Exception('Network error'),
      );

      final response = await provider.chat(
        [AIChatMessage(role: 'user', content: 'Hello')],
        testContext,
      );

      expect(response, contains('unexpected error'));
    });

    test('passes conversation history to model', () async {
      final capturedContents = <List<Content>>[];

      when(() => mockModel.generateContent(any())).thenAnswer((invocation) {
        final contents =
            invocation.positionalArguments[0] as Iterable<Content>;
        capturedContents.add(contents.toList());
        return Future.value(GenerateContentResponse(
          [
            Candidate(
              Content('model', [TextPart('Response')]),
              null,
              null,
              null,
              null,
            ),
          ],
          null,
        ));
      });

      await provider.chat(
        [
          AIChatMessage(role: 'user', content: 'First message'),
          AIChatMessage(role: 'assistant', content: 'First reply'),
          AIChatMessage(role: 'user', content: 'Second message'),
        ],
        testContext,
      );

      expect(capturedContents, hasLength(1));
      final contents = capturedContents.first;
      // System prompt (user) + ack (model) + 3 messages = 5
      expect(contents.length, 5);
      // Check system prompt is first
      expect(contents[0].role, 'user');
      expect(
        contents[0].parts.whereType<TextPart>().first.text,
        testContext.systemPrompt,
      );
    });

    test('maps assistant role to model role', () async {
      final capturedContents = <List<Content>>[];

      when(() => mockModel.generateContent(any())).thenAnswer((invocation) {
        final contents =
            invocation.positionalArguments[0] as Iterable<Content>;
        capturedContents.add(contents.toList());
        return Future.value(GenerateContentResponse(
          [
            Candidate(
              Content('model', [TextPart('Response')]),
              null,
              null,
              null,
              null,
            ),
          ],
          null,
        ));
      });

      await provider.chat(
        [
          AIChatMessage(role: 'user', content: 'Hello'),
          AIChatMessage(role: 'assistant', content: 'Hi there'),
        ],
        testContext,
      );

      final contents = capturedContents.first;
      // The assistant message should be mapped to 'model'
      expect(contents[3].role, 'model');
    });
  });

  group('GeminiProvider.analyze', () {
    test('returns parsed analysis result', () async {
      const structuredResponse = '''
SUMMARY: Luna's growth is tracking well along the 50th percentile.
INSIGHTS:
- Weight gain is consistent at 200g per week
- Height is above average for age
RECOMMENDATION: Continue current feeding schedule.
''';

      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          [
            Candidate(
              Content('model', [TextPart(structuredResponse)]),
              null,
              null,
              null,
              null,
            ),
          ],
          null,
        ),
      );

      final result = await provider.analyze(AnalysisRequest(
        type: AnalysisType.growthTrend,
        data: {'weights': [3.5, 4.2, 5.1]},
        context: testContext,
      ));

      expect(result.summary, contains('50th percentile'));
      expect(result.insights, hasLength(2));
      expect(result.insights[0], contains('200g per week'));
      expect(result.recommendation, contains('feeding schedule'));
      expect(result.disclaimer, medicalDisclaimer);
    });

    test('handles unstructured response', () async {
      when(() => mockModel.generateContent(any())).thenAnswer(
        (_) async => GenerateContentResponse(
          [
            Candidate(
              Content('model', [TextPart('Everything looks fine.')]),
              null,
              null,
              null,
              null,
            ),
          ],
          null,
        ),
      );

      final result = await provider.analyze(AnalysisRequest(
        type: AnalysisType.feedingPattern,
        data: {'feedings_per_day': 8},
        context: testContext,
      ));

      expect(result.summary, contains('Everything looks fine'));
    });

    test('handles API error in analyze', () async {
      when(() => mockModel.generateContent(any())).thenThrow(
        ServerException('Rate limited'),
      );

      final result = await provider.analyze(AnalysisRequest(
        type: AnalysisType.sleepPattern,
        data: {},
        context: testContext,
      ));

      expect(result.summary, contains('unavailable'));
    });

    test('handles unexpected error in analyze', () async {
      when(() => mockModel.generateContent(any())).thenThrow(
        Exception('Something broke'),
      );

      final result = await provider.analyze(AnalysisRequest(
        type: AnalysisType.developmentAssessment,
        data: {},
        context: testContext,
      ));

      expect(result.summary, contains('unexpected error'));
    });
  });

  group('GeminiProvider construction', () {
    test('can be constructed with API key', () {
      final p = GeminiProvider(apiKey: 'test-key');
      expect(p, isA<AIProvider>());
      expect(p.apiKey, 'test-key');
      expect(p.modelName, 'gemini-2.0-flash');
    });

    test('can override model name', () {
      final p = GeminiProvider(apiKey: 'key', modelName: 'gemini-1.5-pro');
      expect(p.modelName, 'gemini-1.5-pro');
    });
  });

  group('Medical disclaimer', () {
    test('medicalDisclaimer constant is not empty', () {
      expect(medicalDisclaimer, isNotEmpty);
      expect(medicalDisclaimer, contains('not a substitute'));
      expect(medicalDisclaimer, contains('pediatrician'));
    });
  });
}
