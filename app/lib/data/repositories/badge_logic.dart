/// Katalog badge dan achievement (P4-010).
///
/// Kode disimpan sebagai teks bebas di tabel `user_badges` dan
/// `user_achievements`, jadi katalog ini adalah satu-satunya sumber nama
/// badge di sisi aplikasi.
class BadgeCatalog {
  const BadgeCatalog._();

  /// Badge streak 3 hari berturut-turut.
  static const String streak3 = 'streak_3';

  /// Badge streak 7 hari berturut-turut.
  static const String streak7 = 'streak_7';

  /// Badge streak 30 hari berturut-turut.
  static const String streak30 = 'streak_30';

  /// Badge 5 level selesai.
  static const String level5 = 'level_5';

  /// Badge 10 level selesai.
  static const String level10 = 'level_10';

  /// Badge 25 level selesai.
  static const String level25 = 'level_25';

  /// Badge 100 XP terkumpul.
  static const String xp100 = 'xp_100';

  /// Badge 500 XP terkumpul.
  static const String xp500 = 'xp_500';

  /// Badge 1000 XP terkumpul.
  static const String xp1000 = 'xp_1000';

  /// Seluruh kode badge yang dikenal aplikasi.
  static const List<String> all = <String>[
    streak3,
    streak7,
    streak30,
    level5,
    level10,
    level25,
    xp100,
    xp500,
    xp1000,
  ];
}

/// Katalog achievement (P4-010).
class AchievementCatalog {
  const AchievementCatalog._();

  /// Achievement login pertama kali.
  static const String firstLogin = 'first_login';

  /// Achievement menyelesaikan satu kuis.
  static const String firstQuizPass = 'first_quiz_pass';

  /// Achievement menyelesaikan seluruh bab 1 (Level 1-15).
  static const String completeChapter1 = 'complete_chapter_1';

  /// Seluruh kode achievement yang dikenal aplikasi.
  static const List<String> all = <String>[
    firstLogin,
    firstQuizPass,
    completeChapter1,
  ];
}

/// Aturan pemberian badge dan achievement (P4-010) yang berdiri sendiri tanpa
/// bergantung pada Supabase, supaya bisa diuji unit test tanpa perangkat.
///
/// Seluruh aturan di sini adalah bentuk murni dari [BadgeRepository].
class BadgeLogic {
  const BadgeLogic._();

  /// Badge yang harus dimiliki user tapi belum ada di [existingBadgeCodes].
  ///
  /// Badge diberikan berdasarkan ambang milestone (streak, level selesai, XP).
  /// Urutan hasil tidak penting.
  static Set<String> computeMissingBadges({
    required Set<String> existingBadgeCodes,
    required int currentStreak,
    required int totalLevelsCompleted,
    required int totalXp,
  }) {
    final Set<String> required = <String>{};

    if (currentStreak >= 3) required.add(BadgeCatalog.streak3);
    if (currentStreak >= 7) required.add(BadgeCatalog.streak7);
    if (currentStreak >= 30) required.add(BadgeCatalog.streak30);

    if (totalLevelsCompleted >= 5) required.add(BadgeCatalog.level5);
    if (totalLevelsCompleted >= 10) required.add(BadgeCatalog.level10);
    if (totalLevelsCompleted >= 25) required.add(BadgeCatalog.level25);

    if (totalXp >= 100) required.add(BadgeCatalog.xp100);
    if (totalXp >= 500) required.add(BadgeCatalog.xp500);
    if (totalXp >= 1000) required.add(BadgeCatalog.xp1000);

    return required.difference(existingBadgeCodes);
  }

  /// Achievement yang harus dimiliki user tapi belum ada di
  /// [existingAchievementCodes].
  ///
  /// Achievement berbasis kejadian (bukan ambang milestone).
  static Set<String> computeMissingAchievements({
    required Set<String> existingAchievementCodes,
    required bool hasEverLoggedIn,
    required bool hasEverPassedQuiz,
    required int levelsCompletedInChapter1,
  }) {
    final Set<String> required = <String>{};

    if (hasEverLoggedIn) required.add(AchievementCatalog.firstLogin);
    if (hasEverPassedQuiz) required.add(AchievementCatalog.firstQuizPass);
    if (levelsCompletedInChapter1 >= 15) {
      required.add(AchievementCatalog.completeChapter1);
    }

    return required.difference(existingAchievementCodes);
  }

  /// Jumlah level dengan status `completed`.
  static int totalLevelsCompleted(List<String> progressStatuses) =>
      progressStatuses.where((String status) => status == 'completed').length;

  /// Jumlah level selesai pada bab 1 (Level 1 sampai 15).
  static int levelsCompletedChapter1(List<Map<String, dynamic>> progressList) {
    return progressList
        .where(
          (Map<String, dynamic> row) =>
              row['status'] == 'completed' &&
              (row['level_id'] as int) >= 1 &&
              (row['level_id'] as int) <= 15,
        )
        .length;
  }

  /// Payload baris badge (INSERT ke `user_badges`).
  ///
  /// Kolom `id` tidak ikut dikirim supaya primary key dibuat database.
  static List<Map<String, dynamic>> buildBadgeRows({
    required String userId,
    required Set<String> badgeCodes,
    required DateTime earnedAt,
  }) {
    final String iso = earnedAt.toUtc().toIso8601String();
    return badgeCodes
        .map(
          (String code) => <String, dynamic>{
            'user_id': userId,
            'badge_code': code,
            'earned_at': iso,
          },
        )
        .toList();
  }

  /// Payload baris achievement (INSERT ke `user_achievements`).
  static List<Map<String, dynamic>> buildAchievementRows({
    required String userId,
    required Set<String> achievementCodes,
    required DateTime earnedAt,
  }) {
    final String iso = earnedAt.toUtc().toIso8601String();
    return achievementCodes
        .map(
          (String code) => <String, dynamic>{
            'user_id': userId,
            'achievement_code': code,
            'earned_at': iso,
          },
        )
        .toList();
  }
}
