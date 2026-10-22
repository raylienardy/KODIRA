-- KODIRA — Migration 4: Streak Policies (P4-010)
-- Date: 2026-10-22
--
-- Tujuan:
--   1. Mengizinkan aplikasi mobile menulis streak milik user sendiri.
--   2. Pola identik dengan tabel user_progress pada migration 3
--      (insert_own_progress / update_own_progress).
--
-- Latar belakang:
--   Tabel user_streaks pada migration 3 hanya bisa ditulis oleh
--   service_role (insert_service_streaks / update_service_streaks), sehingga
--   aplikasi tidak bisa memperbarui streak saat user login. Policy
--   service_role tetap dipertahankan supaya proses server tetap bisa menulis.
--
-- Catatan:
--   - Tidak mengubah skema tabel, hanya menambah policy baru.
--   - Idempotent: policy dengan nama yang sama dibuang lebih dulu bila sudah
--     ada, jadi file ini aman dijalankan berulang.

-- ============================================
-- DROP POLICY LAMA (kalau migrasi dijalankan ulang)
-- ============================================

DROP POLICY IF EXISTS insert_own_streaks ON public.user_streaks;
DROP POLICY IF EXISTS update_own_streaks ON public.user_streaks;

-- ============================================
-- USER-SCOPED POLICIES (baris milik user sendiri)
-- ============================================

CREATE POLICY insert_own_streaks ON public.user_streaks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY update_own_streaks ON public.user_streaks
  FOR UPDATE USING (auth.uid() = user_id);
