-- Fix: teacher role was appearing in global leaderboard (with 0 XP,
-- since teachers don't do quizzes). Exclude role='teacher' from view.
CREATE OR REPLACE VIEW public.leaderboard_global AS
SELECT
  u.id AS user_id,
  u.name,
  u.nim,
  COALESCE(SUM(up.xp_earned), 0)::int AS total_xp
FROM public.users u
LEFT JOIN public.user_progress up ON up.user_id = u.id
WHERE u.role = 'student'
GROUP BY u.id, u.name, u.nim
ORDER BY total_xp DESC;

ALTER VIEW public.leaderboard_global SET (security_invoker = false);
GRANT SELECT ON public.leaderboard_global TO authenticated;
