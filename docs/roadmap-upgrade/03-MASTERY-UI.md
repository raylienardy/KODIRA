# Fitur #3 — Mastery UI Breakdown & Transparansi Skor

## 1. Konteks
Saat ini, tampilan skor mastery di aplikasi KODIRA disajikan dalam persentase tunggal (misal: 85%). Hal ini menimbulkan kebingungan bagi mahasiswa saat mereka merasa telah menjawab semua soal dengan benar namun skor tidak mencapai 100%. Untuk meningkatkan transparansi, sistem perlu menjelaskan breakdown dari komponen formula mastery yang digunakan.

## 2. Scope
Transparansi formula mastery melalui UI breakdown detail pada halaman profil, didukung oleh refaktoring engine adaptif.

## 3. Spec Detail & Spesifikasi Teknis
- **Trigger**: Menambahkan fungsi `onTap` pada widget mastery bar di halaman profil (`ProfileScreen`).
- **Antarmuka (UI)**: Dialog *bottom sheet* yang menampilkan breakdown berikut secara rinci:
  - **A (Akurasi)**: Rasio jawaban benar (`correct / total`, rentang 0.0–1.0).
  - **C (Konsistensi)**: Performa historis terbaik dari riwayat sebelumnya.
  - **E (Error Rate)**: Nilai kesalahan (`1.0 - A`).
  - **Tn (Time Taken)**: Kecepatan pengerjaan dinormalisasi terhadap batas waktu soal.
- **Formula (Informasi Visual)**:
  `M = 0.45×A + 0.25×C + 0.20×(1 − E) + 0.10×(1 − Tn)`
- **Keterangan Tambahan & Tips**: Menambahkan panduan actionable: *"Untuk mencapai 100%: jawab lebih cepat, ulangi kuis tanpa bantuan hint, dan pertahankan akurasi tinggi di level berikutnya."*

## 4. File yang Disentuh (File:Line & Snippet)
- **`app/lib/features/profile/widgets/mastery_section.dart:16-50`**
  - Modifikasi widget untuk mendukung interaksi tap:
    ```dart
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => MasteryBreakdownSheet(masteryData: data),
        );
      },
      child: masteryAsync.when(
        data: (data) => MasteryBar(data: data),
        loading: () => LoadingWidget(),
        error: (err, stack) => ErrorWidget(),
      ),
    );
    ```
- **`app/lib/features/profile/widgets/mastery_breakdown_sheet.dart` (BARU)**
  - Implementasi komponen UI sheet kustom.
- **Refactoring Required (`AdaptiveEngine`)**:
  - Saat ini `AdaptiveEngine.computeMastery` (di `app/lib/features/adaptive/services/adaptive_engine.dart:30`) mengembalikan nilai tunggal `double`.
  - Harus direfaktor menjadi mengembalikan objek `MasteryBreakdown`:
    ```dart
    class MasteryBreakdown {
      final double accuracy;
      final double consistency;
      final double errorRate;
      final double timeNorm;
      final double total;
      const MasteryBreakdown({required this.accuracy, required this.consistency, required this.errorRate, required this.timeNorm, required this.total});
    }
    ```

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**: `app/test/features/profile/mastery_breakdown_test.dart` (5 kasus uji):
  1. `DialogAppearance`: Memastikan bottom sheet muncul saat mastery bar ditekan.
  2. `FormulaDisplay`: Memastikan angka komponen A, C, E, Tn dan Total sesuai dengan perhitungan engine.
  3. `TipRendering`: Memastikan tips perbaikan skor muncul dengan benar.
  4. `DismissFunctionality`: Memastikan interaksi tutup/dismiss sheet berjalan mulus.
  5. `DataMapping`: Memastikan `MasteryBreakdown` object terpetakan dengan benar dari hasil kalkulasi.

## 6. Definition of Done (DoD)
- Mahasiswa dapat memahami secara detail komponen yang membentuk nilai mastery mereka dan mengetahui langkah perbaikan untuk mencapai 100%.
- Unit test mastery breakdown lulus 100%.

## 7. Blocker & Dependency
- Bergantung pada refaktoring `AdaptiveEngine` untuk mengekspos komponen internal mastery.

## 8. Effort Estimate
- 3 jam pengerjaan (UI, Refaktoring Engine, dan Unit Test).

## 9. Risk & Mitigasi
- **Risk**: Pengguna awam kesulitan memahami istilah teknis seperti "Normalized Time" atau "Error Rate".
- **Mitigasi**: Menggunakan label bahasa Indonesia yang ramah (Contoh: *"Waktu Pengerjaan"* daripada *"Time Taken"*, *"Tingkat Kesalahan"* daripada *"Error Rate"*).
