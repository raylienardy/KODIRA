-- KODIRA — Migration: Seed 5 Dummy Users untuk demo Leaderboard (Fitur #10)
-- Tanggal: 2026-11-09
--
-- Tujuan:
--   Menyediakan 5 mahasiswa dummy dengan total XP bervariasi agar halaman
--   Leaderboard menampilkan peringkat yang representatif saat demo.
--
-- Strategi: OPSI A (dipilih)
--   Insert langsung via SQL migration.
--   Catatan penting: "public.users only" TIDAK mungkin dilakukan karena
--   public.users.id REFERENCES auth.users(id), sehingga baris auth.users
--   wajib dibuat lebih dulu. Karena itu skrip ini menulis ke auth.users
--   dengan hash bcrypt TestQA2026, sehingga akun dummy TETAP bisa dipakai
--   login (email: nim_<NIM>@kodira.local — sesuai AuthLogic.nimToEmail).
--
-- Data (keputusan locked):
--   NIM                Nama            Levels  Total XP
--   2402095010101      Andi Pratama      10      2500
--   2402095010102      Budi Santoso       9      1800
--   2402095010103      Citra Dewi         6      1500
--   2402095010104      Dewi Lestari       8      1200
--   2402095010105      Eko Prasetyo       5       800
--
-- Password semua akun: TestQA2026
-- Distribusi XP per level: total_xp / levels_completed (sisa dibagi +1 ke
-- level awal), sehingga SUM(xp_earned) tepat sama dengan Total XP.
--
-- Scope:
--   - Tabel classes / class_students BELUM ADA (Fitur #2C & #9 belum
--     dikerjakan), jadi seed ini tanpa relasi kelas.
--   - Tidak ada ALTER tabel existing; hanya INSERT.
--
-- Idempotency:
--   Aman dijalankan berulang: pengecekan NOT EXISTS + ON CONFLICT.
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/migrations/20261109000002_seed_dummy_users.sql
--   atau copy-paste isi file ini ke Supabase SQL Editor.

-- pgcrypto: dibutuhkan oleh crypt() dan gen_salt() untuk hash password.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  v_user_id    UUID;
  v_level_id   INT;
  v_xp_each    INT;
  v_xp_rem     INT;
  v_idx        INT;
  v_data       RECORD;
  v_email      TEXT;
BEGIN
  -- Prasyarat: master level harus sudah di-seed.
  IF NOT EXISTS (SELECT 1 FROM public.levels) THEN
    RAISE EXCEPTION
      'Tabel public.levels kosong. Jalankan seed level (supabase/seed.sql + seed-cpp-*.sql) terlebih dahulu.';
  END IF;

  FOR v_data IN
    SELECT * FROM (VALUES
      ('2402095010101', 'Andi Pratama',  10, 2500),
      ('2402095010102', 'Budi Santoso',   9, 1800),
      ('2402095010103', 'Citra Dewi',     6, 1500),
      ('2402095010104', 'Dewi Lestari',   8, 1200),
      ('2402095010105', 'Eko Prasetyo',   5,  800)
    ) AS t(nim, name, levels_completed, total_xp)
  LOOP
    v_email := 'nim_' || v_data.nim || '@kodira.local';

    -- ==========================================
    -- 1) auth.users (wajib — target FK public.users)
    -- ==========================================
    SELECT id INTO v_user_id FROM auth.users WHERE email = v_email;

    IF v_user_id IS NULL THEN
      v_user_id := gen_random_uuid();
      INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
        created_at, updated_at
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        v_user_id,
        'authenticated',
        'authenticated',
        v_email,
        crypt('TestQA2026', gen_salt('bf')),
        NOW(),
        '{"provider":"email","providers":["email"]}'::jsonb,
        jsonb_build_object('name', v_data.name, 'nim', v_data.nim),
        NOW(),
        NOW()
      );
    END IF;

    -- ==========================================
    -- 2) public.users
    -- ==========================================
    INSERT INTO public.users (id, nim, name, email, created_at, updated_at)
    VALUES (v_user_id, v_data.nim, v_data.name, v_email, NOW(), NOW())
    ON CONFLICT (nim) DO NOTHING;

    -- Pastikan v_user_id menunjuk baris public.users yang benar
    -- (kasus: NIM sudah ada sebelumnya dengan id berbeda).
    SELECT id INTO v_user_id FROM public.users WHERE nim = v_data.nim;

    -- ==========================================
    -- 3) user_progress — distribusi XP ke beberapa level
    -- ==========================================
    v_xp_each := v_data.total_xp / v_data.levels_completed;
    v_xp_rem   := v_data.total_xp - (v_xp_each * v_data.levels_completed);

    FOR v_idx IN 1 .. v_data.levels_completed LOOP
      SELECT id INTO v_level_id
      FROM public.levels
      WHERE level_number = v_idx
      ORDER BY id
      LIMIT 1;

      IF v_level_id IS NOT NULL THEN
        INSERT INTO public.user_progress (
          user_id, level_id, status, mastery_score, xp_earned,
          attempts, last_attempt_at, completed_at
        ) VALUES (
          v_user_id, v_level_id, 'completed', 0.95,
          v_xp_each + CASE WHEN v_idx <= v_xp_rem THEN 1 ELSE 0 END,
          1, NOW(), NOW()
        )
        ON CONFLICT (user_id, level_id) DO UPDATE
          SET status = EXCLUDED.status,
              mastery_score = EXCLUDED.mastery_score,
              xp_earned = EXCLUDED.xp_earned;
      END IF;
    END LOOP;
  END LOOP;
END $$;

-- ============================================
-- Verifikasi seed (dari docs/roadmap-upgrade/10-SEED-USERS.md §4)
-- ============================================
DO $$
DECLARE
  v_count INT;
  v_xp    INT;
BEGIN
  -- View leaderboard harus sudah dibuat (migrasi 20261109000001).
  IF to_regclass('public.leaderboard_global') IS NULL THEN
    RAISE NOTICE 'View leaderboard_global belum ada — lewati verifikasi leaderboard. Jalankan migrasi 20261109000001_leaderboard_rls.sql.';
    RETURN;
  END IF;

  SELECT COUNT(*), COALESCE(MAX(lg.total_xp), 0)
  INTO v_count, v_xp
  FROM public.leaderboard_global lg
  JOIN public.users u ON u.id = lg.user_id
  WHERE u.nim BETWEEN '2402095010101' AND '2402095010105';

  IF v_count <> 5 THEN
    RAISE EXCEPTION 'Seed verification failed: expected 5 dummy rows in leaderboard_global, found %', v_count;
  END IF;

  IF v_xp <> 2500 THEN
    RAISE EXCEPTION 'Seed verification failed: expected top dummy XP 2500, found %', v_xp;
  END IF;

  RAISE NOTICE 'Seed verification OK: 5 dummy users, top XP = %', v_xp;
END $$;

-- Query verifikasi manual (dokumentasi §4):
--   SELECT name, nim, total_xp FROM public.leaderboard_global ORDER BY total_xp DESC;
-- Hasil: Andi (2500) > Budi (1800) > Citra (1500) > Dewi (1200) > Eko (800)
--        disertai user existing (Ridho, Test User).
