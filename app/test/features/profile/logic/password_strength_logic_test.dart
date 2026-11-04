import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/profile/logic/password_strength_logic.dart';

void main() {
  group('PasswordStrengthLogic Tests', () {
    test('evaluate_empty_weak', () {
      expect(PasswordStrengthLogic.evaluate(''), PasswordStrength.weak);
    });

    test('evaluate_6chars_weak', () {
      expect(PasswordStrengthLogic.evaluate('123456'), PasswordStrength.weak);
    });

    test('evaluate_7chars_weak', () {
      expect(PasswordStrengthLogic.evaluate('1234567'), PasswordStrength.weak);
    });

    test('evaluate_8chars_digitLetters_medium', () {
      expect(
        PasswordStrengthLogic.evaluate('Passw0rd'),
        PasswordStrength.medium,
      );
    });

    test('evaluate_10chars_noSymbol_medium', () {
      expect(
        PasswordStrengthLogic.evaluate('Password1234'),
        PasswordStrength.medium,
      );
    });

    test('evaluate_10chars_digitLettersSymbol_strong', () {
      expect(
        PasswordStrengthLogic.evaluate('Passw0rd!@#'),
        PasswordStrength.strong,
      );
    });
  });
}
