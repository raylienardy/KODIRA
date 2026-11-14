import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/user_model.dart';
import '../../core/errors/auth_exception.dart';
import '../../features/profile/logic/password_update_logic.dart';
import 'auth_logic.dart';
import 'i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final supa.SupabaseClient _client;

  AuthRepository(this._client);

  /// Mengambil user yang sedang login (jika ada).
  @override
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
  @override
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
  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supa.AuthException catch (e) {
      throw KodiraAuthException.unknown(e.message);
    }
  }

  /// Stream perubahan status auth (true = logged in).
  @override
  Stream<bool> authStateChanges() {
    return _client.auth.onAuthStateChange.map((data) => data.session != null);
  }

  /// Update password user. Verifikasi [oldPassword] dulu, lalu ganti ke
  /// [newPassword]. Throw `AuthException` jika verifikasi gagal.
  ///
  /// Step 1: verifikasi password lama lewat `signInWithPassword`. Ini juga
  /// refresh session aktif.
  /// Step 2: update password. Fallback ke `currentPassword` jika server
  /// require reauth (`secure_password_change = true`).
  @override
  Future<void> updatePassword({
    required String nim,
    required String oldPassword,
    required String newPassword,
  }) async {
    final String email = AuthLogic.nimToEmail(nim);

    // Step 1: verifikasi password lama. Ini juga refresh session aktif.
    await _client.auth.signInWithPassword(email: email, password: oldPassword);

    // Step 2: update password. Fallback ke currentPassword jika server
    // require reauth (secure_password_change = true).
    try {
      await _client.auth.updateUser(supa.UserAttributes(password: newPassword));
    } on supa.AuthException catch (e) {
      if (PasswordUpdateLogic.shouldRetryWithCurrentPassword(e.message)) {
        await _client.auth.updateUser(
          supa.UserAttributes(
            password: newPassword,
            currentPassword: oldPassword,
          ),
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> updateProfile({required String name}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const supa.AuthException('Tidak terautentikasi');
    await _client.from('users').update({'name': name}).eq('id', userId);
  }

  @override
  Future<UserModel> signUpWithNim({
    required String nim,
    required String name,
    required String password,
    String role = 'student',
  }) async {
    final String email = AuthLogic.nimToEmail(nim);

    // 1b. Validasi identifier: NIM (12-13 digit) untuk mahasiswa,
    //     NIDN (10 digit) untuk dosen.
    final bool isTeacher = role == 'teacher';
    if (isTeacher) {
      if (!RegExp(r'^\d{10}$').hasMatch(nim)) {
        throw const supa.AuthException('NIDN harus 10 digit angka');
      }
    } else if (!RegExp(r'^\d{12,13}$').hasMatch(nim)) {
      throw const supa.AuthException('NIM harus 12 atau 13 digit angka');
    }

    // 2. Check NIM duplicate (client-side quick check)
    final existing = await _client
        .from('users')
        .select('id')
        .eq('nim', nim)
        .maybeSingle();
    if (existing != null) {
      throw const supa.AuthException('NIM sudah terdaftar. Silakan login.');
    }

    // 3. Sign up via Supabase Auth (trigger auto-creates public.users with role)
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'nim': nim,
        'name': name,
        'role': role,
        'nidn': isTeacher ? nim : null,
      },
    );

    if (authResponse.user == null) {
      throw const supa.AuthException('Registrasi gagal. Coba lagi.');
    }

    // 4. Return user model
    final userMap = await _client
        .from('users')
        .select()
        .eq('id', authResponse.user!.id)
        .single();
    return UserModel.fromSupabase(Map<String, dynamic>.from(userMap));
  }
}
