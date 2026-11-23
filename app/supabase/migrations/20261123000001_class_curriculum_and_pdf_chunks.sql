-- KODIRA — Migration #19: Class Curriculum Isolation, PDF Material Chunks, and RLS Per-Class
-- Date: 2026-11-23
-- Description:
--   1. Tambahkan support class-isolated curriculum pada tabel levels (class_id nullable).
--   2. Tambahkan support alternative_answers pada tabel exercises untuk validator semantik setara.
--   3. Buat tabel class_material_chunks untuk potongan teks materi PDF per kelas/level tanpa file biner.
--   4. Update RLS policies pada levels, materials, exercises, dan class_material_chunks agar terisolasi per kelas.
--   5. Tambahkan RPC function clone_default_curriculum_to_class dan shift_class_levels.

-- ============================================
-- 1) ALTER TABLE public.levels (Kurikulum Per-Kelas)
-- ============================================

ALTER TABLE public.levels
  ADD COLUMN IF NOT EXISTS class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_levels_class_id_level_number
  ON public.levels (class_id, level_number);

-- Hapus constraint unique global lama jika ada
ALTER TABLE public.levels
  DROP CONSTRAINT IF EXISTS levels_level_number_key;

-- Tambahkan unique constraint per kelas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'levels_class_id_level_number_key'
  ) THEN
    ALTER TABLE public.levels
      ADD CONSTRAINT levels_class_id_level_number_key
      UNIQUE (class_id, level_number);
  END IF;
END $$;

-- Partial unique index agar template global (class_id IS NULL) tidak terduplikasi
CREATE UNIQUE INDEX IF NOT EXISTS idx_levels_single_global_template
  ON public.levels (level_number)
  WHERE class_id IS NULL;


-- ============================================
-- 2) ALTER TABLE public.exercises (Jawaban Alternatif Setara)
-- ============================================

ALTER TABLE public.exercises
  ADD COLUMN IF NOT EXISTS alternative_answers JSONB DEFAULT '[]'::jsonb;


-- ============================================
-- 3) CREATE TABLE public.class_material_chunks (Potongan Teks PDF)
-- ============================================

CREATE TABLE IF NOT EXISTS public.class_material_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
  level_id INT REFERENCES public.levels(id) ON DELETE SET NULL,
  source_title TEXT,
  chunk_order INT NOT NULL,
  topic_title TEXT,
  content_text TEXT NOT NULL,
  keywords JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_class_material_chunks_class_id
  ON public.class_material_chunks (class_id);

CREATE INDEX IF NOT EXISTS idx_class_material_chunks_level_id
  ON public.class_material_chunks (level_id);


-- ============================================
-- 4) RLS POLICIES (POLI PER KELAS & MAHASISWA / DOSEN)
-- ============================================

-- A. RLS for class_material_chunks
ALTER TABLE public.class_material_chunks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS class_material_chunks_select ON public.class_material_chunks;
CREATE POLICY class_material_chunks_select ON public.class_material_chunks
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.class_students cs
      WHERE cs.class_id = class_material_chunks.class_id
        AND cs.student_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.class_teachers ct
      WHERE ct.class_id = class_material_chunks.class_id
        AND ct.teacher_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS class_material_chunks_insert ON public.class_material_chunks;
CREATE POLICY class_material_chunks_insert ON public.class_material_chunks
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.class_teachers ct
      WHERE ct.class_id = class_id
        AND ct.teacher_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS class_material_chunks_update ON public.class_material_chunks;
CREATE POLICY class_material_chunks_update ON public.class_material_chunks
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.class_teachers ct
      WHERE ct.class_id = class_material_chunks.class_id
        AND ct.teacher_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.class_teachers ct
      WHERE ct.class_id = class_id
        AND ct.teacher_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS class_material_chunks_delete ON public.class_material_chunks;
CREATE POLICY class_material_chunks_delete ON public.class_material_chunks
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.class_teachers ct
      WHERE ct.class_id = class_material_chunks.class_id
        AND ct.teacher_id = auth.uid()
    )
  );


-- B. RLS for levels
ALTER TABLE public.levels ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS select_levels ON public.levels;
DROP POLICY IF EXISTS "Teachers can manage levels" ON public.levels;
DROP POLICY IF EXISTS levels_select ON public.levels;
DROP POLICY IF EXISTS levels_manage_teacher ON public.levels;

CREATE POLICY levels_select ON public.levels
  FOR SELECT TO authenticated
  USING (
    class_id IS NULL
    OR EXISTS (
      SELECT 1 FROM public.class_teachers ct
      WHERE ct.class_id = levels.class_id
        AND ct.teacher_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.class_students cs
      WHERE cs.class_id = levels.class_id
        AND cs.student_id = auth.uid()
    )
  );

CREATE POLICY levels_manage_teacher ON public.levels
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'teacher'
    )
    AND (
      class_id IS NULL
      OR EXISTS (
        SELECT 1 FROM public.class_teachers ct
        WHERE ct.class_id = levels.class_id
          AND ct.teacher_id = auth.uid()
      )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'teacher'
    )
    AND (
      class_id IS NULL
      OR EXISTS (
        SELECT 1 FROM public.class_teachers ct
        WHERE ct.class_id = class_id
          AND ct.teacher_id = auth.uid()
      )
    )
  );


-- C. RLS for materials
ALTER TABLE public.materials ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS select_materials ON public.materials;
DROP POLICY IF EXISTS "Teachers can manage materials" ON public.materials;
DROP POLICY IF EXISTS materials_select ON public.materials;
DROP POLICY IF EXISTS materials_manage_teacher ON public.materials;

CREATE POLICY materials_select ON public.materials
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.levels l
      WHERE l.id = materials.level_id
        AND (
          l.class_id IS NULL
          OR EXISTS (
            SELECT 1 FROM public.class_teachers ct
            WHERE ct.class_id = l.class_id
              AND ct.teacher_id = auth.uid()
          )
          OR EXISTS (
            SELECT 1 FROM public.class_students cs
            WHERE cs.class_id = l.class_id
              AND cs.student_id = auth.uid()
          )
        )
    )
  );

CREATE POLICY materials_manage_teacher ON public.materials
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'teacher'
    )
    AND EXISTS (
      SELECT 1 FROM public.levels l
      WHERE l.id = materials.level_id
        AND (
          l.class_id IS NULL
          OR EXISTS (
            SELECT 1 FROM public.class_teachers ct
            WHERE ct.class_id = l.class_id
              AND ct.teacher_id = auth.uid()
          )
        )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'teacher'
    )
    AND EXISTS (
      SELECT 1 FROM public.levels l
      WHERE l.id = level_id
        AND (
          l.class_id IS NULL
          OR EXISTS (
            SELECT 1 FROM public.class_teachers ct
            WHERE ct.class_id = l.class_id
              AND ct.teacher_id = auth.uid()
          )
        )
    )
  );


-- D. RLS for exercises
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS select_exercises ON public.exercises;
DROP POLICY IF EXISTS "Teachers can manage exercises" ON public.exercises;
DROP POLICY IF EXISTS exercises_select ON public.exercises;
DROP POLICY IF EXISTS exercises_manage_teacher ON public.exercises;

CREATE POLICY exercises_select ON public.exercises
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.levels l
      WHERE l.id = exercises.level_id
        AND (
          l.class_id IS NULL
          OR EXISTS (
            SELECT 1 FROM public.class_teachers ct
            WHERE ct.class_id = l.class_id
              AND ct.teacher_id = auth.uid()
          )
          OR EXISTS (
            SELECT 1 FROM public.class_students cs
            WHERE cs.class_id = l.class_id
              AND cs.student_id = auth.uid()
          )
        )
    )
  );

CREATE POLICY exercises_manage_teacher ON public.exercises
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'teacher'
    )
    AND EXISTS (
      SELECT 1 FROM public.levels l
      WHERE l.id = exercises.level_id
        AND (
          l.class_id IS NULL
          OR EXISTS (
            SELECT 1 FROM public.class_teachers ct
            WHERE ct.class_id = l.class_id
              AND ct.teacher_id = auth.uid()
          )
        )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'teacher'
    )
    AND EXISTS (
      SELECT 1 FROM public.levels l
      WHERE l.id = level_id
        AND (
          l.class_id IS NULL
          OR EXISTS (
            SELECT 1 FROM public.class_teachers ct
            WHERE ct.class_id = l.class_id
              AND ct.teacher_id = auth.uid()
          )
        )
    )
  );


-- ============================================
-- 5) RPC FUNCTIONS (clone_default_curriculum_to_class & shift_class_levels)
-- ============================================

-- RPC 1: clone_default_curriculum_to_class
CREATE OR REPLACE FUNCTION public.clone_default_curriculum_to_class(
  p_class_id UUID
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_old_level RECORD;
  v_new_level_id INT;
  v_cloned_count INT := 0;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- Verifikasi pemanggil adalah pengajar di kelas ini
  IF NOT EXISTS (
    SELECT 1 FROM public.class_teachers
    WHERE class_id = p_class_id AND teacher_id = v_uid
  ) THEN
    RAISE EXCEPTION 'not_class_teacher';
  END IF;

  -- Jika kelas sudah memiliki level per-kelas, batalkan untuk menghindari duplikasi
  IF EXISTS (
    SELECT 1 FROM public.levels
    WHERE class_id = p_class_id
  ) THEN
    RETURN 0;
  END IF;

  -- Loop menyalin 15 level standar global (class_id IS NULL)
  FOR v_old_level IN
    SELECT id, level_number, title, description, topic, language, difficulty
    FROM public.levels
    WHERE class_id IS NULL
    ORDER BY level_number ASC
  LOOP
    INSERT INTO public.levels (
      level_number, title, description, topic, language, difficulty, class_id, created_at
    )
    VALUES (
      v_old_level.level_number,
      v_old_level.title,
      v_old_level.description,
      v_old_level.topic,
      v_old_level.language,
      v_old_level.difficulty,
      p_class_id,
      NOW()
    )
    RETURNING id INTO v_new_level_id;

    -- Salin materi level (5 slide)
    INSERT INTO public.materials (
      level_id, slide_order, title, content, code_snippet, created_at
    )
    SELECT
      v_new_level_id, slide_order, title, content, code_snippet, NOW()
    FROM public.materials
    WHERE level_id = v_old_level.id;

    -- Salin latihan & kuis level (5 latihan + 3 kuis)
    INSERT INTO public.exercises (
      level_id, type, prompt, payload, difficulty, alternative_answers, created_at
    )
    SELECT
      v_new_level_id, type, prompt, payload, difficulty, alternative_answers, NOW()
    FROM public.exercises
    WHERE level_id = v_old_level.id;

    v_cloned_count := v_cloned_count + 1;
  END LOOP;

  RETURN v_cloned_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.clone_default_curriculum_to_class(UUID) TO authenticated;


-- RPC 2: shift_class_levels
CREATE OR REPLACE FUNCTION public.shift_class_levels(
  p_class_id UUID,
  p_from_level_number INT,
  p_delta INT
)
RETURNS VOID
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

  -- Verifikasi pemanggil adalah pengajar kelas ini
  IF NOT EXISTS (
    SELECT 1 FROM public.class_teachers
    WHERE class_id = p_class_id AND teacher_id = v_uid
  ) THEN
    RAISE EXCEPTION 'not_class_teacher';
  END IF;

  IF p_delta = 0 THEN
    RETURN;
  END IF;

  -- Langkah 1: Geser level_number ke offset sementara (+10000) agar tidak melanggar constraint UNIQUE (class_id, level_number)
  UPDATE public.levels
  SET level_number = level_number + 10000
  WHERE class_id = p_class_id
    AND level_number >= p_from_level_number;

  -- Langkah 2: Kembalikan nilai ke level_number akhir setelah ditambah p_delta
  UPDATE public.levels
  SET level_number = (level_number - 10000) + p_delta
  WHERE class_id = p_class_id
    AND level_number >= (p_from_level_number + 10000);
END;
$$;

GRANT EXECUTE ON FUNCTION public.shift_class_levels(UUID, INT, INT) TO authenticated;
