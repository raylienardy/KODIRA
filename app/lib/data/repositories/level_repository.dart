import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/level_model.dart';
import '../models/user_progress_model.dart';
import 'i_level_repository.dart';

class LevelRepository implements ILevelRepository {
  final supa.SupabaseClient _client;

  LevelRepository(this._client);

  /// Ambil semua level dari tabel `levels`, urut by level_number ASC.
  @override
  Future<List<LevelModel>> getAllLevels() async {
    try {
      final response = await _client
          .from('levels')
          .select()
          .order('level_number', ascending: true);

      final list = response as List<dynamic>;
      return list
          .map((item) => LevelModel.fromSupabase(item as Map<String, dynamic>))
          .toList();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat daftar level: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat level: $e');
    }
  }

  /// Ambil satu level berdasarkan ID.
  @override
  Future<LevelModel?> getLevelById(int id) async {
    try {
      final response = await _client
          .from('levels')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return LevelModel.fromSupabase(response);
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat detail level: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat detail level: $e');
    }
  }

  /// Ambil semua progress user dari tabel `user_progress`.
  @override
  Future<List<UserProgressModel>> getUserProgress(String userId) async {
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId);

      final list = response as List<dynamic>;
      return list
          .map(
            (item) =>
                UserProgressModel.fromSupabase(item as Map<String, dynamic>),
          )
          .toList();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat progress belajar: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat progress: $e');
    }
  }

  /// Ambil progress spesifik user untuk level tertentu.
  @override
  Future<UserProgressModel?> getProgressForLevel(
    String userId,
    int levelId,
  ) async {
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('level_id', levelId)
          .maybeSingle();

      if (response == null) return null;
      return UserProgressModel.fromSupabase(response);
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat progress level: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat progress level: $e');
    }
  }
}
