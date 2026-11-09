import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/profile/screens/change_password_screen.dart';
import 'package:kodira/shared/widgets/app_drawer.dart';

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository(this.user);

  final UserModel user;
  int signOutCalls = 0;

  @override
  Future<UserModel?> getCurrentUser() async => user;

  @override
  Future<UserModel> signInWithNim({
    required String nim,
    required String password,
  }) async => user;

  @override
  Future<UserModel> signUpWithNim({
    required String nim,
    required String name,
    required String password,
  }) async => user;

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }

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

class _DrawerHome extends StatelessWidget {
  const _DrawerHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Home Page')),
    );
  }
}

Future<GoRouter> _pumpDrawer(
  WidgetTester tester,
  _FakeAuthRepository repo,
) async {
  final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => const _DrawerHome()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: const Center(child: Text('Profile Page')),
        ),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/join-class',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Join Class Page'))),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        authStateProvider.overrideWith((ref) {
          final AuthNotifier notifier = AuthNotifier(
            ref.watch(authRepositoryProvider),
            ref,
          );
          notifier.restoreSession(repo.user);
          return notifier;
        }),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AppBar).last,
      matching: find.byIcon(Icons.menu),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final UserModel user = UserModel(
    id: 'user-1',
    nim: '2402095010141',
    name: 'Ayu Tester',
    createdAt: DateTime(2026, 1, 1),
  );

  testWidgets('rendersFourItems', (tester) async {
    final _FakeAuthRepository repo = _FakeAuthRepository(user);
    await _pumpDrawer(tester, repo);
    await _openDrawer(tester);

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Ganti Password'), findsOneWidget);
    expect(find.text('Ganti Kelas'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Tentang Aplikasi'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Ayu Tester'), findsOneWidget);
    expect(find.text('2402095010141'), findsOneWidget);
  });

  testWidgets('gantiKelasNavigates', (tester) async {
    final _FakeAuthRepository repo = _FakeAuthRepository(user);
    await _pumpDrawer(tester, repo);
    await _openDrawer(tester);

    await tester.tap(find.text('Ganti Kelas'));
    await tester.pumpAndSettle();

    expect(find.text('Join Class Page'), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);
    expect(find.byType(AppDrawer), findsNothing);
  });

  testWidgets('logoutShowsConfirmDialog', (tester) async {
    final _FakeAuthRepository repo = _FakeAuthRepository(user);
    await _pumpDrawer(tester, repo);
    await _openDrawer(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Yakin ingin keluar dari akun?'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('logoutConfirmCallsSignOut', (tester) async {
    final _FakeAuthRepository repo = _FakeAuthRepository(user);
    await _pumpDrawer(tester, repo);
    await _openDrawer(tester);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();

    expect(repo.signOutCalls, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('profilNavigates', (tester) async {
    final _FakeAuthRepository repo = _FakeAuthRepository(user);
    await _pumpDrawer(tester, repo);
    await _openDrawer(tester);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Profile Page'), findsOneWidget);
    expect(find.byType(AppDrawer), findsNothing);
  });

  testWidgets('gantiPasswordNavigates', (tester) async {
    final _FakeAuthRepository repo = _FakeAuthRepository(user);
    await _pumpDrawer(tester, repo);
    await _openDrawer(tester);

    await tester.tap(find.text('Ganti Password'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Ganti Password'), findsOneWidget);
  });

  testWidgets('duplicateRoutePushDoesNotPushMultipleTimes', (tester) async {
    final _FakeAuthRepository repo = _FakeAuthRepository(user);
    await _pumpDrawer(tester, repo);

    // Navigate to profile first via drawer
    await _openDrawer(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Profile Page'), findsOneWidget);

    // Open drawer from profile page and tap Profil again (already on /profile)
    await _openDrawer(tester);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Should still be on profile page without exception or duplicate push
    expect(find.text('Profile Page'), findsOneWidget);
    expect(find.text('Home Page'), findsNothing);
  });
}
