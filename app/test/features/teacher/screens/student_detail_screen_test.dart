import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/class_roster_entry.dart';
import 'package:kodira/data/models/level_model.dart';
import 'package:kodira/data/models/student_detail.dart';
import 'package:kodira/data/models/teacher_class_entry.dart';
import 'package:kodira/data/repositories/teacher_repository.dart';
import 'package:kodira/features/home/providers/level_provider.dart';
import 'package:kodira/features/teacher/providers/teacher_provider.dart';
import 'package:kodira/features/teacher/screens/student_detail_screen.dart';

class _FakeTeacherRepository implements TeacherRepository {
  _FakeTeacherRepository({this.detail, this.error});

  StudentDetail? detail;
  Object? error;

  @override
  Future<List<TeacherClassEntry>> getTeacherClasses(String teacherId) async =>
      const <TeacherClassEntry>[];

  @override
  Future<List<ClassRosterEntry>> getClassRoster(String classId) async =>
      const <ClassRosterEntry>[];

  @override
  Future<StudentDetail?> getStudentDetail({
    required String classId,
    required String studentId,
  }) async {
    if (error != null) throw error!;
    return detail;
  }
}

StudentDetail _detail({
  String name = 'Andi',
  String nim = '2402095010101',
  int totalXp = 2500,
  int levelsCompleted = 8,
  double avgMastery = 0.65,
  Map<String, double> masteryByLevel = const <String, double>{},
}) {
  return StudentDetail(
    classId: 'cls-1',
    studentId: 's1',
    name: name,
    nim: nim,
    totalXp: totalXp,
    levelsCompleted: levelsCompleted,
    avgMastery: avgMastery,
    masteryByLevel: masteryByLevel,
  );
}

final List<LevelModel> _levels = <LevelModel>[
  LevelModel(
    id: 1,
    levelNumber: 1,
    title: 'Dasar C++',
    topic: 'C++',
    createdAt: DateTime(2026, 1, 1),
  ),
  LevelModel(
    id: 2,
    levelNumber: 2,
    title: 'Dasar Java',
    topic: 'Java',
    createdAt: DateTime(2026, 1, 1),
  ),
];

void main() {
  const String classId = 'cls-1';
  const String studentId = 's1';

  Widget createTestWidget({
    required _FakeTeacherRepository repository,
    required List<LevelModel> levels,
  }) {
    return ProviderScope(
      overrides: <Override>[
        teacherRepositoryProvider.overrideWithValue(repository),
        studentDetailProvider(
          const StudentDetailParams(classId: classId, studentId: studentId),
        ).overrideWith(
          (ref) async => repository.getStudentDetail(
            classId: classId,
            studentId: studentId,
          ),
        ),
        allLevelsProvider.overrideWith((ref) async => levels),
      ],
      child: const MaterialApp(
        home: StudentDetailScreen(classId: classId, studentId: studentId),
      ),
    );
  }

  testWidgets('renders loading indicator', (tester) async {
    final completer = Completer<StudentDetail?>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          teacherRepositoryProvider.overrideWithValue(_FakeTeacherRepository()),
          studentDetailProvider(
            const StudentDetailParams(classId: classId, studentId: studentId),
          ).overrideWith((ref) => completer.future),
          allLevelsProvider.overrideWith((ref) async => _levels),
        ],
        child: const MaterialApp(
          home: StudentDetailScreen(classId: classId, studentId: studentId),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders detail with XP and levels completed', (tester) async {
    final repo = _FakeTeacherRepository(detail: _detail());
    await tester.pumpWidget(
      createTestWidget(repository: repo, levels: _levels),
    );
    await tester.pumpAndSettle();

    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('NIM: 2402095010101'), findsOneWidget);
    expect(find.text('2500'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Level Selesai'), findsOneWidget);
  });

  testWidgets('renders mastery per topic grouped from levels', (tester) async {
    final repo = _FakeTeacherRepository(
      detail: _detail(
        avgMastery: 0.625,
        masteryByLevel: const <String, double>{'1': 0.75, '2': 0.50},
      ),
    );
    await tester.pumpWidget(
      createTestWidget(repository: repo, levels: _levels),
    );
    await tester.pumpAndSettle();

    expect(find.text('C++'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Java'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('renders empty mastery state', (tester) async {
    final repo = _FakeTeacherRepository(
      detail: _detail(masteryByLevel: const <String, double>{}),
    );
    await tester.pumpWidget(
      createTestWidget(repository: repo, levels: _levels),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada progress tersimpan untuk mahasiswa ini'),
      findsOneWidget,
    );
  });

  testWidgets('error state shows message', (tester) async {
    final repo = _FakeTeacherRepository(error: Exception('boom'));
    await tester.pumpWidget(
      createTestWidget(repository: repo, levels: _levels),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat detail'), findsOneWidget);
  });

  testWidgets('detail not found shows empty state', (tester) async {
    final repo = _FakeTeacherRepository(detail: null);
    await tester.pumpWidget(
      createTestWidget(repository: repo, levels: _levels),
    );
    await tester.pumpAndSettle();

    expect(find.text('Data mahasiswa tidak ditemukan'), findsOneWidget);
  });
}
