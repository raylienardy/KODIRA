# Fitur #7 — Leaderboard Kelas

## Konteks
Kompetisi sehat memotivasi mahasiswa belajar. Leaderboard menampilkan peringkat mahasiswa berdasarkan total XP yang dikumpulkan.

## Scope
Penyediaan halaman Leaderboard global (Fase 2) dan leaderboard berbasis kelas (Fase 3B).

## Spec Detail
- **Tampilan Utama**:
  - Peringkat 1 s/d 10 (dengan sorotan khusus Top 3: Emas, Perak, Perunggu).
  - Posisi pengguna saat ini (Contoh: "Peringkat Anda: #12 • 1450 XP").
- **Kueri Data**:
  - `SELECT u.id, u.name, u.nim, SUM(up.xp_earned) AS total_xp FROM users u JOIN user_progress up ON u.id = up.user_id GROUP BY u.id ORDER BY total_xp DESC LIMIT 10`
- **RLS Policy Baru (T1 Confirmed)**:
  - Mengizinkan akses baca data agregat `xp_earned` untuk pengguna terautentikasi tanpa mengekspos data sensitif (PII).
  ```sql
  CREATE POLICY select_leaderboard ON user_progress
  FOR SELECT TO authenticated
  USING (true);
  ```

## File yang Disentuh
- `app/lib/features/leaderboard/screens/leaderboard_screen.dart` (BARU).
- `app/lib/features/leaderboard/providers/leaderboard_provider.dart` (BARU).
- `app/supabase/migrations/20261030000001_leaderboard_rls.sql` (BARU).

## Test Cases
- Verify kueri pengurutan XP menghasilkan urutan menurun (DESC).
- Verify highlight top 3 memberikan lencana visual yang benar.
- Verify posisi mahasiswa yang tidak masuk top 10 tetap menampilkan ranking personal.

## Definition of Done
- Mahasiswa dapat melihat peringkat mereka di antara rekan sekelas.
- Kebijakan RLS database tervalidasi aman dan tidak membocorkan informasi privat.

## Blocker / Dependency
- Memerlukan tabel relasi kelas untuk filter per kelas pada Fase 3B.

## Effort Estimate
- 4 jam.

## Risk
- Masalah performa kueri agregat `SUM` pada tabel besar. Mitigasi: penambahan indeks database pada kolom `user_id` dan `xp_earned` di tabel `user_progress`.
