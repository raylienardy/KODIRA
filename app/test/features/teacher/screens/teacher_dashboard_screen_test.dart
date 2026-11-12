import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/class_roster_entry.dart';
import 'package:kodira/data/models/student_detail.dart';
import 'package:kodira/data/models/teacher_class_entry.dart';
import 'package:kodira/data/repositories/teacher_repository.dart';
import 'package:kodira/features/teacher/providers/teacher_provider.dart';
import 'package:kodira/features/teacher/screens/teacher_dashboard_screen.dart';

class _FakeTeacherRepository implements TeacherRepository {
  _FakeTeacherRepository({this.classes = const [], this.error});

  List<TeacherClassEntry> classes;
  Exception? error;

  @override
  Future<List<TeacherClassEntry>> getTeacherClasses(String teacherId) async {
    if (error != null) throw error!;
    return classes;
  }

  @override
  Future<List<ClassRosterEntry>> getClassRoster(String classId) async =>
      const <ClassRosterEntry>[];

  @override
  Future<StudentDetail?> getStudentDetail({
    required String classId,
    required String studentId,
  }) async {
    if (error != null) throw error!;
    return null;
  }
}

void main() {
  late _FakeTeacherRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeTeacherRepository(classes: const <TeacherClassEntry>[]);
  });

  Widget createTestWidget({_FakeTeacherRepository? repository}) {
    final _FakeTeacherRepository repo = repository ?? fakeRepo;
    return ProviderScope(
      overrides: <Override>[
        teacherRepositoryProvider.overrideWithValue(repo),
        teacherClassesProvider.overrideWith(
          (ref) => repo.getTeacherClasses('teacher-1'),
        ),
      ],
      child: const MaterialApp(home: TeacherDashboardScreen()),
    );
  }

  testWidgets('renders loading indicator', (tester) async {
    final completer = Completer<List<TeacherClassEntry>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          teacherRepositoryProvider.overrideWithValue(fakeRepo),
          teacherClassesProvider.overrideWith((ref) => completer.future),
        ],
        child: const MaterialApp(home: TeacherDashboardScreen()),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(
      find.text('Belum ada kelas. Buat kelas baru dulu via menu Buat Kelas.'),
      findsOneWidget,
    );
  });

  testWidgets('renders class list', (tester) async {
    fakeRepo.classes = <TeacherClassEntry>[
      TeacherClassEntry(
        id: 'c1',
        name: 'PTIK B 2024',
        code: 'PTIK24',
        teacherRole: 'owner',
        createdAt: DateTime(2026, 11, 10),
      ),
      TeacherClassEntry(
        id: 'c2',
        name: 'PTIK A 2024',
        code: 'PTIKA1',
        teacherRole: 'co-teacher',
        createdAt: DateTime(2026, 11, 9),
      ),
    ];
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('PTIK B 2024'), findsOneWidget);
    expect(find.text('PTIK A 2024'), findsOneWidget);
    expect(find.text('Kode: PTIK24'), findsOneWidget);
    expect(find.text('Kode: PTIKA1'), findsOneWidget);
  });

  testWidgets('error state shows message', (tester) async {
    final errorRepo = _FakeTeacherRepository(error: Exception('boom'));
    await tester.pumpWidget(createTestWidget(repository: errorRepo));
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat kelas'), findsOneWidget);
  });
}
