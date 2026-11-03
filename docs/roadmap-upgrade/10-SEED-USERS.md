# Seed Data Mahasiswa (Dummy Users & Seeding Strategy)

## 1. Konteks
Untuk keperluan pengujian fungsionalitas Leaderboard, Title Progression, dan Admin Panel secara komprehensif, diperlukan data mahasiswa tiruan (*dummy*) yang memiliki variasi tingkat penyelesaian level, perolehan XP, dan riwayat aktivitas yang representatif.

## 2. Scope
Penyediaan skrip SQL seeding data 5 mahasiswa baru dengan NIM berurutan di bawah kelas default *"PTIK B 2024"*, lengkap dengan distribusi progress level yang bervariasi.

## 3. SQL Seed Lengkap (`app/supabase/seed-dummy-users.sql`)
```sql
-- Seed 5 dummy users (NIM 2402095010101 s/d 105)
-- Kelas: PTIK B 2024 (join_code: 'PTIK24')
-- Password default untuk semua akun: TestUser2026

DO $$
DECLARE
  v_class_id INT;
  v_user_id UUID;
  v_level_id INT;
  v_data RECORD;
BEGIN
  -- Dapatkan ID kelas PTIK24
  SELECT id INTO v_class_id FROM public.classes WHERE join_code = 'PTIK24';
  IF v_class_id IS NULL THEN
    RAISE EXCEPTION 'Kelas PTIK24 belum dibuat. Jalankan migrasi dan backfill terlebih dahulu.';
  END IF;

  -- Loop pembuatan 5 dummy user dengan progress berbeda
  FOR v_data IN 
    SELECT * FROM (VALUES
      ('2402095010101', 'Andi Pratama', 3, 250),
      ('2402095010102', 'Budi Santoso', 5, 450),
      ('2402095010103', 'Citra Dewi', 8, 750),
      ('2402095010104', 'Dewi Lestari', 12, 1150),
      ('2402095010105', 'Eko Prasetyo', 20, 2000)
    ) AS t(nim, name, levels_completed, total_xp)
  LOOP
    -- Periksa apakah user dengan NIM tersebut sudah ada
    IF NOT EXISTS (SELECT 1 FROM public.users WHERE nim = v_data.nim) THEN
      v_user_id := gen_random_uuid();
      
      -- Insert ke auth.users Supabase
      INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, aud, role, created_at, updated_at)
      VALUES (v_user_id, 'nim_' || v_data.nim || '@kodira.local',
        crypt('TestUser2026', gen_salt('bf')), NOW(),
        '{\"provider\":\"email\",\"providers\":[\"email\"]}'::jsonb,
        jsonb_build_object('name', v_data.name),
        'authenticated', 'authenticated', NOW(), NOW());
      
      -- Insert ke public.users
      INSERT INTO public.users (id, nim, name, email, role, primary_class_id)
      VALUES (v_user_id, v_data.nim, v_data.name, 'nim_' || v_data.nim || '@kodira.local', 'student', v_class_id);
      
      -- Enroll ke class_students
      INSERT INTO public.class_students (class_id, student_id, is_primary)
      VALUES (v_class_id, v_user_id, TRUE)
      ON CONFLICT DO NOTHING;
      
      -- Seed progress level sesuai jumlah yang diselesaikan
      FOR i IN 1..v_data.levels_completed LOOP
        SELECT id INTO v_level_id FROM public.levels WHERE level_number = i AND language = 'cpp' LIMIT 1;
        IF v_level_id IS NOT NULL THEN
          INSERT INTO public.user_progress (user_id, level_id, status, mastery_score, xp_earned, attempts, completed_at)
          VALUES (v_user_id, v_level_id, 'completed', 0.95, v_data.total_xp / v_data.levels_completed, 1, NOW())
          ON CONFLICT (user_id, level_id) DO UPDATE 
          SET status = 'completed', xp_earned = EXCLUDED.xp_earned;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
END $$;
```

## 4. Test Cases & Skenario Pengujian
- **Skenario Verifikasi**:
  1. Jalankan skrip SQL di Supabase SQL Editor.
  2. Jalankan kueri: `SELECT u.name, SUM(up.xp_earned) FROM public.users u JOIN public.user_progress up ON u.id = up.user_id GROUP BY u.name ORDER BY sum DESC;`
  3. Pastikan kelima mahasiswa dummy beserta pengguna existing muncul dengan total XP berurutan dari yang tertinggi ke terendah.

## 5. Blocker, Effort & Risk
- **Effort**: 1 jam pengerjaan skrip dan pengujian seed.
- **Risk**: Konflik UUID atau duplikasi email pada tabel `auth.users` jika dijalankan berulang kali.
- **Mitigasi**: Skrip dilengkapi dengan pengaman pengecekan `NOT EXISTS` berdasarkan NIM dan penanganan konflik `ON CONFLICT`.
