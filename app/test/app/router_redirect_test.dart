import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/app/router.dart';
import 'package:kodira/data/models/teacher_class_entry.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/home/providers/level_provider.dart';
import 'package:kodira/features/home/screens/home_screen.dart';
import 'package:kodira/features/teacher/providers/teacher_provider.dart';
import 'package:kodira/features/teacher/screens/teacher_dashboard_screen.dart';

class _FakeAuthRepo implements IAuthRepository {
  _FakeAuthRepo(this.user);
  final UserModel user;

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
    String role = 'student',
  }) async => user;

  @override
  Future<void> signOut() async {}

  @override
  Stream<bool> authStateChanges() => const Stream<bool>.empty();

  @override
  Future<void> updatePassword({
    required String nim,
    required String oldPassword,
    required String newPassword,
  }) async => throw UnimplementedError();

  @override
  Future<void> updateProfile({required String name}) async =>
      throw UnimplementedError();
}

class _FakeSessionNotifier extends SessionNotifier {
  _FakeSessionNotifier(super.repo, super.ref)
    : super.forTesting(
        hasStoredSession: false,
        restoreTimeout: const Duration(milliseconds: 50),
        retryDelays: const <Duration>[Duration.zero],
      ) {
    // Selalu anggap session valid supaya aturan redirect ke /login tidak
    // menimpa pemeriksaan role (rule 2-7).
    state = SessionStatus.authenticated;
  }
}

void main() {
  final studentUser = UserModel(
    id: 'student-1',
    nim: '2402095010141',
    name: 'Mahasiswa Test',
    role: 'student',
    createdAt: DateTime(2026, 1, 1),
  );

  final teacherUser = UserModel(
    id: 'teacher-1',
    nim: '0012345678',
    name: 'Dosen Test',
    role: 'teacher',
    createdAt: DateTime(2026, 1, 1),
  );

  List<Override> createOverrides(UserModel user) => [
    sessionStatusProvider.overrideWith(
      (ref) => _FakeSessionNotifier(_FakeAuthRepo(user), ref),
    ),
    authStateProvider.overrideWith((ref) {
      final notifier = AuthNotifier(_FakeAuthRepo(user), ref);
      notifier.restoreSession(user);
      return notifier;
    }),
    teacherClassesProvider.overrideWith((ref) async => <TeacherClassEntry>[]),
    allLevelsProvider.overrideWith((ref) async => []),
    allProgressProvider.overrideWith((ref) async => []),
    totalXpProvider.overrideWith((ref) async => 0),
    currentStreakProvider.overrideWith((ref) async => null),
    badgeCountProvider.overrideWith((ref) async => 0),
  ];

  testWidgets('teacherRedirectedFromHomeToDashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: createOverrides(teacherUser),
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(goRouterProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TeacherDashboardScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.text('Kelas Saya'), findsOneWidget);
  });

  testWidgets('studentNotRedirectedFromHome', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: createOverrides(studentUser),
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(goRouterProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(TeacherDashboardScreen), findsNothing);
    expect(find.text('Kelas Saya'), findsNothing);
  });

  testWidgets('teacherAlreadyOnDashboardNotRedirected', (tester) async {
    final container = ProviderContainer(
      overrides: createOverrides(teacherUser),
    );
    addTearDown(container.dispose);

    final router = container.read(goRouterProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Setelah landing di dashboard, navigasi eksplisit ke path yang sama
    // tidak boleh memicu redirect loop.
    router.go('/teacher-dashboard');
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/teacher-dashboard',
    );
    expect(find.byType(TeacherDashboardScreen), findsOneWidget);
  });
}
