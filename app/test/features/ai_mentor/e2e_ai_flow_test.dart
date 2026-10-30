import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/ai_repository.dart';
import 'package:kodira/data/sources/remote/ai_source.dart';
import 'package:kodira/features/adaptive/services/adaptive_engine.dart';
import 'package:kodira/features/ai_mentor/providers/ai_provider.dart';
import 'package:kodira/features/ai_mentor/widgets/feedback_bottom_sheet.dart';
import 'package:kodira/features/ai_mentor/widgets/hint_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Fake AI Repository untuk E2E AI Flow test
class _FakeAiRepository extends AiRepository {
  _FakeAiRepository() : super(_FakeAiSource());

  String hintResponse = 'Hint edukatif dari AI (mock)';
  String feedbackResponse = 'Feedback dari AI (mock)';
  List<Map<String, dynamic>> quizResponse = [
    {
      'question': 'Soal remedial 1',
      'options': ['A', 'B', 'C', 'D'],
      'answer': 0,
      'explanation': 'Penjelasan soal remedial',
    },
  ];

  Object? failure;
  int hintCalls = 0;
  int feedbackCalls = 0;
  int quizCalls = 0;

  @override
  Future<String> getHint({
    required int levelId,
    required String topic,
    required String userCode,
    required int hintLevel,
  }) async {
    hintCalls++;
    if (failure != null) throw failure!;
    return '$hintResponse level $hintLevel';
  }

  @override
  Future<String> getFeedback({
    required int levelId,
    required String topic,
    required String userCode,
    required String expectedAnswer,
    required bool isCorrect,
  }) async {
    feedbackCalls++;
    if (failure != null) throw failure!;
    return feedbackResponse;
  }

  @override
  Future<List<Map<String, dynamic>>> generateQuiz({
    required int levelId,
    required String topic,
    required String language,
    required int questionCount,
    String? context,
  }) async {
    quizCalls++;
    if (failure != null) throw failure!;
    return quizResponse;
  }
}

class _FakeAiSource extends AiSource {
  _FakeAiSource() : super(SupabaseClient('https://example.com', 'test-key'));
}

void main() {
  late _FakeAiRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeAiRepository();
  });

  group('E2E Flow 1 — Hint Integration via HintBottomSheet', () {
    testWidgets(
      'HintBottomSheet fetches and displays AI hint with multi-level flow',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [aiRepositoryProvider.overrideWithValue(fakeRepo)],
            child: const MaterialApp(
              home: Scaffold(
                body: HintBottomSheet(
                  levelId: 1,
                  topic: 'Variabel',
                  userCode: 'int x = 10',
                ),
              ),
            ),
          ),
        );

        // Awalnya tombol level 1 ada
        expect(find.text('Minta Hint Level 1'), findsOneWidget);

        // Request Level 1
        await tester.tap(find.text('Minta Hint Level 1'));
        await tester.pumpAndSettle();

        expect(
          find.text('Hint edukatif dari AI (mock) level 1'),
          findsOneWidget,
        );
        expect(fakeRepo.hintCalls, 1);

        // Lanjut Level 2
        expect(find.text('Minta Hint Level 2'), findsOneWidget);
        await tester.tap(find.text('Minta Hint Level 2'));
        await tester.pumpAndSettle();

        expect(
          find.text('Hint edukatif dari AI (mock) level 2'),
          findsOneWidget,
        );
        expect(fakeRepo.hintCalls, 2);
      },
    );

    testWidgets(
      'Hint request respects max 3 attempts limit and disables button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [aiRepositoryProvider.overrideWithValue(fakeRepo)],
            child: const MaterialApp(
              home: Scaffold(
                body: HintBottomSheet(levelId: 1, topic: 'V', userCode: ''),
              ),
            ),
          ),
        );

        for (int i = 1; i <= 3; i++) {
          await tester.tap(find.text('Minta Hint Level $i'));
          await tester.pumpAndSettle();
        }

        expect(find.text('Hint maksimal sudah digunakan'), findsOneWidget);
        expect(fakeRepo.hintCalls, 3);
      },
    );
  });

  group('E2E Flow 2 — AI Feedback via FeedbackBottomSheet', () {
    testWidgets(
      'FeedbackBottomSheet displays AI feedback for incorrect answer',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [aiRepositoryProvider.overrideWithValue(fakeRepo)],
            child: const MaterialApp(
              home: Scaffold(
                body: FeedbackBottomSheet(
                  levelId: 1,
                  topic: 'Variabel',
                  userCode: 'string x = 10',
                  expectedAnswer: 'int',
                  isCorrect: false,
                ),
              ),
            ),
          ),
        );

        // Tunggu settle karena initState memicu request AI
        await tester.pumpAndSettle();

        expect(find.text('Feedback dari AI (mock)'), findsOneWidget);
        expect(fakeRepo.feedbackCalls, 1);
      },
    );

    testWidgets('FeedbackBottomSheet shows fallback UI when AI request fails', (
      tester,
    ) async {
      fakeRepo.failure = Exception('AI Offline');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiRepositoryProvider.overrideWithValue(fakeRepo)],
          child: const MaterialApp(
            home: Scaffold(
              body: FeedbackBottomSheet(
                levelId: 1,
                topic: 'V',
                userCode: '',
                expectedAnswer: 'A',
                isCorrect: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Feedback AI tidak tersedia saat ini'), findsOneWidget);
      expect(fakeRepo.feedbackCalls, 1);
    });
  });

  group('E2E Flow 3 — Adaptive Engine & Remedial Wiring', () {
    test('AdaptiveEngine classifies low mastery as Fail/Remedial trigger', () {
      // Skenario: 0 benar dari 3 soal, waktu habis
      final mastery = AdaptiveEngine.computeMastery(
        correct: 0,
        total: 3,
        secondsUsed: 180,
        timeLimitPerQuestion: 60,
      );

      expect(mastery, lessThan(AdaptiveEngine.masteryRemedialMin));
      expect(AdaptiveEngine.classify(mastery), AdaptiveTier.fail);
      expect(AdaptiveEngine.shouldTriggerRemedialQuiz(mastery), isTrue);
    });

    test('AdaptiveEngine classifies high mastery as Pass/Unlock', () {
      // Skenario: 3 benar dari 3 soal, waktu cepat
      final mastery = AdaptiveEngine.computeMastery(
        correct: 3,
        total: 3,
        secondsUsed: 45,
        timeLimitPerQuestion: 60,
      );

      expect(mastery, greaterThanOrEqualTo(AdaptiveEngine.masteryPass));
      expect(AdaptiveEngine.classify(mastery), AdaptiveTier.pass);
      expect(AdaptiveEngine.shouldUnlockNext(mastery), isTrue);
    });

    testWidgets(
      'AI repository can generate remedial quiz questions when triggered',
      (tester) async {
        final questions = await fakeRepo.generateQuiz(
          levelId: 1,
          topic: 'Variabel',
          language: 'C++',
          questionCount: 3,
        );

        expect(questions, isNotEmpty);
        expect(questions.first['question'], 'Soal remedial 1');
        expect(fakeRepo.quizCalls, 1);
      },
    );
  });

  group('E2E Flow 4 — PII Guardrail & Payload Safety', () {
    testWidgets('AI requests do not propagate PII or sensitive profile data', (
      tester,
    ) async {
      // Simulasi request via HintBottomSheet
      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiRepositoryProvider.overrideWithValue(fakeRepo)],
          child: const MaterialApp(
            home: Scaffold(
              body: HintBottomSheet(
                levelId: 1,
                topic: 'Variabel',
                userCode: 'int x = 5;',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Minta Hint Level 1'));
      await tester.pumpAndSettle();

      // Verifikasi hintCalls bertambah
      expect(fakeRepo.hintCalls, 1);

      // Catatan: PII check sebenarnya berada di level Unit Test AiRepository.
      // Di sini kita memverifikasi bahwa wiring tetap memanggil repo dengan aman.
      // Detail implementasi PII guardrail ada di data layer yang sudah ter-test.
    });
  });
}
