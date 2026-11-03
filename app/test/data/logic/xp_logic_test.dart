import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/logic/xp_logic.dart';

void main() {
  group('LevelTier', () {
    test('fromLevelNumber_1_isMudah', () {
      expect(LevelTier.fromLevelNumber(1), LevelTier.mudah);
    });

    test('fromLevelNumber_15_isMudah', () {
      expect(LevelTier.fromLevelNumber(15), LevelTier.mudah);
    });

    test('fromLevelNumber_16_isSedang', () {
      expect(LevelTier.fromLevelNumber(16), LevelTier.sedang);
    });

    test('fromLevelNumber_35_isSedang', () {
      expect(LevelTier.fromLevelNumber(35), LevelTier.sedang);
    });

    test('fromLevelNumber_36_isTinggi', () {
      expect(LevelTier.fromLevelNumber(36), LevelTier.tinggi);
    });

    test('fromLevelNumber_50_isTinggi', () {
      expect(LevelTier.fromLevelNumber(50), LevelTier.tinggi);
    });

    test('fromLevelNumber_outOfRange_throws', () {
      expect(() => LevelTier.fromLevelNumber(0), throwsArgumentError);
      expect(() => LevelTier.fromLevelNumber(51), throwsArgumentError);
    });

    test('label_isIndonesian', () {
      expect(LevelTier.mudah.label, 'Mudah');
      expect(LevelTier.sedang.label, 'Sedang');
      expect(LevelTier.tinggi.label, 'Tinggi');
    });
  });

  group('XpLogic.streakMultiplier', () {
    test('streak0_is10x', () {
      expect(XpLogic.streakMultiplier(0), 1.0);
    });

    test('streak6_is10x', () {
      expect(XpLogic.streakMultiplier(6), 1.0);
    });

    test('streak7_is15x', () {
      expect(XpLogic.streakMultiplier(7), 1.5);
    });

    test('streak29_is15x', () {
      expect(XpLogic.streakMultiplier(29), 1.5);
    });

    test('streak30_is20x', () {
      expect(XpLogic.streakMultiplier(30), 2.0);
    });

    test('streak59_is20x', () {
      expect(XpLogic.streakMultiplier(59), 2.0);
    });

    test('streak60_is25x', () {
      expect(XpLogic.streakMultiplier(60), 2.5);
    });

    test('streak100_is25x', () {
      expect(XpLogic.streakMultiplier(100), 2.5);
    });

    test('negativeStreak_is10x', () {
      expect(XpLogic.streakMultiplier(-1), 1.0);
    });
  });

  group('XpLogic.baseXpFor', () {
    test('mudahPass_is50', () {
      expect(
        XpLogic.baseXpFor(
          tier: LevelTier.mudah,
          isPass: true,
          isRemedial: false,
        ),
        50,
      );
    });

    test('mudahRemedial_is25', () {
      expect(
        XpLogic.baseXpFor(
          tier: LevelTier.mudah,
          isPass: false,
          isRemedial: true,
        ),
        25,
      );
    });

    test('sedangPass_is100', () {
      expect(
        XpLogic.baseXpFor(
          tier: LevelTier.sedang,
          isPass: true,
          isRemedial: false,
        ),
        100,
      );
    });

    test('sedangRemedial_is50', () {
      expect(
        XpLogic.baseXpFor(
          tier: LevelTier.sedang,
          isPass: false,
          isRemedial: true,
        ),
        50,
      );
    });

    test('tinggiPass_is150', () {
      expect(
        XpLogic.baseXpFor(
          tier: LevelTier.tinggi,
          isPass: true,
          isRemedial: false,
        ),
        150,
      );
    });

    test('tinggiRemedial_is75', () {
      expect(
        XpLogic.baseXpFor(
          tier: LevelTier.tinggi,
          isPass: false,
          isRemedial: true,
        ),
        75,
      );
    });

    test('failAllTiers_is0', () {
      for (final LevelTier tier in LevelTier.values) {
        expect(
          XpLogic.baseXpFor(tier: tier, isPass: false, isRemedial: false),
          0,
        );
      }
    });

    test('passAndRemedialTogether_throws', () {
      expect(
        () => XpLogic.baseXpFor(
          tier: LevelTier.mudah,
          isPass: true,
          isRemedial: true,
        ),
        throwsArgumentError,
      );
    });
  });

  group('XpLogic.computeAttemptXp', () {
    test('MudahPass', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.70,
        tier: LevelTier.mudah,
        currentStreak: 0,
        previousXp: 0,
      );

      expect(result.baseXp, 50);
      expect(result.multiplier, 1.0);
      expect(result.attemptXp, 50);
      expect(result.previousXp, 0);
      expect(result.finalXp, 50);
      expect(result.isImprovement, isTrue);
      expect(result.isPass, isTrue);
      expect(result.isRemedial, isFalse);
      expect(result.isFail, isFalse);
    });

    test('MudahRemedial', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.40,
        tier: LevelTier.mudah,
        currentStreak: 0,
        previousXp: 0,
      );

      expect(result.baseXp, 25);
      expect(result.attemptXp, 25);
      expect(result.finalXp, 25);
      expect(result.isPass, isFalse);
      expect(result.isRemedial, isTrue);
      expect(result.isFail, isFalse);
    });

    test('SedangPass', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.70,
        tier: LevelTier.sedang,
        currentStreak: 0,
        previousXp: 0,
      );

      expect(result.baseXp, 100);
      expect(result.attemptXp, 100);
      expect(result.finalXp, 100);
    });

    test('SedangRemedial', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.40,
        tier: LevelTier.sedang,
        currentStreak: 0,
        previousXp: 0,
      );

      expect(result.baseXp, 50);
      expect(result.attemptXp, 50);
      expect(result.finalXp, 50);
    });

    test('TinggiPass', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.70,
        tier: LevelTier.tinggi,
        currentStreak: 0,
        previousXp: 0,
      );

      expect(result.baseXp, 150);
      expect(result.attemptXp, 150);
      expect(result.finalXp, 150);
    });

    test('TinggiRemedial', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.40,
        tier: LevelTier.tinggi,
        currentStreak: 0,
        previousXp: 0,
      );

      expect(result.baseXp, 75);
      expect(result.attemptXp, 75);
      expect(result.finalXp, 75);
    });

    test('Streak7x', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.sedang,
        currentStreak: 7,
        previousXp: 0,
      );

      expect(result.baseXp, 100);
      expect(result.multiplier, 1.5);
      expect(result.attemptXp, 150);
      expect(result.finalXp, 150);
    });

    test('Streak30x', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.tinggi,
        currentStreak: 30,
        previousXp: 0,
      );

      expect(result.baseXp, 150);
      expect(result.multiplier, 2.0);
      expect(result.attemptXp, 300);
      expect(result.finalXp, 300);
    });

    test('Streak60x', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.tinggi,
        currentStreak: 60,
        previousXp: 0,
      );

      expect(result.baseXp, 150);
      expect(result.multiplier, 2.5);
      expect(result.attemptXp, 375);
      expect(result.finalXp, 375);
    });

    test('FailZeroXp', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.39,
        tier: LevelTier.tinggi,
        currentStreak: 60,
        previousXp: 120,
      );

      expect(result.baseXp, 0);
      expect(result.attemptXp, 0);
      expect(result.previousXp, 120);
      expect(result.finalXp, 120);
      expect(result.isImprovement, isFalse);
      expect(result.isPass, isFalse);
      expect(result.isRemedial, isFalse);
      expect(result.isFail, isTrue);
    });

    test('RetakeLowerXp', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.mudah,
        currentStreak: 0,
        previousXp: 200,
      );

      expect(result.attemptXp, 50);
      expect(result.previousXp, 200);
      expect(result.finalXp, 200);
      expect(result.isImprovement, isFalse);
    });

    test('RetakeHigherXp', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.sedang,
        currentStreak: 7,
        previousXp: 50,
      );

      expect(result.attemptXp, 150);
      expect(result.previousXp, 50);
      expect(result.finalXp, 150);
      expect(result.isImprovement, isTrue);
    });

    test('RetakeEqualXp', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.sedang,
        currentStreak: 0,
        previousXp: 100,
      );

      expect(result.attemptXp, 100);
      expect(result.previousXp, 100);
      expect(result.finalXp, 100);
      expect(result.isImprovement, isFalse);
    });

    test('MultiplierRounding', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.50,
        tier: LevelTier.mudah,
        currentStreak: 7,
        previousXp: 0,
      );

      expect(result.baseXp, 25);
      expect(result.multiplier, 1.5);
      expect(result.attemptXp, 38);
      expect(result.finalXp, 38);
    });

    test('negativePreviousXp_isClampedToZero', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.mudah,
        currentStreak: 0,
        previousXp: -10,
      );

      expect(result.previousXp, 0);
      expect(result.attemptXp, 50);
      expect(result.finalXp, 50);
      expect(result.isImprovement, isTrue);
    });

    test('NaNMastery_isFail', () {
      final XpResult result = XpLogic.computeAttemptXp(
        adaptiveMastery: double.nan,
        tier: LevelTier.tinggi,
        currentStreak: 60,
        previousXp: 0,
      );

      expect(result.baseXp, 0);
      expect(result.attemptXp, 0);
      expect(result.finalXp, 0);
      expect(result.isFail, isTrue);
      expect(result.isPass, isFalse);
      expect(result.isRemedial, isFalse);
    });

    test('equality_membandingkanSeluruhField', () {
      final XpResult first = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.sedang,
        currentStreak: 7,
        previousXp: 50,
      );
      final XpResult second = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.sedang,
        currentStreak: 7,
        previousXp: 50,
      );
      final XpResult different = XpLogic.computeAttemptXp(
        adaptiveMastery: 0.80,
        tier: LevelTier.sedang,
        currentStreak: 30,
        previousXp: 50,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
    });
  });
}
