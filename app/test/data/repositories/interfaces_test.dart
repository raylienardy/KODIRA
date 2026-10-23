import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/models/exercise_model.dart';
import 'package:kodira/data/models/level_model.dart';
import 'package:kodira/data/models/material_model.dart';
import 'package:kodira/data/models/user_model.dart';
import 'package:kodira/data/models/user_progress_model.dart';
import 'package:kodira/data/models/user_streak_model.dart';
import 'package:kodira/data/repositories/auth_repository.dart';
import 'package:kodira/data/repositories/badge_repository.dart';
import 'package:kodira/data/repositories/exercise_repository.dart';
import 'package:kodira/data/repositories/i_auth_repository.dart';
import 'package:kodira/data/repositories/i_badge_repository.dart';
import 'package:kodira/data/repositories/i_exercise_repository.dart';
import 'package:kodira/data/repositories/i_level_repository.dart';
import 'package:kodira/data/repositories/i_material_repository.dart';
import 'package:kodira/data/repositories/i_streak_repository.dart';
import 'package:kodira/data/repositories/i_user_progress_repository.dart';
import 'package:kodira/data/repositories/level_repository.dart';
import 'package:kodira/data/repositories/material_repository.dart';
import 'package:kodira/data/repositories/streak_repository.dart';
import 'package:kodira/data/repositories/user_progress_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements IAuthRepository {
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
  Future<void> signOut() async {}

  @override
  Stream<bool> authStateChanges() => const Stream<bool>.empty();
}

class _FakeLevelRepository implements ILevelRepository {
  @override
  Future<List<LevelModel>> getAllLevels() async => <LevelModel>[];

  @override
  Future<LevelModel?> getLevelById(int id) async => null;

  @override
  Future<List<UserProgressModel>> getUserProgress(String userId) async =>
      <UserProgressModel>[];

  @override
  Future<UserProgressModel?> getProgressForLevel(
    String userId,
    int levelId,
  ) async => null;
}

class _FakeMaterialRepository implements IMaterialRepository {
  @override
  Future<List<MaterialModel>> getMaterialsByLevel(int levelId) async =>
      <MaterialModel>[];
}

class _FakeExerciseRepository implements IExerciseRepository {
  @override
  Future<List<ExerciseModel>> getExercisesByLevel(int levelId) async =>
      <ExerciseModel>[];

  @override
  Future<List<ExerciseModel>> getExercisesByLevelAndType(
    int levelId,
    String type,
  ) async => <ExerciseModel>[];
}

class _FakeUserProgressRepository implements IUserProgressRepository {
  @override
  Future<List<UserProgressModel>> getAllForUser(String userId) async =>
      <UserProgressModel>[];

  @override
  Future<UserProgressModel?> getForLevel(String userId, int levelId) async =>
      null;

  @override
  Future<void> upsert({
    required String userId,
    required int levelId,
    required String status,
    required double masteryScore,
    required int xpEarned,
    required int attempts,
  }) async {}

  @override
  Future<int> getTotalXp(String userId) async => 0;
}

class _FakeStreakRepository implements IStreakRepository {
  @override
  Future<UserStreakModel?> getForUser(String userId) async => null;

  @override
  Future<UserStreakModel> updateOnActivity({
    required String userId,
    required DateTime now,
  }) async {
    throw UnimplementedError();
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
  ) async {
    return (newBadges: <String>{}, newAchievements: <String>{});
  }
}

void main() {
  final SupabaseClient client = SupabaseClient(
    'https://example.supabase.co',
    'test-key',
  );

  group('Concrete implements interface', () {
    test('AuthRepository implements IAuthRepository', () {
      expect(AuthRepository(client), isA<IAuthRepository>());
    });

    test('LevelRepository implements ILevelRepository', () {
      expect(LevelRepository(client), isA<ILevelRepository>());
    });

    test('MaterialRepository implements IMaterialRepository', () {
      expect(MaterialRepository(client), isA<IMaterialRepository>());
    });

    test('ExerciseRepository implements IExerciseRepository', () {
      expect(ExerciseRepository(client), isA<IExerciseRepository>());
    });

    test('UserProgressRepository implements IUserProgressRepository', () {
      expect(UserProgressRepository(client), isA<IUserProgressRepository>());
    });

    test('StreakRepository implements IStreakRepository', () {
      expect(StreakRepository(client), isA<IStreakRepository>());
    });

    test('BadgeRepository implements IBadgeRepository', () {
      expect(BadgeRepository(client), isA<IBadgeRepository>());
    });
  });

  group('Fake can implement interface', () {
    test('IAuthRepository can be implemented', () {
      expect(_FakeAuthRepository(), isA<IAuthRepository>());
    });

    test('ILevelRepository can be implemented', () {
      expect(_FakeLevelRepository(), isA<ILevelRepository>());
    });

    test('IMaterialRepository can be implemented', () {
      expect(_FakeMaterialRepository(), isA<IMaterialRepository>());
    });

    test('IExerciseRepository can be implemented', () {
      expect(_FakeExerciseRepository(), isA<IExerciseRepository>());
    });

    test('IUserProgressRepository can be implemented', () {
      expect(_FakeUserProgressRepository(), isA<IUserProgressRepository>());
    });

    test('IStreakRepository can be implemented', () {
      expect(_FakeStreakRepository(), isA<IStreakRepository>());
    });

    test('IBadgeRepository can be implemented', () {
      expect(_FakeBadgeRepository(), isA<IBadgeRepository>());
    });
  });
}
