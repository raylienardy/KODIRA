import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/material_model.dart';

class MaterialRepository {
  final supa.SupabaseClient _client;

  MaterialRepository(this._client);

  /// Ambil semua materi untuk level tertentu, urut by slide_order ASC.
  Future<List<MaterialModel>> getMaterialsByLevel(int levelId) async {
    try {
      final response = await _client
          .from('materials')
          .select()
          .eq('level_id', levelId)
          .order('slide_order', ascending: true);

      final list = response as List<dynamic>;
      return list
          .map(
            (item) => MaterialModel.fromSupabase(item as Map<String, dynamic>),
          )
          .toList();
    } on supa.PostgrestException catch (e) {
      throw Exception('Gagal memuat materi level: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat materi: $e');
    }
  }
}
