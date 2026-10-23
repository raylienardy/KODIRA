import 'dart:async';

import '../models/user_model.dart';

/// Kontrak repository autentikasi.
///
/// Implementasi konkret: `AuthRepository`.
abstract class IAuthRepository {
  /// Mengambil user yang sedang login (jika ada).
  Future<UserModel?> getCurrentUser();

  /// Login dengan NIM + password.
  Future<UserModel> signInWithNim({
    required String nim,
    required String password,
  });

  /// Logout user.
  Future<void> signOut();

  /// Stream perubahan status auth (true = logged in).
  Stream<bool> authStateChanges();
}
