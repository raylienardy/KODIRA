import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Tingkat hasil kuis yang menentukan judul, pesan, dan tombol dialog.
enum ResultTier { fail, remedial, pass }

/// Aturan tampilan hasil kuis yang berdiri sendiri tanpa bergantung pada
/// widget, sehingga bisa diuji unit test tanpa perangkat.
class ResultLogic {
  const ResultLogic._();

  /// Klasifikasi hasil berdasarkan rasio jawaban benar.
  static ResultTier computeTier(int score, int total) {
    if (total <= 0) return ResultTier.fail;
    final double ratio = score / total;
    if (ratio >= 0.7) return ResultTier.pass;
    if (ratio >= 0.4) return ResultTier.remedial;
    return ResultTier.fail;
  }

  /// Judul dialog untuk setiap tingkat.
  static String titleFor(ResultTier tier) => switch (tier) {
    ResultTier.pass => 'Lulus!',
    ResultTier.remedial => 'Hampir!',
    ResultTier.fail => 'Belum Lulus',
  };

  /// Subjudul dialog untuk setiap tingkat.
  static String subtitleFor(ResultTier tier) => switch (tier) {
    ResultTier.pass => 'Kamu berhasil menyelesaikan level ini.',
    ResultTier.remedial => 'Coba sekali lagi untuk memperbaiki skor.',
    ResultTier.fail => 'Yuk pelajari materinya lagi sebelum mencoba.',
  };

  /// Label tombol primary.
  ///
  /// Lulus pada level terakhir mengarah ke Home; lulus pada level lain
  /// mengarah ke level berikutnya. Gagal dan remedial mengulang kuis.
  static String primaryLabelFor({
    required ResultTier tier,
    required int levelId,
    required bool isLastLevel,
  }) {
    if (tier == ResultTier.pass) {
      if (isLastLevel) return 'Kembali ke Home';
      return 'Lanjut ke Level ${levelId + 1}';
    }
    return 'Coba Lagi';
  }

  /// Label tombol secondary, atau null bila tombol tidak ditampilkan.
  static String? secondaryLabelFor({
    required ResultTier tier,
    required bool isLastLevel,
  }) {
    if (tier == ResultTier.pass) {
      return isLastLevel ? null : 'Kembali ke Home';
    }
    return 'Review Materi';
  }

  /// Pesan XP di dialog.
  ///
  /// [xpEarned] adalah XP efektif yang tersimpan (nilai tertinggi antara
  /// XP lama dan XP baru), sedangkan [xpThisAttempt] adalah XP mentah dari
  /// percobaan ini. Percobaan ulang pada level yang sudah pernah lulus
  /// memakai XP efektif supaya angka yang ditampilkan tidak menurun.
  static String xpMessageFor({
    required int xpEarned,
    required int xpThisAttempt,
    required bool isFirstCompletion,
    required int attempts,
  }) {
    if (isFirstCompletion) {
      if (xpThisAttempt > 0) {
        return 'Kamu mendapat $xpThisAttempt XP';
      }
      return 'Belum dapat XP. Coba tingkatkan skormu.';
    }
    if (xpEarned > 0) {
      return 'XP sudah maksimal ($xpEarned). Percobaan ke-$attempts.';
    }
    return 'Percobaan ke-$attempts.';
  }

  /// Warna aksen mastery bar dan skor sesuai tingkat hasil.
  static Color masteryColorFor(ResultTier tier) => switch (tier) {
    ResultTier.pass => KodiraColors.success500,
    ResultTier.remedial => KodiraColors.reward500,
    ResultTier.fail => KodiraColors.alert700,
  };
}
