import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/badge_logic.dart';

/// Kontrak tulis pada tabel `user_badges` dan `user_achievements`.
///
/// CATATAN PENTING — integration test di-defer ke Phase 6 (P6-001):
///
/// [BadgeRepository] menerima `SupabaseClient` (kelas konkret, bukan
/// interface), sehingga round-trip ke database tidak bisa dipalsukan tanpa
/// mock. Seluruh aturan bisnisnya berada di [BadgeLogic] yang diuji penuh di
/// `badge_logic_test.dart`, dan test di bawah memverifikasi payload persis
/// yang dikirim repository ke kedua tabel.
///
/// Skema tabel:
/// - `user_badges`: id, user_id, badge_code, earned_at, UNIQUE(user_id, badge_code)
/// - `user_achievements`: id, user_id, achievement_code, earned_at,
///   UNIQUE(user_id, achievement_code)
void main() {
  final DateTime earnedAt = DateTime.utc(2026, 10, 22, 8);

  group('payload badge', () {
    test('memakai kolom user_id, badge_code, dan earned_at', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildBadgeRows(
        userId: 'user-1',
        badgeCodes: <String>{BadgeCatalog.streak3},
        earnedAt: earnedAt,
      );

      expect(rows.length, 1);
      expect(rows.first['user_id'], 'user-1');
      expect(rows.first['badge_code'], 'streak_3');
      expect(rows.first['earned_at'], '2026-10-22T08:00:00.000Z');
    });

    test('tidak mengirim kolom id karena primary key dibuat database', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildBadgeRows(
        userId: 'user-1',
        badgeCodes: <String>{BadgeCatalog.level5},
        earnedAt: earnedAt,
      );

      expect(rows.first.containsKey('id'), isFalse);
      expect(rows.first.keys.toSet(), <String>{
        'user_id',
        'badge_code',
        'earned_at',
      });
    });

    test('kumpulan badge kosong menghasilkan tanpa baris', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildBadgeRows(
        userId: 'user-1',
        badgeCodes: <String>{},
        earnedAt: earnedAt,
      );

      expect(rows, isEmpty);
    });
  });

  group('payload achievement', () {
    test('memakai kolom user_id, achievement_code, dan earned_at', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildAchievementRows(
        userId: 'user-1',
        achievementCodes: <String>{AchievementCatalog.completeChapter1},
        earnedAt: earnedAt,
      );

      expect(rows.length, 1);
      expect(rows.first['user_id'], 'user-1');
      expect(rows.first['achievement_code'], 'complete_chapter_1');
      expect(rows.first['earned_at'], '2026-10-22T08:00:00.000Z');
    });

    test('tidak mengirim kolom id dan tidak memakai nama badge_code', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildAchievementRows(
        userId: 'user-1',
        achievementCodes: <String>{AchievementCatalog.firstLogin},
        earnedAt: earnedAt,
      );

      expect(rows.first.containsKey('id'), isFalse);
      expect(rows.first.containsKey('badge_code'), isFalse);
      expect(rows.first.keys.toSet(), <String>{
        'user_id',
        'achievement_code',
        'earned_at',
      });
    });

    test('kumpulan achievement kosong menghasilkan tanpa baris', () {
      final List<Map<String, dynamic>> rows = BadgeLogic.buildAchievementRows(
        userId: 'user-1',
        achievementCodes: <String>{},
        earnedAt: earnedAt,
      );

      expect(rows, isEmpty);
    });
  });

  group('kode badge dan achievement', () {
    test('semua kode katalog berupa string yang tidak kosong', () {
      for (final String code in BadgeCatalog.all) {
        expect(code, isNotEmpty);
      }
      for (final String code in AchievementCatalog.all) {
        expect(code, isNotEmpty);
      }
    });

    test('katalog badge dan achievement tidak saling tumpang tindih', () {
      expect(
        BadgeCatalog.all.toSet().intersection(AchievementCatalog.all.toSet()),
        isEmpty,
      );
    });
  });
}
