import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'badge_logic.dart';

/// Repository untuk tabel `user_badges` dan `user_achievements` yang menyimpan
/// pencapaian gamifikasi milik user.
class BadgeRepository {
  final supa.SupabaseClient _client;

  BadgeRepository(this._client);

  /// Kode badge yang sudah dimiliki user.
  Future<Set<String>> getBadgeCodes(String userId) async {
    try {
      final response = await _client
          .from('user_badges')
          .select('badge_code')
          .eq('user_id', userId);

      final list = response as List<dynamic>;
      return list
          .map(
            (dynamic row) =>
                (row as Map<String, dynamic>)['badge_code'] as String,
          )
          .toSet();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat badge: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat badge: $e');
    }
  }

  /// Kode achievement yang sudah dimiliki user.
  Future<Set<String>> getAchievementCodes(String userId) async {
    try {
      final response = await _client
          .from('user_achievements')
          .select('achievement_code')
          .eq('user_id', userId);

      final list = response as List<dynamic>;
      return list
          .map(
            (dynamic row) =>
                (row as Map<String, dynamic>)['achievement_code'] as String,
          )
          .toSet();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat achievement: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat achievement: $e');
    }
  }

  /// Berikan badge ke user.
  ///
  /// Memakai upsert dengan `onConflict` pada `(user_id, badge_code)` supaya
  /// aman ketika dua pemicu berjalan bersamaan (login dan kuis).
  Future<void> awardBadges({
    required String userId,
    required Set<String> badgeCodes,
    DateTime? earnedAt,
  }) async {
    if (badgeCodes.isEmpty) return;

    final List<Map<String, dynamic>> rows = BadgeLogic.buildBadgeRows(
      userId: userId,
      badgeCodes: badgeCodes,
      earnedAt: earnedAt ?? DateTime.now(),
    );

    try {
      await _client
          .from('user_badges')
          .upsert(rows, onConflict: 'user_id,badge_code');
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memberikan badge: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memberikan badge: $e');
    }
  }

  /// Berikan achievement ke user.
  ///
  /// Memakai upsert dengan `onConflict` pada `(user_id, achievement_code)`.
  Future<void> awardAchievements({
    required String userId,
    required Set<String> achievementCodes,
    DateTime? earnedAt,
  }) async {
    if (achievementCodes.isEmpty) return;

    final List<Map<String, dynamic>> rows = BadgeLogic.buildAchievementRows(
      userId: userId,
      achievementCodes: achievementCodes,
      earnedAt: earnedAt ?? DateTime.now(),
    );

    try {
      await _client
          .from('user_achievements')
          .upsert(rows, onConflict: 'user_id,achievement_code');
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memberikan achievement: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memberikan achievement: $e');
    }
  }

  /// Periksa milestone user lalu berikan badge dan achievement baru.
  ///
  /// Dipanggil setelah login, setelah session restore, dan setelah kuis
  /// selesai. Idempotent: badge serta achievement yang sudah dimiliki tidak
  /// ditulis ulang.
  Future<({Set<String> newBadges, Set<String> newAchievements})> checkAndAward(
    String userId,
  ) async {
    final response = await _client
        .from('user_progress')
        .select('level_id, status, xp_earned')
        .eq('user_id', userId);
    final List<Map<String, dynamic>> progressList = (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .toList();

    final streakResponse = await _client
        .from('user_streaks')
        .select('current_streak')
        .eq('user_id', userId)
        .maybeSingle();
    final int currentStreak =
        (streakResponse?['current_streak'] as num?)?.toInt() ?? 0;

    final int totalXp = progressList.fold<int>(
      0,
      (int sum, Map<String, dynamic> row) =>
          sum + ((row['xp_earned'] as num?)?.toInt() ?? 0),
    );
    final int totalLevelsCompleted = BadgeLogic.totalLevelsCompleted(
      progressList
          .map((Map<String, dynamic> row) => row['status'] as String)
          .toList(),
    );
    final int chapter1Completed = BadgeLogic.levelsCompletedChapter1(
      progressList,
    );

    final Set<String> existingBadges = await getBadgeCodes(userId);
    final Set<String> existingAchievements = await getAchievementCodes(userId);

    final Set<String> newBadges = BadgeLogic.computeMissingBadges(
      existingBadgeCodes: existingBadges,
      currentStreak: currentStreak,
      totalLevelsCompleted: totalLevelsCompleted,
      totalXp: totalXp,
    );
    final Set<String> newAchievements = BadgeLogic.computeMissingAchievements(
      existingAchievementCodes: existingAchievements,
      hasEverLoggedIn: true,
      hasEverPassedQuiz: totalLevelsCompleted > 0,
      levelsCompletedInChapter1: chapter1Completed,
    );

    await awardBadges(userId: userId, badgeCodes: newBadges);
    await awardAchievements(userId: userId, achievementCodes: newAchievements);

    return (newBadges: newBadges, newAchievements: newAchievements);
  }
}
