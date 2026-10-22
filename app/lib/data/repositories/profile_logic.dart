import 'badge_logic.dart';

/// Aturan tampilan layar Profil (P4-011) yang berdiri sendiri tanpa bergantung
/// pada Supabase maupun widget, supaya bisa diuji unit test tanpa perangkat.
///
/// Semua fungsi di sini murni: masukan sama selalu menghasilkan keluaran sama.
class ProfileLogic {
  const ProfileLogic._();

  /// Nama topik cadangan bila `levels.topic` kosong atau null.
  static const String fallbackTopic = 'Umum';

  /// Kelompokkan mastery per topik menjadi `{topic: rata-rata}`.
  ///
  /// Baris dengan `masteryScore <= 0` dilewati karena belum ada bukti
  /// penguasaan. Baris dengan `levelId` yang tidak dikenal juga dilewati
  /// supaya data lama tidak membuat layar crash.
  ///
  /// Parameter [progress] berisi peta dengan kunci `levelId` dan
  /// `masteryScore` (rentang 0.0 sampai 1.0). Parameter [levelIdToTopic]
  /// memetakan id level ke nama topik.
  static Map<String, double> groupMasteryByTopic({
    required List<Map<String, dynamic>> progress,
    required Map<int, String> levelIdToTopic,
  }) {
    final Map<String, List<double>> groups = <String, List<double>>{};

    for (final Map<String, dynamic> row in progress) {
      final double mastery = (row['masteryScore'] as num?)?.toDouble() ?? 0;
      if (mastery <= 0) continue;

      final int? levelId = (row['levelId'] as num?)?.toInt();
      if (levelId == null) continue;

      final String? rawTopic = levelIdToTopic[levelId];
      final String topic = (rawTopic == null || rawTopic.trim().isEmpty)
          ? fallbackTopic
          : rawTopic.trim();

      groups.putIfAbsent(topic, () => <double>[]).add(mastery);
    }

    return <String, double>{
      for (final MapEntry<String, List<double>> entry in groups.entries)
        entry.key:
            entry.value.reduce((double a, double b) => a + b) /
            entry.value.length,
    };
  }

  /// Ubah tanggal menjadi label relatif berbahasa Indonesia.
  ///
  /// Perbandingan memakai tanggal kalender (bukan selisih jam) supaya
  /// aktivitas pukul 23.59 tetap terbaca "Hari ini" keesokan paginya.
  static String formatRelativeDate(DateTime date, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final DateTime target = DateTime(date.year, date.month, date.day);
    final int days = today.difference(target).inDays;

    if (days <= 0) return 'Hari ini';
    if (days == 1) return 'Kemarin';
    if (days < 7) return '$days hari lalu';
    if (days < 30) {
      final int weeks = days ~/ 7;
      return weeks == 1 ? '1 minggu lalu' : '$weeks minggu lalu';
    }
    if (days < 365) {
      final int months = days ~/ 30;
      return months == 1 ? '1 bulan lalu' : '$months bulan lalu';
    }
    final int years = days ~/ 365;
    return years == 1 ? '1 tahun lalu' : '$years tahun lalu';
  }

  /// Tanggal ringkas berbahasa Indonesia, contoh `22 Okt 2026`.
  static String formatShortDate(DateTime date) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final String month = months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  /// Level yang sedang dikerjakan user.
  ///
  /// Aturan: ambil level `active` tertinggi; bila tidak ada, ambil level
  /// `completed` tertinggi lalu tambah satu. Bila tidak ada progress sama
  /// sekali, user mulai dari level 1.
  ///
  /// Nilai `active` tetap dipakai bila lebih tinggi dari saran `completed + 1`,
  /// sehingga data yang tidak konsisten tidak menurunkan level tampilan.
  static int computeActiveLevel(List<Map<String, dynamic>> progress) {
    int highestActive = 0;
    int highestCompleted = 0;

    for (final Map<String, dynamic> row in progress) {
      final String status = row['status'] as String? ?? '';
      final int levelId = (row['levelId'] as num?)?.toInt() ?? 0;
      if (levelId <= 0) continue;

      if (status == 'active' && levelId > highestActive) {
        highestActive = levelId;
      }
      if (status == 'completed' && levelId > highestCompleted) {
        highestCompleted = levelId;
      }
    }

    final int nextFromCompleted = highestCompleted > 0
        ? highestCompleted + 1
        : 0;
    final int candidate = highestActive > nextFromCompleted
        ? highestActive
        : nextFromCompleted;

    return candidate > 0 ? candidate : 1;
  }

  /// Nama tampilan badge dari kode penyimpanan.
  ///
  /// Kode yang belum dikenal dikembalikan apa adanya supaya badge baru dari
  /// server tetap tampil tanpa perlu rilis aplikasi.
  static String badgeDisplayName(String code) {
    switch (code) {
      case BadgeCatalog.streak3:
        return '3 Hari';
      case BadgeCatalog.streak7:
        return 'Seminggu';
      case BadgeCatalog.streak30:
        return 'Sebulan';
      case BadgeCatalog.level5:
        return '5 Level';
      case BadgeCatalog.level10:
        return '10 Level';
      case BadgeCatalog.level25:
        return '25 Level';
      case BadgeCatalog.xp100:
        return '100 XP';
      case BadgeCatalog.xp500:
        return '500 XP';
      case BadgeCatalog.xp1000:
        return '1000 XP';
      default:
        return code;
    }
  }

  /// Nama tampilan achievement dari kode penyimpanan.
  static String achievementDisplayName(String code) {
    switch (code) {
      case AchievementCatalog.firstLogin:
        return 'Login Pertama';
      case AchievementCatalog.firstQuizPass:
        return 'Kuis Pertama Lulus';
      case AchievementCatalog.completeChapter1:
        return 'Bab 1 Selesai (L1-15)';
      default:
        return code;
    }
  }

  /// Label status progress untuk daftar aktivitas.
  static String activityStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'active':
        return 'Sedang belajar';
      case 'remedial':
        return 'Remedial';
      case 'locked':
        return 'Terkunci';
      default:
        return status;
    }
  }
}
