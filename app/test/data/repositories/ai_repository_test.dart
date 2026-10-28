import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/ai_repository.dart';
import 'package:kodira/data/sources/remote/ai_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AiRepository', () {
    late _FakeAiSource source;
    late AiRepository repository;

    setUp(() {
      source = _FakeAiSource();
      repository = AiRepository(source);
    });

    test('getHint parses hint response as a string', () async {
      source.hintResponse = {'hint': 'Periksa urutan operasi.'};

      final result = await repository.getHint(
        levelId: 1,
        topic: 'Operator aritmatika',
        userCode: 'int x = 2;',
        hintLevel: 1,
      );

      expect(result, 'Periksa urutan operasi.');
      expect(source.lastHintLevel, 1);
    });

    test('getHint propagates AiException from a failed source request', () {
      source.error = AiException(400, 'Field topic tidak valid.');

      expect(
        () => repository.getHint(
          levelId: 1,
          topic: 'topik',
          userCode: '',
          hintLevel: 1,
        ),
        throwsA(isA<AiException>()),
      );
    });

    test('getFeedback parses feedback response', () async {
      source.feedbackResponse = {'feedback': 'Coba cek tipe data.'};

      final result = await repository.getFeedback(
        levelId: 1,
        topic: 'Variabel',
        userCode: 'int nilai = "5";',
        expectedAnswer: 'Gunakan nilai integer.',
        isCorrect: false,
      );

      expect(result, 'Coba cek tipe data.');
    });

    test('getFeedback sends correct answers for positive feedback', () async {
      source.feedbackResponse = {'feedback': 'Jawabanmu tepat.'};

      final result = await repository.getFeedback(
        levelId: 2,
        topic: 'Percabangan',
        userCode: '',
        expectedAnswer: 'if else',
        isCorrect: true,
      );

      expect(result, 'Jawabanmu tepat.');
      expect(source.lastFeedbackCorrect, isTrue);
    });

    test('generateQuiz returns questions from source', () async {
      source.quizResponse = [
        {
          'question': 'Hasil 2 + 3?',
          'options': ['4', '5', '6', '7'],
          'answer': 1,
          'explanation': 'Dua ditambah tiga sama dengan lima.',
        },
      ];

      final result = await repository.generateQuiz(
        levelId: 1,
        topic: 'Operator aritmatika',
        language: 'cpp',
        questionCount: 1,
      );

      expect(result, hasLength(1));
      expect(result.single['answer'], 1);
    });

    test('generateQuiz propagates source errors', () {
      source.error = AiException(502, 'Gagal generate soal');

      expect(
        () => repository.generateQuiz(
          levelId: 1,
          topic: 'Operator',
          language: 'cpp',
          questionCount: 3,
        ),
        throwsA(isA<AiException>()),
      );
    });

    test('AiRepository can be substituted by a test fake', () async {
      final fake = _FakeAiRepository();

      expect(
        await fake.getHint(
          levelId: 1,
          topic: 'Variabel',
          userCode: '',
          hintLevel: 1,
        ),
        'hint dari fake',
      );
    });

    test(
      'request bodies contain no user identifiers or profile fields',
      () async {
        final client = _RecordingSupabaseClient();
        final aiSource = AiSource(client);

        await aiSource.requestHint(
          levelId: 1,
          topic: 'Variabel',
          userCode: 'int x = 5;',
          hintLevel: 1,
        );
        expect(
          client.lastBody!.keys,
          containsAll(['levelId', 'topic', 'userCode', 'hintLevel']),
        );
        expect(client.lastBody!.keys, isNot(contains('userId')));
        expect(client.lastBody!.keys, isNot(contains('nim')));
        expect(client.lastBody!.keys, isNot(contains('name')));

        await aiSource.requestFeedback(
          levelId: 1,
          topic: 'Variabel',
          userCode: '',
          expectedAnswer: 'integer',
          isCorrect: false,
        );
        expect(
          client.lastBody!.keys,
          containsAll(['expectedAnswer', 'isCorrect']),
        );
        expect(client.lastBody!.keys, isNot(contains('userId')));
        expect(client.lastBody!.keys, isNot(contains('nim')));
        expect(client.lastBody!.keys, isNot(contains('name')));
      },
    );

    test('source converts a non-200 response into AiException', () async {
      final client = _RecordingSupabaseClient(
        response: const FunctionResponse(
          status: 429,
          data: {'error': 'Terlalu banyak permintaan.'},
        ),
      );
      final aiSource = AiSource(client);

      await expectLater(
        aiSource.requestHint(
          levelId: 1,
          topic: 'Variabel',
          userCode: '',
          hintLevel: 1,
        ),
        throwsA(
          isA<AiException>()
              .having((error) => error.statusCode, 'statusCode', 429)
              .having(
                (error) => error.message,
                'message',
                'Terlalu banyak permintaan.',
              ),
        ),
      );
    });
  });
}

class _FakeAiSource extends AiSource {
  _FakeAiSource() : super(_RecordingSupabaseClient());

  Map<String, dynamic> hintResponse = {'hint': 'hint'};
  Map<String, dynamic> feedbackResponse = {'feedback': 'feedback'};
  List<Map<String, dynamic>> quizResponse = [];
  Object? error;
  int? lastHintLevel;
  bool? lastFeedbackCorrect;

  @override
  Future<Map<String, dynamic>> requestHint({
    required int levelId,
    required String topic,
    required String userCode,
    required int hintLevel,
  }) async {
    lastHintLevel = hintLevel;
    if (error != null) throw error!;
    return hintResponse;
  }

  @override
  Future<Map<String, dynamic>> requestFeedback({
    required int levelId,
    required String topic,
    required String userCode,
    required String expectedAnswer,
    required bool isCorrect,
  }) async {
    lastFeedbackCorrect = isCorrect;
    if (error != null) throw error!;
    return feedbackResponse;
  }

  @override
  Future<List<Map<String, dynamic>>> requestQuiz({
    required int levelId,
    required String topic,
    required String language,
    required int questionCount,
    String? context,
  }) async {
    if (error != null) throw error!;
    return quizResponse;
  }
}

class _FakeAiRepository extends AiRepository {
  _FakeAiRepository() : super(_FakeAiSource());

  @override
  Future<String> getHint({
    required int levelId,
    required String topic,
    required String userCode,
    required int hintLevel,
  }) async => 'hint dari fake';
}

class _RecordingSupabaseClient extends SupabaseClient {
  _RecordingSupabaseClient({
    this.response = const FunctionResponse(
      status: 200,
      data: {'hint': 'hint respons'},
    ),
  }) : super('https://example.supabase.co', 'test-anon-key');

  final FunctionResponse response;
  Map<String, Object?>? lastBody;

  @override
  FunctionsClient get functions => _RecordingFunctionsClient(this, response);
}

class _RecordingFunctionsClient extends FunctionsClient {
  _RecordingFunctionsClient(this.owner, this.response)
    : super('https://example.supabase.co/functions/v1', const {});

  final _RecordingSupabaseClient owner;
  final FunctionResponse response;

  @override
  Future<FunctionResponse> invoke(
    String functionName, {
    Map<String, String>? headers,
    Object? body,
    HttpMethod method = HttpMethod.post,
    String? region,
    Future<void>? abortSignal,
    Iterable<dynamic>? files,
    Map<String, dynamic>? queryParameters,
  }) async {
    owner.lastBody = body is Map<String, Object?> ? body : null;
    return response;
  }
}
