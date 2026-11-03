/// Komponen pembentuk nilai mastery yang dihitung saat submit kuis.
///
/// Nilai ini hanya hidup di memori selama alur hasil kuis. Tidak ada
/// persistensi ke database, sehingga baris lama tidak memiliki breakdown.
class MasteryBreakdown {
  /// Akurasi jawaban benar (`correct / total`), rentang 0.0–1.0.
  final double accuracy;

  /// Konsistensi dari mastery terbaik sebelumnya, rentang 0.0–1.0.
  final double consistency;

  /// Waktu pengerjaan ternormalisasi, rentang 0.0–1.0.
  final double timeNorm;

  /// Nilai mastery total hasil formula, rentang 0.0–1.0.
  final double total;

  MasteryBreakdown({
    required double accuracy,
    required double consistency,
    required double timeNorm,
    required double total,
  }) : accuracy = _clamp01(accuracy),
       consistency = _clamp01(consistency),
       timeNorm = _clamp01(timeNorm),
       total = _clamp01(total);

  /// Tingkat kesalahan turunan: `1 - accuracy`.
  double get errorRate => 1.0 - accuracy;

  /// Kontribusi akurasi gabungan (A + komponen E) ke nilai mastery.
  ///
  /// Formula asli memakai `0.45·A + 0.20·(1 − E)`. Karena `E = 1 − A`,
  /// kedua suku itu setara dengan `0.65·A`.
  double get combinedAccuracyContribution => 0.65 * accuracy;

  /// Kontribusi kecepatan ke nilai mastery: `0.10·(1 − Tn)`.
  double get speedContribution => 0.10 * (1.0 - timeNorm);

  static double _clamp01(double value) {
    if (value.isNaN) return 0.0;
    if (value <= 0.0) return 0.0;
    if (value >= 1.0) return 1.0;
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasteryBreakdown &&
          other.accuracy == accuracy &&
          other.consistency == consistency &&
          other.timeNorm == timeNorm &&
          other.total == total;

  @override
  int get hashCode => Object.hash(accuracy, consistency, timeNorm, total);

  @override
  String toString() =>
      'MasteryBreakdown(accuracy: $accuracy, consistency: $consistency, '
      'timeNorm: $timeNorm, total: $total)';
}
