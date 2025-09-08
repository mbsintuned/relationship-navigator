// Assessment domain models for the Flutter app
import 'package:freezed_annotation/freezed_annotation.dart';

part 'assessment_models.freezed.dart';
part 'assessment_models.g.dart';

@freezed
class Assessment with _$Assessment {
  const factory Assessment({
    required String id,
    required String name,
    required String category,
    required String version,
    required String description,
    required String instructions,
    required int timeLimitMinutes,
    required AssessmentScoring scoring,
    required Map<String, String> scaleLabels,
    required List<AssessmentQuestion> questions,
    required Map<String, List<double>> interpretationRanges,
    required Map<String, DimensionDescription> dimensionDescriptions,
    Map<String, String>? relationshipImplications,
  }) = _Assessment;

  factory Assessment.fromJson(Map<String, dynamic> json) =>
      _$AssessmentFromJson(json);
}

@freezed
class AssessmentScoring with _$AssessmentScoring {
  const factory AssessmentScoring({
    List<String>? dimensions,
    List<int>? scaleRange,
    int? questionsPerDimension,
    bool? reverseScoringEnabled,
    String? resultType,
  }) = _AssessmentScoring;

  factory AssessmentScoring.fromJson(Map<String, dynamic> json) =>
      _$AssessmentScoringFromJson(json);
}

@freezed
class AssessmentQuestion with _$AssessmentQuestion {
  const factory AssessmentQuestion({
    required String id,
    required String text,
    required String dimension,
    required bool reverseScored,
    String? category,
    List<String>? options,
    Map<String, dynamic>? metadata,
  }) = _AssessmentQuestion;

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) =>
      _$AssessmentQuestionFromJson(json);
}

@freezed
class DimensionDescription with _$DimensionDescription {
  const factory DimensionDescription({
    required String name,
    required String high,
    required String low,
    String? description,
  }) = _DimensionDescription;

  factory DimensionDescription.fromJson(Map<String, dynamic> json) =>
      _$DimensionDescriptionFromJson(json);
}

@freezed
class AssessmentResponse with _$AssessmentResponse {
  const factory AssessmentResponse({
    required String assessmentId,
    required String personId,
    required Map<String, int> responses,
    required DateTime startedAt,
    DateTime? completedAt,
    int? currentQuestionIndex,
    bool? isCompleted,
  }) = _AssessmentResponse;

  factory AssessmentResponse.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResponseFromJson(json);
}

@freezed
class AssessmentResult with _$AssessmentResult {
  const factory AssessmentResult({
    required String id,
    required String assessmentId,
    required String personId,
    required Map<String, int> rawResponses,
    required AssessmentScores calculatedScores,
    required double confidenceLevel,
    required DateTime completedAt,
    DateTime? expiresAt,
    String? notes,
  }) = _AssessmentResult;

  factory AssessmentResult.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResultFromJson(json);
}

@freezed
class AssessmentScores with _$AssessmentScores {
  const factory AssessmentScores({
    // Big Five scores
    double? openness,
    double? conscientiousness,
    double? extraversion,
    double? agreeableness,
    double? neuroticism,
    
    // MBTI scores
    String? mbtiType,
    double? eiScore,
    double? snScore,
    double? tfScore,
    double? jpScore,
    
    // Enneagram scores
    int? enneagramType,
    String? wing,
    String? instinctVariant,
    
    // DISC scores
    double? dominance,
    double? influence,
    double? steadiness,
    double? compliance,
    
    // Attachment scores
    String? attachmentStyle,
    Map<String, double>? attachmentScores,
    
    // Emotional Intelligence scores
    double? selfAwareness,
    double? selfManagement,
    double? socialAwareness,
    double? relationshipManagement,
    
    // Generic scores for extensibility
    Map<String, double>? rawScores,
    Map<String, double>? percentiles,
    Map<String, String>? interpretations,
  }) = _AssessmentScores;

  factory AssessmentScores.fromJson(Map<String, dynamic> json) =>
      _$AssessmentScoresFromJson(json);
}

@freezed
class AssessmentSession with _$AssessmentSession {
  const factory AssessmentSession({
    required String id,
    required String assessmentId,
    required String personId,
    required AssessmentSessionStatus status,
    required DateTime startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    int? currentQuestionIndex,
    int? totalQuestions,
    Map<String, int>? responses,
    int? timeSpentMinutes,
    List<String>? flaggedQuestions,
  }) = _AssessmentSession;

  factory AssessmentSession.fromJson(Map<String, dynamic> json) =>
      _$AssessmentSessionFromJson(json);
}

enum AssessmentSessionStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  abandoned,
  expired,
}

enum AssessmentCategory {
  personality,
  relational,
  emotional,
  alternative,
}

enum AssessmentDifficulty {
  beginner,
  intermediate,
  advanced,
}

// Assessment progress tracking
@freezed
class AssessmentProgress with _$AssessmentProgress {
  const factory AssessmentProgress({
    required int currentQuestion,
    required int totalQuestions,
    required double progressPercentage,
    required int estimatedTimeRemainingMinutes,
    int? questionsAnswered,
    int? questionsSkipped,
    bool? canGoBack,
    bool? showProgress,
  }) = _AssessmentProgress;

  factory AssessmentProgress.fromJson(Map<String, dynamic> json) =>
      _$AssessmentProgressFromJson(json);
}

// Assessment recommendations
@freezed
class AssessmentRecommendation with _$AssessmentRecommendation {
  const factory AssessmentRecommendation({
    required String assessmentId,
    required String title,
    required String description,
    required String reason,
    required int priorityScore,
    required Duration estimatedTime,
    bool? isCompleted,
    DateTime? lastTaken,
    List<String>? benefits,
    List<String>? prerequisites,
  }) = _AssessmentRecommendation;

  factory AssessmentRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AssessmentRecommendationFromJson(json);
}

// Assessment validation
class AssessmentValidator {
  static bool isResponseValid(int response, List<int> scaleRange) {
    return response >= scaleRange.first && response <= scaleRange.last;
  }

  static bool isSessionComplete(AssessmentSession session) {
    return session.status == AssessmentSessionStatus.completed &&
           session.responses?.length == session.totalQuestions;
  }

  static bool isSessionExpired(AssessmentSession session, int timeoutMinutes) {
    if (session.startedAt == null) return false;
    final elapsed = DateTime.now().difference(session.startedAt).inMinutes;
    return elapsed > timeoutMinutes;
  }

  static double calculateCompletionPercentage(AssessmentSession session) {
    if (session.totalQuestions == null || session.totalQuestions == 0) {
      return 0.0;
    }
    
    final answered = session.responses?.length ?? 0;
    return (answered / session.totalQuestions!) * 100.0;
  }

  static List<String> validateResponses(
    Map<String, int> responses,
    Assessment assessment,
  ) {
    final errors = <String>[];
    
    // Check if all questions are answered
    final expectedQuestions = assessment.questions.map((q) => q.id).toSet();
    final answeredQuestions = responses.keys.toSet();
    final missing = expectedQuestions.difference(answeredQuestions);
    
    if (missing.isNotEmpty) {
      errors.add('Missing responses for questions: ${missing.join(', ')}');
    }
    
    // Check if responses are within valid range
    final scaleRange = assessment.scoring.scaleRange ?? [1, 5];
    for (final entry in responses.entries) {
      if (!isResponseValid(entry.value, scaleRange)) {
        errors.add('Invalid response for ${entry.key}: ${entry.value}');
      }
    }
    
    return errors;
  }
}

// Assessment analytics
class AssessmentAnalytics {
  static Map<String, double> calculateDimensionAverages(
    List<AssessmentResult> results,
    String assessmentType,
  ) {
    if (results.isEmpty) return {};
    
    final averages = <String, double>{};
    
    switch (assessmentType) {
      case 'big_five':
        averages['openness'] = results
            .map((r) => r.calculatedScores.openness ?? 0)
            .reduce((a, b) => a + b) / results.length;
        averages['conscientiousness'] = results
            .map((r) => r.calculatedScores.conscientiousness ?? 0)
            .reduce((a, b) => a + b) / results.length;
        averages['extraversion'] = results
            .map((r) => r.calculatedScores.extraversion ?? 0)
            .reduce((a, b) => a + b) / results.length;
        averages['agreeableness'] = results
            .map((r) => r.calculatedScores.agreeableness ?? 0)
            .reduce((a, b) => a + b) / results.length;
        averages['neuroticism'] = results
            .map((r) => r.calculatedScores.neuroticism ?? 0)
            .reduce((a, b) => a + b) / results.length;
        break;
        
      case 'attachment':
        if (results.isNotEmpty && results.first.calculatedScores.attachmentScores != null) {
          final attachmentScores = results.first.calculatedScores.attachmentScores!;
          for (final key in attachmentScores.keys) {
            averages[key] = results
                .map((r) => r.calculatedScores.attachmentScores?[key] ?? 0)
                .reduce((a, b) => a + b) / results.length;
          }
        }
        break;
    }
    
    return averages;
  }

  static List<String> identifyTrends(List<AssessmentResult> historicalResults) {
    final trends = <String>[];
    
    if (historicalResults.length < 2) return trends;
    
    // Sort by completion date
    historicalResults.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    
    // Analyze Big Five trends if available
    final first = historicalResults.first.calculatedScores;
    final last = historicalResults.last.calculatedScores;
    
    if (first.openness != null && last.openness != null) {
      final change = last.openness! - first.openness!;
      if (change.abs() > 0.5) {
        trends.add(change > 0 
            ? 'Increasing openness to new experiences'
            : 'Becoming more conventional in preferences');
      }
    }
    
    if (first.conscientiousness != null && last.conscientiousness != null) {
      final change = last.conscientiousness! - first.conscientiousness!;
      if (change.abs() > 0.5) {
        trends.add(change > 0
            ? 'Becoming more organized and disciplined'
            : 'Becoming more flexible and spontaneous');
      }
    }
    
    // Add more trend analysis for other dimensions...
    
    return trends;
  }

  static double calculateAssessmentReliability(AssessmentResult result) {
    // Simple reliability estimate based on response consistency
    // In a real implementation, this would use more sophisticated metrics
    return result.confidenceLevel;
  }
}

// Assessment utilities
extension AssessmentExtensions on Assessment {
  bool get isPersonalityAssessment => category == 'personality';
  bool get isRelationalAssessment => category == 'relational';
  bool get isEmotionalAssessment => category == 'emotional';
  
  Duration get estimatedDuration => Duration(minutes: timeLimitMinutes);
  
  bool get hasTimeLimit => timeLimitMinutes > 0;
  
  List<String> get dimensionNames => 
      scoring.dimensions ?? dimensionDescriptions.keys.toList();
}

extension AssessmentResultExtensions on AssessmentResult {
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  
  bool get isRecentlyCompleted => 
      DateTime.now().difference(completedAt).inDays < 7;
  
  Map<String, dynamic> get primaryScores {
    final scores = <String, dynamic>{};
    
    // Add Big Five scores if available
    if (calculatedScores.openness != null) {
      scores['Openness'] = calculatedScores.openness;
    }
    if (calculatedScores.conscientiousness != null) {
      scores['Conscientiousness'] = calculatedScores.conscientiousness;
    }
    if (calculatedScores.extraversion != null) {
      scores['Extraversion'] = calculatedScores.extraversion;
    }
    if (calculatedScores.agreeableness != null) {
      scores['Agreeableness'] = calculatedScores.agreeableness;
    }
    if (calculatedScores.neuroticism != null) {
      scores['Neuroticism'] = calculatedScores.neuroticism;
    }
    
    // Add attachment style if available
    if (calculatedScores.attachmentStyle != null) {
      scores['Attachment Style'] = calculatedScores.attachmentStyle;
    }
    
    // Add MBTI type if available
    if (calculatedScores.mbtiType != null) {
      scores['MBTI Type'] = calculatedScores.mbtiType;
    }
    
    return scores;
  }
}
