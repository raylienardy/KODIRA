-- ============================================
-- Migration: Register Self-Service (#3)
-- - RLS: allow user to insert own users row (fallback)
-- - Trigger: auto-create public.users on auth.users insert
-- ============================================

-- 1) RLS: insert own user row
CREATE POLICY insert_own_user ON public.users
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

-- 2) Function: handle new user from auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_nim TEXT;
  v_name TEXT;
BEGIN
  v_nim := COALESCE(NEW.raw_user_meta_data->>'nim', '');
  v_name := COALESCE(NEW.raw_user_meta_data->>'name', 'Mahasiswa');

  -- Skip if NIM empty (shouldn't happen from our register flow)
  IF v_nim = '' THEN
    RAISE NOTICE 'handle_new_user: NIM empty for user %, skipping public.users insert', NEW.id;
    RETURN NEW;
  END IF;

  INSERT INTO public.users (
    id, nim, name, email, role, created_at, updated_at
  ) VALUES (
    NEW.id,
    v_nim,
    v_name,
    NEW.email,
    'student',
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- 3) Trigger: fires after every auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
