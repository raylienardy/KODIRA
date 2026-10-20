-- KODIRA — Seed minimum untuk P4-005 (Latihan Drag & Drop)
-- Tujuan:
--   1. Materials level 2 & 3 (5 slide per level)
--   2. Exercises drag_drop level 1 & 3 (5 exercise per level)
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/seed.sql
--
-- Idempotency:
--   Tabel materials tidak punya unique constraint pada (level_id, slide_order),
--   dan exercises tidak punya unique constraint pada (level_id, prompt).
--   Karena itu setiap INSERT memakai WHERE NOT EXISTS, bukan ON CONFLICT.
--
-- Schema payload drag_drop (v1):
--   {
--     "tokens": [{"id": "t1", "text": "..."}],
--     "answer": ["t1", "t2"],
--     "language": "cpp"
--   }
--
-- Seed aman dijalankan berulang. Bagian verifikasi di akhir akan
-- menggagalkan transaksi jika total data tidak sesuai harapan.

BEGIN;

-- ============================================
-- SECTION 1: MATERIALS LEVEL 2 — Variabel & Konstanta
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Apa itu Variabel',
       'Variabel adalah tempat menyimpan data di memori yang nilainya bisa berubah selama program berjalan. Bayangkan variabel seperti kotak berlabel yang bisa diisi dan diganti isinya.',
       NULL
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Deklarasi Variabel',
       'Untuk membuat variabel, tentukan tipe data, nama, lalu nilai awal. Contohnya:',
       'int x = 10;'
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Konstanta',
       'Konstanta adalah nilai yang tidak boleh berubah setelah dideklarasikan. Gunakan kata kunci const agar compiler mencegah perubahan.',
       'const int MAX = 100;'
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh Penggunaan',
       'Variabel dan konstanta sering dipakai bersama. Perhatikan komentar pada contoh berikut:',
       'const int MAX = 100;
int nilai = 80;

// nilai bisa berubah
nilai = 90;

// MAX tidak bisa diubah
cout << nilai;'
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami variabel dan konstanta. Selanjutnya, kamu akan berlatih menyusun deklarasi variabel dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 2: MATERIALS LEVEL 3 — Tipe Data Dasar
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Tipe Data Integer',
       'Integer adalah tipe data bilangan bulat, seperti 10, -5, atau 0. Di C++, int umumnya berukuran 4 byte dengan rentang sekitar -2.147.483.648 hingga 2.147.483.647.',
       'int umur = 20;'
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Tipe Data Float',
       'Float dan double digunakan untuk bilangan desimal. Gunakan float untuk presisi tunggal dan double untuk presisi ganda.',
       'float suhu = 36.5;
double pi = 3.14159;'
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Tipe Data Char',
       'Char menyimpan satu karakter dan ditulis dengan petik tunggal, bukan petik ganda.',
       'char nilai = ''A'';'
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Tipe Data Boolean',
       'Boolean hanya memiliki dua nilai: true atau false. Tipe ini sering dipakai untuk menyimpan status.',
       'bool lulus = true;'
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah mengenal empat tipe data dasar C++. Selanjutnya, kamu akan berlatih menyusun deklarasi dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 3: EXERCISES LEVEL 1 — drag_drop
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun kode Hello World',
       $json${
         "tokens": [
           {"id": "t4", "text": "cout << \"Hello World\";"},
           {"id": "t1", "text": "#include <iostream>"},
           {"id": "t6", "text": "}"},
           {"id": "t3", "text": "int main() {"},
           {"id": "t5", "text": "return 0;"},
           {"id": "t2", "text": "using namespace std;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun kode Hello World'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun struktur program C++ minimal',
       $json${
         "tokens": [
           {"id": "t2", "text": "int main() {"},
           {"id": "t4", "text": "}"},
           {"id": "t1", "text": "#include <iostream>"},
           {"id": "t3", "text": "return 0;"}
         ],
         "answer": ["t1", "t2", "t3", "t4"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun struktur program C++ minimal'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun output ''Halo Indonesia''',
       $json${
         "tokens": [
           {"id": "t3", "text": "int main() {"},
           {"id": "t1", "text": "#include <iostream>"},
           {"id": "t5", "text": "}"},
           {"id": "t4", "text": "cout << \"Halo Indonesia\";"},
           {"id": "t2", "text": "using namespace std;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun output ''Halo Indonesia'''
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun komentar + print',
       $json${
         "tokens": [
           {"id": "t4", "text": "std::cout << \"Halo\";"},
           {"id": "t2", "text": "#include <iostream>"},
           {"id": "t1", "text": "// Mencetak sapaan"},
           {"id": "t5", "text": "}"},
           {"id": "t3", "text": "int main() {"}
         ],
         "answer": ["t2", "t1", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun komentar + print'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi variabel + print',
       $json${
         "tokens": [
           {"id": "t4", "text": "std::cout << umur;"},
           {"id": "t1", "text": "#include <iostream>"},
           {"id": "t5", "text": "}"},
           {"id": "t3", "text": "int umur = 20;"},
           {"id": "t2", "text": "int main() {"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi variabel + print'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 4: EXERCISES LEVEL 3 — drag_drop
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi integer',
       $json${
         "tokens": [
           {"id": "t2", "text": "= 10"},
           {"id": "t3", "text": ";"},
           {"id": "t1", "text": "int nilai"}
         ],
         "answer": ["t1", "t2", "t3"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi integer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi float',
       $json${
         "tokens": [
           {"id": "t3", "text": ";"},
           {"id": "t1", "text": "float ipk"},
           {"id": "t2", "text": "= 3.75"}
         ],
         "answer": ["t1", "t2", "t3"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi float'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi char',
       $json${
         "tokens": [
           {"id": "t2", "text": "= 'A'"},
           {"id": "t1", "text": "char grade"},
           {"id": "t3", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi char'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi bool',
       $json${
         "tokens": [
           {"id": "t1", "text": "bool lulus"},
           {"id": "t3", "text": ";"},
           {"id": "t2", "text": "= true"}
         ],
         "answer": ["t1", "t2", "t3"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi bool'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun kombinasi 4 tipe data',
       $json${
         "tokens": [
           {"id": "t3", "text": "float ipk = 3.75;"},
           {"id": "t5", "text": "bool lulus = true;"},
           {"id": "t1", "text": "// Empat tipe data dasar"},
           {"id": "t4", "text": "char grade = 'A';"},
           {"id": "t2", "text": "int umur = 20;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun kombinasi 4 tipe data'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 5: VERIFICATION
-- ============================================

DO $$
DECLARE
  total_materials INT;
  total_exercises INT;
  l1_materials INT;
  l2_materials INT;
  l3_materials INT;
  l1_exercises INT;
  l3_exercises INT;
BEGIN
  SELECT count(*) INTO total_materials FROM public.materials;
  SELECT count(*) INTO total_exercises FROM public.exercises;

  SELECT count(*) INTO l1_materials
  FROM public.materials m
  JOIN public.levels l ON l.id = m.level_id
  WHERE l.level_number = 1 AND l.language = 'cpp';

  SELECT count(*) INTO l2_materials
  FROM public.materials m
  JOIN public.levels l ON l.id = m.level_id
  WHERE l.level_number = 2 AND l.language = 'cpp';

  SELECT count(*) INTO l3_materials
  FROM public.materials m
  JOIN public.levels l ON l.id = m.level_id
  WHERE l.level_number = 3 AND l.language = 'cpp';

  SELECT count(*) INTO l1_exercises
  FROM public.exercises e
  JOIN public.levels l ON l.id = e.level_id
  WHERE l.level_number = 1 AND l.language = 'cpp' AND e.type = 'drag_drop';

  SELECT count(*) INTO l3_exercises
  FROM public.exercises e
  JOIN public.levels l ON l.id = e.level_id
  WHERE l.level_number = 3 AND l.language = 'cpp' AND e.type = 'drag_drop';

  IF total_materials <> 15 THEN
    RAISE EXCEPTION 'Seed verification failed: expected 15 materials, found %', total_materials;
  END IF;

  IF total_exercises <> 10 THEN
    RAISE EXCEPTION 'Seed verification failed: expected 10 exercises, found %', total_exercises;
  END IF;

  IF l1_materials <> 5 OR l2_materials <> 5 OR l3_materials <> 5 THEN
    RAISE EXCEPTION 'Seed verification failed: expected 5 materials per level for levels 1-3, found L1=%, L2=%, L3=%',
      l1_materials, l2_materials, l3_materials;
  END IF;

  IF l1_exercises <> 5 OR l3_exercises <> 5 THEN
    RAISE EXCEPTION 'Seed verification failed: expected 5 drag_drop exercises for levels 1 and 3, found L1=%, L3=%',
      l1_exercises, l3_exercises;
  END IF;
END
$$;

COMMIT;
