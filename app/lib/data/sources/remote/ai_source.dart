import 'package:supabase_flutter/supabase_flutter.dart';

class AiSource {
  final SupabaseClient _client;

  AiSource(this._client);

  Future<Map<String, dynamic>> requestHint({
    required int levelId,
    required String topic,
    required String userCode,
    required int hintLevel,
  }) async {
    return _invokeMap('ai-hint', {
      'levelId': levelId,
      'topic': topic,
      'userCode': userCode,
      'hintLevel': hintLevel,
    }, fallbackMessage: 'Gagal memuat hint');
  }

  Future<Map<String, dynamic>> requestFeedback({
    required int levelId,
    required String topic,
    required String userCode,
    required String expectedAnswer,
    required bool isCorrect,
  }) async {
    return _invokeMap('ai-feedback', {
      'levelId': levelId,
      'topic': topic,
      'userCode': userCode,
      'expectedAnswer': expectedAnswer,
      'isCorrect': isCorrect,
    }, fallbackMessage: 'Gagal memuat feedback');
  }

  Future<List<Map<String, dynamic>>> requestQuiz({
    required int levelId,
    required String topic,
    required String language,
    required int questionCount,
    String? context,
  }) async {
    final response = await _invokeFunction('ai-generate-quiz', {
      'levelId': levelId,
      'topic': topic,
      'language': language,
      'questionCount': questionCount,
      'context': ?context,
    });
    final data = _validatedData(response, 'Gagal generate soal');
    if (data is! Map) {
      throw AiException(response.status, 'Format soal AI tidak valid.');
    }
    final questions = data['questions'];
    if (questions is! List) {
      throw AiException(response.status, 'Format soal AI tidak valid.');
    }
    return questions
        .whereType<Map>()
        .map((question) => Map<String, dynamic>.from(question))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _invokeMap(
    String functionName,
    Map<String, Object?> body, {
    required String fallbackMessage,
  }) async {
    final response = await _invokeFunction(functionName, body);
    final data = _validatedData(response, fallbackMessage);
    if (data is! Map) {
      throw AiException(response.status, 'Format respons AI tidak valid.');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<FunctionResponse> _invokeFunction(
    String functionName,
    Map<String, Object?> body,
  ) async {
    try {
      return await _client.functions.invoke(functionName, body: body);
    } on FunctionException catch (error) {
      final details = error.details;
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : error.reasonPhrase ?? 'Permintaan ke layanan AI gagal.';
      throw AiException(error.status, message);
    } catch (_) {
      throw AiException(0, 'Layanan AI tidak dapat dijangkau.');
    }
  }

  Object? _validatedData(FunctionResponse response, String fallbackMessage) {
    if (response.status != 200) {
      final data = response.data;
      final error = data is Map ? data['error'] : null;
      throw AiException(
        response.status,
        error is String && error.isNotEmpty ? error : fallbackMessage,
      );
    }
    return response.data;
  }
}

class AiException implements Exception {
  final int statusCode;
  final String message;

  AiException(this.statusCode, this.message);

  @override
  String toString() => 'AiException($statusCode): $message';
}
