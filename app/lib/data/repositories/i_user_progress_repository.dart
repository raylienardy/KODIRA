import '../models/user_progress_model.dart';

/// Kontrak repository progress belajar user.
///
/// Implementasi konkret: `UserProgressRepository`.
abstract class IUserProgressRepository {
  /// Ambil seluruh progress milik satu user.
  Future<List<UserProgressModel>> getAllForUser(String userId);

  /// Ambil progress user pada satu level, atau null bila belum ada.
  Future<UserProgressModel?> getForLevel(String userId, int levelId);

  /// Simpan hasil belajar untuk satu level.
  Future<void> upsert({
    required String userId,
    required int levelId,
    required String status,
    required double masteryScore,
    required int xpEarned,
    required int attempts,
  });

  /// Total XP yang sudah dikumpulkan user.
  Future<int> getTotalXp(String userId);
}
