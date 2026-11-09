-- KODIRA — Migration #9: Classes + Roles + Enrollment
-- Tanggal: 2026-11-10
-- Strategi: INCREMENTAL (backward compat, zero data loss)
-- Design: 2-table relasi (class_teachers + class_students)

-- ============================================
-- 1) ALTER users — add role, primary_class_id, nidn
-- ============================================
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'student'
    CHECK (role IN ('teacher', 'student'));

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS primary_class_id UUID;

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS nidn TEXT;

-- ============================================
-- 2) CREATE classes table
-- ============================================
CREATE TABLE IF NOT EXISTS public.classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL CHECK (LENGTH(code) = 6),
  description TEXT,
  created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_classes_created_by
  ON public.classes(created_by);

-- ============================================
-- 3) CREATE class_teachers (M:N user↔class, role=owner/co-teacher)
-- ============================================
CREATE TABLE IF NOT EXISTS public.class_teachers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'owner' CHECK (role IN ('owner', 'co-teacher')),
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(class_id, teacher_id)
);

CREATE INDEX IF NOT EXISTS idx_class_teachers_teacher
  ON public.class_teachers(teacher_id);

-- ============================================
-- 4) CREATE class_students (M:N user↔class, is_primary flag)
-- ============================================
CREATE TABLE IF NOT EXISTS public.class_students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(class_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_class_students_student
  ON public.class_students(student_id);

-- Ensure only 1 primary class per student
CREATE UNIQUE INDEX IF NOT EXISTS idx_one_primary_per_student
  ON public.class_students(student_id)
  WHERE is_primary = true;

-- ============================================
-- 5) Add FK for users.primary_class_id (idempotent guard)
-- ============================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fk_users_primary_class'
  ) THEN
    ALTER TABLE public.users
      ADD CONSTRAINT fk_users_primary_class
      FOREIGN KEY (primary_class_id)
      REFERENCES public.classes(id)
      ON DELETE SET NULL;
  END IF;
END $$;

-- ============================================
-- 6) Index #C7 — leaderboard perf
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_progress_user_xp
  ON public.user_progress(user_id, xp_earned DESC);

-- ============================================
-- 7) RLS policies
-- ============================================
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_students ENABLE ROW LEVEL SECURITY;

-- Classes: members can SELECT (via class_teachers OR class_students)
CREATE POLICY classes_select_member ON public.classes
  FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.class_teachers ct 
            WHERE ct.class_id = classes.id AND ct.teacher_id = auth.uid())
    OR
    EXISTS (SELECT 1 FROM public.class_students cs 
            WHERE cs.class_id = classes.id AND cs.student_id = auth.uid())
  );

-- Classes: teacher can INSERT (creates own class)
CREATE POLICY classes_insert_teacher ON public.classes
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'teacher')
  );

-- Classes: teacher who owns can UPDATE
CREATE POLICY classes_update_owner ON public.classes
  FOR UPDATE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.class_teachers ct 
            WHERE ct.class_id = classes.id 
              AND ct.teacher_id = auth.uid() 
              AND ct.role = 'owner')
  );

-- class_teachers: only class owner can manage
CREATE POLICY class_teachers_select ON public.class_teachers
  FOR SELECT TO authenticated
  USING (
    teacher_id = auth.uid()
    OR EXISTS (SELECT 1 FROM public.class_teachers ct 
               WHERE ct.class_id = class_teachers.class_id 
                 AND ct.teacher_id = auth.uid()
                 AND ct.role = 'owner')
  );

-- class_students: student can see own enrollment
CREATE POLICY class_students_select_own ON public.class_students
  FOR SELECT TO authenticated
  USING (student_id = auth.uid());

-- class_students: teacher can see student list of own class
CREATE POLICY class_students_select_teacher ON public.class_students
  FOR SELECT TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.class_teachers ct 
            WHERE ct.class_id = class_students.class_id 
              AND ct.teacher_id = auth.uid())
  );

-- class_students: insert only via RPC (join_class), not direct
-- (no INSERT policy → direct INSERT blocked)

-- ============================================
-- 8) Backfill — default class + enroll 7 users
-- ============================================
DO $$
DECLARE
  v_class_id UUID;
  v_user RECORD;
BEGIN
  -- Create default class if not exists
  SELECT id INTO v_class_id FROM public.classes WHERE code = 'PTIK24';
  
  IF v_class_id IS NULL THEN
    INSERT INTO public.classes (name, code, description, created_by)
    VALUES (
      'PTIK B 2024',
      'PTIK24',
      'Kelas default untuk mahasiswa PTIK B 2024',
      NULL  -- teacher belum ada, null OK
    )
    RETURNING id INTO v_class_id;
  END IF;
  
  -- Enroll 7 users as students (5 dummy + Ridho 141 + Test User 999)
  FOR v_user IN 
    SELECT id, nim FROM public.users 
    WHERE nim IN (
      '2402095010101', '2402095010102', '2402095010103',
      '2402095010104', '2402095010105',
      '2402095010141', '2402095010999'
    )
  LOOP
    INSERT INTO public.class_students (class_id, student_id, is_primary)
    VALUES (v_class_id, v_user.id, true)
    ON CONFLICT (class_id, student_id) DO NOTHING;
  END LOOP;
  
  -- Set primary_class_id for enrolled users
  UPDATE public.users
  SET primary_class_id = v_class_id
  WHERE nim IN (
    '2402095010101', '2402095010102', '2402095010103',
    '2402095010104', '2402095010105',
    '2402095010141', '2402095010999'
  ) AND primary_class_id IS NULL;
  
  RAISE NOTICE 'Backfill OK: class %, 7 users enrolled', v_class_id;
END $$;
