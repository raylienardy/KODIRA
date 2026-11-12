import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kodira/data/models/my_class_model.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/repositories/class_repository.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/auth/screens/register_screen.dart';
import 'package:kodira/features/class/providers/class_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeAuthRepository implements IAuthRepository {
  bool signUpCalled = false;
  String? lastNim;
  String? lastName;
  String? lastRole;
  bool shouldThrowDuplicate = false;

  final UserModel user = UserModel(
    id: 'user-new',
    nim: '2402095010999',
    name: 'Mahasiswa Baru',
    email: 'nim_2402095010999@kodira.local',
    createdAt: DateTime(2026, 11, 10),
  );

  @override
  Future<UserModel?> getCurrentUser() async => user;

  @override
  Future<UserModel> signInWithNim({
    required String nim,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> signUpWithNim({
    required String nim,
    required String name,
    required String password,
    String role = 'student',
  }) async {
    signUpCalled = true;
    lastNim = nim;
    lastName = name;
    lastRole = role;
    if (shouldThrowDuplicate) {
      throw const supa.AuthException('NIM sudah terdaftar. Silakan login.');
    }
    return user;
  }

  @override
  Future<void> signOut() async {}

  @override
  Stream<bool> authStateChanges() => const Stream<bool>.empty();

  @override
  Future<void> updatePassword({
    required String nim,
    required String oldPassword,
    required String newPassword,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfile({required String name}) async {
    throw UnimplementedError();
  }
}

class _FakeClassRepository implements ClassRepository {
  int joinCalls = 0;
  String? lastCode;
  Map<String, dynamic>? joinResult;
  Object? joinError;

  @override
  Future<List<MyClass>> getMyClasses(String userId) async => const [];

  @override
  Future<Map<String, dynamic>> joinClass(String code) async {
    joinCalls += 1;
    lastCode = code;
    final error = joinError;
    if (error != null) throw error;
    return joinResult ??
        <String, dynamic>{
          'success': true,
          'already_member': false,
          'class': <String, dynamic>{'name': 'PTIK B 2024'},
        };
  }

  @override
  Future<void> setPrimaryClass(String classId) async {}

  @override
  Future<Map<String, dynamic>> createClass({
    required String name,
    String? description,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeAuthRepository fakeAuth;
  late _FakeClassRepository fakeClass;

  final fakeSession = supa.Session(
    accessToken: 'token',
    tokenType: 'bearer',
    user: supa.User(
      id: 'user-new',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime(2026, 11, 10).toIso8601String(),
    ),
  );

  setUp(() {
    fakeAuth = _FakeAuthRepository();
    fakeClass = _FakeClassRepository();
  });

  void setViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget createTestWidget({supa.Session? session}) {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home Page')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeAuth),
        classRepositoryProvider.overrideWithValue(fakeClass),
        currentSupabaseSessionProvider.overrideWithValue(session),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> fillForm(
    WidgetTester tester, {
    String nim = '2402095010999',
    String name = 'Mahasiswa Baru',
    String password = 'rahasia123',
    String? confirm,
    String? classCode,
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), nim);
    await tester.enterText(find.byType(TextFormField).at(1), name);
    await tester.enterText(find.byType(TextFormField).at(2), password);
    await tester.enterText(
      find.byType(TextFormField).at(3),
      confirm ?? password,
    );
    if (classCode != null) {
      // Field kode kelas adalah TextField biasa (bukan TextFormField) agar
      // input opsional ini tidak ikut memblokir validasi form registrasi.
      await tester.enterText(find.byType(TextField).at(4), classCode);
    }
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
  }

  testWidgets('rendersFourFields', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('NIM'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Daftar'), findsOneWidget);
  });

  // Fitur #P4: field kode kelas opsional hanya tampil untuk mahasiswa.
  testWidgets('rendersOptionalClassCodeFieldForStudent', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Kode Kelas (Opsional)'), findsOneWidget);
    expect(find.text('6 karakter, dari dosen Anda'), findsOneWidget);
  });

  testWidgets('validationInvalidNim', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, nim: '123');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('NIM harus 13 digit angka'), findsOneWidget);
    expect(fakeAuth.signUpCalled, isFalse);
  });

  testWidgets('validationEmptyNama', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, name: '');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(fakeAuth.signUpCalled, isFalse);
  });

  testWidgets('validationShortPassword', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, password: '123');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    expect(fakeAuth.signUpCalled, isFalse);
  });

  testWidgets('validationPasswordMismatch', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, password: 'rahasia123', confirm: 'rahasia456');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
    expect(fakeAuth.signUpCalled, isFalse);
  });

  testWidgets('validSubmit_callsRepoAndNavigates', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester);
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeAuth.lastNim, '2402095010999');
    expect(fakeAuth.lastName, 'Mahasiswa Baru');
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('duplicateNim_showsError', (tester) async {
    setViewport(tester);
    fakeAuth.shouldThrowDuplicate = true;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester);
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(find.text('NIM sudah terdaftar. Silakan login.'), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);
  });

  testWidgets('roleSelectorRenders', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Daftar Sebagai'), findsOneWidget);
    expect(find.byType(SegmentedButton<String>), findsOneWidget);
    expect(find.text('Mahasiswa'), findsOneWidget);
    expect(find.text('Dosen'), findsOneWidget);
    expect(find.text('NIM'), findsOneWidget);
  });

  testWidgets('submitAsTeacher_callsRepoWithRole', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dosen'));
    await tester.pumpAndSettle();

    expect(find.text('NIDN'), findsOneWidget);
    expect(find.text('Kode Kelas (Opsional)'), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), '1234567890');
    await tester.enterText(find.byType(TextFormField).at(1), 'Prof. Dosen');
    await tester.enterText(find.byType(TextFormField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextFormField).at(3), 'rahasia123');
    await tester.pump();

    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeAuth.lastNim, '1234567890');
    expect(fakeAuth.lastName, 'Prof. Dosen');
    expect(fakeAuth.lastRole, 'teacher');
    expect(find.text('Home Page'), findsOneWidget);
  });

  // --- Fitur #P4: auto-join kelas saat registrasi mahasiswa ---

  testWidgets('noClassCode_doesNotCallJoin', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await fillForm(tester);
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeClass.joinCalls, 0);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('validClassCode_callsJoinAndNavigates', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await fillForm(tester, classCode: 'PTIK24');
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeClass.joinCalls, 1);
    expect(fakeClass.lastCode, 'PTIK24');
    expect(find.textContaining('Berhasil join PTIK B 2024'), findsOneWidget);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('classCode_isUppercasedBeforeJoin', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await fillForm(tester, classCode: 'ptik24');
    await submit(tester);

    expect(fakeClass.joinCalls, 1);
    expect(fakeClass.lastCode, 'PTIK24');
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('joinError_doesNotBlockRegistration', (tester) async {
    setViewport(tester);
    fakeClass.joinResult = <String, dynamic>{'error': 'class_not_found'};

    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await fillForm(tester, classCode: 'WRONG1');
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeClass.joinCalls, 1);
    expect(find.textContaining('Kode kelas tidak ditemukan'), findsOneWidget);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('joinThrowsException_doesNotBlockRegistration', (tester) async {
    setViewport(tester);
    fakeClass.joinError = Exception('network down');

    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await fillForm(tester, classCode: 'PTIK24');
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeClass.joinCalls, 1);
    expect(find.textContaining('gagal join kelas'), findsOneWidget);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('alreadyMember_doesNotBlockRegistration', (tester) async {
    setViewport(tester);
    fakeClass.joinResult = <String, dynamic>{
      'success': true,
      'already_member': true,
      'class': <String, dynamic>{'name': 'PTIK B 2024'},
    };

    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await fillForm(tester, classCode: 'PTIK24');
    await submit(tester);

    expect(find.textContaining('sudah member kelas'), findsOneWidget);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('shortClassCode_skipsJoinButRegisters', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await fillForm(tester, classCode: 'ABC');
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeClass.joinCalls, 0);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('nullSession_showsConfirmEmailHintAndSkipsJoin', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget(session: null));
    await tester.pumpAndSettle();

    await fillForm(tester, classCode: 'PTIK24');
    await submit(tester);

    expect(fakeAuth.signUpCalled, isTrue);
    expect(fakeClass.joinCalls, 0);
    expect(find.textContaining('Cek email untuk konfirmasi'), findsOneWidget);
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('teacherWithClassCodeFieldHidden_neverJoins', (tester) async {
    setViewport(tester);
    await tester.pumpWidget(createTestWidget(session: fakeSession));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dosen'));
    await tester.pumpAndSettle();

    expect(find.text('Kode Kelas (Opsional)'), findsNothing);

    await fillForm(tester, nim: '1234567890', name: 'Prof. Dosen');
    await submit(tester);

    expect(fakeAuth.lastRole, 'teacher');
    expect(fakeClass.joinCalls, 0);
    expect(find.text('Home Page'), findsOneWidget);
  });
}
