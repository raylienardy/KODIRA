# Overview Roadmap Upgrade KODIRA

## 1. Konteks Proyek & Status Saat Ini
KODIRA adalah aplikasi mobile Android untuk pembelajaran pemrograman C++ dan Java bagi mahasiswa JTIK semester 1, mata kuliah Pemrograman Dasar. Proyek ini dibangun menggunakan Flutter (frontend), Supabase (backend PostgreSQL dengan Row Level Security), dan Edge Functions (AI adaptive mentor). 

Hingga saat ini, fase pengembangan inti telah selesai dengan **302 unit & widget test PASS** dan pipeline CI GitHub Actions yang hijau. Dokumen ini merangkum rencana peningkatan fitur pasca-submit berdasarkan evaluasi dosen, pengujian pendahuluan, dan arsitektur kelas kolaboratif.

## 2. Umpan Balik Dosen & Kebutuhan Utama
Berikut adalah 8 poin masukan utama dari dosen pengampu yang menjadi dasar perancangan roadmap ini:
1. **Pengelompokan Level**: Tingkatan materi perlu dikelompokkan secara visual dan logis menjadi kategori Mudah, Sedang, dan Tinggi.
2. **Admin Panel Web**: Dosen memerlukan antarmuka web untuk mengelola kelas, mengunggah materi, dan memantau aktivitas mahasiswa.
3. **Mastery Transparency**: Mahasiswa dan dosen perlu melihat breakdown detail dari formula mastery (akurasi, konsistensi, error rate, waktu).
4. **Manajemen Kredensial**: Fasilitas ganti password mandiri di aplikasi mobile dan reset password oleh dosen di web.
5. **Panduan & About**: Halaman informasi statis yang merangkum panduan belajar, sistem XP, dan FAQ.
6. **XP Bertingkat & Streak Multiplier**: Perolehan XP harus menyesuaikan kesulitan level ditambah pengali streak harian.
7. **Leaderboard Kelas**: Peringkat mahasiswa per kelas dengan highlight top 3 dan nama lengkap.
8. **Sistem Gelar (Title Progression)**: Penghargaan gelar akademik pemrograman seiring pencapaian level mahasiswa.

## 3. Spesifikasi Final Keputusan Pengguna
Seluruh ambiguitas teknis telah dikonfirmasi dan disetujui dalam spesifikasi final berikut:
- **Roles**: 2 peran utama (`teacher` dan `student`). Verifikasi dosen menggunakan email domain `@ub.ac.id` (auto-approve) atau NIDN manual review.
- **Class Model**: Relasi M:N (mahasiswa dapat mengikuti banyak kelas, 1 kelas diajar banyak dosen). Menggunakan kode join 6-karakter alfanumerik (contoh: `ABC123`).
- **Sidebar Drawer**: Tombol profil lama diganti total dengan menu navigasi drawer (Profil, Ganti Password, Ganti Kelas, Logout).
- **Ganti Kelas Screen**: Dilengkapi pencarian kelas, daftar kelas terdaftar, dan tombol join via kode serta radio button untuk memilih kelas aktif (primary class).
- **Monorepo Structure**: Folder `admin/` berbasis Next.js 15 + React 19 ditempatkan langsung di root repository KODIRA.
- **Migration Strategy**: Inkremental (data existing dipertahankan, tidak ada penghapusan progress lama).
- **Seed Data**: Menyediakan 1 kelas default "PTIK B 2024" dengan 5 data dummy mahasiswa untuk pengujian fungsional.

## 4. Breakdown Fase Pengembangan

```
[Fase 1: Quick Wins (10h)] ──> [Fase 2: Medium (10h)] ──> [Fase 3A: Konsep & Skeleton (4h)] ──> [Fase 3B: Admin MVP (27h)]
  - #3 Mastery Breakdown         - #1 Level Grouping (3 Tier)   - #2A Admin Concept Doc                  - #2C Admin Full MVP & Parser
  - #6 XP Tiering                - #7 Leaderboard (Global)      - #2B Next.js 15 Setup + CI Matrix       - #4B Web Reset Password
  - #4a Mobile Password          - #8 Title Progression                                                  - DB Class Migration & RLS
  - #5 About Static Page
```

## 5. Ringkasan Risiko & Mitigasi
1. **Kompleksitas Migrasi Multi-Kelas**: Penambahan relasi M:N berisiko mempengaruhi kueri progress existing. Mitigasi: menggunakan migration terisolasi dan pengujian inkremental tanpa menghapus data tabel lama.
2. **Konflik CI Pipeline Monorepo**: Penambahan aplikasi Next.js dalam satu repo berisiko memperlambat build workflow. Mitigasi: memisahkan job linting Flutter dan Next.js menggunakan matrix GitHub Actions.
3. **Privasi Leaderboard**: Tampilan peringkat global berpotensi mengekspos data sensitif. Mitigasi: RLS policy dibatasi hanya mengekspos `user_id`, `name`, `nim`, dan `xp_earned` kepada pengguna terautentikasi.
