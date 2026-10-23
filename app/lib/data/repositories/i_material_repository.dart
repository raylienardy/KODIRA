import '../models/material_model.dart';

/// Kontrak repository materi pembelajaran.
///
/// Implementasi konkret: `MaterialRepository`.
abstract class IMaterialRepository {
  /// Ambil semua materi untuk level tertentu.
  Future<List<MaterialModel>> getMaterialsByLevel(int levelId);
}
