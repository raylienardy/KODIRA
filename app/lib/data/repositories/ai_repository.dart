import '../sources/remote/ai_source.dart';

class AiRepository {
  final AiSource _source;

  AiRepository(this._source);

  Future<String> getHint({
    required int levelId,
    required String topic,
    required String userCode,
    required int hintLevel,
  }) async {
    final data = await _source.requestHint(
      levelId: levelId,
      topic: topic,
      userCode: userCode,
      hintLevel: hintLevel,
    );
    return data['hint'] is String ? data['hint'] as String : '';
  }

  Future<String> getFeedback({
    required int levelId,
    required String topic,
    required String userCode,
    required String expectedAnswer,
    required bool isCorrect,
    String? classId,
  }) async {
    final data = await _source.requestFeedback(
      levelId: levelId,
      topic: topic,
      userCode: userCode,
      expectedAnswer: expectedAnswer,
      isCorrect: isCorrect,
      classId: classId,
    );
    return data['feedback'] is String ? data['feedback'] as String : '';
  }

  Future<List<Map<String, dynamic>>> generateQuiz({
    required int levelId,
    required String topic,
    required String language,
    required int questionCount,
    String? context,
    String? mode,
    String? classId,
    String? userId,
    String? sessionNonce,
  }) {
    return _source.requestQuiz(
      levelId: levelId,
      topic: topic,
      language: language,
      questionCount: questionCount,
      context: context,
      mode: mode,
      classId: classId,
      userId: userId,
      sessionNonce: sessionNonce,
    );
  }
}
