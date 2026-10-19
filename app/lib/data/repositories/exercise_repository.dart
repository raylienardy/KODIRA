import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/exercise_model.dart';

class ExerciseRepository {
  final supa.SupabaseClient _client;

  ExerciseRepository(this._client);

  /// Ambil semua exercise untuk level tertentu.
  Future<List<ExerciseModel>> getExercisesByLevel(int levelId) async {
    try {
      final response = await _client
          .from('exercises')
          .select()
          .eq('level_id', levelId);

      final list = response as List<dynamic>;
      return list
          .map(
            (item) => ExerciseModel.fromSupabase(item as Map<String, dynamic>),
          )
          .toList();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat exercise level: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat exercise: $e');
    }
  }

  /// Ambil semua exercise untuk level dan tipe tertentu.
  Future<List<ExerciseModel>> getExercisesByLevelAndType(
    int levelId,
    String type,
  ) async {
    try {
      final response = await _client
          .from('exercises')
          .select()
          .eq('level_id', levelId)
          .eq('type', type);

      final list = response as List<dynamic>;
      return list
          .map(
            (item) => ExerciseModel.fromSupabase(item as Map<String, dynamic>),
          )
          .toList();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat exercise level & tipe: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat exercise tipe: $e');
    }
  }
}
