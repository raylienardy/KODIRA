import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/streak_logic.dart';

void main() {
  // Tanggal acuan: 22 Oktober 2026, 09:00 (waktu lokal).
  final DateTime now = DateTime(2026, 10, 22, 9);

  group('StreakLogic.computeCurrentStreak', () {
    test('belum pernah aktif -> streak 1', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: null,
          currentStreak: 0,
          now: now,
        ),
        1,
      );
    });

    test('aktif hari ini -> streak tidak bertambah', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: DateTime(2026, 10, 22, 1),
          currentStreak: 4,
          now: now,
        ),
        4,
      );
    });

    test('aktif kemarin -> streak bertambah satu', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: DateTime(2026, 10, 21, 23),
          currentStreak: 4,
          now: now,
        ),
        5,
      );
    });

    test('terputus 2 hari -> streak reset ke 1', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: DateTime(2026, 10, 20, 9),
          currentStreak: 4,
          now: now,
        ),
        1,
      );
    });

    test('terputus 7 hari -> streak reset ke 1', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: DateTime(2026, 10, 15, 9),
          currentStreak: 12,
          now: now,
        ),
        1,
      );
    });

    test('beda jam di hari yang sama -> streak tetap', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: DateTime(2026, 10, 22, 23, 59),
          currentStreak: 3,
          now: now,
        ),
        3,
      );
    });

    test('lintas bulan -> streak bertambah satu', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: DateTime(2026, 10, 31, 22),
          currentStreak: 6,
          now: DateTime(2026, 11, 1, 8),
        ),
        7,
      );
    });

    test('lintas tahun -> streak bertambah satu', () {
      expect(
        StreakLogic.computeCurrentStreak(
          lastActiveDate: DateTime(2025, 12, 31, 22),
          currentStreak: 2,
          now: DateTime(2026, 1, 1, 8),
        ),
        3,
      );
    });
  });

  group('StreakLogic.computeLongestStreak', () {
    test('streak saat ini lebih besar -> dipakai yang lebih besar', () {
      expect(
        StreakLogic.computeLongestStreak(currentStreak: 7, longestStreak: 4),
        7,
      );
    });

    test('sama besar -> nilai lama dipertahankan', () {
      expect(
        StreakLogic.computeLongestStreak(currentStreak: 5, longestStreak: 5),
        5,
      );
    });

    test('streak saat ini lebih kecil -> rekor lama dipertahankan', () {
      expect(
        StreakLogic.computeLongestStreak(currentStreak: 2, longestStreak: 9),
        9,
      );
    });
  });

  group('StreakLogic.isActiveToday', () {
    test('belum pernah aktif -> false', () {
      expect(
        StreakLogic.isActiveToday(lastActiveDate: null, now: now),
        isFalse,
      );
    });

    test('aktif hari ini -> true', () {
      expect(
        StreakLogic.isActiveToday(
          lastActiveDate: DateTime(2026, 10, 22, 6),
          now: now,
        ),
        isTrue,
      );
    });

    test('aktif kemarin -> false', () {
      expect(
        StreakLogic.isActiveToday(
          lastActiveDate: DateTime(2026, 10, 21, 23),
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('StreakLogic.formatDateOnly', () {
    test('menghasilkan format YYYY-MM-DD tanpa jam', () {
      expect(
        StreakLogic.formatDateOnly(DateTime(2026, 10, 22, 9, 30)),
        '2026-10-22',
      );
    });

    test('tanggal dengan nol di depan tetap dua digit', () {
      expect(
        StreakLogic.formatDateOnly(DateTime(2026, 1, 5, 12)),
        '2026-01-05',
      );
    });
  });
}
