class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => message;

  // Factory constructors for common errors
  factory AuthException.invalidCredentials() =>
      AuthException('invalid_credentials', 'NIM atau password salah');

  factory AuthException.networkError() =>
      AuthException('network_error', 'Koneksi bermasalah, coba lagi');

  factory AuthException.userNotFound() =>
      AuthException('user_not_found', 'Akun tidak ditemukan');

  factory AuthException.unknown([String? detail]) =>
      AuthException('unknown', detail ?? 'Terjadi kesalahan');
}
