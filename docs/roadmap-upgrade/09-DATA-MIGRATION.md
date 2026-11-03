# Migrasi Data & Skema Lengkap

## 1. Konteks
Implementasi fitur multi-kelas (#2) dan leaderboard (#7) memerlukan perubahan skema database PostgreSQL di Supabase. Strategi migrasi yang dipilih adalah inkremental untuk memastikan data progress mahasiswa saat ini tidak terhapus.

## 2. Scope
Skema lengkap untuk tabel kelas, relasi pengajar-mahasiswa, penambahan kolom role pada tabel `users`, serta kebijakan RLS.

## 3. SQL Migration Lengkap
```sql
-- Migration: 20261030000000_classes_and_roles.sql
-- Description: Penambahan multi-class support, teacher roles, dan relasi M:N

-- 1. Add columns to users table
ALTER TABLE public.users 
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'student' 
    CHECK (role IN ('teacher', 'student')),
  ADD COLUMN IF NOT EXISTS primary_class_id INT NULL,
  ADD COLUMN IF NOT EXISTS nidn TEXT NULL;

-- 2. Create classes table
CREATE TABLE public.classes (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  course TEXT NOT NULL DEFAULT 'Pemrograman Dasar',
  year INT NOT NULL,
  join_code VARCHAR(6) UNIQUE NOT NULL,
  created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_classes_join_code ON public.classes(join_code);

-- 3. Create class_teachers table (M:N teacher <-> class)
CREATE TABLE public.class_teachers (
  class_id INT REFERENCES public.classes(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'owner' CHECK (role IN ('owner', 'co-teacher')),
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (class_id, teacher_id)
);

-- 4. Create class_students table (M:N student <-> class)
CREATE TABLE public.class_students (
  class_id INT REFERENCES public.classes(id) ON DELETE CASCADE,
  student_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT FALSE,
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (class_id, student_id)
);
CREATE INDEX idx_class_students_student ON public.class_students(student_id);

-- 5. Add FK for primary_class_id on users
ALTER TABLE public.users
  ADD CONSTRAINT fk_users_primary_class 
  FOREIGN KEY (primary_class_id) REFERENCES public.classes(id) 
  ON DELETE SET NULL;

-- 6. Enable RLS on classes
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
CREATE POLICY classes_select_member ON public.classes
  FOR SELECT USING (
    auth.uid() IN (SELECT teacher_id FROM class_teachers WHERE class_id = classes.id)
    OR
    auth.uid() IN (SELECT student_id FROM class_students WHERE class_id = classes.id)
  );
CREATE POLICY classes_insert_teacher ON public.classes
  FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT id FROM users WHERE role = 'teacher')
  );

-- 7. Enable RLS on class_students
ALTER TABLE public.class_students ENABLE ROW LEVEL SECURITY;
CREATE POLICY class_students_select ON public.class_students
  FOR SELECT USING (
    auth.uid() = student_id OR auth.uid() IN (SELECT teacher_id FROM class_teachers WHERE class_id = class_students.class_id)
  );
CREATE POLICY class_students_insert ON public.class_students
  FOR INSERT WITH CHECK (
    auth.uid() = student_id OR auth.uid() IN (SELECT teacher_id FROM class_teachers WHERE class_id = class_students.class_id)
  );

-- 8. Leaderboard policy on user_progress
CREATE POLICY select_leaderboard ON public.user_progress
  FOR SELECT TO authenticated
  USING (true);
```

## 4. Backfill SQL (Inkremental)
```sql
-- Set existing users role to student
UPDATE public.users SET role = 'student' WHERE role IS NULL OR role = '';

-- Create default class 'PTIK B 2024'
INSERT INTO public.classes (name, course, year, join_code, created_by)
VALUES ('PTIK B 2024', 'Pemrograman Dasar', 2024, 'PTIK24', NULL)
ON CONFLICT (join_code) DO NOTHING;

-- Enroll existing users into PTIK24
INSERT INTO public.class_students (class_id, student_id, is_primary)
SELECT c.id, u.id, TRUE
FROM public.classes c, public.users u
WHERE c.join_code = 'PTIK24'
  AND u.nim IN ('2402095010141', '2402095010999')
ON CONFLICT DO NOTHING;

-- Set primary_class_id for existing users
UPDATE public.users
SET primary_class_id = (SELECT id FROM public.classes WHERE join_code = 'PTIK24')
WHERE nim IN ('2402095010141', '2402095010999');
```

## 5. Rollback Script (Emergency)
```sql
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS fk_users_primary_class;
ALTER TABLE public.users DROP COLUMN IF EXISTS primary_class_id;
ALTER TABLE public.users DROP COLUMN IF EXISTS nidn;
ALTER TABLE public.users DROP COLUMN IF EXISTS role;
DROP TABLE IF EXISTS public.class_students;
DROP TABLE IF EXISTS public.class_teachers;
DROP TABLE IF EXISTS public.classes;
DROP POLICY IF EXISTS select_leaderboard ON public.user_progress;
```

## 6. Test Cases & Definition of Done
- Jalankan migration script di database staging Supabase dan pastikan tidak ada error sintaks.
- Pastikan user existing (`Ridho`, `Test User`) tetap dapat mengakses progress mereka setelah migrasi.

## 7. Blocker, Effort & Risk
- **Effort**: 2 jam.
- **Risk**: Kegagalan migrasi di produksi. Mitigasi: Backup database sebelum eksekusi dan siap dengan script Rollback.
