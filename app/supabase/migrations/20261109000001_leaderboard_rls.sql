-- View untuk leaderboard global
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

-- RLS untuk view (Postgres: security invoker by default)
ALTER VIEW public.leaderboard_global SET (security_invoker = true);

-- Policy: authenticated users can read leaderboard
GRANT SELECT ON public.leaderboard_global TO authenticated;
