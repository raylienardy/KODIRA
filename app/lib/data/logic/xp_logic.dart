/// Tier kesulitan level berdasarkan nomor level.
///
/// Mapping mengikuti `docs/roadmap-upgrade/01-LEVEL-GROUPING.md`:
/// - Mudah: level 1–15
/// - Sedang: level 16–35
/// - Tinggi: level 36–50
enum LevelTier {
  mudah,
  sedang,
  tinggi;

  /// Tentukan tier dari nomor level.
  ///
  /// Melempar [ArgumentError] bila [levelNumber] di luar rentang 1–50.
  static LevelTier fromLevelNumber(int levelNumber) {
    if (levelNumber < 1 || levelNumber > 50) {
      throw ArgumentError.value(
        levelNumber,
        'levelNumber',
        'Nomor level harus berada pada rentang 1..50',
      );
    }
    if (levelNumber <= 15) return LevelTier.mudah;
    if (levelNumber <= 35) return LevelTier.sedang;
    return LevelTier.tinggi;
  }

  /// Label tier dalam bahasa Indonesia.
  String get label => switch (this) {
    LevelTier.mudah => 'Mudah',
    LevelTier.sedang => 'Sedang',
    LevelTier.tinggi => 'Tinggi',
  };
}

/// Hasil perhitungan XP untuk satu percobaan kuis.
///
/// Nilai [attemptXp], [previousXp], dan [finalXp] dijamin minimal 0 oleh
/// [XpLogic.computeAttemptXp]. Constructor tetap `const` dan memakai assert
/// untuk menangkap pemakaian langsung yang melanggar invariant di mode debug.
class XpResult {
  /// XP dasar sebelum multiplier streak.
  final int baseXp;

  /// Pengali streak yang dipakai pada percobaan ini.
  final double multiplier;

  /// XP yang diperoleh dari percobaan ini, minimal 0.
  final int attemptXp;

  /// XP terbaik sebelum percobaan ini, minimal 0.
  final int previousXp;

  /// XP akhir yang layak disimpan, minimal 0.
  final int finalXp;

  /// Apakah percobaan ini lulus (mastery >= 0.70).
  final bool isPass;

  /// Apakah percobaan ini remedial (0.40 <= mastery < 0.70).
  final bool isRemedial;

  /// Apakah percobaan ini gagal (mastery < 0.40).
  final bool isFail;

  /// **Peringatan:** konstruktor ini tidak melakukan clamping. Untuk produksi
  /// gunakan [XpLogic.computeAttemptXp] yang menjamin seluruh nilai XP >= 0.
  /// Konstruktor langsung hanya untuk test atau data yang sudah tervalidasi.
  const XpResult({
    required this.baseXp,
    required this.multiplier,
    required this.attemptXp,
    required this.previousXp,
    required this.finalXp,
    required this.isPass,
    required this.isRemedial,
    required this.isFail,
  }) : assert(baseXp >= 0),
       assert(attemptXp >= 0),
       assert(previousXp >= 0),
       assert(finalXp >= 0);

  /// Apakah percobaan ini menaikkan XP terbaik.
  bool get isImprovement => attemptXp > previousXp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XpResult &&
          other.baseXp == baseXp &&
          other.multiplier == multiplier &&
          other.attemptXp == attemptXp &&
          other.previousXp == previousXp &&
          other.finalXp == finalXp &&
          other.isPass == isPass &&
          other.isRemedial == isRemedial &&
          other.isFail == isFail;

  @override
  int get hashCode => Object.hash(
    baseXp,
    multiplier,
    attemptXp,
    previousXp,
    finalXp,
    isPass,
    isRemedial,
    isFail,
  );

  @override
  String toString() =>
      'XpResult(baseXp: $baseXp, multiplier: $multiplier, '
      'attemptXp: $attemptXp, previousXp: $previousXp, finalXp: $finalXp, '
      'isPass: $isPass, isRemedial: $isRemedial, isFail: $isFail)';
}

/// Aturan XP berbasis tier level dan multiplier streak harian.
///
/// Kelas ini murni dan tidak bergantung pada Flutter/Supabase, sehingga bisa
/// diuji unit test tanpa perangkat. [ProgressLogic.computeXp] yang lama tetap
/// dipertahankan sebagai aturan "XP terbaik tidak pernah turun"; kelas ini
/// hanya menghitung XP percobaan sebelum aturan max tersebut diterapkan.
class XpLogic {
  const XpLogic._();

  /// Ambang mastery lulus, parity dengan `AdaptiveEngine.masteryPass`.
  static const double masteryPassThreshold = 0.70;

  /// Ambang mastery remedial, parity dengan
  /// `AdaptiveEngine.masteryRemedialMin`.
  static const double masteryRemedialMin = 0.40;

  /// XP dasar untuk kombinasi tier dan klasifikasi hasil.
  ///
  /// [isPass] dan [isRemedial] tidak boleh sama-sama true. Bila keduanya
  /// false, hasilnya gagal dan XP dasar bernilai 0.
  static int baseXpFor({
    required LevelTier tier,
    required bool isPass,
    required bool isRemedial,
  }) {
    if (isPass && isRemedial) {
      throw ArgumentError('isPass dan isRemedial tidak boleh sama-sama true');
    }
    if (!isPass && !isRemedial) return 0;
    if (isPass) {
      return switch (tier) {
        LevelTier.mudah => 50,
        LevelTier.sedang => 100,
        LevelTier.tinggi => 150,
      };
    }
    return switch (tier) {
      LevelTier.mudah => 25,
      LevelTier.sedang => 50,
      LevelTier.tinggi => 75,
    };
  }

  /// Pengali streak: 1–6 hari 1.0x, 7–29 hari 1.5x, 30–59 hari 2.0x,
  /// 60 hari atau lebih 2.5x. Nilai negatif diperlakukan sebagai 1.0x.
  static double streakMultiplier(int currentStreak) {
    if (currentStreak < 0) return 1.0;
    if (currentStreak >= 60) return 2.5;
    if (currentStreak >= 30) return 2.0;
    if (currentStreak >= 7) return 1.5;
    return 1.0;
  }

  /// Hitung XP satu percobaan kuis.
  ///
  /// [adaptiveMastery] adalah nilai mastery total (0.0–1.0), bukan rasio
  /// jawaban mentah. [previousXp] adalah XP terbaik yang sudah tersimpan.
  static XpResult computeAttemptXp({
    required double adaptiveMastery,
    required LevelTier tier,
    required int currentStreak,
    required int previousXp,
  }) {
    final double safeMastery = adaptiveMastery.isNaN
        ? 0.0
        : adaptiveMastery.clamp(0.0, 1.0);

    final bool isPass = safeMastery >= masteryPassThreshold;
    final bool isRemedial = !isPass && safeMastery >= masteryRemedialMin;
    final bool isFail = !isPass && !isRemedial;

    final int baseXp = baseXpFor(
      tier: tier,
      isPass: isPass,
      isRemedial: isRemedial,
    );
    final double multiplier = streakMultiplier(currentStreak);
    final int safePreviousXp = previousXp < 0 ? 0 : previousXp;
    final int attemptXp = baseXp == 0 ? 0 : (baseXp * multiplier).round();
    final int finalXp = attemptXp > safePreviousXp ? attemptXp : safePreviousXp;

    return XpResult(
      baseXp: baseXp,
      multiplier: multiplier,
      attemptXp: attemptXp,
      previousXp: safePreviousXp,
      finalXp: finalXp,
      isPass: isPass,
      isRemedial: isRemedial,
      isFail: isFail,
    );
  }
}
