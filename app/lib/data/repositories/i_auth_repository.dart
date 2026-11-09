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

  /// Register user baru dengan NIM + password + nama.
  /// Auto-enroll ke default class "PTIK24".
  /// Returns UserModel yang siap untuk auto-login.
  Future<UserModel> signUpWithNim({
    required String nim,
    required String name,
    required String password,
  });

  /// Logout user.
  Future<void> signOut();

  /// Stream perubahan status auth (true = logged in).
  Stream<bool> authStateChanges();

  /// Update password user. Verifikasi [oldPassword] dulu, lalu ganti ke
  /// [newPassword]. Throw `AuthException` jika verifikasi gagal.
  Future<void> updatePassword({
    required String nim,
    required String oldPassword,
    required String newPassword,
  });

  /// Update nama profil user yang sedang login.
  /// Throw `AuthException` jika gagal.
  Future<void> updateProfile({required String name});
}
