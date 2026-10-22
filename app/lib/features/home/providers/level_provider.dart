import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/level_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/models/user_streak_model.dart';
import '../../../data/repositories/badge_repository.dart';
import '../../../data/repositories/level_repository.dart';
import '../../../data/repositories/streak_repository.dart';
import '../../../data/repositories/user_progress_repository.dart';
import '../../auth/providers/auth_provider.dart';

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LevelRepository(client);
});

final userProgressRepositoryProvider = Provider<UserProgressRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserProgressRepository(client);
});

final allLevelsProvider = FutureProvider<List<LevelModel>>((ref) async {
  final repo = ref.watch(levelRepositoryProvider);
  return repo.getAllLevels();
});

/// Seluruh progress belajar milik user yang sedang login.
///
/// Menggantikan pengambilan progress lewat `LevelRepository` supaya semua
/// sumber progress memakai satu repository yang sama.
final allProgressProvider = FutureProvider<List<UserProgressModel>>((
  ref,
) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  if (user == null) {
    return [];
  }
  final repo = ref.watch(userProgressRepositoryProvider);
  return repo.getAllForUser(user.id);
});

/// Total XP yang sudah dikumpulkan user dari seluruh level.
final totalXpProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  if (user == null) {
    return 0;
  }
  final repo = ref.watch(userProgressRepositoryProvider);
  return repo.getTotalXp(user.id);
});

/// Alias lama dari [allProgressProvider], tetap dipakai oleh layar Home.
final userProgressProvider = allProgressProvider;

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return StreakRepository(client);
});

/// Streak harian user yang sedang login, null bila belum pernah aktif.
final currentStreakProvider = FutureProvider<UserStreakModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  if (user == null) {
    return null;
  }
  final repo = ref.watch(streakRepositoryProvider);
  return repo.getForUser(user.id);
});

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return BadgeRepository(client);
});

/// Jumlah badge dan achievement yang sudah dimiliki user.
final badgeCountProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  if (user == null) {
    return 0;
  }
  final repo = ref.watch(badgeRepositoryProvider);
  final badges = await repo.getBadgeCodes(user.id);
  final achievements = await repo.getAchievementCodes(user.id);
  return badges.length + achievements.length;
});

final levelProgressProvider = FutureProvider.family<UserProgressModel?, int>((
  ref,
  levelId,
) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  if (user == null) {
    return null;
  }
  final repo = ref.watch(userProgressRepositoryProvider);
  return repo.getForLevel(user.id, levelId);
});
