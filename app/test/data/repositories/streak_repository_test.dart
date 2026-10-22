import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/streak_logic.dart';

/// Kontrak tulis pada tabel `user_streaks`.
///
/// CATATAN PENTING — integration test di-defer ke Phase 6 (P6-001):
///
/// [StreakRepository] menerima `SupabaseClient` (kelas konkret, bukan
/// interface), sehingga round-trip ke database tidak bisa dipalsukan tanpa
/// mock. Seluruh aturan bisnisnya berada di [StreakLogic] yang diuji penuh di
/// `streak_logic_test.dart`, dan test di bawah memverifikasi payload persis
/// yang dikirim repository ke tabel `user_streaks`.
///
/// Kolom `user_streaks` hanya `user_id`, `current_streak`, `longest_streak`,
/// dan `last_active_date` (tipe DATE). Kolom `updated_at` TIDAK ADA, sehingga
/// payload tidak boleh mengirim field tersebut.
void main() {
  final DateTime now = DateTime(2026, 10, 22, 9);

  group('payload insert StreakRepository', () {
    test('berisi user, streak, dan tanggal aktif', () {
      final Map<String, dynamic> payload = StreakLogic.buildInsertPayload(
        userId: 'user-1',
        currentStreak: 1,
        longestStreak: 1,
        lastActiveDate: now,
      );

      expect(payload['user_id'], 'user-1');
      expect(payload['current_streak'], 1);
      expect(payload['longest_streak'], 1);
      expect(payload['last_active_date'], '2026-10-22');
    });

    test('tidak mengirim kolom updated_at yang tidak ada di tabel', () {
      final Map<String, dynamic> payload = StreakLogic.buildInsertPayload(
        userId: 'user-1',
        currentStreak: 1,
        longestStreak: 1,
        lastActiveDate: now,
      );

      expect(payload.containsKey('updated_at'), isFalse);
      expect(payload.keys.toSet(), <String>{
        'user_id',
        'current_streak',
        'longest_streak',
        'last_active_date',
      });
    });
  });

  group('payload update StreakRepository', () {
    test('hanya mengirim streak dan tanggal aktif', () {
      final Map<String, dynamic> payload = StreakLogic.buildUpdatePayload(
        currentStreak: 5,
        longestStreak: 9,
        lastActiveDate: now,
      );

      expect(payload['current_streak'], 5);
      expect(payload['longest_streak'], 9);
      expect(payload['last_active_date'], '2026-10-22');
      expect(payload.containsKey('updated_at'), isFalse);
      expect(payload.containsKey('user_id'), isFalse);
    });

    test('tanggal aktif memakai format YYYY-MM-DD tanpa jam', () {
      final Map<String, dynamic> payload = StreakLogic.buildUpdatePayload(
        currentStreak: 2,
        longestStreak: 2,
        lastActiveDate: DateTime(2026, 1, 5, 23, 59, 59),
      );

      expect(payload['last_active_date'], '2026-01-05');
    });
  });

  group('aturan streak harian', () {
    test('sudah aktif hari ini -> tidak ada perubahan yang ditulis', () {
      final DateTime lastActive = DateTime(2026, 10, 22, 6);
      final int current = StreakLogic.computeCurrentStreak(
        lastActiveDate: lastActive,
        currentStreak: 3,
        now: now,
      );

      expect(
        StreakLogic.isActiveToday(lastActiveDate: lastActive, now: now),
        isTrue,
      );
      expect(current, 3);
    });

    test('rekor streak memakai nilai tertinggi', () {
      final int longest = StreakLogic.computeLongestStreak(
        currentStreak: 2,
        longestStreak: 9,
      );

      expect(longest, 9);
    });

    test('streak lanjut naik satu dan rekor ikut naik', () {
      final int current = StreakLogic.computeCurrentStreak(
        lastActiveDate: DateTime(2026, 10, 21, 23),
        currentStreak: 3,
        now: now,
      );
      final int longest = StreakLogic.computeLongestStreak(
        currentStreak: current,
        longestStreak: 3,
      );

      expect(current, 4);
      expect(longest, 4);
    });
  });
}
