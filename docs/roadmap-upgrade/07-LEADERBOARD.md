# Fitur #7 — Leaderboard Kelas & Global

## 1. Konteks
Kompetisi sehat terbukti meningkatkan motivasi belajar mahasiswa dalam menguasai konsep pemrograman C++ dan Java. Fitur leaderboard menyajikan peringkat mahasiswa berdasarkan akumulasi total XP yang diperoleh dari penyelesaian level.

## 2. Scope
Penyediaan halaman Leaderboard global pada aplikasi mobile (Fase 2) dan penyaringan leaderboard berbasis kelas perkuliahan (Fase 3B).

## 3. Spec Detail & Spesifikasi Teknis
- **Tampilan Antarmuka**:
  - Daftar peringkat 1 s/d 10 dengan sorotan khusus untuk **Top 3** (Medali Emas, Perak, Perunggu).
  - Kartu posisi pengguna aktif di bagian bawah atau atas (Contoh: *"Peringkat Anda: #12 • 1450 XP"*).
- **Kueri Agregasi Peringkat (SQL)**:
  ```sql
  SELECT u.id, u.name, u.nim, SUM(up.xp_earned) AS total_xp 
  FROM public.users u 
  JOIN public.user_progress up ON u.id = up.user_id 
  GROUP BY u.id, u.name, u.nim 
  ORDER BY total_xp DESC 
  LIMIT 10;
  ```
- **Kueri Pencarian Peringkat Personal**:
  ```sql
  WITH ranked AS (
    SELECT u.id, u.name, u.nim, SUM(up.xp_earned) AS total_xp,
           RANK() OVER (ORDER BY SUM(up.xp_earned) DESC) AS rank
    FROM public.users u 
    JOIN public.user_progress up ON u.id = up.user_id
    GROUP BY u.id, u.name, u.nim
  )
  SELECT * FROM ranked WHERE id = $1;
  ```
- **Kebijakan Keamanan RLS (T1 Confirmed)**:
  Untuk menjaga privasi, data yang terekspos dibatasi hanya mencakup identitas publik (`user_id`, `name`, `nim`) dan total perolehan XP. Policy akses dibaca oleh pengguna terautentikasi:
  ```sql
  CREATE POLICY select_leaderboard ON public.user_progress
  FOR SELECT TO authenticated
  USING (true);
  ```

## 4. File yang Disentuh (File:Line & Arsitektur)
- **`app/lib/features/leaderboard/screens/leaderboard_screen.dart` (BARU)**
  - Tampilan halaman leaderboard dengan tab global dan per-kelas.
- **`app/lib/features/leaderboard/providers/leaderboard_provider.dart` (BARU)**
  - State management menggunakan Riverpod FutureProvider untuk mengambil data ranking dari repository.
- **`app/lib/data/repositories/leaderboard_repository.dart` (BARU)**
  - Eksekusi kueri Supabase untuk pemanggilan data top ranking dan own rank.
- **`app/supabase/migrations/20261030000001_leaderboard_rls.sql` (BARU)**
  - Skema migrasi SQL penambahan policy RLS leaderboard.

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**: `app/test/features/leaderboard/leaderboard_test.dart` (5 kasus uji):
  1. `Top10QueryExecution`: Memastikan data yang ditarik tepat 10 entri teratas urutan menurun.
  2. `Top3BadgeAssignment`: Memastikan peringkat 1 mendapat medali emas, 2 perak, 3 perunggu.
  3. `PersonalRankFallback`: Memastikan mahasiswa di luar peringkat 10 tetap dapat melihat posisi rank mereka secara akurat.
  4. `EmptyLeaderboardState`: Penanganan tampilan kosong ketika belum ada mahasiswa yang menyelesaikan kuis.
  5. `DataPrivacyPolicy`: Memastikan kolom sensitif (seperti password atau token auth) tidak ikut terekspos.

## 6. Definition of Done (DoD)
- Mahasiswa dapat melihat perbandingan skor XP mereka dengan rekan sekelas secara realtime.
- Kebijakan RLS tervalidasi aman tanpa kebocoran data privasi.

## 7. Blocker & Dependency
- Bergantung pada penyelesaian migrasi tabel kelas (Fitur #2C) untuk mendukung filter leaderboard berbasis kelas perkuliahan.

## 8. Effort Estimate
- 4 jam pengerjaan (Repository, Provider, UI Screen, dan RLS Migration).

## 9. Risk & Mitigasi
- **Risk**: Penurunan performa kueri agregat `SUM` pada tabel `user_progress` saat jumlah baris data meningkat drastis.
- **Mitigasi**: Pembuatan indeks komposit pada database:
  ```sql
  CREATE INDEX idx_user_progress_user_xp ON public.user_progress(user_id, xp_earned);
  ```
