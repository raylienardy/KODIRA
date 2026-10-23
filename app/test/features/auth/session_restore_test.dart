import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/core/errors/auth_exception.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/models/user_streak_model.dart';
import 'package:kodira/data/repositories/auth_repository.dart';
import 'package:kodira/data/repositories/badge_repository.dart';
import 'package:kodira/data/repositories/streak_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/home/providers/level_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final Provider<Ref> _testRefProvider = Provider<Ref>((ref) => ref);

SupabaseClient _fakeClient() =>
    SupabaseClient('https://example.supabase.co', 'test-anon-key');

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({
    this.user,
    this.errors = const <Object>[],
    this.authEvents,
  }) : super(_fakeClient());

  UserModel? user;
  final List<Object> errors;
  final Stream<bool>? authEvents;
  int getCurrentUserCalls = 0;
  int signOutCalls = 0;

  @override
  Future<UserModel?> getCurrentUser() async {
    final int index = getCurrentUserCalls;
    getCurrentUserCalls += 1;
    if (index < errors.length) {
      throw errors[index];
    }
    return user;
  }

  @override
  Stream<bool> authStateChanges() => authEvents ?? const Stream<bool>.empty();

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }
}

class _FakeStreakRepository extends StreakRepository {
  _FakeStreakRepository() : super(_fakeClient());

  int updateCalls = 0;

  @override
  Future<UserStreakModel> updateOnActivity({
    required String userId,
    required DateTime now,
  }) async {
    updateCalls += 1;
    return UserStreakModel(
      userId: userId,
      currentStreak: 1,
      longestStreak: 1,
      lastActiveDate: now,
    );
  }
}

class _FakeBadgeRepository extends BadgeRepository {
  _FakeBadgeRepository() : super(_fakeClient());

  int checkCalls = 0;

  @override
  Future<({Set<String> newBadges, Set<String> newAchievements})> checkAndAward(
    String userId,
  ) async {
    checkCalls += 1;
    return (newBadges: <String>{}, newAchievements: <String>{});
  }
}

UserModel _user({String id = 'user-1'}) {
  return UserModel(
    id: id,
    nim: '2402095010141',
    name: 'Muhammad Ridho S.',
    createdAt: DateTime(2026, 10, 1),
  );
}

const List<Duration> _noRetryDelays = <Duration>[
  Duration.zero,
  Duration.zero,
  Duration.zero,
  Duration.zero,
];

({ProviderContainer container, Ref ref}) _harness(
  _FakeAuthRepository repo, {
  _FakeStreakRepository? streakRepository,
  _FakeBadgeRepository? badgeRepository,
}) {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      authRepositoryProvider.overrideWithValue(repo),
      streakRepositoryProvider.overrideWithValue(
        streakRepository ?? _FakeStreakRepository(),
      ),
      badgeRepositoryProvider.overrideWithValue(
        badgeRepository ?? _FakeBadgeRepository(),
      ),
    ],
  );
  addTearDown(() async {
    await pumpEventQueue();
    container.dispose();
  });
  return (container: container, ref: container.read(_testRefProvider));
}

void main() {
  group('SessionNotifier restore', () {
    test('sukses mengisi user dan status authenticated', () async {
      final _FakeAuthRepository repo = _FakeAuthRepository(user: _user());
      final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
      final SessionNotifier notifier = SessionNotifier.forTesting(
        repo,
        harness.ref,
        hasStoredSession: true,
      );
      addTearDown(notifier.dispose);

      await notifier.restoreCompleted;

      expect(notifier.state, SessionStatus.authenticated);
      expect(harness.container.read(authStateProvider).user?.id, 'user-1');
      expect(harness.container.read(authStateProvider).userLoadFailed, isFalse);
      expect(repo.getCurrentUserCalls, 1);
    });

    test('timeout pertama lalu retry sukses mengisi user', () async {
      final _FakeAuthRepository repo = _FakeAuthRepository(
        user: _user(),
        errors: <Object>[TimeoutException('cold start')],
      );
      final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
      final SessionNotifier notifier = SessionNotifier.forTesting(
        repo,
        harness.ref,
        hasStoredSession: true,
        retryDelays: _noRetryDelays,
      );
      addTearDown(notifier.dispose);

      await notifier.restoreCompleted;

      expect(notifier.state, SessionStatus.authenticated);
      expect(harness.container.read(authStateProvider).user?.id, 'user-1');
      expect(harness.container.read(authStateProvider).userLoadFailed, isFalse);
      expect(repo.getCurrentUserCalls, 2);
    });

    test(
      'gagal empat kali tetap authenticated dengan userLoadFailed',
      () async {
        final _FakeAuthRepository repo = _FakeAuthRepository(
          errors: <Object>[
            TimeoutException('cold start 1'),
            TimeoutException('cold start 2'),
            TimeoutException('cold start 3'),
            TimeoutException('cold start 4'),
          ],
        );
        final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
        final SessionNotifier notifier = SessionNotifier.forTesting(
          repo,
          harness.ref,
          hasStoredSession: true,
          retryDelays: _noRetryDelays,
        );
        addTearDown(notifier.dispose);

        await notifier.restoreCompleted;

        expect(notifier.state, SessionStatus.authenticated);
        expect(harness.container.read(authStateProvider).user, isNull);
        expect(
          harness.container.read(authStateProvider).userLoadFailed,
          isTrue,
        );
        expect(repo.getCurrentUserCalls, 4);
      },
    );

    test(
      'KodiraAuthException tidak di-retry dan session dibersihkan',
      () async {
        final _FakeAuthRepository repo = _FakeAuthRepository(
          errors: <Object>[KodiraAuthException.userNotFound()],
        );
        final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
        final SessionNotifier notifier = SessionNotifier.forTesting(
          repo,
          harness.ref,
          hasStoredSession: true,
        );
        addTearDown(notifier.dispose);

        await notifier.restoreCompleted;

        expect(notifier.state, SessionStatus.unauthenticated);
        expect(repo.getCurrentUserCalls, 1);
        expect(repo.signOutCalls, 1);
        expect(
          harness.container.read(authStateProvider).userLoadFailed,
          isFalse,
        );
      },
    );

    test('tanpa session tersimpan langsung unauthenticated', () async {
      final _FakeAuthRepository repo = _FakeAuthRepository(user: _user());
      final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
      final SessionNotifier notifier = SessionNotifier.forTesting(
        repo,
        harness.ref,
        hasStoredSession: false,
      );
      addTearDown(notifier.dispose);

      await notifier.restoreCompleted;

      expect(notifier.state, SessionStatus.unauthenticated);
      expect(repo.getCurrentUserCalls, 0);
    });
  });

  group('SessionNotifier auth events', () {
    test('session event mengisi user yang belum ada', () async {
      final StreamController<bool> controller = StreamController<bool>();
      addTearDown(controller.close);
      final _FakeAuthRepository repo = _FakeAuthRepository(
        user: _user(),
        authEvents: controller.stream,
      );
      final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
      final SessionNotifier notifier = SessionNotifier.forTesting(
        repo,
        harness.ref,
        hasStoredSession: false,
      );
      addTearDown(notifier.dispose);

      controller.add(true);
      await pumpEventQueue();

      expect(notifier.state, SessionStatus.authenticated);
      expect(harness.container.read(authStateProvider).user?.id, 'user-1');
      expect(harness.container.read(authStateProvider).userLoadFailed, isFalse);
    });

    test('session event tanpa user menandai userLoadFailed', () async {
      final StreamController<bool> controller = StreamController<bool>();
      addTearDown(controller.close);
      final _FakeAuthRepository repo = _FakeAuthRepository(
        authEvents: controller.stream,
      );
      final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
      final SessionNotifier notifier = SessionNotifier.forTesting(
        repo,
        harness.ref,
        hasStoredSession: false,
      );
      addTearDown(notifier.dispose);

      controller.add(true);
      await pumpEventQueue();

      expect(notifier.state, SessionStatus.authenticated);
      expect(harness.container.read(authStateProvider).userLoadFailed, isTrue);
    });
  });

  group('AuthNotifier.resolveUserForSave', () {
    test('memuat ulang user saat state kosong', () async {
      final _FakeAuthRepository repo = _FakeAuthRepository(user: _user());
      final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
      final AuthNotifier notifier = harness.container.read(
        authStateProvider.notifier,
      );

      expect(notifier.state.user, isNull);

      final UserModel? resolved = await notifier.resolveUserForSave();

      expect(resolved?.id, 'user-1');
      expect(notifier.state.user?.id, 'user-1');
      expect(notifier.state.userLoadFailed, isFalse);
      expect(repo.getCurrentUserCalls, 1);
    });

    test(
      'gagal reload mengembalikan null lalu user lama dipakai tanpa reload',
      () async {
        final _FakeAuthRepository repo = _FakeAuthRepository();
        final ({ProviderContainer container, Ref ref}) harness = _harness(repo);
        final AuthNotifier notifier = harness.container.read(
          authStateProvider.notifier,
        );

        notifier.setUserLoadFailed();
        final UserModel? failed = await notifier.resolveUserForSave();

        expect(failed, isNull);
        expect(notifier.state.userLoadFailed, isTrue);
        expect(repo.getCurrentUserCalls, 1);

        notifier.restoreSession(_user());
        await pumpEventQueue();

        expect(notifier.state.userLoadFailed, isFalse);
        expect(notifier.state.user?.id, 'user-1');

        final UserModel? existing = await notifier.resolveUserForSave();

        expect(existing?.id, 'user-1');
        expect(repo.getCurrentUserCalls, 1);
      },
    );
  });

  group('AuthNotifier.retryUserLoad', () {
    test('sukses mengisi user dan menyegarkan streak serta badge', () async {
      final _FakeAuthRepository repo = _FakeAuthRepository(
        errors: <Object>[
          TimeoutException('cold start 1'),
          TimeoutException('cold start 2'),
          TimeoutException('cold start 3'),
          TimeoutException('cold start 4'),
        ],
      );
      final _FakeStreakRepository streak = _FakeStreakRepository();
      final _FakeBadgeRepository badge = _FakeBadgeRepository();
      final ({ProviderContainer container, Ref ref}) harness = _harness(
        repo,
        streakRepository: streak,
        badgeRepository: badge,
      );
      final SessionNotifier session = SessionNotifier.forTesting(
        repo,
        harness.ref,
        hasStoredSession: true,
        retryDelays: _noRetryDelays,
      );
      addTearDown(session.dispose);

      await session.restoreCompleted;
      expect(harness.container.read(authStateProvider).userLoadFailed, isTrue);

      repo.user = _user();
      final AuthNotifier authNotifier = harness.container.read(
        authStateProvider.notifier,
      );
      final bool ok = await authNotifier.retryUserLoad();

      expect(ok, isTrue);
      expect(harness.container.read(authStateProvider).user?.id, 'user-1');
      expect(harness.container.read(authStateProvider).userLoadFailed, isFalse);
      expect(repo.getCurrentUserCalls, 5);
      expect(streak.updateCalls, 1);
      expect(badge.checkCalls, 1);
    });

    test('gagal memuat ulang mempertahankan banner aktif', () async {
      final _FakeAuthRepository repo = _FakeAuthRepository(
        errors: <Object>[
          TimeoutException('cold start 1'),
          TimeoutException('cold start 2'),
          TimeoutException('cold start 3'),
          TimeoutException('cold start 4'),
        ],
      );
      final _FakeStreakRepository streak = _FakeStreakRepository();
      final _FakeBadgeRepository badge = _FakeBadgeRepository();
      final ({ProviderContainer container, Ref ref}) harness = _harness(
        repo,
        streakRepository: streak,
        badgeRepository: badge,
      );
      final SessionNotifier session = SessionNotifier.forTesting(
        repo,
        harness.ref,
        hasStoredSession: true,
        retryDelays: _noRetryDelays,
      );
      addTearDown(session.dispose);

      await session.restoreCompleted;
      final AuthNotifier authNotifier = harness.container.read(
        authStateProvider.notifier,
      );
      final bool ok = await authNotifier.retryUserLoad();

      expect(ok, isFalse);
      expect(harness.container.read(authStateProvider).user, isNull);
      expect(harness.container.read(authStateProvider).userLoadFailed, isTrue);
      expect(repo.getCurrentUserCalls, 5);
      expect(streak.updateCalls, 0);
      expect(badge.checkCalls, 0);
    });
  });
}
