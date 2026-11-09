-- View untuk leaderboard global
-- Catatan deploy/re-deploy:
-- Jika view sudah ada dengan security_invoker=true, drop dulu dengan:
-- DROP VIEW IF EXISTS public.leaderboard_global;
CREATE OR REPLACE VIEW public.leaderboard_global AS
SELECT
  u.id AS user_id,
  u.name,
  u.nim,
  COALESCE(SUM(up.xp_earned), 0)::int AS total_xp
FROM public.users u
LEFT JOIN public.user_progress up ON up.user_id = u.id
GROUP BY u.id, u.name, u.nim
ORDER BY total_xp DESC;

-- Security Definer (security_invoker = false)
-- View owner (postgres role) me-bypass RLS tabel user_progress untuk melakukan
-- agregasi cross-user. Data mentah user_progress detail tetap terlindungi oleh
-- RLS select_own_progress milik masing-masing user.
ALTER VIEW public.leaderboard_global SET (security_invoker = false);

-- Policy: authenticated users can read leaderboard
GRANT SELECT ON public.leaderboard_global TO authenticated;
