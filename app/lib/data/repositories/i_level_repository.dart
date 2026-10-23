import '../models/level_model.dart';
import '../models/user_progress_model.dart';

/// Kontrak repository level dan progress level.
///
/// Implementasi konkret: `LevelRepository`.
abstract class ILevelRepository {
  /// Ambil semua level, urut berdasarkan level number.
  Future<List<LevelModel>> getAllLevels();

  /// Ambil satu level berdasarkan ID.
  Future<LevelModel?> getLevelById(int id);

  /// Ambil semua progress user.
  Future<List<UserProgressModel>> getUserProgress(String userId);

  /// Ambil progress user untuk level tertentu.
  Future<UserProgressModel?> getProgressForLevel(String userId, int levelId);
}
