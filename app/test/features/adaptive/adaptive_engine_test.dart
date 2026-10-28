import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/adaptive/services/adaptive_engine.dart';
import 'package:kodira/features/quiz/screens/quiz_screen.dart';

void main() {
  group('AdaptiveEngine.computeMastery', () {
    test('total soal 0 mengembalikan 0.0', () {
      final m = AdaptiveEngine.computeMastery(
        correct: 0,
        total: 0,
        secondsUsed: 10,
        timeLimitPerQuestion: 60,
      );
      expect(m, 0.0);
    });

    test(
      '3/3 benar, waktu sangat cepat, percobaan pertama -> skor tinggi (> 0.70)',
      () {
        final m = AdaptiveEngine.computeMastery(
          correct: 3,
          total: 3,
          secondsUsed:
              9, // 3 detik per soal -> timeNorm 3/60 = 0.05 -> 1 - Tn = 0.95
          timeLimitPerQuestion: 60,
          previousMastery: 0.0,
        );
        // A = 1.0 (0.45), C = 0 (0), 1-E = 1.0 (0.20), 1-Tn = 0.95 (0.095)
        // Total = 0.45 + 0.20 + 0.095 = 0.745
        expect(m, closeTo(0.745, 0.005));
        expect(AdaptiveEngine.classify(m), AdaptiveTier.pass);
      },
    );

    test(
      '3/3 benar, waktu sangat cepat, dengan riwayat konsistensi 0.9 -> skor sangat tinggi (> 0.90)',
      () {
        final m = AdaptiveEngine.computeMastery(
          correct: 3,
          total: 3,
          secondsUsed: 9,
          timeLimitPerQuestion: 60,
          previousMastery: 0.9,
        );
        // 0.745 + 0.25 * 0.9 = 0.745 + 0.225 = 0.97
        expect(m, closeTo(0.970, 0.005));
        expect(AdaptiveEngine.classify(m), AdaptiveTier.pass);
      },
    );

    test(
      '3/3 benar, waktu lambat menghabiskan batas waktu, percobaan pertama',
      () {
        final m = AdaptiveEngine.computeMastery(
          correct: 3,
          total: 3,
          secondsUsed: 180, // 60 detik per soal -> Tn = 1.0 -> 1 - Tn = 0.0
          timeLimitPerQuestion: 60,
          previousMastery: 0.0,
        );
        // A = 1.0 (0.45), C = 0.0 (0), 1-E = 1.0 (0.20), 1-Tn = 0.0 (0.0)
        // Total = 0.65 (masuk remedial tier karena lambat dan first attempt)
        expect(m, closeTo(0.65, 0.001));
        expect(AdaptiveEngine.classify(m), AdaptiveTier.remedial);
      },
    );

    test('2/3 benar, waktu sedang, percobaan pertama -> remedial tier', () {
      final m = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed:
            60, // 20 detik per soal -> Tn = 20/60 = 0.333 -> 1 - Tn = 0.667
        timeLimitPerQuestion: 60,
        previousMastery: 0.0,
      );
      // A = 2/3 (0.300), C = 0 (0), 1-E = 2/3 (0.1333), 1-Tn = 2/3 (0.0667)
      // Total = 0.500
      expect(m, closeTo(0.500, 0.005));
      expect(AdaptiveEngine.classify(m), AdaptiveTier.remedial);
    });

    test(
      '2/3 benar dengan riwayat konsistensi tinggi (0.80) -> lulus ambang 0.70',
      () {
        final m = AdaptiveEngine.computeMastery(
          correct: 2,
          total: 3,
          secondsUsed: 60,
          timeLimitPerQuestion: 60,
          previousMastery: 0.80,
        );
        // 0.500 + 0.25 * 0.80 = 0.700
        expect(m, closeTo(0.700, 0.005));
        expect(AdaptiveEngine.classify(m), AdaptiveTier.pass);
        expect(AdaptiveEngine.shouldUnlockNext(m), isTrue);
      },
    );

    test(
      '1/3 benar, waktu lambat, percobaan pertama -> skor rendah di bawah 40%',
      () {
        final m = AdaptiveEngine.computeMastery(
          correct: 1,
          total: 3,
          secondsUsed:
              150, // 50s per soal -> Tn = 50/60 = 0.833 -> 1 - Tn = 0.1667
          timeLimitPerQuestion: 60,
          previousMastery: 0.0,
        );
        // A = 1/3 (0.150), C = 0, 1-E = 1/3 (0.0667), 1-Tn = 0.1667 (0.0167)
        // Total = 0.233
        expect(m, lessThan(0.40));
        expect(AdaptiveEngine.classify(m), AdaptiveTier.fail);
        expect(AdaptiveEngine.shouldTriggerRemedialQuiz(m), isTrue);
      },
    );

    test('0/3 benar dan kehabisan waktu -> 0.0 total', () {
      final m = AdaptiveEngine.computeMastery(
        correct: 0,
        total: 3,
        secondsUsed: 180,
        timeLimitPerQuestion: 60,
        previousMastery: 0.0,
      );
      expect(m, 0.0);
      expect(AdaptiveEngine.classify(m), AdaptiveTier.fail);
      expect(AdaptiveEngine.shouldTriggerRemedialQuiz(m), isTrue);
    });

    test(
      'waktu pengerjaan melebihi batas (overflow) diclamp ke normalized time 1.0',
      () {
        final m1 = AdaptiveEngine.computeMastery(
          correct: 2,
          total: 3,
          secondsUsed: 180,
          timeLimitPerQuestion: 60,
        );
        final m2 = AdaptiveEngine.computeMastery(
          correct: 2,
          total: 3,
          secondsUsed: 500, // jauh melebihi batas waktu
          timeLimitPerQuestion: 60,
        );
        expect(m1, equals(m2));
      },
    );

    test('detik pengerjaan bernilai negatif diamankan ke 0', () {
      final m = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed: -10,
        timeLimitPerQuestion: 60,
      );
      expect(m, greaterThan(0.0));
    });

    test('previousMastery di atas 1.0 diclamp ke 1.0', () {
      final mNormal = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed: 60,
        timeLimitPerQuestion: 60,
        previousMastery: 1.0,
      );
      final mOverflow = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed: 60,
        timeLimitPerQuestion: 60,
        previousMastery: 2.5,
      );
      expect(mOverflow, equals(mNormal));
    });

    test('previousMastery bernilai negatif diclamp ke 0.0', () {
      final mZero = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed: 60,
        timeLimitPerQuestion: 60,
        previousMastery: 0.0,
      );
      final mNegative = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed: 60,
        timeLimitPerQuestion: 60,
        previousMastery: -0.5,
      );
      expect(mNegative, equals(mZero));
    });

    test('correct melebihi total diclamp ke total', () {
      final mNormal = AdaptiveEngine.computeMastery(
        correct: 3,
        total: 3,
        secondsUsed: 60,
        timeLimitPerQuestion: 60,
      );
      final mOverflow = AdaptiveEngine.computeMastery(
        correct: 10,
        total: 3,
        secondsUsed: 60,
        timeLimitPerQuestion: 60,
      );
      expect(mOverflow, equals(mNormal));
    });

    test('timeLimitPerQuestion <= 0 menggunakan nilai fallback 60 detik', () {
      final m = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed: 30,
        timeLimitPerQuestion: 0,
      );
      expect(m, greaterThan(0.0));
    });
  });

  group('AdaptiveEngine.classify', () {
    test('skor 0.85 -> AdaptiveTier.pass', () {
      expect(AdaptiveEngine.classify(0.85), AdaptiveTier.pass);
    });

    test('batas kelulusan persis 0.70 -> AdaptiveTier.pass', () {
      expect(AdaptiveEngine.classify(0.70), AdaptiveTier.pass);
    });

    test('skor 0.699 -> AdaptiveTier.remedial', () {
      expect(AdaptiveEngine.classify(0.699), AdaptiveTier.remedial);
    });

    test('batas remedial persis 0.40 -> AdaptiveTier.remedial', () {
      expect(AdaptiveEngine.classify(0.40), AdaptiveTier.remedial);
    });

    test('skor 0.399 -> AdaptiveTier.fail', () {
      expect(AdaptiveEngine.classify(0.399), AdaptiveTier.fail);
    });

    test('skor 0.0 -> AdaptiveTier.fail', () {
      expect(AdaptiveEngine.classify(0.0), AdaptiveTier.fail);
    });

    test('skor sempurna 1.0 -> AdaptiveTier.pass', () {
      expect(AdaptiveEngine.classify(1.0), AdaptiveTier.pass);
    });
  });

  group('AdaptiveEngine.shouldTriggerRemedialQuiz', () {
    test('skor 0.39 memicu remedial kuis AI', () {
      expect(AdaptiveEngine.shouldTriggerRemedialQuiz(0.39), isTrue);
    });

    test('skor 0.0 memicu remedial kuis AI', () {
      expect(AdaptiveEngine.shouldTriggerRemedialQuiz(0.0), isTrue);
    });

    test('skor 0.40 tidak memicu remedial kuis AI', () {
      expect(AdaptiveEngine.shouldTriggerRemedialQuiz(0.40), isFalse);
    });

    test('skor 0.65 tidak memicu remedial kuis AI', () {
      expect(AdaptiveEngine.shouldTriggerRemedialQuiz(0.65), isFalse);
    });

    test('skor 0.70 tidak memicu remedial kuis AI', () {
      expect(AdaptiveEngine.shouldTriggerRemedialQuiz(0.70), isFalse);
    });
  });

  group('AdaptiveEngine.shouldUnlockNext', () {
    test('skor >= 0.70 membuka level berikutnya', () {
      expect(AdaptiveEngine.shouldUnlockNext(0.70), isTrue);
      expect(AdaptiveEngine.shouldUnlockNext(0.88), isTrue);
      expect(AdaptiveEngine.shouldUnlockNext(1.0), isTrue);
    });

    test('skor < 0.70 tidak membuka level berikutnya', () {
      expect(AdaptiveEngine.shouldUnlockNext(0.69), isFalse);
      expect(AdaptiveEngine.shouldUnlockNext(0.40), isFalse);
      expect(AdaptiveEngine.shouldUnlockNext(0.15), isFalse);
    });
  });

  group('QuizQuestion.fromAiMap', () {
    test('memetakan format Map soal standar dari Edge Function AI', () {
      final map = {
        'question': 'Berapakah output dari cout << 10 % 3;?',
        'options': ['0', '1', '2', '3'],
        'answer': 1,
        'explanation': 'Sisa bagi 10 dibagi 3 adalah 1.',
        'language': 'cpp',
      };

      final q = QuizQuestion.fromAiMap(map);
      expect(q, isNotNull);
      expect(q!.prompt, 'Berapakah output dari cout << 10 % 3;?');
      expect(q.options, hasLength(4));
      expect(q.options[1].id, 'opt_1');
      expect(q.options[1].text, '1');
      expect(q.answerId, 'opt_1');
      expect(q.explanation, 'Sisa bagi 10 dibagi 3 adalah 1.');
      expect(q.language, 'cpp');
    });

    test(
      'menerima format prompt alternatif dan answer bertipe string index',
      () {
        final map = {
          'prompt': 'Tipe data untuk bilangan bulat di Java adalah?',
          'options': ['float', 'int', 'boolean', 'char'],
          'answer': '1',
          'explanation': 'int digunakan untuk bilangan bulat.',
        };

        final q = QuizQuestion.fromAiMap(map, language: 'java');
        expect(q, isNotNull);
        expect(q!.language, 'java');
        expect(q.answerId, 'opt_1');
      },
    );

    test('mengabaikan map yang tidak memiliki opsi minimal 2', () {
      final map = {
        'question': 'Soal tidak valid',
        'options': ['Hanya satu pilihan'],
        'answer': 0,
      };

      final q = QuizQuestion.fromAiMap(map);
      expect(q, isNull);
    });

    test('mengabaikan map dengan prompt kosong', () {
      final map = {
        'question': '   ',
        'options': ['A', 'B'],
        'answer': 0,
      };

      final q = QuizQuestion.fromAiMap(map);
      expect(q, isNull);
    });
  });
}
