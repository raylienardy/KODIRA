-- Teacher drill-down view: aggregate student progress per class.
-- security_invoker=false allows teacher read without changing base-table RLS.
-- Colocated with leaderboard_by_class pattern (migration 20261110000004).
CREATE OR REPLACE VIEW public.student_detail_by_class AS
SELECT
  cs.class_id,
  u.id AS student_id,
  u.name,
  u.nim,
  COALESCE(SUM(up.xp_earned), 0)::int AS total_xp,
  COALESCE(
    COUNT(*) FILTER (WHERE up.status = 'completed'),
    0
  )::int AS levels_completed,
  COALESCE(
    AVG(up.mastery_score) FILTER (WHERE up.mastery_score IS NOT NULL),
    0.0
  )::numeric(5,3) AS avg_mastery,
  COALESCE(
    jsonb_object_agg(
      up.level_id::text,
      up.mastery_score
    ) FILTER (WHERE up.level_id IS NOT NULL AND up.mastery_score IS NOT NULL),
    '{}'::jsonb
  ) AS mastery_by_level
FROM public.class_students cs
JOIN public.users u ON u.id = cs.student_id
LEFT JOIN public.user_progress up ON up.user_id = u.id
GROUP BY cs.class_id, u.id, u.name, u.nim;

ALTER VIEW public.student_detail_by_class SET (security_invoker = false);
GRANT SELECT ON public.student_detail_by_class TO authenticated;
