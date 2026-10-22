import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user_model.dart';
import '../../core/errors/auth_exception.dart';
import 'auth_logic.dart';

class AuthRepository {
  final supa.SupabaseClient _client;

  AuthRepository(this._client);

  /// Mengambil user yang sedang login (jika ada).
  Future<UserModel?> getCurrentUser() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    // Ambil data lengkap dari tabel `users` di database.
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromSupabase(response);
    } on supa.PostgrestException catch (e) {
      throw KodiraAuthException.unknown(e.message);
    }
  }

  /// Login dengan NIM + password.
  /// NIM dikonversi ke format email internal sebelum dipakai ke Supabase.
  Future<UserModel> signInWithNim({
    required String nim,
    required String password,
  }) async {
    final email = AuthLogic.nimToEmail(nim);

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw KodiraAuthException.userNotFound();

      // Update last_login di tabel users.
      await _client
          .from('users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', user.id);

      // Ambil data lengkap dari tabel users.
      final userData = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromSupabase(userData);
    } on supa.AuthException catch (e) {
      // Handle error dari Supabase Auth.
      if (AuthLogic.isInvalidCredentials(e.message)) {
        throw KodiraAuthException.invalidCredentials();
      }
      throw KodiraAuthException.unknown(e.message);
    } on supa.PostgrestException catch (e) {
      throw KodiraAuthException.unknown(e.message);
    } catch (e) {
      throw KodiraAuthException.networkError();
    }
  }

  /// Logout user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supa.AuthException catch (e) {
      throw KodiraAuthException.unknown(e.message);
    }
  }

  /// Stream perubahan status auth (true = logged in).
  Stream<bool> authStateChanges() {
    return _client.auth.onAuthStateChange.map((data) => data.session != null);
  }
}
