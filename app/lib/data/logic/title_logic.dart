enum UserTitle { pemula, menengah, mahir, master, grandMaster }

/// Hitung gelar (title) user dari total XP tanpa mengubah skema database.
class TitleLogic {
  const TitleLogic._();

  static UserTitle fromTotalXp(int totalXp) {
    final safe = totalXp < 0 ? 0 : totalXp;
    if (safe >= 7000) return UserTitle.grandMaster;
    if (safe >= 3500) return UserTitle.master;
    if (safe >= 1500) return UserTitle.mahir;
    if (safe >= 500) return UserTitle.menengah;
    return UserTitle.pemula;
  }

  static String label(UserTitle title) => switch (title) {
    UserTitle.pemula => 'Pemula',
    UserTitle.menengah => 'Menengah',
    UserTitle.mahir => 'Mahir',
    UserTitle.master => 'Master',
    UserTitle.grandMaster => 'Grand Master',
  };

  static String description(UserTitle title) => switch (title) {
    UserTitle.pemula => 'Baru memulai perjalanan belajar',
    UserTitle.menengah => 'Sudah menguasai dasar-dasar',
    UserTitle.mahir => 'Konsisten dan produktif',
    UserTitle.master => 'Penguasaan level lanjut',
    UserTitle.grandMaster => 'Puncak pencapaian KODIRA',
  };

  static String emoji(UserTitle title) => switch (title) {
    UserTitle.pemula => '🌱',
    UserTitle.menengah => '🌿',
    UserTitle.mahir => '🌳',
    UserTitle.master => '🏆',
    UserTitle.grandMaster => '👑',
  };
}
