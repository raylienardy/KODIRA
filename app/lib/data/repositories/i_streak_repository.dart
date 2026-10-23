import '../models/user_streak_model.dart';

/// Kontrak repository streak harian user.
///
/// Implementasi konkret: `StreakRepository`.
abstract class IStreakRepository {
  /// Ambil streak milik satu user, atau null bila belum pernah aktif.
  Future<UserStreakModel?> getForUser(String userId);

  /// Perbarui streak saat user aktif.
  Future<UserStreakModel> updateOnActivity({
    required String userId,
    required DateTime now,
  });
}
