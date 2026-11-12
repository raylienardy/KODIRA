import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/class_roster_entry.dart';
import '../models/teacher_class_entry.dart';
import '../models/student_detail.dart';

/// Repository khusus sisi dosen (Teacher Dashboard).
///
/// Sengaja terpisah dari `ClassRepository` yang fokus pada sisi mahasiswa,
/// supaya repository lama (beserta fake di test existing) tidak berubah.
class TeacherRepository {
  final supa.SupabaseClient _client;
  TeacherRepository(this._client);

  /// Get aggregated student detail from teacher-safe view.
  /// Returns null if student not enrolled in class.
  Future<StudentDetail?> getStudentDetail({
    required String classId,
    required String studentId,
  }) async {
    final response = await _client
        .from('student_detail_by_class')
        .select()
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (response == null) return null;

    final raw = response;
    final masteryJson = raw['mastery_by_level'];
    final masteryMap = <String, double>{};
    if (masteryJson is Map) {
      for (final entry in masteryJson.entries) {
        final v = entry.value;
        if (v is num) {
          masteryMap[entry.key.toString()] = v.toDouble();
        }
      }
    }

    return StudentDetail(
      classId: raw['class_id'] as String,
      studentId: raw['student_id'] as String,
      name: raw['name'] as String,
      nim: raw['nim'] as String,
      totalXp: (raw['total_xp'] as num?)?.toInt() ?? 0,
      levelsCompleted: (raw['levels_completed'] as num?)?.toInt() ?? 0,
      avgMastery: (raw['avg_mastery'] as num?)?.toDouble() ?? 0.0,
      masteryByLevel: masteryMap,
    );
  }

  /// Get classes where user is a teacher (owner/co-teacher).
  /// Query via M:N table `class_teachers` (NOT classes.teacher_id — tidak ada).
  Future<List<TeacherClassEntry>> getTeacherClasses(String teacherId) async {
    final response = await _client
        .from('class_teachers')
        .select('''
          class_id,
          role,
          added_at,
          classes:class_id (
            name,
            code,
            description,
            created_at
          )
        ''')
        .eq('teacher_id', teacherId)
        .order('added_at', ascending: false);

    final data = List<Map<String, dynamic>>.from(response);
    return data.map((row) {
      final cls = row['classes'] as Map<String, dynamic>?;
      final createdAtRaw = cls?['created_at'] as String?;
      return TeacherClassEntry(
        id: row['class_id'] as String,
        name: cls?['name'] as String? ?? 'Unknown',
        code: cls?['code'] as String? ?? '------',
        description: cls?['description'] as String?,
        teacherRole: row['role'] as String? ?? 'owner',
        createdAt: createdAtRaw != null
            ? DateTime.parse(createdAtRaw)
            : DateTime.parse(row['added_at'] as String),
      );
    }).toList();
  }

  /// Get full roster of a class (all students incl. XP=0).
  /// Source: `leaderboard_by_class` view (LEFT JOIN progress + COALESCE 0),
  /// TANPA limit (beda dengan LeaderboardRepository.fetchTop10ByClass).
  Future<List<ClassRosterEntry>> getClassRoster(String classId) async {
    final response = await _client
        .from('leaderboard_by_class')
        .select()
        .eq('class_id', classId)
        .order('total_xp', ascending: false);

    final data = List<Map<String, dynamic>>.from(response);
    return data
        .map(
          (row) => ClassRosterEntry(
            userId: row['user_id'] as String,
            name: row['name'] as String,
            nim: row['nim'] as String,
            totalXp: row['total_xp'] as int,
          ),
        )
        .toList();
  }
}
