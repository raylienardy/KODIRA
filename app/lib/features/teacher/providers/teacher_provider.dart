import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/class_roster_entry.dart';
import '../../../data/models/teacher_class_entry.dart';
import '../../../data/models/student_detail.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../auth/providers/auth_provider.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TeacherRepository(client);
});

final teacherClassesProvider = FutureProvider<List<TeacherClassEntry>>((
  ref,
) async {
  final user = ref.watch(authStateProvider).user;
  if (user == null) return [];
  return ref.read(teacherRepositoryProvider).getTeacherClasses(user.id);
});

final classRosterProvider =
    FutureProvider.family<List<ClassRosterEntry>, String>((ref, classId) async {
      return ref.read(teacherRepositoryProvider).getClassRoster(classId);
    });

class StudentDetailParams {
  final String classId;
  final String studentId;
  const StudentDetailParams({required this.classId, required this.studentId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentDetailParams &&
          other.classId == classId &&
          other.studentId == studentId;

  @override
  int get hashCode => Object.hash(classId, studentId);
}

final studentDetailProvider =
    FutureProvider.family<StudentDetail?, StudentDetailParams>((
      ref,
      params,
    ) async {
      return ref
          .read(teacherRepositoryProvider)
          .getStudentDetail(
            classId: params.classId,
            studentId: params.studentId,
          );
    });
