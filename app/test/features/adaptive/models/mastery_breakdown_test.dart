import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/adaptive/models/mastery_breakdown.dart';
import 'package:kodira/features/adaptive/services/adaptive_engine.dart';

void main() {
  group('MasteryBreakdown', () {
    test('nilai di bawah 0 di-clamp ke 0', () {
      final breakdown = MasteryBreakdown(
        accuracy: -0.5,
        consistency: -1.0,
        timeNorm: -0.1,
        total: -2.0,
      );

      expect(breakdown.accuracy, 0.0);
      expect(breakdown.consistency, 0.0);
      expect(breakdown.timeNorm, 0.0);
      expect(breakdown.total, 0.0);
    });

    test('nilai di atas 1 di-clamp ke 1', () {
      final breakdown = MasteryBreakdown(
        accuracy: 1.5,
        consistency: 2.0,
        timeNorm: 3.0,
        total: 1.2,
      );

      expect(breakdown.accuracy, 1.0);
      expect(breakdown.consistency, 1.0);
      expect(breakdown.timeNorm, 1.0);
      expect(breakdown.total, 1.0);
    });

    test('NaN dianggap 0', () {
      final breakdown = MasteryBreakdown(
        accuracy: double.nan,
        consistency: double.nan,
        timeNorm: double.nan,
        total: double.nan,
      );

      expect(breakdown.accuracy, 0.0);
      expect(breakdown.consistency, 0.0);
      expect(breakdown.timeNorm, 0.0);
      expect(breakdown.total, 0.0);
    });

    test('errorRate adalah 1 - accuracy', () {
      final breakdown = MasteryBreakdown(
        accuracy: 0.8,
        consistency: 0.5,
        timeNorm: 0.25,
        total: 0.7,
      );

      expect(breakdown.errorRate, closeTo(0.2, 1e-12));
    });

    test('combinedAccuracyContribution adalah 0.65 * accuracy', () {
      final breakdown = MasteryBreakdown(
        accuracy: 0.8,
        consistency: 0.5,
        timeNorm: 0.25,
        total: 0.7,
      );

      expect(breakdown.combinedAccuracyContribution, closeTo(0.52, 1e-12));
    });

    test('speedContribution adalah 0.10 * (1 - timeNorm)', () {
      final breakdown = MasteryBreakdown(
        accuracy: 0.8,
        consistency: 0.5,
        timeNorm: 0.25,
        total: 0.7,
      );

      expect(breakdown.speedContribution, closeTo(0.075, 1e-12));
    });

    test('equality membandingkan seluruh komponen', () {
      final first = MasteryBreakdown(
        accuracy: 0.8,
        consistency: 0.5,
        timeNorm: 0.25,
        total: 0.7,
      );
      final second = MasteryBreakdown(
        accuracy: 0.8,
        consistency: 0.5,
        timeNorm: 0.25,
        total: 0.7,
      );
      final different = MasteryBreakdown(
        accuracy: 0.9,
        consistency: 0.5,
        timeNorm: 0.25,
        total: 0.7,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
    });
  });

  group('AdaptiveEngine.computeMasteryBreakdown', () {
    test('total sama dengan computeMastery', () {
      final breakdown = AdaptiveEngine.computeMasteryBreakdown(
        correct: 2,
        total: 3,
        secondsUsed: 90,
        timeLimitPerQuestion: 60,
        previousMastery: 0.8,
      );
      final mastery = AdaptiveEngine.computeMastery(
        correct: 2,
        total: 3,
        secondsUsed: 90,
        timeLimitPerQuestion: 60,
        previousMastery: 0.8,
      );

      expect(breakdown.total, closeTo(mastery, 1e-12));
    });

    test('total mengikuti formula 0.65A + 0.25C + 0.10(1 - Tn)', () {
      final breakdown = AdaptiveEngine.computeMasteryBreakdown(
        correct: 2,
        total: 3,
        secondsUsed: 90,
        timeLimitPerQuestion: 60,
        previousMastery: 0.8,
      );

      final expected =
          0.65 * breakdown.accuracy +
          0.25 * breakdown.consistency +
          0.10 * (1.0 - breakdown.timeNorm);

      expect(breakdown.total, closeTo(expected, 1e-12));
      expect(breakdown.accuracy, closeTo(2 / 3, 1e-12));
      expect(breakdown.consistency, closeTo(0.8, 1e-12));
      expect(breakdown.timeNorm, closeTo(0.5, 1e-12));
    });

    test('total 0 mengembalikan breakdown nol', () {
      final breakdown = AdaptiveEngine.computeMasteryBreakdown(
        correct: 3,
        total: 0,
        secondsUsed: 30,
        timeLimitPerQuestion: 60,
        previousMastery: 0.8,
      );

      expect(breakdown.accuracy, 0.0);
      expect(breakdown.timeNorm, 0.0);
      expect(breakdown.total, 0.0);
    });
  });
}
