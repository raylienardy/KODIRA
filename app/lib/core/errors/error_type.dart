/// Klasifikasi error yang dipakai seluruh lapisan UI.
///
/// Setiap nilai membawa pesan Bahasa Indonesia yang siap ditampilkan dan
/// penanda apakah operasi layak dicoba ulang.
enum ErrorType {
  network('Koneksi bermasalah. Periksa internet Anda.'),
  timeout('Waktu habis. Coba lagi.'),
  unauthorized('Sesi habis. Silakan login ulang.'),
  notFound('Data tidak ditemukan.'),
  validation('Data tidak valid.'),
  server('Server sedang bermasalah. Coba lagi nanti.'),
  unknown('Terjadi kesalahan. Coba lagi.');

  /// Pesan yang aman ditampilkan ke pengguna.
  final String userMessage;

  const ErrorType(this.userMessage);

  /// Petakan exception atau pesan error ke [ErrorType] yang sesuai.
  ///
  /// Pencocokan memakai isi pesan karena sumber error berbeda-beda:
  /// `SocketException` dari jaringan, `TimeoutException`, `PostgrestException`
  /// dengan kode status, dan `KodiraAuthException` dengan kode teks.
  static ErrorType fromException(Object e) {
    final String s = e.toString().toLowerCase();
    if (s.contains('socketexception') || s.contains('network')) {
      return network;
    }
    if (s.contains('timeout')) return timeout;
    if (s.contains('401') || s.contains('unauthorized') || s.contains('jwt')) {
      return unauthorized;
    }
    if (s.contains('404') || s.contains('not found')) return notFound;
    if (s.contains('400') || s.contains('invalid')) return validation;
    if (s.contains('500') || s.contains('server')) return server;
    return unknown;
  }

  /// Error sementara yang masuk akal untuk dicoba ulang.
  bool get isRetryable => this == network || this == timeout || this == server;
}
