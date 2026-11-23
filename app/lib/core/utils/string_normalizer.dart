/// Helper normalisasi string untuk perbandingan jawaban latihan KODIRA.
///
/// Fungsi ini menggabungkan spasi berlebih, membersihkan spasi di sekitar
/// tanda baca seperti `; = , ( ) { }`, dan mengubah huruf sesuai kebutuhan
/// agar variasi penulisan jawaban (misalnya urutan deklarasi variabel yang
/// ditukar) dikenali sebagai setara.
class StringNormalizer {
  StringNormalizer._();

  /// Normalisasi string untuk perbandingan jawaban latihan.
  ///
  /// Langkah yang diterapkan:
  /// 1. `trim()` — buang spasi di awal/akhir.
  /// 2. Ganti newline/tab dengan spasi.
  /// 3. Gabungkan spasi berlebih menjadi satu spasi.
  /// 4. Hapus spasi di sekitar tanda baca `; = , ( ) { }`.
  /// 5. Lowercase (kasus tidak mempengaruhi logika C++/Java, tapi
  ///    mempermudah perbandingan teks bebas kasus).
  static String normalize(String? input) {
    if (input == null) return '';
    var text = input.trim();
    if (text.isEmpty) return '';

    // Ganti newline/tab dengan spasi, lalu gabungkan spasi berlebih.
    text = text.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // Hapus spasi di sekitar tanda baca yang umum dalam kode.
    const punctuation = ';=,(){}';
    for (final char in punctuation.split('')) {
      text = text.replaceAll(' $char', char);
      text = text.replaceAll('$char ', char);
    }

    // Hapus spasi berlebih yang mungkin muncul lagi setelah langkah di atas.
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  /// Bandingkan dua string setelah dinormalisasi.
  static bool equals(String? a, String? b) {
    return normalize(a) == normalize(b);
  }

  /// Cek apakah [userInput] cocok dengan [expected] atau dengan salah satu
  /// entri dalam [alternatives] (setelah dinormalisasi).
  static bool matches(
    String? userInput,
    String? expected,
    List<String> alternatives,
  ) {
    final normalizedUser = normalize(userInput);
    if (normalizedUser.isEmpty) return false;

    if (equals(normalizedUser, expected)) return true;

    for (final alt in alternatives) {
      if (equals(normalizedUser, alt)) return true;
    }

    return false;
  }
}
