import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uu/services/ai/ai_provider.dart';

/// Abstraction over [GenerativeModel] to enable testing.
///
/// The `google_generative_ai` package marks [GenerativeModel] as `final`,
/// so it cannot be mocked directly. This thin wrapper can be.
abstract class GenerativeModelWrapper {
  Future<GenerateContentResponse> generateContent(
    Iterable<Content> content,
  );
}

/// Default wrapper that delegates to a real [GenerativeModel].
class _RealGenerativeModelWrapper implements GenerativeModelWrapper {
  final GenerativeModel _model;
  _RealGenerativeModelWrapper(this._model);

  @override
  Future<GenerateContentResponse> generateContent(
    Iterable<Content> content,
  ) =>
      _model.generateContent(content);
}

/// AI provider implementation using Google's Gemini API.
///
/// Requires a valid API key. The model defaults to `gemini-2.0-flash`
/// but can be overridden.
class GeminiProvider implements AIProvider {
  final String apiKey;
  final String modelName;
  GenerativeModelWrapper? _wrapper;

  GeminiProvider({
    required this.apiKey,
    this.modelName = 'gemini-2.0-flash',
  });

  /// Visible for testing: allows injecting a mock [GenerativeModelWrapper].
  GeminiProvider.withModel(GenerativeModelWrapper wrapper)
      : apiKey = '',
        modelName = '',
        _wrapper = wrapper;

  GenerativeModelWrapper get _model {
    _wrapper ??= _RealGenerativeModelWrapper(
      GenerativeModel(model: modelName, apiKey: apiKey),
    );
    return _wrapper!;
  }

  @override
  Future<String> chat(List<AIChatMessage> messages, BabyContext context) async {
    if (messages.isEmpty) {
      throw ArgumentError('Messages list cannot be empty');
    }

    final contents = <Content>[];

    // Add system prompt as first user context
    contents.add(Content('user', [TextPart(context.systemPrompt)]));
    contents.add(Content('model', [
      TextPart(
          'Understood. I\'m ready to help with ${context.babyName}\'s care.'),
    ]));

    // Add conversation history
    for (final msg in messages) {
      final role = msg.role == 'user' ? 'user' : 'model';
      contents.add(Content(role, [TextPart(msg.content)]));
    }

    try {
      final response = await _model.generateContent(contents);
      final text = response.text;
      if (text == null || text.isEmpty) {
        return 'I wasn\'t able to generate a response. Please try again.';
      }
      return _ensureDisclaimer(text);
    } on GenerativeAIException catch (e) {
      return 'I\'m having trouble connecting to the AI service. '
          'Please try again later. (${e.message})';
    } catch (e) {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    final prompt = _buildAnalysisPrompt(request);

    final contents = [
      Content('user', [TextPart(request.context.systemPrompt)]),
      Content('model', [
        TextPart(
          'Understood. I\'m ready to analyse ${request.context.babyName}\'s data.',
        ),
      ]),
      Content('user', [TextPart(prompt)]),
    ];

    try {
      final response = await _model.generateContent(contents);
      final text = response.text ?? 'Unable to complete analysis.';
      return _parseAnalysisResponse(text);
    } on GenerativeAIException catch (e) {
      return AnalysisResult(
        summary: 'Analysis unavailable: ${e.message}',
        insights: [],
      );
    } catch (e) {
      return AnalysisResult(
        summary: 'An unexpected error occurred during analysis.',
        insights: [],
      );
    }
  }

  String _buildAnalysisPrompt(AnalysisRequest request) {
    final typeLabel = switch (request.type) {
      AnalysisType.growthTrend => 'growth trend analysis',
      AnalysisType.feedingPattern => 'feeding pattern analysis',
      AnalysisType.sleepPattern => 'sleep pattern analysis',
      AnalysisType.developmentAssessment => 'developmental assessment',
    };

    return 'Please provide a $typeLabel based on the following data:\n'
        '${request.data.entries.map((e) => '${e.key}: ${e.value}').join('\n')}\n\n'
        'Format your response as:\n'
        'SUMMARY: <one paragraph summary>\n'
        'INSIGHTS:\n- <insight 1>\n- <insight 2>\n'
        'RECOMMENDATION: <optional recommendation>';
  }

  AnalysisResult _parseAnalysisResponse(String text) {
    String summary = text;
    List<String> insights = [];
    String? recommendation;

    // Try to parse structured response
    final summaryMatch =
        RegExp(r'SUMMARY:\s*(.+?)(?=INSIGHTS:|$)', dotAll: true)
            .firstMatch(text);
    if (summaryMatch != null) {
      summary = summaryMatch.group(1)!.trim();
    }

    final insightsMatch = RegExp(
      r'INSIGHTS:\s*(.+?)(?=RECOMMENDATION:|$)',
      dotAll: true,
    ).firstMatch(text);
    if (insightsMatch != null) {
      insights = insightsMatch
          .group(1)!
          .split('\n')
          .map((l) => l.replaceFirst(RegExp(r'^[-*]\s*'), '').trim())
          .where((l) => l.isNotEmpty)
          .toList();
    }

    final recMatch =
        RegExp(r'RECOMMENDATION:\s*(.+?)$', dotAll: true).firstMatch(text);
    if (recMatch != null) {
      recommendation = recMatch.group(1)!.trim();
    }

    return AnalysisResult(
      summary: summary,
      insights: insights,
      recommendation: recommendation,
    );
  }

  /// Ensure every response includes the medical disclaimer.
  String _ensureDisclaimer(String text) {
    if (text.contains(medicalDisclaimer)) {
      return text;
    }
    return '$text\n\n$medicalDisclaimer';
  }
}
