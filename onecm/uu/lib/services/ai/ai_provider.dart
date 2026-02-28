/// Pluggable AI provider interface for baby growth assistant chat.
///
/// Implementations can target different backends (Gemini, OpenAI, etc.)
/// while keeping the rest of the app backend-agnostic.
library;

/// A single message in a conversation.
class AIChatMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;

  AIChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Contextual data about a baby, assembled by [BabyContextBuilder]
/// and passed to the AI provider so it can give personalised responses.
class BabyContext {
  final String babyName;
  final DateTime dateOfBirth;
  final String? gender;
  final String systemPrompt;

  BabyContext({
    required this.babyName,
    required this.dateOfBirth,
    this.gender,
    required this.systemPrompt,
  });

  int get ageInDays => DateTime.now().difference(dateOfBirth).inDays;
  int get ageInMonths => (ageInDays / 30.44).floor();
}

/// The type of analysis to request from the AI provider.
enum AnalysisType {
  growthTrend,
  feedingPattern,
  sleepPattern,
  developmentAssessment,
}

/// A request for AI-powered analysis of baby data.
class AnalysisRequest {
  final AnalysisType type;
  final Map<String, dynamic> data;
  final BabyContext context;

  AnalysisRequest({
    required this.type,
    required this.data,
    required this.context,
  });
}

/// Result of an AI analysis.
class AnalysisResult {
  final String summary;
  final List<String> insights;
  final String? recommendation;
  final String disclaimer;

  AnalysisResult({
    required this.summary,
    this.insights = const [],
    this.recommendation,
    this.disclaimer = medicalDisclaimer,
  });
}

/// Medical disclaimer appended to every health-related response.
const String medicalDisclaimer =
    'This information is for general guidance only and is not a substitute '
    'for professional medical advice. Always consult your pediatrician or '
    'healthcare provider for medical concerns.';

/// Abstract interface for AI providers.
///
/// Implementations must handle:
/// - Building conversation context from [BabyContext]
/// - Appending medical disclaimers to health-related responses
/// - Graceful error handling when the API is unavailable
abstract class AIProvider {
  /// Send a chat message and get a reply.
  ///
  /// [messages] is the conversation history.
  /// [context] provides baby-specific context for personalised responses.
  Future<String> chat(List<AIChatMessage> messages, BabyContext context);

  /// Analyse baby data and return structured insights.
  Future<AnalysisResult> analyze(AnalysisRequest request);
}
