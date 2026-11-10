import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/my_class_model.dart';

class ClassRepository {
  final supa.SupabaseClient _client;
  ClassRepository(this._client);

  /// Get user's enrolled classes (M:N).
  Future<List<MyClass>> getMyClasses(String userId) async {
    final response = await _client
        .from('class_students')
        .select('''
          class_id,
          is_primary,
          enrolled_at,
          classes:class_id (
            name,
            code,
            description
          )
        ''')
        .eq('student_id', userId)
        .order('enrolled_at', ascending: false);

    final data = List<Map<String, dynamic>>.from(response);
    return data.map((row) {
      final classData = row['classes'] as Map<String, dynamic>?;
      return MyClass(
        id: row['class_id'] as String,
        name: classData?['name'] as String? ?? 'Unknown',
        code: classData?['code'] as String? ?? '------',
        description: classData?['description'] as String?,
        isPrimary: row['is_primary'] as bool? ?? false,
        enrolledAt: DateTime.parse(row['enrolled_at'] as String),
      );
    }).toList();
  }

  /// Join new class via 6-char code.
  Future<Map<String, dynamic>> joinClass(String code) async {
    final result = await _client.rpc(
      'join_class',
      params: {'p_code': code.toUpperCase()},
    );
    return Map<String, dynamic>.from(result as Map);
  }

  /// Set class as primary.
  Future<void> setPrimaryClass(String classId) async {
    await _client.rpc('set_primary_class', params: {'p_class_id': classId});
  }

  /// Create new class (teacher only).
  ///
  /// Menghasilkan kode 6-karakter unik di server, memasukkan baris ke
  /// tabel `classes`, lalu menambahkan teacher sebagai owner.
  Future<Map<String, dynamic>> createClass({
    required String name,
    String? description,
  }) async {
    final result = await _client.rpc(
      'create_class',
      params: {'p_name': name, 'p_description': description},
    );
    return Map<String, dynamic>.from(result as Map);
  }
}
