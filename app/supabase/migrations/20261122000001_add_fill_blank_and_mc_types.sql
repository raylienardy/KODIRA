-- 1. Perbarui CHECK constraint pada kolom exercises.type
-- Hapus constraint lama (nama default PostgreSQL: exercises_type_check)
ALTER TABLE public.exercises
  DROP CONSTRAINT IF EXISTS exercises_type_check;

-- Tambahkan constraint baru yang mengizinkan seluruh tipe soal Sprint 3 & Sprint 4
ALTER TABLE public.exercises
  ADD CONSTRAINT exercises_type_check
  CHECK (type IN ('drag_drop', 'code_editor', 'quiz', 'fill_in_the_blank', 'multiple_choice'));

-- 2. Pastikan dosen (role = 'teacher') memiliki izin INSERT/UPDATE/DELETE
-- pada tabel levels, materials, dan exercises dari Web Admin Panel
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'levels' AND policyname = 'Teachers can manage levels'
  ) THEN
    CREATE POLICY "Teachers can manage levels"
      ON public.levels
      FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users
          WHERE id = auth.uid() AND role = 'teacher'
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.users
          WHERE id = auth.uid() AND role = 'teacher'
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'materials' AND policyname = 'Teachers can manage materials'
  ) THEN
    CREATE POLICY "Teachers can manage materials"
      ON public.materials
      FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users
          WHERE id = auth.uid() AND role = 'teacher'
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.users
          WHERE id = auth.uid() AND role = 'teacher'
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'exercises' AND policyname = 'Teachers can manage exercises'
  ) THEN
    CREATE POLICY "Teachers can manage exercises"
      ON public.exercises
      FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.users
          WHERE id = auth.uid() AND role = 'teacher'
        )
      )
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.users
          WHERE id = auth.uid() AND role = 'teacher'
        )
      );
  END IF;
END $$;