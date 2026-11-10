import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/class_roster_entry.dart';
import 'package:kodira/data/models/teacher_class_entry.dart';
import 'package:kodira/data/repositories/teacher_repository.dart';
import 'package:kodira/features/teacher/providers/teacher_provider.dart';
import 'package:kodira/features/teacher/screens/class_roster_screen.dart';

class _FakeTeacherRepository implements TeacherRepository {
  _FakeTeacherRepository({this.roster = const [], this.error});

  List<ClassRosterEntry> roster;
  Exception? error;

  @override
  Future<List<TeacherClassEntry>> getTeacherClasses(String teacherId) async =>
      const <TeacherClassEntry>[];

  @override
  Future<List<ClassRosterEntry>> getClassRoster(String classId) async {
    if (error != null) throw error!;
    return roster;
  }
}

void main() {
  late _FakeTeacherRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeTeacherRepository(roster: const <ClassRosterEntry>[]);
  });

  Widget createTestWidget({
    String classId = 'cls-1',
    _FakeTeacherRepository? repository,
  }) {
    final _FakeTeacherRepository repo = repository ?? fakeRepo;
    return ProviderScope(
      overrides: <Override>[
        teacherRepositoryProvider.overrideWithValue(repo),
        classRosterProvider(
          classId,
        ).overrideWith((ref) => repo.getClassRoster(classId)),
      ],
      child: MaterialApp(home: ClassRosterScreen(classId: classId)),
    );
  }

  testWidgets('renders loading indicator', (tester) async {
    final completer = Completer<List<ClassRosterEntry>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          teacherRepositoryProvider.overrideWithValue(fakeRepo),
          classRosterProvider('cls-1').overrideWith((ref) => completer.future),
        ],
        child: const MaterialApp(home: ClassRosterScreen(classId: 'cls-1')),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty roster', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Belum ada mahasiswa di kelas ini'), findsOneWidget);
  });

  testWidgets('renders roster rows with XP', (tester) async {
    fakeRepo.roster = <ClassRosterEntry>[
      const ClassRosterEntry(
        userId: 'u1',
        name: 'Andi',
        nim: '2402095010101',
        totalXp: 2500,
      ),
      const ClassRosterEntry(
        userId: 'u2',
        name: 'Budi',
        nim: '2402095010102',
        totalXp: 1800,
      ),
    ];
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('NIM: 2402095010101'), findsOneWidget);
    expect(find.text('2500'), findsOneWidget);
    expect(find.text('1800'), findsOneWidget);
  });

  testWidgets('error state shows message', (tester) async {
    final errorRepo = _FakeTeacherRepository(error: Exception('boom'));
    await tester.pumpWidget(createTestWidget(repository: errorRepo));
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat roster'), findsOneWidget);
  });
}
