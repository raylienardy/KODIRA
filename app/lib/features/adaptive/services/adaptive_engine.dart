/// Tingkat pencapaian mastery hasil evaluasi adaptif.
enum AdaptiveTier { pass, remedial, fail }

/// Mesin adaptif KODIRA berbasis aturan (rule-based) sesuai spesifikasi PRD & arsitektur.
///
/// Formula mastery:
/// `M = 0.45A + 0.25C + 0.20(1 - E) + 0.10(1 - Tn)`
///
/// Referensi spesifikasi:
/// - `docs/03-architecture.md` §7.1: Formula Mastery & aturan adaptasi
/// - `docs/04-guidelines.md` §6.2: Parameter akurasi, selesai, error, dan waktu
///
/// Interpretasi variabel:
/// - `A`  (Accuracy): Rasio jawaban benar terhadap total soal (`correct / total`, rentang 0.0–1.0).
/// - `C`  (Consistency / Completed): Riwayat mastery terbaik sebelumnya dari `user_progress`
///        (`previousMastery` di-clamp 0.0–1.0; bernilai 0.0 pada attempt pertama).
/// - `E`  (Error rate): Tingkat kesalahan (`1.0 - accuracy`). Komponen `(1 - E)` sebanding dengan akurasi.
/// - `Tn` (Normalized Time): Rata-rata detik per soal dinormalisasi terhadap batas waktu soal
///        (`avgSeconds / timeLimitPerQuestion`, di-clamp 0.0–1.0). `(1 - Tn)` mengapresiasi kecepatan.
class AdaptiveEngine {
  const AdaptiveEngine._();

  /// Ambang batas kelulusan dan pembukaan level berikutnya (M >= 70%).
  static const double masteryPass = 0.70;

  /// Ambang batas minimum remedial (M >= 40%). Nilai di bawah ini memicu remedial kuis AI.
  static const double masteryRemedialMin = 0.40;

  /// Hitung skor mastery komprehensif dari performa pengerjaan kuis.
  static double computeMastery({
    required int correct,
    required int total,
    required int secondsUsed,
    required int timeLimitPerQuestion,
    double previousMastery = 0.0,
  }) {
    if (total <= 0) return 0.0;

    final int effectiveLimit = timeLimitPerQuestion > 0
        ? timeLimitPerQuestion
        : 60;
    final int safeSeconds = secondsUsed > 0 ? secondsUsed : 0;
    final int safeCorrect = correct.clamp(0, total);

    // A: akurasi jawaban benar (0.0 - 1.0)
    final double accuracy = safeCorrect / total;

    // C: konsistensi pencapaian dari riwayat terbaik sebelumnya (0.0 - 1.0)
    final double consistency = previousMastery.clamp(0.0, 1.0);

    // E: tingkat kesalahan (0.0 - 1.0)
    final double errorRate = 1.0 - accuracy;

    // Tn: waktu pengerjaan ternormalisasi (0.0 - 1.0)
    final double avgPerQuestion = safeSeconds / total;
    final double timeNorm = (avgPerQuestion / effectiveLimit).clamp(0.0, 1.0);

    final double mastery =
        0.45 * accuracy +
        0.25 * consistency +
        0.20 * (1.0 - errorRate) +
        0.10 * (1.0 - timeNorm);

    return mastery.clamp(0.0, 1.0);
  }

  /// Klasifikasikan tingkat adaptif berdasarkan nilai mastery.
  static AdaptiveTier classify(double mastery) {
    if (mastery >= masteryPass) return AdaptiveTier.pass;
    if (mastery >= masteryRemedialMin) return AdaptiveTier.remedial;
    return AdaptiveTier.fail;
  }

  /// Menentukan apakah user wajib mendapatkan soal remedial dari AI (M < 40%).
  static bool shouldTriggerRemedialQuiz(double mastery) =>
      mastery < masteryRemedialMin;

  /// Menentukan apakah user memenuhi syarat membuka level berikutnya (M >= 70%).
  static bool shouldUnlockNext(double mastery) => mastery >= masteryPass;
}
