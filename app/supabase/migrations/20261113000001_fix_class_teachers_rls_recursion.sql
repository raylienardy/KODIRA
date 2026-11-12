-- Fix: RLS infinite recursion on class_teachers (42P17).
-- Symptom: /join-class, /teacher-dashboard, set_primary_class all fail with
--   "infinite recursion detected in policy for relation class_teachers".
-- Root cause: original class_teachers_select policy had a self-referential
--   EXISTS(SELECT FROM class_teachers) branch, causing cyclic RLS evaluation
--   when class_students.class_students_select_teacher also queried class_teachers.
-- Fix: keep only the direct teacher_id = auth.uid() branch. App code always
--   filters by teacher_id when querying class_teachers, so removing the
--   recursive OR EXISTS branch does not break any feature.

DROP POLICY IF EXISTS class_teachers_select ON public.class_teachers;

CREATE POLICY class_teachers_select ON public.class_teachers
  FOR SELECT TO authenticated
  USING (teacher_id = auth.uid());
