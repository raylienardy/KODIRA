/// Entri kelas yang diampu oleh seorang dosen.
///
/// Datanya diambil dari tabel M:N `class_teachers` yang di-embed dengan tabel
/// `classes`, jadi [id] merujuk ke `classes.id` (bukan ke `class_teachers.id`).
class TeacherClassEntry {
  final String id;
  final String name;
  final String code;
  final String? description;

  /// Peran dosen pada kelas ini: `owner` atau `co-teacher`.
  final String teacherRole;

  final DateTime createdAt;

  const TeacherClassEntry({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.teacherRole,
    required this.createdAt,
  });
}
