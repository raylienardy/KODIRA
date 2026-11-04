/// Logika verifikasi password update yang bisa dites tanpa Supabase mock.
class PasswordUpdateLogic {
  const PasswordUpdateLogic._();

  /// Apakah error message dari updateUser perlu retry dengan
  /// currentPassword (secure_password_change = true di Supabase server)?
  static bool shouldRetryWithCurrentPassword(String errorMessage) {
    final msg = errorMessage.toLowerCase();
    return msg.contains('reauthentication') || msg.contains('current password');
  }
}
