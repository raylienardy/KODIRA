import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/level_model.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/models/user_progress_model.dart';
import 'package:kodira/data/models/user_streak_model.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/data/repositories/i_badge_repository.dart';
import 'package:kodira/data/repositories/i_user_progress_repository.dart';
import 'package:kodira/features/auth/providers/auth_provider.dart';
import 'package:kodira/features/home/providers/level_provider.dart';
import 'package:kodira/features/quiz/screens/quiz_screen.dart';

const QuizQuestion _question = QuizQuestion(
  prompt: 'Berapa hasil dari 1 + 1?',
  language: 'cpp',
  options: [
    QuizOption(id: 'a', text: '1'),
    QuizOption(id: 'b', text: '2'),
  ],
  answerId: 'b',
  explanation: '1 + 1 = 2.',
);

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository(this.user);

  final UserModel? user;

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
    throw UnimplementedError();
  }
}

class _UpsertCall {
  const _UpsertCall({
    required this.levelId,
    required this.status,
    required this.xpEarned,
    required this.attempts,
  });

  final int levelId;
  final String status;
  final int xpEarned;
  final int attempts;
}

class _FakeProgressRepository implements IUserProgressRepository {
  _FakeProgressRepository({this.existing});

  final UserProgressModel? existing;
  final List<_UpsertCall> upserts = <_UpsertCall>[];

  @override
  Future<List<UserProgressModel>> getAllForUser(String userId) async =>
      const <UserProgressModel>[];

  @override
  Future<UserProgressModel?> getForLevel(String userId, int levelId) async {
    final UserProgressModel? current = existing;
    if (current != null && current.levelId == levelId) return current;
    return null;
  }

  @override
  Future<int> getTotalXp(String userId) async => 0;

  @override
  Future<void> upsert({
    required String userId,
    required int levelId,
    required String status,
    required double masteryScore,
    required int xpEarned,
    required int attempts,
  }) async {
    upserts.add(
      _UpsertCall(
        levelId: levelId,
        status: status,
        xpEarned: xpEarned,
        attempts: attempts,
      ),
    );
  }
}

class _FakeBadgeRepository implements IBadgeRepository {
  @override
  Future<Set<String>> getBadgeCodes(String userId) async => <String>{};

  @override
  Future<Set<String>> getAchievementCodes(String userId) async => <String>{};

  @override
  Future<void> awardBadges({
    required String userId,
    required Set<String> badgeCodes,
    DateTime? earnedAt,
  }) async {}

  @override
  Future<void> awardAchievements({
    required String userId,
    required Set<String> achievementCodes,
    DateTime? earnedAt,
  }) async {}

  @override
  Future<({Set<String> newBadges, Set<String> newAchievements})> checkAndAward(
    String userId,
  ) async => (newBadges: <String>{}, newAchievements: <String>{});
}

UserProgressModel _completedProgress(int levelId) {
  return UserProgressModel(
    id: 'progress-$levelId',
    userId: 'user-1',
    levelId: levelId,
    status: 'completed',
    masteryScore: 0.8,
    xpEarned: 0,
    attempts: 1,
  );
}

Future<_FakeProgressRepository> _pumpQuiz(
  WidgetTester tester, {
  required int levelId,
  required int levelNumber,
  required int streak,
  bool failLevels = false,
}) async {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final progressRepo = _FakeProgressRepository(
    existing: _completedProgress(levelId),
  );
  final user = UserModel(
    id: 'user-1',
    nim: '123456789',
    name: 'Mahasiswa Test',
    createdAt: DateTime(2026, 1, 1),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
        userProgressRepositoryProvider.overrideWithValue(progressRepo),
        badgeRepositoryProvider.overrideWithValue(_FakeBadgeRepository()),
        allLevelsProvider.overrideWith((ref) async {
          if (failLevels) {
            throw Exception('gagal memuat daftar level');
          }
          return <LevelModel>[
            LevelModel(
              id: levelId,
              levelNumber: levelNumber,
              title: 'Level $levelNumber',
              createdAt: DateTime(2026, 1, 1),
            ),
          ];
        }),
        currentStreakProvider.overrideWith(
          (ref) async => UserStreakModel(
            userId: 'user-1',
            currentStreak: streak,
            longestStreak: streak,
          ),
        ),
      ],
      child: MaterialApp(
        home: QuizScreen(
          levelId: levelId,
          levelTitle: 'Level $levelNumber',
          overrideQuestions: const <QuizQuestion>[_question],
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump();
  return progressRepo;
}

Future<void> _finishQuiz(WidgetTester tester) async {
  await tester.tap(find.text('2'));
  await tester.pump();
  await tester.tap(find.text('Kirim Jawaban'));
  await tester.pump();
  await tester.tap(find.text('Lihat Hasil'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tier sedang dengan streak 7 menghasilkan 150 XP', (
    WidgetTester tester,
  ) async {
    final progressRepo = await _pumpQuiz(
      tester,
      levelId: 20,
      levelNumber: 20,
      streak: 7,
    );

    await _finishQuiz(tester);

    expect(progressRepo.upserts, isNotEmpty);
    expect(progressRepo.upserts.first.levelId, 20);
    expect(progressRepo.upserts.first.status, 'completed');
    expect(progressRepo.upserts.first.xpEarned, 150);
    expect(find.text('Kamu mendapat 150 XP'), findsOneWidget);
  });

  testWidgets('tier tinggi memakai base 150 XP sebelum multiplier', (
    WidgetTester tester,
  ) async {
    final progressRepo = await _pumpQuiz(
      tester,
      levelId: 36,
      levelNumber: 36,
      streak: 7,
    );

    await _finishQuiz(tester);

    expect(progressRepo.upserts, isNotEmpty);
    expect(progressRepo.upserts.first.levelId, 36);
    expect(progressRepo.upserts.first.xpEarned, 225);
    expect(find.text('Kamu mendapat 225 XP'), findsOneWidget);
  });

  testWidgets('provider level gagal memakai fallback tier mudah tanpa crash', (
    WidgetTester tester,
  ) async {
    final progressRepo = await _pumpQuiz(
      tester,
      levelId: 10,
      levelNumber: 10,
      streak: 0,
      failLevels: true,
    );

    await _finishQuiz(tester);

    expect(progressRepo.upserts, isNotEmpty);
    expect(progressRepo.upserts.first.levelId, 10);
    expect(progressRepo.upserts.first.xpEarned, 50);
    expect(find.text('Kamu mendapat 50 XP'), findsOneWidget);
    expect(find.text('Lulus!'), findsOneWidget);
  });
}
