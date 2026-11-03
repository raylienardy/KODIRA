# Fitur #2C — Admin Panel (MVP)

## Konteks
Pengembangan antarmuka utama Admin Web untuk mendukung fitur manajemen dosen, AI content generator, dan monitoring mahasiswa.

## Scope
Pembangunan penuh 6 modul MVP Admin Web dan integrasi database Supabase.

## Spec Detail
1. **Teacher Auth**: Register dengan email `@ub.ac.id` (auto-approve) atau antrean verifikasi NIDN/NIP (2 jam).
2. **AI Material Parser**: Upload file (PDF/Word), memproses teks, dan mengekstrak materi serta soal secara otomatis (6 jam).
3. **Level Preview & Edit**: Mengulas materi yang digenerate AI (5 slide materi, 5 drag&drop, 3 kuis), mengedit, dan mempublikasikan ke aplikasi mobile (4 jam).
4. **Student Management**: Menampilkan daftar mahasiswa, membuat akun baru, dan fitur impor massal via file CSV (3 jam).
5. **Dashboard Analytics**: Menampilkan statistik frekuensi login, tingkat penyelesaian level, dan daftar materi tersulit (4 jam).
6. **Reset Password Student**: Fitur tombol untuk menyetel ulang kata sandi mahasiswa yang di-request (1 jam).
- **Database & Deployment**: Skema migrasi database (2 jam), policy RLS leaderboard (1 jam), UI antrean verifikasi NIDN (2 jam), deployment & polishing (2 jam).

## File yang Disentuh
- `admin/src/app/(dashboard)/...`
- Migration SQL: `app/supabase/migrations/20261030000000_classes_and_roles.sql`

## Test Cases
- Verify pembacaan dan ekstraksi file PDF materi menjadi slide.
- Verify fungsi impor bulk student via CSV.
- Verify reset password mahasiswa bekerja dan dapat digunakan untuk login kembali.

## Definition of Done
- Seluruh 6 modul MVP beroperasi sempurna pada peramban web.
- Dosen dapat mengunggah materi baru yang langsung muncul di aplikasi mobile secara terstruktur.

## Blocker / Dependency
- Memerlukan migrasi skema tabel `classes`, `class_teachers`, `class_students`.

## Effort Estimate
- 27 jam total.

## Risk
- Kegagalan ekstraksi AI pada format PDF yang kompleks. Mitigasi: menyediakan fallback antarmuka pengeditan manual yang komprehensif bagi dosen.
