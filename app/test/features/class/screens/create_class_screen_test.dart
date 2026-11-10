import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/my_class_model.dart';
import 'package:kodira/data/repositories/class_repository.dart';
import 'package:kodira/features/class/providers/class_provider.dart';
import 'package:kodira/features/class/screens/create_class_screen.dart';

class _FakeClassRepository implements ClassRepository {
  _FakeClassRepository();

  Map<String, dynamic> createResult = <String, dynamic>{
    'success': true,
    'class_id': 'class-new',
    'code': 'AB12CD',
    'name': 'Pemrograman Dasar - A',
  };

  int createCalls = 0;
  String? lastName;
  String? lastDescription;

  @override
  Future<Map<String, dynamic>> createClass({
    required String name,
    String? description,
  }) async {
    createCalls += 1;
    lastName = name;
    lastDescription = description;
    return createResult;
  }

  @override
  Future<List<MyClass>> getMyClasses(String userId) async => const <MyClass>[];

  @override
  Future<Map<String, dynamic>> joinClass(String code) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setPrimaryClass(String classId) async {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeClassRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeClassRepository();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: <Override>[
        classRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(home: CreateClassScreen()),
    );
  }

  Future<void> submitForm(
    WidgetTester tester, {
    String name = 'Pemrograman Dasar - A',
    String description = '',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), name);
    await tester.enterText(find.byType(TextFormField).at(1), description);
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Buat Kelas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('rendersForm', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Buat Kelas'), findsNWidgets(2));
    expect(find.text('Kelas Baru'), findsOneWidget);
    expect(find.text('Nama Kelas'), findsOneWidget);
    expect(find.text('Deskripsi (opsional)'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('validationEmptyName', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitForm(tester, name: '');

    expect(find.text('Nama kelas wajib diisi'), findsOneWidget);
    expect(fakeRepo.createCalls, 0);
  });

  testWidgets('validationShortName', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitForm(tester, name: 'AB');

    expect(find.text('Nama kelas minimal 3 karakter'), findsOneWidget);
    expect(fakeRepo.createCalls, 0);
  });

  testWidgets('successCreateShowsCodeDialog', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitForm(tester, name: 'Kelas Demo', description: 'Kelas uji coba');

    expect(fakeRepo.createCalls, 1);
    expect(fakeRepo.lastName, 'Kelas Demo');
    expect(fakeRepo.lastDescription, 'Kelas uji coba');
    expect(find.text('Kelas berhasil dibuat'), findsOneWidget);
    expect(find.text('AB12CD'), findsOneWidget);
    expect(find.text('Salin Kode'), findsOneWidget);
  });

  testWidgets('notTeacherShowsError', (tester) async {
    fakeRepo.createResult = <String, dynamic>{'error': 'not_teacher'};
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitForm(tester);

    expect(fakeRepo.createCalls, 1);
    expect(find.text('Hanya dosen yang bisa membuat kelas'), findsOneWidget);
    expect(find.text('Kelas berhasil dibuat'), findsNothing);
  });

  testWidgets('copyCodeShowsSnackBar', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitForm(tester);
    expect(find.text('AB12CD'), findsOneWidget);

    await tester.tap(find.text('Salin Kode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Kode disalin'), findsOneWidget);
  });
}
