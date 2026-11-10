-- ============================================
-- Migration: teacher registration & create_class RPC (#P2+#P3)
-- - Update handle_new_user to accept 'role' from metadata ('student' | 'teacher')
-- - Add nidn column to users
-- - RLS policy for teachers to insert into class_teachers
-- - RPC function create_class to generate 6-char code and assign owner
-- ============================================

-- 1) Update handle_new_user trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_nim TEXT;
  v_name TEXT;
  v_role TEXT;
  v_nidn TEXT;
BEGIN
  v_nim := COALESCE(NEW.raw_user_meta_data->>'nim', '');
  v_name := COALESCE(NEW.raw_user_meta_data->>'name', 'Mahasiswa');
  v_role := COALESCE(NEW.raw_user_meta_data->>'role', 'student');
  v_nidn := NULLIF(TRIM(COALESCE(NEW.raw_user_meta_data->>'nidn', '')), '');

  -- Validate role
  IF v_role NOT IN ('student', 'teacher') THEN
    v_role := 'student';
  END IF;

  IF v_nim = '' THEN
    RAISE NOTICE 'handle_new_user: NIM empty for user %, skipping', NEW.id;
    RETURN NEW;
  END IF;

  INSERT INTO public.users (
    id, nim, name, email, role, nidn, created_at, updated_at
  ) VALUES (
    NEW.id, v_nim, v_name, NEW.email, v_role, v_nidn, NOW(), NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- 2) NIDN column for teachers (optional)
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS nidn TEXT;

-- 3) RLS: allow teacher to INSERT class_teachers
DROP POLICY IF EXISTS class_teachers_insert_self ON public.class_teachers;
CREATE POLICY class_teachers_insert_self ON public.class_teachers
  FOR INSERT TO authenticated
  WITH CHECK (
    teacher_id = auth.uid()
    AND EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'teacher')
  );

-- 4) RPC: create_class (generates code + insert + enroll teacher)
CREATE OR REPLACE FUNCTION public.create_class(
  p_name TEXT,
  p_description TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_code TEXT;
  v_class_id UUID;
  v_attempt INT := 0;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('error', 'not_authenticated');
  END IF;

  -- Verify user is teacher
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = v_uid AND role = 'teacher') THEN
    RETURN jsonb_build_object('error', 'not_teacher');
  END IF;

  -- Generate unique 6-char code
  LOOP
    v_code := upper(substring(md5(random()::text) from 1 for 6));
    EXIT WHEN NOT EXISTS (SELECT 1 FROM public.classes WHERE code = v_code);
    v_attempt := v_attempt + 1;
    IF v_attempt > 10 THEN
      RETURN jsonb_build_object('error', 'code_generation_failed');
    END IF;
  END LOOP;

  -- Insert class
  INSERT INTO public.classes (name, code, description, created_by)
  VALUES (p_name, v_code, p_description, v_uid)
  RETURNING id INTO v_class_id;

  -- Auto-enroll teacher as owner
  INSERT INTO public.class_teachers (class_id, teacher_id, role)
  VALUES (v_class_id, v_uid, 'owner');

  RETURN jsonb_build_object(
    'success', true,
    'class_id', v_class_id,
    'code', v_code,
    'name', p_name
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_class(TEXT, TEXT) TO authenticated;
