/// Aturan validasi autentikasi (P4-001) yang berdiri sendiri tanpa
/// bergantung pada Supabase, supaya bisa diuji unit test tanpa perangkat.
///
/// Seluruh aturan di sini adalah bentuk murni dari [AuthRepository]:
/// memindahkan logika ke kelas ini tidak mengubah perilaku produksi.
class AuthLogic {
  const AuthLogic._();

  /// NIM mahasiswa terdiri atas 13 digit angka, contoh `2402095010141`.
  ///
  /// Helper ini tersedia untuk validasi di sisi UI. Saat ini belum dipasang
  /// ke alur login supaya perilaku produksi tidak berubah.
  static bool isValidNim(String nim) {
    return RegExp(r'^\d{13}$').hasMatch(nim);
  }

  /// Mengubah NIM menjadi format email internal Supabase.
  static String nimToEmail(String nim) => 'nim_$nim@kodira.local';

  /// Apakah pesan error Supabase menandakan kredensial tidak valid?
  ///
  /// Supabase memakai pesan yang berbeda-bedanya untuk kredensial salah,
  /// jadi pemeriksaan dilakukan pada isi pesannya.
  static bool isInvalidCredentials(String message) {
    final lower = message.toLowerCase();
    return lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials');
  }

  /// Memetakan kode error Supabase ke pesan Bahasa Indonesia.
  ///
  /// Dipakai lapisan UI untuk menampilkan pesan yang lebih ramah. Repository
  /// tetap melempar [KodiraAuthException] dengan pesan yang sama seperti
  /// sebelumnya agar tampilan pengguna tidak berubah.
  static String mapAuthError(String code, String? message) {
    switch (code) {
      case 'invalid_credentials':
        return 'NIM atau password salah.';
      case 'user_not_found':
        return 'Akun tidak ditemukan.';
      case 'email_not_confirmed':
        return 'Akun belum dikonfirmasi.';
      default:
        return message ?? 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
