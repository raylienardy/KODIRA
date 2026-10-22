-- KODIRA — Migration 5: Badge & Achievement Policies (P4-010)
-- Date: 2026-10-22
--
-- Tujuan:
--   1. Mengizinkan aplikasi mobile menulis badge dan achievement milik user
--      sendiri, sehingga pemberian badge bisa berjalan otomatis.
--   2. Pola identik dengan tabel user_progress dan user_streaks pada
--      migration 3 dan 4 (insert_own_progress / insert_own_streaks).
--
-- Latar belakang:
--   Tabel user_badges dan user_achievements pada migration 3 hanya bisa
--   ditulis oleh service_role (insert_service_badges /
--   insert_service_achievements), sehingga aplikasi tidak bisa memberi
--   badge secara otomatis. Policy service_role tetap dipertahankan supaya
--   proses server tetap bisa menulis.
--
-- Catatan:
--   - Tidak mengubah skema tabel, hanya menambah policy baru.
--   - Idempotent: policy dengan nama yang sama dibuang lebih dulu bila sudah
--     ada, jadi file ini aman dijalankan berulang.
--   - Nama policy tidak bentrok dengan policy lama berawalan service_.

-- ============================================
-- DROP POLICY LAMA (kalau migrasi dijalankan ulang)
-- ============================================

DROP POLICY IF EXISTS insert_own_badges ON public.user_badges;
DROP POLICY IF EXISTS update_own_badges ON public.user_badges;
DROP POLICY IF EXISTS insert_own_achievements ON public.user_achievements;
DROP POLICY IF EXISTS update_own_achievements ON public.user_achievements;

-- ============================================
-- USER-SCOPED POLICIES (baris milik user sendiri)
-- ============================================

CREATE POLICY insert_own_badges ON public.user_badges
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY update_own_badges ON public.user_badges
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY insert_own_achievements ON public.user_achievements
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY update_own_achievements ON public.user_achievements
  FOR UPDATE USING (auth.uid() = user_id);
