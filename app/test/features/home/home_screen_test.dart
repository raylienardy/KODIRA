import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/level_model.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/models/user_progress_model.dart';
import 'package:kodira/data/models/user_streak_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/home/providers/level_provider.dart';
import 'package:kodira/features/home/screens/home_screen.dart';

void main() {
  final user = UserModel(
    id: 'user-1',
    nim: '2402095010141',
    name: 'Ayu Tester',
    createdAt: DateTime(2026, 1, 1),
  );
  final levels = <LevelModel>[
    LevelModel(
      id: 1,
      levelNumber: 1,
      title: 'Pengenalan C++',
      topic: 'Dasar C++',
      language: 'cpp',
      createdAt: DateTime(2026, 1, 1),
    ),
    LevelModel(
      id: 2,
      levelNumber: 2,
      title: 'Variabel',
      topic: 'Variabel',
      language: 'cpp',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];
  final progress = <UserProgressModel>[
    const UserProgressModel(
      id: 'progress-1',
      userId: 'user-1',
      levelId: 1,
      status: 'completed',
      masteryScore: 1,
      xpEarned: 100,
      attempts: 1,
    ),
  ];

  List<Override> baseOverrides({
    required Future<List<LevelModel>> Function() levelsLoader,
    required Future<List<UserProgressModel>> Function() progressLoader,
  }) => <Override>[
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
    authStateProvider.overrideWith((ref) {
      final notifier = AuthNotifier(ref.watch(authRepositoryProvider), ref);
      notifier.restoreSession(user);
      return notifier;
    }),
    allLevelsProvider.overrideWith((ref) => levelsLoader()),
    userProgressProvider.overrideWith((ref) => progressLoader()),
    totalXpProvider.overrideWith((ref) async => 100),
    currentStreakProvider.overrideWith(
      (ref) async => const UserStreakModel(
        userId: 'user-1',
        currentStreak: 0,
        longestStreak: 0,
      ),
    ),
    badgeCountProvider.overrideWith((ref) async => 0),
    levelProgressProvider(1).overrideWith((ref) async => progress.first),
    levelProgressProvider(2).overrideWith((ref) async => null),
  ];

  Future<void> pumpHome(
    WidgetTester tester, {
    required Future<List<LevelModel>> Function() levelsLoader,
    required Future<List<UserProgressModel>> Function() progressLoader,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(
          levelsLoader: levelsLoader,
          progressLoader: progressLoader,
        ),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
  }

  testWidgets('menampilkan indikator loading saat provider level loading', (
    tester,
  ) async {
    final completer = Completer<List<LevelModel>>();
    await pumpHome(
      tester,
      levelsLoader: () => completer.future,
      progressLoader: () async => progress,
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(levels);
    await tester.pumpAndSettle();
  });

  testWidgets('menampilkan teks error saat provider level error', (
    tester,
  ) async {
    await pumpHome(
      tester,
      levelsLoader: () =>
          Future<List<LevelModel>>.error(Exception('network failed')),
      progressLoader: () async => progress,
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Koneksi'), findsOneWidget);
  });

  testWidgets('menampilkan empty state saat tidak ada level', (tester) async {
    await pumpHome(
      tester,
      levelsLoader: () async => <LevelModel>[],
      progressLoader: () async => <UserProgressModel>[],
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada level'), findsOneWidget);
  });

  testWidgets('menampilkan list level saat data berhasil dimuat', (
    tester,
  ) async {
    await pumpHome(
      tester,
      levelsLoader: () async => levels,
      progressLoader: () async => progress,
    );
    await tester.pumpAndSettle();

    expect(find.text('Pengenalan C++'), findsOneWidget);
    expect(find.text('Variabel'), findsWidgets);
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
