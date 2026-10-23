import '../models/exercise_model.dart';

/// Kontrak repository exercise.
///
/// Implementasi konkret: `ExerciseRepository`.
abstract class IExerciseRepository {
  /// Ambil semua exercise untuk level tertentu.
  Future<List<ExerciseModel>> getExercisesByLevel(int levelId);

  /// Ambil exercise untuk level dan tipe tertentu.
  Future<List<ExerciseModel>> getExercisesByLevelAndType(
    int levelId,
    String type,
  );
}
