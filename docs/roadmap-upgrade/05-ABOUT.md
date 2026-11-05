# Fitur #5 — About & Panduan Statis

## 1. Konteks
Aplikasi KODIRA membutuhkan dokumentasi internal yang dapat diakses mahasiswa kapan saja untuk memahami mekanisme gamifikasi, sistem penilaian, dan aturan belajar tanpa harus keluar dari aplikasi.

## 2. Scope
Halaman informasi statis (`AboutScreen`) di aplikasi mobile dengan konten markdown yang dibaca dari aset lokal.

## 3. Spec Detail & Spesifikasi Teknis
- **Routing**: Menambahkan route `/about` di `router.dart` dan masukkan ke dalam menu *Sidebar Drawer*.
- **Implementasi**: `AboutScreen` membaca file `app/assets/content/about.md` dan merendernya menggunakan `flutter_markdown`.
- **Konten (6 Sections)**:

### Section 1: Cara Naik Level
```markdown
Setiap level di KODIRA mengikuti alur belajar yang konsisten:
1. Baca Materi — 5 slide materi interaktif yang menjelaskan konsep pemrograman dengan contoh kode.
2. Latihan (Exercise) — 5 soal drag & drop untuk menguji pemahaman sintaks dan logika.
3. Kuis (Quiz) — 3 soal pilihan ganda dengan timer 60 detik per soal.

Syarat Lulus: Skor kuis ≥ 70% untuk membuka level berikutnya.
- Skor 40–69% → Remedial (ulangi kuis dengan soal baru dari AI).
- Skor < 40% → Gagal (wajib pelajari ulang materi dari awal).

Kalau Anda mengerjakan kuis dengan skor < 70%, jangan khawatir — gunakan tombol 'Minta Hint AI' untuk pemahaman lebih dalam, lalu coba ulangi kuis.
```

### Section 2: Sistem XP
```markdown
XP (Experience Points) adalah indikator progres belajar Anda.
- Level Mudah (1-15): 50 XP (Lulus), 25 XP (Remedial).
- Level Sedang (16-35): 100 XP (Lulus), 50 XP (Remedial).
- Level Tinggi (36-50): 150 XP (Lulus), 75 XP (Remedial).

Streak Multiplier (Bonus konsistensi harian):
- 7 hari berturut-turut: ×1.5
- 30 hari berturut-turut: ×2.0
- 60+ hari berturut-turut: ×2.5

Bonus streak diterapkan otomatis saat Anda menyelesaikan kuis.
```

### Section 3: Cara Hitung Mastery
```markdown
Skor Mastery (0–100%) dihitung dari 4 komponen:
M = 0.45×A + 0.25×C + 0.20×(1−E) + 0.10×(1−Tn)

- A (Akurasi): Persentase jawaban benar (0–1).
- C (Konsistensi): Skor mastery tertinggi sebelumnya (0–1).
- E (Error Rate): 1 − A (semakin sedikit kesalahan, semakin tinggi skor).
- Tn (Time Normalized): Rata-rata waktu per soal dibagi batas waktu (semakin cepat, semakin tinggi skor).

Tips mencapai 100%:
- Jawab soal dengan benar (maksimalkan A).
- Kerjakan kuis lebih cepat tanpa menurunkan akurasi (minimalkan Tn).
- Lakukan kuis ulangan (mengisi C dari riwayat sebelumnya).
```

### Section 4: Streak & Badge
```markdown
Streak: Hari aktif berturut-turut (minimal 1 kuis selesai).
- Streak putus jika tidak ada aktivitas > 24 jam.
- Badge Streak: 3 hari, 7 hari, 30 hari, 60 hari.

Badge Level: Disemat saat menyelesaikan level ke-5, 10, 25, 50.
Badge XP: Disemat saat total XP mencapai 100, 500, 1000, 2500.
```

### Section 5: Tips Belajar
```markdown
1. Gunakan Hint AI — Bantu memahami logika soal tanpa memberi jawaban langsung.
2. Ulangi Kuis Remedial — Soal baru dari AI, peluang naikkan mastery.
3. Jaga Streak — Setidaknya 1 kuis per hari untuk bonus XP.
4. Fokus Mastery, bukan Hanya Lulus — Mastery tinggi = fondasi kuat untuk level lanjutan.
```

### Section 6: FAQ
```markdown
Q: Lupa password, gimana?
A: Hubungi dosen pengampu untuk reset password via panel admin web.

Q: Kenapa mastery saya 85% padahal jawaban 100% benar?
A: Mastery dihitung dari Akurasi + Waktu + Konsistensi. Cepat & konsisten = 100%.

Q: Bisa pindah bahasa (C++ ↔ Java) di tengah jalan?
A: Bisa. Progress per bahasa terpisah. Pilih bahasa di awal level.
```

## 4. File yang Disentuh (File:Line & Snippet)
- **`app/lib/features/profile/screens/about_screen.dart` (BARU)**
- **`app/assets/content/about.md` (Aset markdown lengkap)**
- **`app/lib/app/router.dart:82`**
  - Registrasi route baru setelah `/change-password`:
    ```dart
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    ```

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**: `app/test/features/profile/about_screen_test.dart` (3 kasus):
  1. `RouteAccessible`: Navigasi `/about` dari drawer berhasil.
  2. `AllSectionsRender`: 6 section markdown tampil utuh.
  3. `ContentMatch`: Konten sesuai dengan file aset `about.md`.

## 6. Definition of Done (DoD)
- Mahasiswa memiliki panduan tertulis lengkap di dalam aplikasi tanpa harus bertanya ke dosen.

## 7. Blocker & Dependency
- **Package**: `flutter_markdown: ^0.7.4` (ditambahkan di `pubspec.yaml`, resolved `0.7.7+1`, discontinued per pub.dev namun **functional**; catat hutang migrasi ke `flutter_markdown_plus` di masa depan).
- **Aset**: Folder `app/assets/content/` + entry `flutter: assets: - assets/content/about.md` di `pubspec.yaml`.
- **Route**: `/about` terdaftar di `router.dart` setelah `/change-password`, drawer item "Tentang Aplikasi" sudah ada.

## 8. Effort Estimate
- 3 jam (termasuk penulisan konten markdown).

## 9. Risk & Mitigasi
- **Risk**: Ukuran paket aplikasi meningkat.
- **Mitigasi**: File markdown teks sangat ringan (< 10 KB) dibandingkan aset gambar.

## Implementation Status (Updated pasca Fase 1d)
- Commit: `37e3590`
- File actual:
  - `app/lib/features/profile/screens/about_screen.dart` (baru)
  - `app/assets/content/about.md` (baru — 6 section sesuai spec baris 14-87, verbatim)
  - `app/test/features/profile/screens/about_screen_test.dart` (baru — 3 test)
  - `app/pubspec.yaml` (edit — flutter_markdown + assets)
  - `app/lib/app/router.dart` (edit — /about route)
  - `app/lib/shared/widgets/app_drawer.dart` (edit — item "Tentang Aplikasi")
- Content: 6 section dari doc baris 14-87, verbatim (verified — tidak ada hallucination).
- Drawer entry: item "Tentang Aplikasi" setelah Ganti Kelas, sebelum Spacer.
- Known technical debt: `flutter_markdown` discontinued, migrasi ke `flutter_markdown_plus` di masa depan.
