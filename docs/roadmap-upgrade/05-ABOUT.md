# Fitur #5 — About & Panduan Statis

## Konteks
Aplikasi membutuhkan dokumentasi internal yang dapat diakses mahasiswa kapan saja untuk memahami aturan main (gamifikasi) dan sistem penilaian di KODIRA.

## Scope
Halaman informasi statis di aplikasi mobile yang memuat panduan belajar.

## Spec Detail
- **Routing**: `/about` diakses melalui menu sidebar drawer.
- **Implementasi**: Widget `AboutScreen` yang membaca file aset markdown.
- **Konten (6 Sections)**:
  1. **Cara Naik Level**: Alur belajar (materi -> latihan -> kuis) dengan ambang kelulusan 70%.
  2. **Sistem XP**: Penjelasan perolehan XP Mudah (50), Sedang (100), Tinggi (150) serta streak multiplier.
  3. **Cara Hitung Mastery**: Penjelasan sederhana tentang akurasi, waktu, dan konsistensi.
  4. **Streak & Badge**: Panduan mendapatkan lencana dan menjaga streak harian.
  5. **Tips Belajar**: Rekomendasi penggunaan AI hint dan pengulangan kuis untuk perbaikan nilai.
  6. **FAQ**: Pertanyaan umum sepert "Bagaimana jika kuis saya gagal?" atau "Kenapa mastery saya belum 100%?".

## File yang Disentuh
- `app/lib/features/profile/screens/about_screen.dart` (BARU).
- `app/assets/content/about.md` (Aset konten markdown).
- `app/lib/app/router.dart` (Registrasi route `/about`).

## Test Cases
- Verify halaman About terbuka melalui menu drawer.
- Verify seluruh 6 section konten tampil lengkap sesuai dengan file aset.
- Verify tautan atau navigasi kembali ke home berfungsi.

## Definition of Done
- Mahasiswa memiliki panduan tertulis lengkap di dalam aplikasi tanpa harus bertanya ke dosen.

## Blocker / Dependency
- Tidak ada.

## Effort Estimate
- 3 jam (Termasuk penulisan konten markdown).

## Risk
- Ukuran paket aplikasi meningkat karena file aset. Mitigasi: menggunakan file markdown teks yang ukurannya sangat kecil dibandingkan gambar.
