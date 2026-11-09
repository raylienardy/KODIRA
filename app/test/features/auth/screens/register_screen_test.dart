import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/auth/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class _FakeAuthRepository implements IAuthRepository {
  bool signUpCalled = false;
  String? lastNim;
  String? lastName;
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
  }) async {
    signUpCalled = true;
    lastNim = nim;
    lastName = name;
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

void main() {
  late _FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeAuthRepository();
  });

  Widget createTestWidget() {
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
      overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> fillForm(
    WidgetTester tester, {
    String nim = '2402095010999',
    String name = 'Mahasiswa Baru',
    String password = 'rahasia123',
    String? confirm,
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), nim);
    await tester.enterText(find.byType(TextFormField).at(1), name);
    await tester.enterText(find.byType(TextFormField).at(2), password);
    await tester.enterText(
      find.byType(TextFormField).at(3),
      confirm ?? password,
    );
    await tester.pump();
  }

  testWidgets('rendersFourFields', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('NIM'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Konfirmasi Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('validationInvalidNim', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, nim: '123');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('NIM harus 13 digit angka'), findsOneWidget);
    expect(fakeRepo.signUpCalled, isFalse);
  });

  testWidgets('validationEmptyNama', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, name: '');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(fakeRepo.signUpCalled, isFalse);
  });

  testWidgets('validationShortPassword', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, password: '123');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    expect(fakeRepo.signUpCalled, isFalse);
  });

  testWidgets('validationPasswordMismatch', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester, password: 'rahasia123', confirm: 'rahasia456');
    await tester.tap(find.text('Daftar'));
    await tester.pump();

    expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
    expect(fakeRepo.signUpCalled, isFalse);
  });

  testWidgets('validSubmit_callsRepoAndNavigates', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester);
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(fakeRepo.signUpCalled, isTrue);
    expect(fakeRepo.lastNim, '2402095010999');
    expect(fakeRepo.lastName, 'Mahasiswa Baru');
    expect(find.text('Home Page'), findsOneWidget);
  });

  testWidgets('duplicateNim_showsError', (tester) async {
    fakeRepo.shouldThrowDuplicate = true;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await fillForm(tester);
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(fakeRepo.signUpCalled, isTrue);
    expect(find.text('NIM sudah terdaftar. Silakan login.'), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);
  });
}
