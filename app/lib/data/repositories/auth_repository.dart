import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';
import '../../core/errors/auth_exception.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Mengambil user yang sedang login (jika ada)
  Future<UserModel?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    final user = session.user;
    // Supabase mengembalikan user data dalam map `user`.
    return UserModel.fromSupabase(user.toJson());
  }

  /// Login dengan NIM + password.
  /// NIM di‑convert ke format email internal sebelum dipakai ke Supabase.
  Future<UserModel> signInWithNim({required String nim, required String password}) async {
    final email = 'nim_${nim}@kodira.local';
    try {
      final response = await _client.auth.signInWithPassword(email: email, password: password);
      if (response.error != null) {
        // Error spesifik Supabase biasanya berisi code "invalid_credentials".
        if (response.error!.message.contains('Invalid login credentials')) {
          throw AuthException.invalidCredentials();
        }
        throw AuthException.unknown(response.error!.message);
      }
      final user = response.user;
      if (user == null) throw AuthException.userNotFound();
      return UserModel.fromSupabase(user.toJson());
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException.networkError();
    }
  }

  /// Logout user.
  Future<void> signOut() async {
    final response = await _client.auth.signOut();
    if (response.error != null) {
      throw AuthException.unknown(response.error!.message);
    }
  }

  /// Stream perubahan status auth (true = logged in).
  Stream<bool> authStateChanges() {
    return _client.auth.onAuthStateChange.map((data) => data.session != null);
  }
}
