# 13 — Post-Demo Upgrade & Revision Plan (Mobile & Web Admin)

**Version:** 1.0  
**Date:** 2026-11-21  
**Status:** Ready for Execution  
**Baseline:** 498 Unit/Widget Tests PASS | `flutter analyze` 0 issues  

---

## 1. Tujuan & Konteks

Dokumen ini menjadi panduan utama (*single source of truth*) untuk tahap penyempurnaan aplikasi **KODIRA** setelah uji coba dan review bersama dua dosen penguji (**Bu Rani** dan **Pak Salam**), sekaligus menuntaskan fitur yang tertunda dari roadmap mobile dan membangun **Web Admin Panel (Fase 3)**.

### Aturan Keras (Guardrails)
File logika inti gamifikasi berikut **DIKUNCI** dan **TIDAK BOLEH DIUBAH** selama proses upgrade agar 498 unit/widget test tetap valid dan tidak terjadi regresi perhitungan skor:
- `app/lib/data/logic/adaptive_engine.dart`
- `app/lib/data/logic/xp_logic.dart`
- `app/lib/data/logic/progress_logic.dart`
- `app/lib/shared/widgets/mastery_bar.dart`

---

## 2. Daftar Revisi & Masukan Dosen

### A. Masukan Bu Rani (UI/UX, Gamifikasi, AI, & Tipe Soal)

| ID | Area | Keluhan / Masukan | Solusi Teknis & Target Implementasi |
| :--- | :--- | :--- | :--- |
| **BR-01** | **Tampilan Materi** | Tata letak materi banyak ruang kosong, ukuran font kurang proporsional, dan blok kode kurang menonjol. | Migrasi `flutter_markdown` ke `flutter_markdown_plus`, perbaiki tipografi (`lineHeight` & ukuran font), tambahkan kartu visual (*callout / key takeaway*), serta tampilkan blok kode berlatar gelap dengan *syntax highlighting* gaya VS Code (`JetBrains Mono`). |
| **BR-02** | **Disclaimer AI** | Selama output berasal murni dari AI, harus ada disclaimer bahwa jawaban AI tidak selamanya 100% benar. | Tambahkan banner/chip peringatan tetap pada `HintBottomSheet`, `FeedbackBottomSheet`, dan hasil `ai-generate-quiz`: *"Catatan: Jawaban ini dihasilkan oleh AI dan berpotensi keliru. Verifikasi kembali dengan materi atau dosen."* |
| **BR-03** | **Timer Kuis Dinamis** | Durasi 60 detik statis tidak setara antar tingkat kesulitan; soal sulit butuh waktu lebih lama dibanding soal mudah. | Ubah `kQuizSecondsPerQuestion = 60` menjadi dinamis berdasarkan `LevelTier` (`xp_logic.dart`): **Mudah (L1–15) = 60 detik**, **Sedang (L16–35) = 90 detik**, **Tinggi (L36–50) = 120 detik**. Sesuaikan rumus `secondsSpent` saat menghitung waktu pengerjaan. |
| **BR-04** | **Tombol Kuis & Latihan** | Posisi tombol aksi kurang nyaman dan tombol **Reset** perlu diberi warna merah agar jelas sebagai aksi destruktif. | Pada layar latihan/kuis, posisikan tombol aksi utama di sebelah kanan (utama) dan tombol **Reset** di sebelah kiri dengan warna merah (`KodiraColors.alert700`). |
| **BR-05** | **Istilah Gaming untuk "Title"** | Kata `"Title"` terasa kaku; ubah menjadi konsep yang lebih *gaming* untuk memicu motivasi. | Ganti label `"Title"` menjadi **Rank / Gelar** dengan penamaan bertema *gaming* (misal: *Rookie Coder → Code Warrior → Bug Slayer → System Architect → Tech Grandmaster*) di Home, Profil, dan kolom nama Leaderboard. |
| **BR-06** | **Home Bar & Kompetisi** | Ruang kosong di sisi kanan Home Bar sebaiknya diisi info **Level sekarang**, **Peringkat Leaderboard**, serta menonjolkan **Badge & Achievement** beserta penjelasan peran tiap badge. | Isi area kanan *Home Header/Bar* dengan kartu ringkas **Level Aktif** dan **Peringkat Kelas/Global** saat ini. Tambahkan *bottom sheet* / dialog interaktif saat kartu **Badge & Achievement** ditekan untuk menjelaskan fungsi, cara mendapatkan, dan peran setiap badge. |
| **BR-07** | **Syntax Highlighting ala VS Code & Warna Blok Latihan** | Berikan warna teks kode seperti di VS Code saat menampilkan kode pemrograman, serta bedakan warna highlight pada blok latihan. | Terapkan tema *VS Code Dark+* menggunakan `flutter_highlight` / `flutter_code_editor` pada tampilan kode materi dan latihan. Beri variasi warna kategori token pada `DragToken` (misal: *keyword*, tipe data, variabel, operator, komentar). |
| **BR-08** | **Bug Error saat Logout** | Terjadi error saat proses logout. | Perbaiki *race condition* antara `Navigator.of(context).pop()` di `AppDrawer._confirmLogout()` dan `GoRouter` redirect listener, serta pastikan provider yang bergantung pada user aktif tidak melempar *exception* saat `authStateProvider` di-reset ke `null`. |
| **BR-09** | **Tipe Soal *Fill in the Blank*** | Tambahkan variasi latihan *Fill in the Blank* melengkapi *Drag and Drop*. | Tambahkan dukungan tipe latihan `fill_in_the_blank` (kode dengan bagian rumpang `___` yang diisi via pilihan chip/input singkat) pada skema `exercises`, repository, dan UI latihan. |

### B. Masukan Pak Salam (Dashboard Dosen, Edit NIM, & Validasi Latihan)

| ID | Area | Keluhan / Masukan | Solusi Teknis & Target Implementasi |
| :--- | :--- | :--- | :--- |
| **PS-01** | **Auto-Refresh Halaman Dosen** | Halaman dosen harus di-refresh manual agar data terbaru (kelas baru / mahasiswa yang baru join) terlihat. | Tambahkan mekanisme auto-refresh saat layar kembali aktif (`RouteAware` / `WidgetsBindingObserver` + invalidasi `teacherClassesProvider` dan `classRosterProvider` setelah kembali dari `/create-class`), serta tombol refresh eksplisit di AppBar. |
| **PS-02** | **Sistem Ganti NIM** | Belum ada fitur untuk mengganti NIM jika mahasiswa/dosen salah input NIM. | Buat Supabase Edge Function / RPC `update-nim` yang memvalidasi format & keunikan NIM baru (12–13 digit), lalu memperbarui `auth.users.email` (`nim_<NIM>@kodira.local`), `auth.identities`, `raw_user_meta_data`, dan `public.users.nim` secara atomik. Tambahkan UI **Ganti NIM** di menu Profil. |
| **PS-03** | **Validasi Komentar Fleksibel di Latihan** | Pada latihan *drag-and-drop*, posisi komentar (`// ...` atau `/* ... */`) tidak seharusnya memengaruhi penilaian atau membuat jawaban menjadi salah. | Perbarui logika validasi di `drag_drop_screen.dart`: saring (*filter*) seluruh token komentar (`text.trim().startsWith('//')` atau `startsWith('/*')`) dari `_dropZoneIds` maupun `data.answer` sebelum membandingkan urutan eksekusi kode. |

### C. Target Roadmap Tertunda (Mobile & Web Admin Fase 3)

| ID | Area | Deskripsi Fitur | Target |
| :--- | :--- | :--- | :--- |
| **RD-01** | **Mastery Breakdown UI (`P2-3`)** | Menampilkan rincian komponen *mastery* (`Accuracy`, `Completeness`, `Efficiency`, `Time`) di halaman Profil (`03-MASTERY-UI.md`). | Mobile App |
| **RD-02** | **Web Admin Panel (`02A–02E`)** | Dashboard berbasis **Next.js 15 + Tailwind CSS + Supabase** untuk Dosen/Admin: manajemen kelas, *bulk import* mahasiswa via CSV/Excel, reset password massal, editor materi/latihan/kuis, **AI PDF-to-Content Generator** (Groq), dan analitik progres kelas. | Web Admin (Folder `web-admin/`) |

---

## 3. Rencana Eksekusi Bertahap (4 Sprint)

### Sprint 1 — Critical Bugfix & Core Logic (Prioritas Utama)
- [ ] **BR-08 (Logout Fix):** Perbaiki alur navigasi `AppDrawer._confirmLogout()` dan sinkronisasi state `AuthNotifier` + `GoRouter` agar logout berjalan mulus tanpa error.
- [ ] **PS-03 (Flexible Comment Validation):** Abaikan token komentar (`//` dan `/* */`) saat memvalidasi urutan jawaban pada `drag_drop_screen.dart`.
- [ ] **BR-03 (Dynamic Quiz Timer):** Ubah durasi kuis menjadi dinamis berdasarkan tier level: Mudah = 60 detik, Sedang = 90 detik, Tinggi = 120 detik.
- [ ] **BR-02 (AI Disclaimer):** Tambahkan banner/label disclaimer di `HintBottomSheet`, `FeedbackBottomSheet`, dan layar kuis AI.
- [ ] **PS-01 (Teacher Auto-Refresh):** Aktifkan pemuatan ulang otomatis pada `TeacherDashboardScreen` dan `ClassRosterScreen` setiap kali halaman dibuka kembali atau setelah membuat kelas baru.

### Sprint 2 — UI/UX Overhaul & Gamifikasi
- [ ] **BR-01 & BR-07 (Materi & VS Code Highlighting):** Upgrade tampilan materi (tipografi, *callout*, hilangkan area kosong) dan terapkan *syntax highlighting* gaya VS Code Dark+ pada blok kode materi serta variasi warna kategori token di latihan *drag-and-drop*.
- [ ] **BR-04 (Button Layout & Reset Color):** Atur ulang posisi tombol aksi pada latihan/kuis dan beri warna merah (`KodiraColors.alert700`) pada tombol **Reset**.
- [ ] **BR-05 & BR-06 (Home Bar, Leaderboard Rank, Gaming Titles, & Badge Info):**
  - Isi sisi kanan Home Bar dengan **Level Saat Ini** dan **Peringkat Leaderboard**.
  - Ubah istilah `"Title"` menjadi **Rank / Gelar** bergaya *gaming* dan tampilkan di Leaderboard.
  - Tambahkan modal penjelasan peran & cara meraih **Badge & Achievement**.
- [ ] **RD-01 (Mastery UI Breakdown):** Tambahkan visualisasi rincian `A / C / E / Tn` di layar Profil.

### Sprint 3 — Fitur Baru (Ganti NIM & Fill in the Blank)
- [ ] **PS-02 (Sistem Ganti NIM):** Buat migrasi SQL / Edge Function `update-nim` + layar/dialog **Ganti NIM** di Profil.
- [ ] **BR-09 (Fill in the Blank):** Tambahkan migrasi skema/seed untuk tipe latihan `fill_in_the_blank`, parser di `ExerciseProvider`, serta widget `FillBlankScreen`.

### Sprint 4 — Web Admin Panel (Next.js 15)
- [ ] **RD-02 (Inisialisasi & Core Web Admin):**
  - Setup proyek `web-admin/` (Next.js 15 App Router, Tailwind CSS, Supabase SSR/JS).
  - Halaman Login Dosen/Admin & Dashboard Statistik Kelas.
  - Fitur Manajemen Mahasiswa (*Bulk Import* CSV/Excel, Reset Password, Edit NIM).
  - Fitur Manajemen Materi, Latihan (*Drag-Drop* & *Fill-in-the-Blank*), Kuis, serta **AI Generator dari Modul PDF/Docx** via Groq API.

---

## 4. Kriteria Keberhasilan (Definition of Done)

1. Seluruh unit & widget test lama (`498 PASS`) tetap lulus ditambah unit test baru untuk setiap perbaikan logika (timer dinamis, filter komentar *drag-drop*, parser *fill-in-the-blank*).
2. `flutter analyze` menghasilkan **0 issues** dan `dart format` bersih.
3. Seluruh poin revisi dari **Bu Rani (BR-01 s.d. BR-09)** dan **Pak Salam (PS-01 s.d. PS-03)** terverifikasi langsung pada build APK terbaru.
4. Aplikasi **Web Admin (`web-admin/`)** berjalan stabil dan terhubung ke database Supabase yang sama secara *real-time*.