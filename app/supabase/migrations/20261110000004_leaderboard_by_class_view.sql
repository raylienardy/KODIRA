-- Leaderboard per-class view (filter by class_id)
-- Uses same security_invoker=false approach sebagai leaderboard_global
CREATE OR REPLACE VIEW public.leaderboard_by_class AS
SELECT
  c.id AS class_id,
  u.id AS user_id,
  u.name,
  u.nim,
  COALESCE(SUM(up.xp_earned), 0)::int AS total_xp
FROM public.classes c
JOIN public.class_students cs ON cs.class_id = c.id
JOIN public.users u ON u.id = cs.student_id
LEFT JOIN public.user_progress up ON up.user_id = u.id
GROUP BY c.id, u.id, u.name, u.nim
ORDER BY total_xp DESC;

ALTER VIEW public.leaderboard_by_class SET (security_invoker = false);
GRANT SELECT ON public.leaderboard_by_class TO authenticated;
