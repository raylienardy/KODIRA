import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repositories/exercise_repository.dart';
import '../../auth/providers/auth_provider.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ExerciseRepository(client);
});

final exercisesByLevelProvider =
    FutureProvider.family<List<ExerciseModel>, int>((ref, levelId) async {
      final repo = ref.watch(exerciseRepositoryProvider);
      return repo.getExercisesByLevel(levelId);
    });

final quizExercisesProvider = FutureProvider.family<List<ExerciseModel>, int>((
  ref,
  levelId,
) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getExercisesByLevelAndType(levelId, 'quiz');
});

final dragDropExercisesProvider =
    FutureProvider.family<List<ExerciseModel>, int>((ref, levelId) async {
      final repo = ref.watch(exerciseRepositoryProvider);
      return repo.getExercisesByLevelAndType(levelId, 'drag_drop');
    });
