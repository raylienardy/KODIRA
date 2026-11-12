import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/my_class_model.dart';
import 'package:kodira/data/repositories/class_repository.dart';
import 'package:kodira/features/class/providers/class_provider.dart';
import 'package:kodira/features/class/screens/join_class_screen.dart';

class _FakeClassRepository implements ClassRepository {
  _FakeClassRepository();

  Map<String, dynamic>? joinResult;

  int joinCalls = 0;
  int setPrimaryCalls = 0;
  String? lastCode;
  String? lastPrimaryClassId;

  @override
  Future<List<MyClass>> getMyClasses(String userId) async => const [];

  @override
  Future<Map<String, dynamic>> joinClass(String code) async {
    joinCalls += 1;
    lastCode = code;
    return joinResult ??
        <String, dynamic>{
          'success': true,
          'already_member': false,
          'class': <String, dynamic>{'name': 'PTIK B 2024'},
        };
  }

  @override
  Future<void> setPrimaryClass(String classId) async {
    setPrimaryCalls += 1;
    lastPrimaryClassId = classId;
  }

  @override
  Future<Map<String, dynamic>> createClass({
    required String name,
    String? description,
  }) async {
    throw UnimplementedError();
  }
}

MyClass _buildClass({
  required String id,
  required String name,
  required String code,
  bool isPrimary = false,
}) {
  return MyClass(
    id: id,
    name: name,
    code: code,
    isPrimary: isPrimary,
    enrolledAt: DateTime(2026, 11, 10),
  );
}

void main() {
  late _FakeClassRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeClassRepository();
  });

  Widget createTestWidget({
    List<MyClass> classes = const <MyClass>[],
    List<Override> extraOverrides = const <Override>[],
  }) {
    return ProviderScope(
      overrides: <Override>[
        classRepositoryProvider.overrideWithValue(fakeRepo),
        myClassesProvider.overrideWith((ref) async => classes),
        ...extraOverrides,
      ],
      child: const MaterialApp(home: JoinClassScreen()),
    );
  }

  Future<void> submitCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(TextField), code);
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Gabung'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('rendersFormAndList', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Gabung Kelas Baru'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Gabung'), findsOneWidget);
    expect(find.text('Kelas Saya'), findsOneWidget);
    expect(find.text('Kamu belum terdaftar di kelas manapun'), findsOneWidget);
  });

  testWidgets('validationInvalidCode', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitCode(tester, '123');

    expect(find.text('Kode harus 6 karakter'), findsOneWidget);
    expect(fakeRepo.joinCalls, 0);
  });

  testWidgets('joinSuccessShowsSnackBar', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitCode(tester, 'ptik24');

    expect(fakeRepo.joinCalls, 1);
    expect(fakeRepo.lastCode, 'PTIK24');
    expect(find.text('Berhasil join PTIK B 2024'), findsOneWidget);
    expect(find.textContaining('PTIK B 2024'), findsOneWidget);
  });

  testWidgets('joinClassNotFoundShowsError', (tester) async {
    fakeRepo.joinResult = <String, dynamic>{'error': 'class_not_found'};
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitCode(tester, 'XXXXXX');

    expect(fakeRepo.joinCalls, 1);
    expect(find.text('Kelas tidak ditemukan'), findsOneWidget);
  });

  testWidgets('joinAlreadyMemberShowsInfo', (tester) async {
    fakeRepo.joinResult = <String, dynamic>{
      'success': true,
      'already_member': true,
      'class': <String, dynamic>{'name': 'PTIK B 2024'},
    };
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await submitCode(tester, 'PTIK24');

    expect(find.text('Kamu sudah member kelas PTIK B 2024'), findsOneWidget);
    expect(find.textContaining('PTIK B 2024'), findsOneWidget);
  });

  testWidgets('listRendersMyClasses', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        classes: <MyClass>[
          _buildClass(
            id: 'c1',
            name: 'PTIK B 2024',
            code: 'PTIK24',
            isPrimary: true,
          ),
          _buildClass(id: 'c2', name: 'PTIK A 2024', code: 'PTIKA1'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PTIK B 2024'), findsOneWidget);
    expect(find.text('PTIK A 2024'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Kode: PTIK24'), findsOneWidget);
    expect(find.text('Set Primary'), findsOneWidget);
  });

  testWidgets('setPrimaryUpdatesClass', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        classes: <MyClass>[
          _buildClass(
            id: 'c1',
            name: 'PTIK B 2024',
            code: 'PTIK24',
            isPrimary: true,
          ),
          _buildClass(id: 'c2', name: 'PTIK A 2024', code: 'PTIKA1'),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Set Primary'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(fakeRepo.setPrimaryCalls, 1);
    expect(fakeRepo.lastPrimaryClassId, 'c2');
    expect(find.text('PTIK A 2024 dijadikan kelas utama'), findsOneWidget);
  });
}
