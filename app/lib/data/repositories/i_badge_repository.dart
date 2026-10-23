/// Kontrak repository badge dan achievement.
///
/// Implementasi konkret: `BadgeRepository`.
abstract class IBadgeRepository {
  /// Kode badge yang sudah dimiliki user.
  Future<Set<String>> getBadgeCodes(String userId);

  /// Kode achievement yang sudah dimiliki user.
  Future<Set<String>> getAchievementCodes(String userId);

  /// Berikan badge ke user.
  Future<void> awardBadges({
    required String userId,
    required Set<String> badgeCodes,
    DateTime? earnedAt,
  });

  /// Berikan achievement ke user.
  Future<void> awardAchievements({
    required String userId,
    required Set<String> achievementCodes,
    DateTime? earnedAt,
  });

  /// Periksa milestone lalu berikan badge dan achievement baru.
  Future<({Set<String> newBadges, Set<String> newAchievements})> checkAndAward(
    String userId,
  );
}
