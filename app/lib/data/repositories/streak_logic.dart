/// Aturan perhitungan streak harian (P4-010) yang berdiri sendiri tanpa
/// bergantung pada Supabase, supaya bisa diuji unit test tanpa perangkat.
///
/// Seluruh aturan di sini adalah bentuk murni dari [StreakRepository].
class StreakLogic {
  const StreakLogic._();

  /// Menghitung streak baru berdasarkan tanggal aktif terakhir.
  ///
  /// - Tanggal aktif terakhir null -> streak 1 (hari pertama).
  /// - Aktif hari ini -> streak tetap (tidak naik, tidak reset).
  /// - Aktif kemarin -> streak bertambah satu.
  /// - Terputus 2 hari atau lebih -> streak reset ke 1.
  ///
  /// Perbandingan memakai tanggal (hari kalender), bukan jam.
  static int computeCurrentStreak({
    required DateTime? lastActiveDate,
    required int currentStreak,
    required DateTime now,
  }) {
    if (lastActiveDate == null) return 1;

    final DateTime last = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int diff = today.difference(last).inDays;

    if (diff == 0) return currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }

  /// Rekor streak tidak pernah turun.
  static int computeLongestStreak({
    required int currentStreak,
    required int longestStreak,
  }) => currentStreak > longestStreak ? currentStreak : longestStreak;

  /// Apakah user sudah aktif pada hari ini?
  static bool isActiveToday({
    required DateTime? lastActiveDate,
    required DateTime now,
  }) {
    if (lastActiveDate == null) return false;
    final DateTime last = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );
    final DateTime today = DateTime(now.year, now.month, now.day);
    return last == today;
  }

  /// Format tanggal tanpa jam untuk kolom bertipe DATE.
  ///
  /// Contoh hasil: `2026-10-22`.
  static String formatDateOnly(DateTime date) =>
      date.toIso8601String().split('T').first;

  /// Payload baris baru (INSERT) untuk tabel `user_streaks`.
  ///
  /// Kolom `updated_at` tidak ada di tabel sehingga tidak ikut dikirim.
  static Map<String, dynamic> buildInsertPayload({
    required String userId,
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
  }) {
    return <String, dynamic>{
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': formatDateOnly(lastActiveDate),
    };
  }

  /// Payload update (UPDATE) untuk tabel `user_streaks`.
  ///
  /// Kolom `updated_at` tidak ada di tabel sehingga tidak ikut dikirim.
  static Map<String, dynamic> buildUpdatePayload({
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActiveDate,
  }) {
    return <String, dynamic>{
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': formatDateOnly(lastActiveDate),
    };
  }
}
