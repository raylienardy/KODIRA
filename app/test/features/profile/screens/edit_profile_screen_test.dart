import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/profile/screens/edit_profile_screen.dart';

class FakeAuthRepository implements IAuthRepository {
  bool updateProfileCalled = false;
  String? lastName;
  bool shouldThrowAuthException = false;

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
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfile({required String name}) async {
    updateProfileCalled = true;
    lastName = name;
    if (shouldThrowAuthException) {
      throw const supa.AuthException('Gagal menyimpan ke server');
    }
  }
}

void main() {
  group('EditProfileScreen Tests', () {
    late FakeAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAuthRepository();
    });

    Widget createTestWidget() {
      final user = UserModel(
        id: 'user-1',
        nim: '2402095010999',
        name: 'Ridho Test',
        createdAt: DateTime(2026, 1, 1),
      );

      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
          authStateProvider.overrideWith((ref) {
            final notifier = AuthNotifier(
              ref.watch(authRepositoryProvider),
              ref,
            );
            notifier.restoreSession(user);
            return notifier;
          }),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/edit-profile',
            routes: [
              GoRoute(
                path: '/edit-profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('rendersWithCurrentName', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.text('Ridho Test'), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
    });

    testWidgets('validationEmptyName_fails', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Nama wajib diisi'), findsOneWidget);
      expect(fakeRepo.updateProfileCalled, isFalse);
    });

    testWidgets('validationTooShort_fails', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'X');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Nama minimal 2 karakter'), findsOneWidget);
      expect(fakeRepo.updateProfileCalled, isFalse);
    });

    testWidgets('validSubmit_callsRepoAndPops', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Budi Test');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(fakeRepo.updateProfileCalled, isTrue);
      expect(fakeRepo.lastName, 'Budi Test');
      expect(find.text('Nama berhasil diperbarui'), findsOneWidget);
    });

    testWidgets('errorOnRepo_showSnackBar', (WidgetTester tester) async {
      fakeRepo.shouldThrowAuthException = true;
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Budi Test');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Gagal menyimpan ke server'), findsOneWidget);
    });
  });
}
