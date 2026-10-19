import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/level_model.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/repositories/level_repository.dart';
import '../../auth/providers/auth_provider.dart';

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return LevelRepository(client);
});

final allLevelsProvider = FutureProvider<List<LevelModel>>((ref) async {
  final repo = ref.watch(levelRepositoryProvider);
  return repo.getAllLevels();
});

final userProgressProvider = FutureProvider<List<UserProgressModel>>((
  ref,
) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;
  if (user == null) {
    return [];
  }
  final repo = ref.watch(levelRepositoryProvider);
  return repo.getUserProgress(user.id);
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
  final repo = ref.watch(levelRepositoryProvider);
  return repo.getProgressForLevel(user.id, levelId);
});
