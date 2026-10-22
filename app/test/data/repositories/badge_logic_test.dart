import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/badge_logic.dart';

void main() {
  group('BadgeLogic.computeMissingBadges', () {
    test('streak di bawah ambang -> belum ada badge streak', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 2,
        totalLevelsCompleted: 0,
        totalXp: 0,
      );

      expect(missing, isEmpty);
    });

    test('streak 3 -> badge streak 3', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 3,
        totalLevelsCompleted: 0,
        totalXp: 0,
      );

      expect(missing, <String>{BadgeCatalog.streak3});
    });

    test('streak 7 -> badge streak 3 dan 7', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 7,
        totalLevelsCompleted: 0,
        totalXp: 0,
      );

      expect(missing, <String>{BadgeCatalog.streak3, BadgeCatalog.streak7});
    });

    test('streak 30 -> seluruh badge streak', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 30,
        totalLevelsCompleted: 0,
        totalXp: 0,
      );

      expect(missing, <String>{
        BadgeCatalog.streak3,
        BadgeCatalog.streak7,
        BadgeCatalog.streak30,
      });
    });

    test('5 level selesai -> badge level 5', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 0,
        totalLevelsCompleted: 5,
        totalXp: 0,
      );

      expect(missing, <String>{BadgeCatalog.level5});
    });

    test('10 level selesai -> badge level 5 dan 10', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 0,
        totalLevelsCompleted: 10,
        totalXp: 0,
      );

      expect(missing, <String>{BadgeCatalog.level5, BadgeCatalog.level10});
    });

    test('25 level selesai -> seluruh badge level', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 0,
        totalLevelsCompleted: 25,
        totalXp: 0,
      );

      expect(missing, <String>{
        BadgeCatalog.level5,
        BadgeCatalog.level10,
        BadgeCatalog.level25,
      });
    });

    test('100 XP -> badge XP 100', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 0,
        totalLevelsCompleted: 0,
        totalXp: 100,
      );

      expect(missing, <String>{BadgeCatalog.xp100});
    });

    test('500 XP -> badge XP 100 dan 500', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 0,
        totalLevelsCompleted: 0,
        totalXp: 500,
      );

      expect(missing, <String>{BadgeCatalog.xp100, BadgeCatalog.xp500});
    });

    test('1000 XP -> seluruh badge XP', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 0,
        totalLevelsCompleted: 0,
        totalXp: 1000,
      );

      expect(missing, <String>{
        BadgeCatalog.xp100,
        BadgeCatalog.xp500,
        BadgeCatalog.xp1000,
      });
    });

    test('badge yang sudah dimiliki tidak diberi lagi', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{BadgeCatalog.streak3, BadgeCatalog.xp100},
        currentStreak: 3,
        totalLevelsCompleted: 0,
        totalXp: 100,
      );

      expect(missing, isEmpty);
    });

    test('kombinasi beberapa milestone', () {
      final Set<String> missing = BadgeLogic.computeMissingBadges(
        existingBadgeCodes: <String>{},
        currentStreak: 7,
        totalLevelsCompleted: 5,
        totalXp: 500,
      );

      expect(missing, <String>{
        BadgeCatalog.streak3,
        BadgeCatalog.streak7,
        BadgeCatalog.level5,
        BadgeCatalog.xp100,
        BadgeCatalog.xp500,
      });
    });
  });

  group('BadgeLogic.computeMissingAchievements', () {
    test('sudah login -> achievement login pertama', () {
      final Set<String> missing = BadgeLogic.computeMissingAchievements(
        existingAchievementCodes: <String>{},
        hasEverLoggedIn: true,
        hasEverPassedQuiz: false,
        levelsCompletedInChapter1: 0,
      );

      expect(missing, <String>{AchievementCatalog.firstLogin});
    });

    test('belum pernah login -> achievement login pertama tidak diberikan', () {
      final Set<String> missing = BadgeLogic.computeMissingAchievements(
        existingAchievementCodes: <String>{},
        hasEverLoggedIn: false,
        hasEverPassedQuiz: true,
        levelsCompletedInChapter1: 15,
      );

      expect(missing, <String>{
        AchievementCatalog.firstQuizPass,
        AchievementCatalog.completeChapter1,
      });
    });

    test('belum ada kejadian sama sekali -> tidak ada achievement', () {
      final Set<String> missing = BadgeLogic.computeMissingAchievements(
        existingAchievementCodes: <String>{},
        hasEverLoggedIn: false,
        hasEverPassedQuiz: false,
        levelsCompletedInChapter1: 0,
      );

      expect(missing, isEmpty);
    });

    test('sudah menyelesaikan satu level -> achievement kuis pertama', () {
      final Set<String> missing = BadgeLogic.computeMissingAchievements(
        existingAchievementCodes: <String>{},
        hasEverLoggedIn: true,
        hasEverPassedQuiz: true,
        levelsCompletedInChapter1: 1,
      );

      expect(missing, <String>{
        AchievementCatalog.firstLogin,
        AchievementCatalog.firstQuizPass,
      });
    });

    test('15 level bab 1 selesai -> achievement bab 1', () {
      final Set<String> missing = BadgeLogic.computeMissingAchievements(
        existingAchievementCodes: <String>{},
        hasEverLoggedIn: true,
        hasEverPassedQuiz: true,
        levelsCompletedInChapter1: 15,
      );

      expect(missing, <String>{
        AchievementCatalog.firstLogin,
        AchievementCatalog.firstQuizPass,
        AchievementCatalog.completeChapter1,
      });
    });

    test('achievement yang sudah dimiliki tidak diberi lagi', () {
      final Set<String> missing = BadgeLogic.computeMissingAchievements(
        existingAchievementCodes: <String>{AchievementCatalog.firstLogin},
        hasEverLoggedIn: true,
        hasEverPassedQuiz: true,
        levelsCompletedInChapter1: 1,
      );

      expect(missing, <String>{AchievementCatalog.firstQuizPass});
    });
  });

  group('statistik progress', () {
    test('totalLevelsCompleted hanya menghitung status completed', () {
      final int total = BadgeLogic.totalLevelsCompleted(<String>[
        'completed',
        'active',
        'completed',
        'locked',
      ]);

      expect(total, 2);
    });

    test('levelsCompletedChapter1 hanya menghitung level 1 sampai 15', () {
      final int total = BadgeLogic.levelsCompletedChapter1(
        <Map<String, dynamic>>[
          <String, dynamic>{'level_id': 1, 'status': 'completed'},
          <String, dynamic>{'level_id': 15, 'status': 'completed'},
          <String, dynamic>{'level_id': 16, 'status': 'completed'},
          <String, dynamic>{'level_id': 2, 'status': 'active'},
        ],
      );

      expect(total, 2);
    });
  });

  group('katalog', () {
    test('9 badge dengan kode unik', () {
      expect(BadgeCatalog.all.length, 9);
      expect(BadgeCatalog.all.toSet().length, 9);
    });

    test('3 achievement dengan kode unik', () {
      expect(AchievementCatalog.all.length, 3);
      expect(AchievementCatalog.all.toSet().length, 3);
    });
  });

  group('payload', () {
    final DateTime earnedAt = DateTime.utc(2026, 10, 22, 8);

    test('buildBadgeRows memakai kolom badge_code dan earned_at', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildBadgeRows(
        userId: 'user-1',
        badgeCodes: <String>{BadgeCatalog.streak3, BadgeCatalog.xp100},
        earnedAt: earnedAt,
      );

      expect(rows.length, 2);
      expect(rows.first['user_id'], 'user-1');
      expect(rows.first['earned_at'], '2026-10-22T08:00:00.000Z');
      expect(
        rows.map((Map<String, dynamic> row) => row['badge_code']).toSet(),
        <String>{BadgeCatalog.streak3, BadgeCatalog.xp100},
      );
    });

    test('buildBadgeRows tidak mengirim kolom id', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildBadgeRows(
        userId: 'user-1',
        badgeCodes: <String>{BadgeCatalog.xp100},
        earnedAt: earnedAt,
      );

      expect(rows.first.containsKey('id'), isFalse);
      expect(rows.first.keys.toSet(), <String>{
        'user_id',
        'badge_code',
        'earned_at',
      });
    });

    test('buildAchievementRows memakai kolom achievement_code', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildAchievementRows(
        userId: 'user-1',
        achievementCodes: <String>{AchievementCatalog.firstLogin},
        earnedAt: earnedAt,
      );

      expect(rows.first['achievement_code'], 'first_login');
      expect(rows.first.keys.toSet(), <String>{
        'user_id',
        'achievement_code',
        'earned_at',
      });
    });
  });
}
