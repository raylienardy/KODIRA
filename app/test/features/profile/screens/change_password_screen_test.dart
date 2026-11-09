import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/profile/screens/change_password_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class FakeAuthRepository implements IAuthRepository {
  bool shouldThrowAuthException = false;
  bool updatePasswordCalled = false;

  @override
  Future<UserModel?> getCurrentUser() async => null;

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
    throw UnimplementedError();
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
    updatePasswordCalled = true;
    if (shouldThrowAuthException) {
      throw const supa.AuthException('Password lama salah');
    }
  }

  @override
  Future<void> updateProfile({required String name}) async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
  });

  Widget createTestWidget() {
    final router = GoRouter(
      initialLocation: '/change-password',
      routes: [
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: '/success',
          builder: (context, state) =>
              const Scaffold(body: Text('Success Screen')),
        ),
      ],
    );

    final user = UserModel(
      id: '123',
      nim: '12345678',
      name: 'Test User',
      email: '12345678@kodira.ac.id',
      createdAt: DateTime.now(),
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
        authStateProvider.overrideWith((ref) {
          final AuthNotifier notifier = AuthNotifier(
            ref.watch(authRepositoryProvider),
            ref,
          );
          notifier.restoreSession(user);
          return notifier;
        }),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('validSubmit_callsRepoAndPops', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextFormField).at(0), 'oldpass123');
    await tester.enterText(find.byType(TextFormField).at(1), 'NewPass123!');
    await tester.enterText(find.byType(TextFormField).at(2), 'NewPass123!');
    await tester.pump();

    // Tap submit
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(fakeRepo.updatePasswordCalled, isTrue);
    expect(find.text('Password berhasil diubah'), findsOneWidget);
  });

  testWidgets('wrongOldPassword_showsSnackBar', (tester) async {
    fakeRepo.shouldThrowAuthException = true;

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'wrongpass');
    await tester.enterText(find.byType(TextFormField).at(1), 'NewPass123!');
    await tester.enterText(find.byType(TextFormField).at(2), 'NewPass123!');
    await tester.pump();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(fakeRepo.updatePasswordCalled, isTrue);
    expect(find.text('Password lama salah'), findsOneWidget);
  });

  testWidgets('weakPassword_showsWeakLabel', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.pump();

    expect(find.text('Lemah'), findsOneWidget);
  });

  testWidgets('mediumPassword_showsMediumLabel', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Password123');
    await tester.pump();

    expect(find.text('Sedang'), findsOneWidget);
  });

  testWidgets('strongPassword_showsStrongLabel', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd!@#');
    await tester.pump();

    expect(find.text('Kuat'), findsOneWidget);
  });

  testWidgets('mismatchConfirm_showsValidationError', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'oldpass123');
    await tester.enterText(find.byType(TextFormField).at(1), 'NewPass123!');
    await tester.enterText(find.byType(TextFormField).at(2), 'Different123!');
    await tester.pump();

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
    expect(fakeRepo.updatePasswordCalled, isFalse);
  });

  testWidgets('tooShortNewPassword_showsValidationError', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'oldpass123');
    await tester.enterText(find.byType(TextFormField).at(1), '12345');
    await tester.enterText(find.byType(TextFormField).at(2), '12345');
    await tester.pump();

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Minimal 6 karakter'), findsAtLeastNWidgets(1));
    expect(fakeRepo.updatePasswordCalled, isFalse);
  });
}
