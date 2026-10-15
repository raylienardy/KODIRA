/// Custom exception untuk error autentikasi KODIRA.
///
/// Dinamai "KodiraAuthException" untuk menghindari konflik dengan
/// `AuthException` dari package `supabase_flutter`.
class KodiraAuthException implements Exception {
  final String code;
  final String message;

  KodiraAuthException(this.code, this.message);

  @override
  String toString() => message;

  factory KodiraAuthException.invalidCredentials() =>
      KodiraAuthException('invalid_credentials', 'NIM atau password salah');

  factory KodiraAuthException.networkError() =>
      KodiraAuthException('network_error', 'Koneksi bermasalah, coba lagi');

  factory KodiraAuthException.userNotFound() =>
      KodiraAuthException('user_not_found', 'Akun tidak ditemukan');

  factory KodiraAuthException.unknown([String? detail]) =>
      KodiraAuthException('unknown', detail ?? 'Terjadi kesalahan');
}
