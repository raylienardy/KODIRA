/// Satu baris roster mahasiswa pada sebuah kelas.
///
/// Datanya diambil dari view `leaderboard_by_class` yang memakai LEFT JOIN ke
/// `user_progress` + `COALESCE(..., 0)`, sehingga mahasiswa yang belum punya
/// progress tetap muncul dengan [totalXp] bernilai 0.
class ClassRosterEntry {
  final String userId;
  final String name;
  final String nim;
  final int totalXp;

  const ClassRosterEntry({
    required this.userId,
    required this.name,
    required this.nim,
    required this.totalXp,
  });
}
