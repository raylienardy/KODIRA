/// Aturan bisnis progress belajar (P4-009) yang berdiri sendiri tanpa
/// bergantung pada Supabase, supaya bisa diuji unit test tanpa perangkat.
///
/// Seluruh aturan di sini adalah bentuk murni dari [UserProgressRepository]:
/// memindahkan logika ke kelas ini tidak mengubah perilaku produksi.
class ProgressLogic {
  const ProgressLogic._();

  /// Status `completed` tidak boleh turun ke `active` maupun `remedial`
  /// ketika user mengulang kuis dengan nilai lebih rendah, sehingga level
  /// yang sudah selesai tidak terlihat mundur di peta level.
  ///
  /// Upgrade dari `active` ke `completed` tetap boleh, dan status lain
  /// memakai status baru apa adanya.
  static String computeStatus({
    required String existingStatus,
    required String newStatus,
  }) {
    if (existingStatus == 'completed' &&
        (newStatus == 'active' || newStatus == 'remedial')) {
      return 'completed';
    }
    return newStatus;
  }

  /// Skor mastery terbaik tidak pernah turun.
  static double computeMastery(double existing, double incoming) =>
      incoming > existing ? incoming : existing;

  /// XP terbaik tidak pernah turun.
  static int computeXp(int existing, int incoming) =>
      incoming > existing ? incoming : existing;

  /// Jumlah percobaan bertambah satu setiap kuis dikerjakan.
  static int computeAttempts(int existing) => existing + 1;

  /// `completed_at` hanya diisi kalau status akhirnya `completed`.
  ///
  /// Waktu penyelesaian asli dipertahankan bila sudah ada, supaya tanggal
  /// selesai level tidak berubah karena kuis diulang.
  static DateTime? computeCompletedAt({
    required String finalStatus,
    required DateTime? existing,
    required DateTime now,
  }) {
    if (finalStatus != 'completed') return null;
    return existing ?? now;
  }

  /// Payload baris baru (INSERT) untuk tabel `user_progress`.
  static Map<String, dynamic> buildInsertPayload({
    required String userId,
    required int levelId,
    required String status,
    required double masteryScore,
    required int xpEarned,
    required int attempts,
    required DateTime now,
  }) {
    return <String, dynamic>{
      'user_id': userId,
      'level_id': levelId,
      'status': status,
      'mastery_score': masteryScore,
      'xp_earned': xpEarned,
      'attempts': attempts,
      'last_attempt_at': now.toIso8601String(),
      'completed_at': computeCompletedAt(
        finalStatus: status,
        existing: null,
        now: now,
      )?.toIso8601String(),
    };
  }

  /// Payload update (UPDATE) untuk baris `user_progress` yang sudah ada.
  ///
  /// Mastery, XP, dan waktu penyelesaian memakai nilai terbaik, sedangkan
  /// status memakai [computeStatus] dan attempts bertambah satu.
  static Map<String, dynamic> buildUpdatePayload({
    required String existingStatus,
    required double existingMasteryScore,
    required int existingXpEarned,
    required int existingAttempts,
    required DateTime? existingCompletedAt,
    required String newStatus,
    required double newMasteryScore,
    required int newXpEarned,
    required DateTime now,
  }) {
    final String finalStatus = computeStatus(
      existingStatus: existingStatus,
      newStatus: newStatus,
    );

    return <String, dynamic>{
      'status': finalStatus,
      'mastery_score': computeMastery(existingMasteryScore, newMasteryScore),
      'xp_earned': computeXp(existingXpEarned, newXpEarned),
      'attempts': computeAttempts(existingAttempts),
      'last_attempt_at': now.toIso8601String(),
      'completed_at': computeCompletedAt(
        finalStatus: finalStatus,
        existing: existingCompletedAt,
        now: now,
      )?.toIso8601String(),
    };
  }
}
