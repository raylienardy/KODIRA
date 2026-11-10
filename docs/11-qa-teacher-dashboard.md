# QA Checklist - Teacher Dashboard Mobile (#P5)

Dokumen ini berisi panduan dan checklist pengujian kualitas (*Quality Assurance*) end-to-end untuk fitur **Teacher Dashboard Mobile (#P5)** pada aplikasi KODIRA. Dokumen ini dirancang untuk dieksekusi sekali jalan sebelum demo proyek (Kamis, 13 November 2026).

---

## 1. Metadata

| Field | Value |
|---|---|
| **Feature** | Teacher Dashboard Mobile (#P5) |
| **Version** | 1.0 |
| **Status** | PENDING QA (deferred until pre-demo) |
| **Last update** | 2026-11-11 |
| **Feature Commit** | `f7c22db` |
| **Test Baseline** | 474 PASS (466 → 474, +8 unit/widget tests) |
| **Owner** | Ridho (`2402095010141`) & Rey (`2402095010152`) |
| **Supervisor** | Kurnia Wahyu Prima, S.Pd., M.Pd. |
| **Related Files** | `lib/features/teacher/**`, `lib/data/repositories/teacher_repository.dart`, `lib/data/models/teacher_class_entry.dart`, `lib/data/models/class_roster_entry.dart`, `lib/app/router.dart`, `lib/shared/widgets/app_drawer.dart` |

---

## 2. Purpose & When to Run

### Tujuan
- Memastikan fungsionalitas sisi dosen (melihat daftar kelas yang diampu dan roster mahasiswa beserta perolehan XP) berjalan lancar pada perangkat nyata.
- Memastikan mekanisme keamanan *role-based guard* berfungsi mencegah mahasiswa mengakses rute dosen.
- Memastikan tidak ada *regression* (kerusakan fitur) pada 24+ fitur mahasiswa yang sudah ada sebelumnya.

### Kapan Dijalankan
1. **Wajib (Sekali)**: Menjelang demo presentasi (Kamis, 13 November 2026).
2. Setiap kali ada penambahan fitur penting atau perubahan pada `router.dart`, `app_drawer.dart`, atau `TeacherRepository`.

### Kapan Tidak Perlu
- Perubahan pada file yang dikunci (*locked files*: `adaptive_engine.dart`, `xp_logic.dart`, `progress_logic.dart`, `mastery_bar.dart`) yang tidak bersinggungan dengan alur dosen.

---

## 3. Scope

### In-Scope (Diuji)
- **TeacherDashboardScreen** (`/teacher-dashboard`): Tampilan daftar kelas yang diampu, status loading, empty state, error state, pull-to-refresh, dan navigasi kartu ke roster.
- **ClassRosterScreen** (`/teacher-roster/:classId`): Tampilan daftar mahasiswa per kelas, status loading, empty state, error state, dan perolehan XP (`total_xp`) per mahasiswa.
- **AppDrawer**: Menu navigasi "Kelas Saya (Dosen)" yang bersifat *conditional* hanya muncul untuk pengguna dengan `role == 'teacher'`.
- **Route Guard**: Pembatasan rute di GoRouter; mahasiswa yang mencoba mengakses `/teacher-dashboard` atau `/teacher-roster/*` secara paksa akan di-redirect kembali ke `/home`.
- **AppDrawer Overflow Fix**: Memastikan seluruh menu pada drawer (termasuk menu tambahan dosen) tampil sempurna tanpa *overflow* pada berbagai ukuran layar.
- **TeacherRepository & Providers**: Integrasi query M:N `class_teachers` dan view `leaderboard_by_class`.

### Out-Of-Scope (Tidak Diuji di Sini)
- *Adaptive Engine*, *XP logic*, *Progress logic*, dan *Mastery bar* (sudah dilindungi test suite otomatis).
- Skema migrasi Supabase (sudah diterapkan dan diuji langsung di SQL Editor Supabase Cloud).
- Admin Panel Web (masuk Fase 3).
- Layar-layar existing yang tidak mengalami perubahan pada `#P5`: `/login`, `/register`, `/home`, `/profile`, `/change-password`, `/about`, `/leaderboard`, `/edit-profile`, `/join-class` (pengujian bersifat *regression smoke* saja).

---

## 4. Prerequisites

### Environment
- Perangkat Android fisik (ARM64) — sangat disarankan untuk pengujian final demo.
- APK Release: 
  ```bash
  flutter build apk --release --split-per-abi --dart-define-from-file=.env
  ```
  Install file `app-arm64-v8a-release.apk` ke perangkat.
- Supabase Cloud (bukan lokal) dengan 13 migrasi aktif.
- Koneksi internet stabil.

### Seed Accounts (dari migrasi `20261109000002_seed_dummy_users.sql` & `#P5`)
- **Akun Dosen (`role = 'teacher'`)**: 
  - Nama: `Ridho S.`
  - Peran: Pemilik kelas `PTIK B 2024` (kode `PTIK24`).
- **Akun Mahasiswa (`role = 'student'`)**:
  - `Andi` (NIM `2402095010101`, 2500 XP)
  - `Budi` (NIM `2402095010102`, 1800 XP)
  - `Citra` (NIM `2402095010103`, 1500 XP)
  - `Dewi` (NIM `2402095010104`, 1200 XP)
  - `Eko` (NIM `2402095010105`, 800 XP)
  - `Ridho` (NIM `2402095010141`, 350 XP)

---

## 5. Pre-QA Setup Checklist

- [ ] APK release `#P5` terinstall dengan sukses di perangkat uji.
- [ ] Koneksi internet terhubung dengan baik ke Supabase Cloud.
- [ ] Akun Dosen (`Ridho S.`) dapat digunakan untuk login.
- [ ] Akun Mahasiswa (`Andi`) dapat digunakan untuk login.
- [ ] Catat versi Flutter (`flutter --version`) pada perangkat developer.
- [ ] Siapkan tangkapan layar perangkat untuk dokumentasi jika ditemukan bug.

---

## 6. Test Cases

| ID | Priority | Steps | Expected | Actual | Status |
|---|---|---|---|---|---|
| **A1** | P0 | Buka aplikasi, masukkan kredensial akun Dosen (`Ridho S.`), tap Login. | Berhasil masuk ke halaman `/home` dengan peran dosen. | `<isi saat QA>` | `PENDING` |
| **A2** | P0 | Tap ikon hamburger/menu di pojok kiri atas untuk membuka `AppDrawer`. | Drawer terbuka. Menu **"Kelas Saya (Dosen)"** muncul di antara "Buat Kelas" dan "Leaderboard". | `<isi saat QA>` | `PENDING` |
| **A3** | P0 | Tap menu **"Kelas Saya (Dosen)"**. | Drawer menutup, router mengarahkan ke `/teacher-dashboard`, AppBar menampilkan teks **"Kelas Saya"**. | `<isi saat QA>` | `PENDING` |
| **A4** | P2 | (Opsional jika bersih) Jika dosen belum memiliki kelas sama sekali. | Muncul *empty state*: *"Belum ada kelas. Buat kelas baru dulu via menu Buat Kelas."* | `<isi saat QA>` | `PENDING` |
| **A5** | P0 | Verifikasi list kelas pada kondisi normal (terdaftar di `PTIK B 2024`). | Kartu kelas muncul dengan nama **"PTIK B 2024"** dan kode **"Kode: PTIK24"**. | `<isi saat QA>` | `PENDING` |
| **A6** | P0 | Tap pada kartu kelas **"PTIK B 2024"**. | Router bernavigasi ke `/teacher-roster/CLS_ID`, AppBar menampilkan **"Daftar Mahasiswa"**. | `<isi saat QA>` | `PENDING` |
| **A7** | P0 | Periksa daftar mahasiswa pada halaman Roster. | Daftar mahasiswa muncul lengkap dengan: Avatar inisial, Nama lengkap, NIM, dan Total XP. | `<isi saat QA>` | `PENDING` |
| **A8** | P1 | Tarik ke bawah (*pull-to-refresh*) pada halaman daftar kelas. | Indikator muat berputar, data kelas diperbarui tanpa error. | `<isi saat QA>` | `PENDING` |
| **A9** | P1 | Periksa urutan mahasiswa pada halaman Roster. | Mahasiswa terurut secara menurun (*DESC*) berdasarkan jumlah XP (Andi di atas, Eko/Ridho di bawah). | `<isi saat QA>` | `PENDING` |
| **B1** | P1 | Buka drawer, pilih **"Buat Kelas"**, buat kelas baru (misal: "Algoritma Struktur Data"). | Kelas berhasil dibuat, kode 6 karakter unik muncul di dialog. | `<isi saat QA>` | `PENDING` |
| **B2** | P1 | Kembali ke `/teacher-dashboard` (tarik *refresh* jika perlu). | Kelas baru *"Algoritma Struktur Data"* langsung muncul di daftar kelas dosen. | `<isi saat QA>` | `PENDING` |
| **B3** | P2 | Uji *scrolling* pada daftar kelas jika dosen memiliki lebih dari 3 kelas. | Scroll berjalan mulus tanpa ada elemen yang terpotong (*overflow*). | `<isi saat QA>` | `PENDING` |
| **C1** | P0 | Logout dari dosen, lalu login menggunakan akun Mahasiswa (`Andi`). | Berhasil login sebagai mahasiswa. | `<isi saat QA>` | `PENDING` |
| **C2** | P0 | Buka `AppDrawer` saat login sebagai mahasiswa. | Menu **"Kelas Saya (Dosen)"** dan **"Buat Kelas"** **TIDAK MUNCUL** sama sekali. | `<isi saat QA>` | `PENDING` |
| **C3** | P0 | Paksa navigasi URL/rute ke `/teacher-dashboard` melalui deep link atau modifikasi. | GoRouter *guard* mendeteksi peran mahasiswa dan langsung mengembalikan (redirect) ke `/home`. | `<isi saat QA>` | `PENDING` |
| **D1** | P0 | Sebagai mahasiswa, buka menu *Home* dan navigasikan latihan/kuis dasar. | Berjalan normal sesuai fungsionalitas existing. | `<isi saat QA>` | `PENDING` |
| **D2** | P0 | Buka drawer mahasiswa $\rightarrow$ **"Ganti Password"**. | Form ganti password terbuka dengan baik. | `<isi saat QA>` | `PENDING` |
| **D3** | P0 | Buka drawer mahasiswa $\rightarrow$ **"Profil"**. | Halaman profil mahasiswa tampil dengan data yang sesuai. | `<isi saat QA>` | `PENDING` |
| **D4** | P0 | Buka drawer mahasiswa $\rightarrow$ **"Leaderboard"**. | Tab global dan per kelas memuat data dengan benar. | `<isi saat QA>` | `PENDING` |
| **D5** | P0 | Buka drawer mahasiswa $\rightarrow$ **"Tentang Aplikasi"**. | Halaman About tampil dengan 6 section panduan. | `<isi saat QA>` | `PENDING` |
| **D6** | P0 | Lakukan *Logout* dari akun mahasiswa. | Sesi terhapus, aplikasi kembali ke halaman `/login`. | `<isi saat QA>` | `PENDING` |
| **D7** | P0 | Login kembali sebagai dosen, buka drawer $\rightarrow$ **"Ganti Kelas"** (`/join-class`). | Halaman gabung kelas / ganti kelas terbuka (dosen juga diperbolehkan bergabung jika diperlukan). | `<isi saat QA>` | `PENDING` |
| **D8** | P0 | Verifikasi bahwa test suite otomatis tetap hijau (`flutter test`). | Total 474 test sukses dijalankan tanpa kegagalan. | `<isi saat QA>` | `PENDING` |
| **E1** | P1 | Buat kelas baru dengan 0 mahasiswa terdaftar, lalu buka roster kelas tersebut. | Menampilkan *empty state*: *"Belum ada mahasiswa di kelas ini"* dengan rapi. | `<isi saat QA>` | `PENDING` |
| **E2** | P2 | Matikan koneksi internet (*Airplane Mode*), lalu buka `/teacher-dashboard`. | Menampilkan pesan error yang ramah pengguna (*Gagal memuat kelas: ...*), tidak *crash*. | `<isi saat QA>` | `PENDING` |
| **E3** | P2 | Hapus sesi aktif dari Supabase Dashboard saat aplikasi terbuka, lalu lakukan interaksi di drawer. | Sistem mendeteksi *unauthenticated* dan mengamankan rute ke login. | `<isi saat QA>` | `PENDING` |
| **E4** | P1 | Uji tampilan pada perangkat berlayar kecil (misal emulator 5" atau viewport sempit). | `AppDrawer` merender seluruh menu tanpa *error bottom overflow* berkat `SingleChildScrollView`. | `<isi saat QA>` | `PENDING` |
| **E5** | P1 | Buat 3 kelas berturut-turut dengan cepat oleh dosen. | Server-side function menghasilkan 3 kode unik 6 karakter berbeda tanpa duplikasi atau *collision*. | `<isi saat QA>` | `PENDING` |
| **F1** | P1 | Sebagai Dosen, buka `AppDrawer` pada perangkat ponsel 5.5". | Menu **"Logout"** di bagian bawah terlihat penuh tanpa terpotong atau memunculkan garis kuning hitam (*overflow*). | `<isi saat QA>` | `PENDING` |
| **F2** | P1 | Periksa seluruh item drawer saat akun dosen aktif (Profil, Ganti Password, Ganti Kelas, Buat Kelas, Kelas Saya (Dosen), Leaderboard, Tentang Aplikasi, Divider, Logout). | Seluruh item tersusun secara vertikal dalam satu kontainer *scrollable* yang responsif. | `<isi saat QA>` | `PENDING` |
| **F3** | P1 | Periksa ulang tampilan drawer saat akun mahasiswa aktif. | Meskipun menu dosen disembunyikan, layout drawer tetap proporsional dan tidak mengalami anomali tata letak. | `<isi saat QA>` | `PENDING` |

---

## 7. Bug Report Template

Jika ditemukan kendala atau ketidaksesuaian saat eksekusi QA, gunakan format pelaporan berikut:

```markdown
- **Bug ID**: BUG-00X
- **Severity**: [Blocker / Critical / Major / Minor / Cosmetic]
- **Priority**: [P0 / P1 / P2]
- **Test Case Ref**: [Misal: A3]
- **Environment**: [Model HP / Android Version / APK Build Hash]
- **Steps to Reproduce**:
  1. ...
  2. ...
- **Expected Result**: ...
- **Actual Result**: ...
- **Screenshot/Log**: [Lampirkan bukti]
- **Root Cause Hypothesis**: ...
```

---

## 8. Acceptance Criteria

Fitur `#P5` dinyatakan **LULUS (SHIP)** jika memenuhi kriteria berikut:
1. **100% test cases P0** berstatus **PASS** (✅).
2. **Minimal 90% test cases P1** berstatus **PASS** (✅).
3. **0 Bug dengan tingkat *Blocker* atau *Critical***.
4. Maksimal 2 bug *Minor* / *Cosmetic* (harus disertai *workaround* jika ada).
5. Seluruh uji regresi (Grup D) dan *role guard* (Grup C) sukses tanpa cacat.

---

## 9. Sign-Off (Diisi saat Eksekusi)

| Parameter | Keterangan |
|---|---|
| **Tanggal Eksekusi** | _______________ |
| **Eksekutor QA** | _______________ |
| **Build / Commit Hash** | `f7c22db` |
| **Total Test Cases** | 31 Test Cases |
| **Lulus (PASS)** | ___ / 31 |
| **Gagal (FAIL)** | ___ / 31 |
| **Temuan Bug** | Blocker: 0 \| Critical: 0 \| Major: ___ \| Minor: ___ |
| **Kesimpulan Akhir** | [ ] SHIP &nbsp;&nbsp;&nbsp;&nbsp; [ ] HOLD &nbsp;&nbsp;&nbsp;&nbsp; [ ] SHIP WITH WORKAROUND |
| **Tanda Tangan** | _______________________ |

---

## 10. Post-QA Cleanup

- [ ] Hapus data kelas uji coba yang dibuat khusus untuk keperluan QA (jika tidak diperlukan untuk demo).
- [ ] Pastikan akun demo utama (`Ridho S.` dan mahasiswa seed) dalam kondisi bersih dan siap digunakan penilai.
- [ ] Perbarui dokumen ini jika ada catatan tambahan atau penyesuaian kecil.

---

## 11. Appendix

- **Build APK Command**:
  ```bash
  flutter build apk --release --split-per-abi --dart-define-from-file=.env
  ```
- **Logcat Filter**:
  ```bash
  flutter logs | grep -iE "teacher|class|roster|router"
  ```
- **Related Documentation**:
  - `docs/10-handover.md`
  - `docs/roadmap-upgrade/README.md`
  - `docs/roadmap-upgrade/07-LEADERBOARD.md`
