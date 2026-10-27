import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/level_model.dart';
import 'package:kodira/data/models/user_achievement_model.dart';
import 'package:kodira/data/models/user_badge_model.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/models/user_progress_model.dart';
import 'package:kodira/data/models/user_streak_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/home/providers/level_provider.dart';
import 'package:kodira/features/profile/providers/profile_provider.dart';
import 'package:kodira/features/profile/screens/profile_screen.dart';

void main() {
  final user = UserModel(
    id: 'user-1',
    nim: '2402095010141',
    name: 'Ayu Tester',
    createdAt: DateTime(2026, 1, 1),
  );
  final progress = <UserProgressModel>[
    UserProgressModel(
      id: 'progress-1',
      userId: 'user-1',
      levelId: 1,
      status: 'completed',
      masteryScore: 0.8,
      xpEarned: 120,
      attempts: 2,
      lastAttemptAt: DateTime(2026, 2, 1),
    ),
  ];
  final levels = <LevelModel>[
    LevelModel(
      id: 1,
      levelNumber: 1,
      title: 'Pengenalan C++',
      topic: 'Dasar C++',
      language: 'cpp',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  List<Override> overrides({
    required Future<List<UserProgressModel>> Function() progressLoader,
    required Future<int> Function() xpLoader,
    required Future<UserStreakModel?> Function() streakLoader,
    required Future<List<LevelModel>> Function() levelsLoader,
    required Future<List<UserBadgeModel>> Function() badgesLoader,
    required Future<List<UserAchievementModel>> Function() achievementsLoader,
    required Future<Map<String, double>> Function() masteryLoader,
    required Future<List<UserProgressModel>> Function() activityLoader,
  }) => <Override>[
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
    authStateProvider.overrideWith((ref) {
      final notifier = AuthNotifier(ref.watch(authRepositoryProvider), ref);
      notifier.restoreSession(user);
      return notifier;
    }),
    allProgressProvider.overrideWith((ref) => progressLoader()),
    totalXpProvider.overrideWith((ref) => xpLoader()),
    currentStreakProvider.overrideWith((ref) => streakLoader()),
    allLevelsProvider.overrideWith((ref) => levelsLoader()),
    badgeCountProvider.overrideWith((ref) async => 3),
    userBadgesProvider.overrideWith((ref) => badgesLoader()),
    userAchievementsProvider.overrideWith((ref) => achievementsLoader()),
    masteryByTopicProvider.overrideWith((ref) => masteryLoader()),
    recentActivityProvider.overrideWith((ref) => activityLoader()),
  ];

  Future<void> pumpProfile(
    WidgetTester tester, {
    required Future<List<UserProgressModel>> Function() progressLoader,
    required Future<int> Function() xpLoader,
    required Future<UserStreakModel?> Function() streakLoader,
    required Future<List<LevelModel>> Function() levelsLoader,
    required Future<List<UserBadgeModel>> Function() badgesLoader,
    required Future<List<UserAchievementModel>> Function() achievementsLoader,
    required Future<Map<String, double>> Function() masteryLoader,
    required Future<List<UserProgressModel>> Function() activityLoader,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(
          progressLoader: progressLoader,
          xpLoader: xpLoader,
          streakLoader: streakLoader,
          levelsLoader: levelsLoader,
          badgesLoader: badgesLoader,
          achievementsLoader: achievementsLoader,
          masteryLoader: masteryLoader,
          activityLoader: activityLoader,
        ),
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
  }

  testWidgets('menampilkan loading pada bagian profil saat provider loading', (
    tester,
  ) async {
    final completer = Completer<List<UserBadgeModel>>();
    await pumpProfile(
      tester,
      progressLoader: () async => progress,
      xpLoader: () async => 120,
      streakLoader: () async => null,
      levelsLoader: () async => levels,
      badgesLoader: () => completer.future,
      achievementsLoader: () async => <UserAchievementModel>[],
      masteryLoader: () async => <String, double>{},
      activityLoader: () async => progress,
    );
    await tester.pump();

    expect(find.text('Memuat badge'), findsOneWidget);
    completer.complete(<UserBadgeModel>[]);
    await tester.pumpAndSettle();
  });

  testWidgets('menampilkan error dari provider profil', (tester) async {
    await pumpProfile(
      tester,
      progressLoader: () =>
          Future<List<UserProgressModel>>.error(Exception('network failed')),
      xpLoader: () async => 120,
      streakLoader: () async => null,
      levelsLoader: () async => levels,
      badgesLoader: () =>
          Future<List<UserBadgeModel>>.error(Exception('network failed')),
      achievementsLoader: () async => <UserAchievementModel>[],
      masteryLoader: () async => <String, double>{},
      activityLoader: () async => progress,
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(
      find.text('Koneksi bermasalah. Periksa internet Anda.'),
      findsWidgets,
    );
  });

  testWidgets('menampilkan nama user dan stat cards saat data sukses', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      progressLoader: () async => progress,
      xpLoader: () async => 120,
      streakLoader: () async => const UserStreakModel(
        userId: 'user-1',
        currentStreak: 4,
        longestStreak: 6,
      ),
      levelsLoader: () async => levels,
      badgesLoader: () async => <UserBadgeModel>[],
      achievementsLoader: () async => <UserAchievementModel>[],
      masteryLoader: () async => <String, double>{'Dasar C++': 0.8},
      activityLoader: () async => progress,
    );
    await tester.pumpAndSettle();

    expect(find.text('Ayu Tester'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('Level Aktif'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
  });
}

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository(this.user);

  final UserModel user;

  @override
  Future<UserModel?> getCurrentUser() async => user;

  @override
  Future<UserModel> signInWithNim({
    required String nim,
    required String password,
  }) async => user;

  @override
  Future<void> signOut() async {}

  @override
  Stream<bool> authStateChanges() => const Stream<bool>.empty();
}
