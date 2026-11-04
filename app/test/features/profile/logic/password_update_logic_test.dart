import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/profile/logic/password_update_logic.dart';

void main() {
  group('PasswordUpdateLogic Tests', () {
    test('shouldRetry_reauthenticationMessage_true', () {
      expect(
        PasswordUpdateLogic.shouldRetryWithCurrentPassword(
          'A reauthentication is required',
        ),
        isTrue,
      );
    });

    test('shouldRetry_currentPasswordMessage_true', () {
      expect(
        PasswordUpdateLogic.shouldRetryWithCurrentPassword(
          'Current password is required',
        ),
        isTrue,
      );
    });

    test('shouldRetry_invalidCredentials_false', () {
      expect(
        PasswordUpdateLogic.shouldRetryWithCurrentPassword(
          'Invalid login credentials',
        ),
        isFalse,
      );
    });

    test('shouldRetry_caseInsensitive', () {
      expect(
        PasswordUpdateLogic.shouldRetryWithCurrentPassword(
          'REAUTHENTICATION required',
        ),
        isTrue,
      );
    });

    test('shouldRetry_empty_false', () {
      expect(PasswordUpdateLogic.shouldRetryWithCurrentPassword(''), isFalse);
    });
  });
}
