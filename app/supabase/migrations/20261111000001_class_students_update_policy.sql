-- Allow student to update own is_primary flag
DROP POLICY IF EXISTS class_students_update_own ON public.class_students;
CREATE POLICY class_students_update_own ON public.class_students
  FOR UPDATE TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- Procedure to set primary class:
-- 1. Verify enrollment
-- 2. Reset all primaries for user
-- 3. Set new primary
-- 4. Update users.primary_class_id
CREATE OR REPLACE FUNCTION public.set_primary_class(p_class_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- Verify enrollment
  IF NOT EXISTS (
    SELECT 1 FROM public.class_students
    WHERE student_id = v_uid AND class_id = p_class_id
  ) THEN
    RAISE EXCEPTION 'not_enrolled';
  END IF;

  -- Reset all primaries
  UPDATE public.class_students
  SET is_primary = false
  WHERE student_id = v_uid;

  -- Set new primary
  UPDATE public.class_students
  SET is_primary = true
  WHERE student_id = v_uid AND class_id = p_class_id;

  -- Update users.primary_class_id
  UPDATE public.users
  SET primary_class_id = p_class_id
  WHERE id = v_uid;
END;
$$;

GRANT EXECUTE ON FUNCTION public.set_primary_class(UUID) TO authenticated;
