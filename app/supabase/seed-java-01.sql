-- KODIRA — Seed Chunk 4 (FINAL) — Java Level 36-50 materials + exercises
-- Tanggal: 2026-10-20
--
-- Tujuan:
--   1. Materials Level 36-50 (15 level x 5 slide = 75 slide)
--   2. Exercises drag_drop Level 36-50 (15 level x 5 exercise = 75 exercise)
--
-- File ini adalah CHUNK 4 dari 4 file seed dan merupakan SEED LENGKAP:
--   1. seed-cpp-01.sql  — L2 exercises, L4-15   (C++)
--   2. seed-cpp-02.sql             — L16-25      (C++)
--   3. seed-cpp-03.sql             — L26-35      (C++)
--   4. seed-java-01.sql  (file ini) — L36-50     (Java)
--   File seed.sql (L1-3) tetap dipertahankan dan tidak diubah oleh file ini.
--
-- Semua level memakai language = 'java' pada query SELECT level.
-- Payload drag_drop memakai "language": "java", bukan "cpp".
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/seed-java-01.sql
--
-- Idempotency:
--   Tabel materials tidak punya unique constraint pada (level_id, slide_order),
--   dan exercises tidak punya unique constraint pada (level_id, prompt).
--   Karena itu setiap INSERT memakai WHERE NOT EXISTS, bukan ON CONFLICT.
--   File ini aman dijalankan berulang; jumlah baris tidak bertambah.
--
-- Schema payload drag_drop (v1):
--   {
--     "tokens": [{"id": "t1", "text": "..."}],
--     "answer": ["t1", "t2"],
--     "language": "java"
--   }
--
-- Aturan token (divalidasi di app/lib/features/exercise/screens/drag_drop_screen.dart):
--   - panjang answer harus sama dengan jumlah tokens
--   - id token unik dan tidak boleh kosong
--   - text token tidak boleh kosong
--   - semua id pada answer harus menunjuk token yang ada
--   - susunan token sesuai answer menghasilkan kode Java yang valid secara sintaks
--   - kurung kurawal {} dan kurung lingkung () pada kode rakitan harus balance
--
-- Verifikasi di akhir memakai DO block RELATIF per level (5 material + 5 exercise),
-- bukan angka absolut, sehingga file ini aman dijalankan berdampingan dengan chunk lain.

BEGIN;

-- ============================================
-- SECTION 1: MATERIALS LEVEL 36 — Pengenalan Java
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Java',
       'Java adalah bahasa pemrograman berorientasi objek (object-oriented) yang berjalan di mana saja lewat Java Virtual Machine (JVM).',
       'public class Main {
  public static void main(String[] args) {
    System.out.println("Halo, dunia!");
  }
}'
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Struktur Program Java',
       'Setiap program Java minimal punya satu class. Nama file harus sama dengan nama class public di dalamnya.',
       '// nama file: Main.java
public class Main {
  // isi class
}'
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Method Main',
       'Method main adalah titik awal eksekusi program. JVM memanggil method ini pertama kali, dan parameter args menyimpan argumen baris perintah.',
       'public static void main(String[] args) {
  System.out.println("Program dimulai");
}'
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Compile dan Run',
       'Kode Java dikompilasi menjadi berkas bytecode (.class) oleh javac, lalu dijalankan oleh perintah java melalui JVM.',
       'javac Main.java
java Main'
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami struktur program Java dan cara menjalankannya. Selanjutnya, kamu akan menyusun kelas pertama dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 2: EXERCISES LEVEL 36 — Pengenalan Java (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun class Main',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "int umur = 20;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun class Main'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun program hello',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "System.out.println(\"Halo, dunia!\");"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun program hello'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun method main',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "static"},
           {"id": "t3", "text": "void"},
           {"id": "t4", "text": "main(String[] args)"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "System.out.println(\"Mulai\");"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun method main'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun variabel Java',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "int umur = 20;"},
           {"id": "t6", "text": "String nama = \"Budi\";"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun variabel Java'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun print variabel',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "String nama = \"Budi\";"},
           {"id": "t7", "text": "System.out.println(\"Halo \" + nama);"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun print variabel'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 3: MATERIALS LEVEL 37 — Class & Object
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan OOP',
       'Pemrograman berorientasi objek (object-oriented programming) mengelompokkan data dan perilaku bersama dalam bentuk class dan object.',
       'class Mobil {
  String warna;
  int kecepatan;
}'
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Membuat Class',
       'Class adalah cetakan atau templat yang mendefinisikan atribut (data) dan method (perilaku) untuk object.',
       'class Mahasiswa {
  String nama;
  int nim;

  void sapa() {
    System.out.println("Halo");
  }
}'
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Membuat Object',
       'Object adalah turunan nyata dari class. Object dibuat dengan operator new lalu disimpan pada variabel bertipe class tersebut.',
       'Mobil mobil = new Mobil();
mobil.warna = "Merah";
mobil.kecepatan = 120;'
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Class Mobil',
       'Setiap object Mobil punya data warna dan kecepatan sendiri, meskipun class yang dipakainya sama.',
       'public class Mobil {
  String warna;
  int kecepatan;

  public static void main(String[] args) {
    Mobil m1 = new Mobil();
    m1.warna = "Merah";
    System.out.println(m1.warna);
  }
}'
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami class sebagai templat dan object sebagai turunan nyata dari class tersebut. Selanjutnya, kamu akan menyusun class dan object serta mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 4: EXERCISES LEVEL 37 — Class & Object (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi class',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Mobil"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "String warna;"},
           {"id": "t6", "text": "int kecepatan;"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi class'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun membuat object',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "Mobil mobil = new Mobil();"},
           {"id": "t6", "text": "mobil.warna = \"Merah\";"},
           {"id": "t7", "text": "mobil.kecepatan = 120;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun membuat object'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun akses field',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Mobil m1 = new Mobil();"},
           {"id": "t7", "text": "System.out.println(m1.warna);"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun akses field'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun dua object',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "Mobil m1 = new Mobil();"},
           {"id": "t6", "text": "m1.warna = \"Merah\";"},
           {"id": "t7", "text": "Mobil m2 = new Mobil();"},
           {"id": "t8", "text": "m2.warna = \"Biru\";"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun dua object'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun method pada object',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Mobil"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "String warna;"},
           {"id": "t5", "text": "void"},
           {"id": "t6", "text": "jalan()"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "System.out.println(\"Mobil jalan\");"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun method pada object'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 5: MATERIALS LEVEL 38 — Constructor
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Constructor',
       'Constructor adalah method khusus yang dipanggil otomatis saat object dibuat, berguna untuk menyiapkan nilai awal object.',
       'class Mobil {
  String warna;

  Mobil(String warna) {
    this.warna = warna;
  }
}'
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Constructor Default',
       'Bila class tidak menulis constructor, Java menyediakan constructor default yang menginisialisasi semua atribut dengan nilai nol.',
       'Mobil m = new Mobil();
System.out.println(m.warna);'
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Constructor Parameter',
       'Constructor dengan parameter menerima nilai dari pemanggil dan menyimpannya ke atribut object.',
       'Mobil(String warna, int kecepatan) {
  this.warna = warna;
  this.kecepatan = kecepatan;
}'
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Class Nilai',
       'Constructor membuat object Nilai langsung terisi NIM dan nilai, tanpa perlu assignment manual.',
       'class Nilai {
  int nim;
  double ipk;

  Nilai(int nim, double ipk) {
    this.nim = nim;
    this.ipk = ipk;
  }
}'
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami constructor sebagai penyiap nilai awal object. Selanjutnya, kamu akan menyusun constructor dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 6: EXERCISES LEVEL 38 — Constructor (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun constructor default',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Mobil"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "Mobil()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "this.warna = \"Merah\";"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun constructor default'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun constructor parameter',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Mobil"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "String warna;"},
           {"id": "t5", "text": "Mobil(String warna)"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "this.warna = warna;"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun constructor parameter'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun keyword this',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Mobil"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "Mobil(String warna)"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "this.warna = warna;"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun keyword this'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun constructor overload',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Mobil"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "Mobil()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "this.warna = \"Merah\";"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "Mobil(String warna)"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "this.warna = warna;"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun constructor overload'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan constructor',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Mobil mobil = new Mobil(\"Merah\");"},
           {"id": "t7", "text": "System.out.println(mobil.warna);"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan constructor'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 7: MATERIALS LEVEL 39 — Enkapsulasi
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Enkapsulasi',
       'Enkapsulasi (encapsulation) menyembunyikan data internal class agar hanya bisa diakses lewat method yang disediakan.',
       'class Rekening {
  private double saldo;

  public double getSaldo() {
    return saldo;
  }
}'
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Modifier Private',
       'Atribut yang ditandai private hanya bisa diakses dari dalam class tersebut, sehingga data terlindungi dari perubahan di luar.',
       'private double saldo;'
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Getter dan Setter',
       'Method getter mengembalikan nilai atribut, sedangkan method setter mengubah nilai atribut dengan validasi di dalamnya.',
       'public void setSaldo(double saldo) {
  if (saldo < 0) {
    System.out.println("Saldo tidak boleh negatif");
    return;
  }
  this.saldo = saldo;
}'
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Class Rekening',
       'Atribut saldo dibuat private dan diakses lewat getter dan setter supaya perubahan tetap terkontrol.',
       'Rekening r = new Rekening();
r.setSaldo(100000);
System.out.println(r.getSaldo());'
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami enkapsulasi, modifier private, serta pasangan getter dan setter. Selanjutnya, kamu akan menyusun class terenkapsulasi dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 8: EXERCISES LEVEL 39 — Enkapsulasi (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun field private',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Rekening"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "private double saldo;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun field private'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun getter',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Rekening"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "private double saldo;"},
           {"id": "t6", "text": "public double getSaldo()"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "return saldo;"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun getter'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun setter',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Rekening"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "private double saldo;"},
           {"id": "t6", "text": "public void setSaldo(double saldo)"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "this.saldo = saldo;"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun setter'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun getter setter lengkap',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Rekening"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "private double saldo;"},
           {"id": "t5", "text": "public double getSaldo()"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "return saldo;"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "public void setSaldo(double saldo)"},
           {"id": "t10", "text": "{"},
           {"id": "t11", "text": "this.saldo = saldo;"},
           {"id": "t12", "text": "}"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun getter setter lengkap'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun validasi setter',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Rekening"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "private double saldo;"},
           {"id": "t5", "text": "public void setSaldo(double saldo)"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "if (saldo < 0) {"},
           {"id": "t8", "text": "System.out.println(\"Saldo tidak boleh negatif\");"},
           {"id": "t9", "text": "return;"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "this.saldo = saldo;"},
           {"id": "t12", "text": "}"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun validasi setter'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 9: MATERIALS LEVEL 40 — Static & Final
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Static',
       'Kata kunci static membuat anggota class dimiliki class itu sendiri dan dibagi oleh semua object dari class tersebut.',
       'class Penghitung {
  static int total = 0;

  static void tambah() {
    total++;
  }
}'
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Static Variable dan Final',
       'Atribut static hanya ada satu salinan untuk seluruh object, sedangkan final dipakai untuk membuat atribut yang nilainya tidak bisa diubah lagi.',
       'class Penghitung {
  static int id = 0;
  static final int MAKS = 100;
}'
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Static Method',
       'Method static dijalankan tanpa object, dipanggil lewat nama class, dan tidak boleh memakai atribut instance.',
       'static int kuadrat(int x) {
  return x * x;
}

int hasil = Penghitung.kuadrat(5);'
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Penghitung ID',
       'Atribut static dipakai untuk memberi nomor urut unik pada setiap object yang dibuat.',
       'class Mahasiswa {
  static int jumlah = 0;
  int nim;

  Mahasiswa(int nim) {
    this.nim = nim;
    jumlah++;
  }
}'
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami penggunaan static dan final di dalam class Java. Selanjutnya, kamu akan menyusun class dengan anggota static dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 10: EXERCISES LEVEL 40 — Static & Final (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun static field',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Penghitung"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "static int total = 0;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun static field'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun static method',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Penghitung"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "static"},
           {"id": "t5", "text": "void"},
           {"id": "t6", "text": "tambah()"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "total++;"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun static method'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan static',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Penghitung"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "static int kuadrat(int x)"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "return x * x;"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "int hasil = Penghitung.kuadrat(5);"},
           {"id": "t10", "text": "int nilai = Penghitung.kuadrat(3);"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan static'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun konstanta final',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Penghitung"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "static int total = 0;"},
           {"id": "t5", "text": "static final int MAKS = 100;"},
           {"id": "t6", "text": "public static final double PI = 3.14;"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun konstanta final'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun counter ID',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Mahasiswa"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "static int jumlah = 0;"},
           {"id": "t5", "text": "int nim;"},
           {"id": "t6", "text": "Mahasiswa(int nim)"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "this.nim = nim;"},
           {"id": "t9", "text": "jumlah++;"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun counter ID'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 11: MATERIALS LEVEL 41 — Inheritance Dasar
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Pewarisan',
       'Pewarisan (inheritance) memungkinkan sebuah class mewarisi atribut dan method dari class lain sehingga kode tidak ditulis berulang.',
       'class Kendaraan {
  int roda;
}

class Motor extends Kendaraan {
  int cc;
}'
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Keyword Extends',
       'Class turunan ditulis dengan keyword extends lalu nama class induk (superclass). Atribut induk otomatis bisa dipakai di class turunan.',
       'class Motor extends Kendaraan {
  void info() {
    System.out.println(roda);
  }
}'
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Hierarki Class',
       'Satu class induk bisa memiliki banyak class turunan, dan pewarisan bisa berlapis beberapa tingkat.',
       'class Kendaraan
  |-- Mobil
  |     |-- Sport
  `-- Motor'
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Class Smartphone',
       'Class Smartphone mewarisi atribut dan method dari class Ponsel, lalu menambah fitur layar sentuh.',
       'class Smartphone extends Ponsel {
  int ukuranLayar;

  void info() {
    System.out.println(ukuranLayar);
  }
}'
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami pewarisan dan keyword extends. Selanjutnya, kamu akan menyusun class turunan dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 12: EXERCISES LEVEL 41 — Inheritance Dasar (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun class induk',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Kendaraan"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int roda;"},
           {"id": "t5", "text": "int tahun;"},
           {"id": "t6", "text": "void"},
           {"id": "t7", "text": "info()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "System.out.println(\"Kendaraan\");"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun class induk'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun class anak extends',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Motor"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Kendaraan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "int cc;"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun class anak extends'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan method induk',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Motor"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Kendaraan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "void"},
           {"id": "t7", "text": "tampil()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "System.out.println(\"Motor\");"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan method induk'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun method override sederhana',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Motor"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Kendaraan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "public void"},
           {"id": "t7", "text": "info()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "System.out.println(\"Motor berjalan\");"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun method override sederhana'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun hierarki tiga level',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Mobil"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Kendaraan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "int pintu;"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "class"},
           {"id": "t9", "text": "Sport"},
           {"id": "t10", "text": "extends"},
           {"id": "t11", "text": "Mobil"},
           {"id": "t12", "text": "{"},
           {"id": "t13", "text": "int cc;"},
           {"id": "t14", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun hierarki tiga level'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 13: MATERIALS LEVEL 42 — Super & Override
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Super',
       'Keyword super dipakai class turunan untuk mengakses constructor dan method milik class induk.',
       'class Motor extends Kendaraan {
  Motor() {
    super();
  }
}'
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Memanggil Constructor Induk',
       'Constructor induk selalu dipanggil otomatis, tetapi super() bisa ditulis eksplisit di baris pertama constructor turunan.',
       'Mobil(String warna) {
  super(warna);
  this.pintu = 4;
}'
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Method Override',
       'Method override adalah method dengan nama dan parameter sama yang ditulis ulang di class turunan untuk mengubah perilaku.',
       'class Motor extends Kendaraan {
  @Override
  public void info() {
    System.out.println("Motor");
  }
}'
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Class Hewan',
       'Method bersuara pada class induk digantikan method bersuara pada class turunan, dan super.bersuara() memanggil versi induk.',
       'class Hewan {
  void bersuara() {
    System.out.println("Suara hewan");
  }
}

class Kucing extends Hewan {
  @Override
  void bersuara() {
    super.bersuara();
    System.out.println("Meong");
  }
}'
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami keyword super dan method override. Selanjutnya, kamu akan menyusun class turunan yang memanggil class induk dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 14: EXERCISES LEVEL 42 — Super & Override (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan super',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Motor"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Kendaraan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "Motor()"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "super();"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan super'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun super method',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Kucing"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Hewan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "void"},
           {"id": "t7", "text": "bersuara()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "super.bersuara();"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun super method'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun override',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Kucing"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Hewan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "@Override"},
           {"id": "t7", "text": "void"},
           {"id": "t8", "text": "bersuara()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "System.out.println(\"Meong\");"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun override'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun override plus super',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Kucing"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Hewan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "@Override"},
           {"id": "t7", "text": "void"},
           {"id": "t8", "text": "bersuara()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "super.bersuara();"},
           {"id": "t11", "text": "System.out.println(\"Meong\");"},
           {"id": "t12", "text": "}"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun override plus super'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun program memanggil override',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Kucing k = new Kucing();"},
           {"id": "t7", "text": "k.bersuara();"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun program memanggil override'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 15: MATERIALS LEVEL 43 — Polymorphism
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Polimorfisme',
       'Polimorfisme (polymorphism) memungkinkan satu pemanggilan method menghasilkan perilaku berbeda tergantung tipe object yang dipakai.',
       'Bentuk b = new Lingkaran();
b.tampil();'
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Overloading versus Overriding',
       'Overloading memakai nama method sama dengan parameter berbeda dalam satu class, sedangkan overriding mengganti method milik class induk.',
       '// overloading
void info(int x) {
  System.out.println(x);
}

void info(String x) {
  System.out.println(x);
}'
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Polimorfisme Runtime',
       'Pemilihan method pada polimorfisme runtime terjadi saat program berjalan, berdasarkan tipe asli object, bukan tipe variabel.',
       'Hewan[] daftar = { new Kucing(), new Anjing() };
for (Hewan h : daftar) {
  h.bersuara();
}'
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Class Bentuk',
       'Satu variabel bertipe Bentuk dapat menunjuk object Lingkaran maupun Persegi, dan method luas dipanggil sesuai objectnya.',
       'class Bentuk {
  double luas() {
    return 0;
  }
}

class Lingkaran extends Bentuk {
  @Override
  double luas() {
    return 3.14 * 25;
  }
}'
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami polimorfisme dan perbedaan antara overloading dengan overriding. Selanjutnya, kamu akan menyusun program polimorfisme dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 16: EXERCISES LEVEL 43 — Polymorphism (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun overloading',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Kalkulator"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int"},
           {"id": "t5", "text": "tambah(int a, int b)"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "return a + b;"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "int"},
           {"id": "t10", "text": "tambah(int a, int b, int c)"},
           {"id": "t11", "text": "{"},
           {"id": "t12", "text": "return a + b + c;"},
           {"id": "t13", "text": "}"},
           {"id": "t14", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun overloading'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun overriding',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Anjing"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Hewan"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "@Override"},
           {"id": "t7", "text": "void"},
           {"id": "t8", "text": "bersuara()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "System.out.println(\"Guk\");"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun overriding'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun array of objek',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Hewan[] daftar = new Hewan[2];"},
           {"id": "t7", "text": "daftar[0] = new Kucing();"},
           {"id": "t8", "text": "daftar[1] = new Anjing();"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun array of objek'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun dispatch runtime',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Hewan[] daftar = new Hewan[2];"},
           {"id": "t7", "text": "daftar[0] = new Kucing();"},
           {"id": "t8", "text": "for (Hewan h : daftar) {"},
           {"id": "t9", "text": "h.bersuara();"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun dispatch runtime'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun polimorfisme lengkap',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Bentuk b = new Lingkaran();"},
           {"id": "t7", "text": "System.out.println(b.luas());"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun polimorfisme lengkap'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 17: MATERIALS LEVEL 44 — Abstract Class
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Abstract Class',
       'Abstract class adalah class yang tidak bisa dibuat object-nya, tetapi bisa menjadi induk class lain.',
       'abstract class Bentuk {
  abstract double luas();
}'
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Keyword Abstract',
       'Class abstrak ditandai keyword abstract dan minimal memiliki satu method abstrak yang belum diisi.',
       'abstract class Bangun {
  abstract double volume();
}'
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Method Abstrak',
       'Method abstrak hanya berupa deklarasi tanpa isi, dan wajib diimplementasikan oleh class turunannya.',
       'abstract double luas();

class Lingkaran extends Bentuk {
  @Override
  double luas() {
    return 3.14 * 25;
  }
}'
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Class Bangun',
       'Class Bangun abstrak memaksa setiap bangun mengimplementasikan method volume sehingga perilakunya seragam.',
       'abstract class Bangun {
  abstract double volume();

  void info() {
    System.out.println("Volume: " + volume());
  }
}'
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami abstract class dan method abstrak. Selanjutnya, kamu akan menyusun class abstrak beserta turunannya dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 18: EXERCISES LEVEL 44 — Abstract Class (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun abstract class',
       $json${
         "tokens": [
           {"id": "t1", "text": "abstract"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Bentuk"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "abstract"},
           {"id": "t6", "text": "double"},
           {"id": "t7", "text": "luas();"},
           {"id": "t8", "text": "void"},
           {"id": "t9", "text": "info()"},
           {"id": "t10", "text": "{"},
           {"id": "t11", "text": "System.out.println(\"Bentuk\");"},
           {"id": "t12", "text": "}"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun abstract class'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun method abstrak',
       $json${
         "tokens": [
           {"id": "t1", "text": "abstract"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Bangun"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "abstract"},
           {"id": "t6", "text": "double"},
           {"id": "t7", "text": "volume();"},
           {"id": "t8", "text": "abstract"},
           {"id": "t9", "text": "double"},
           {"id": "t10", "text": "luas();"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun method abstrak'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun implementasi method abstrak',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Kubus"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Bangun"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "@Override"},
           {"id": "t7", "text": "double"},
           {"id": "t8", "text": "volume()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "return 125;"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun implementasi method abstrak'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun abstract dengan super',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Kubus"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Bangun"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "@Override"},
           {"id": "t7", "text": "double"},
           {"id": "t8", "text": "volume()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "return 125;"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "void"},
           {"id": "t13", "text": "info()"},
           {"id": "t14", "text": "{"},
           {"id": "t15", "text": "super.info();"},
           {"id": "t16", "text": "}"},
           {"id": "t17", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14", "t15", "t16", "t17"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun abstract dengan super'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun abstract plus subclass',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Persegi"},
           {"id": "t3", "text": "extends"},
           {"id": "t4", "text": "Bentuk"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "@Override"},
           {"id": "t7", "text": "double"},
           {"id": "t8", "text": "luas()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "return 16;"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun abstract plus subclass'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 19: MATERIALS LEVEL 45 — Interface
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Interface',
       'Interface (antarmuka) adalah kontrak perilaku: isinya hanya method abstrak yang wajib diimplementasikan oleh class yang menerimanya.',
       'interface Cetak {
  void cetak();
}'
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Keyword Implements',
       'Class menyatakan hubungan dengan keyword implements, lalu mengisi semua method dari interface tersebut.',
       'class Laporan implements Cetak {
  public void cetak() {
    System.out.println("Mencetak laporan");
  }
}'
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Banyak Interface',
       'Satu class dapat mengimplementasikan lebih dari satu interface, sehingga perilakunya bisa digabungkan.',
       'class Laporan implements Cetak, Kirim {
  // isi kedua method
}'
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Interface Plugin',
       'Interface plugin memungkinkan fitur tambahan ditambahkan tanpa mengubah kode class yang sudah ada.',
       'interface Plugin {
  String nama();
}

class PluginHalo implements Plugin {
  public String nama() {
    return "Halo";
  }
}'
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami interface dan keyword implements. Selanjutnya, kamu akan menyusun interface beserta implementasinya dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 20: EXERCISES LEVEL 45 — Interface (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi interface',
       $json${
         "tokens": [
           {"id": "t1", "text": "interface"},
           {"id": "t2", "text": "Cetak"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "void"},
           {"id": "t5", "text": "cetak();"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "interface"},
           {"id": "t8", "text": "Kirim"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "void"},
           {"id": "t11", "text": "kirim();"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi interface'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun implements',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Laporan"},
           {"id": "t3", "text": "implements"},
           {"id": "t4", "text": "Cetak"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "public void"},
           {"id": "t7", "text": "cetak()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "System.out.println(\"Mencetak\");"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun implements'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun banyak interface',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Laporan"},
           {"id": "t3", "text": "implements"},
           {"id": "t4", "text": "Cetak, Kirim"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "public void"},
           {"id": "t7", "text": "cetak()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "System.out.println(\"Mencetak\");"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "public void"},
           {"id": "t12", "text": "kirim()"},
           {"id": "t13", "text": "{"},
           {"id": "t14", "text": "System.out.println(\"Mengirim\");"},
           {"id": "t15", "text": "}"},
           {"id": "t16", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14", "t15", "t16"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun banyak interface'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun default method',
       $json${
         "tokens": [
           {"id": "t1", "text": "interface"},
           {"id": "t2", "text": "Cetak"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "void"},
           {"id": "t5", "text": "cetak();"},
           {"id": "t6", "text": "default void"},
           {"id": "t7", "text": "info()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "System.out.println(\"Info\");"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun default method'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun interface lengkap',
       $json${
         "tokens": [
           {"id": "t1", "text": "interface"},
           {"id": "t2", "text": "Plugin"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "String"},
           {"id": "t5", "text": "nama();"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "class"},
           {"id": "t8", "text": "PluginHalo"},
           {"id": "t9", "text": "implements"},
           {"id": "t10", "text": "Plugin"},
           {"id": "t11", "text": "{"},
           {"id": "t12", "text": "public String"},
           {"id": "t13", "text": "nama()"},
           {"id": "t14", "text": "{"},
           {"id": "t15", "text": "return \"Halo\";"},
           {"id": "t16", "text": "}"},
           {"id": "t17", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14", "t15", "t16", "t17"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun interface lengkap'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 21: MATERIALS LEVEL 46 — ArrayList
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Struktur Data',
       'Struktur data (data structure) menyimpan dan mengatur data agar bisa diakses dengan cara yang rapi dan efisien.',
       'import java.util.ArrayList;

ArrayList<String> nama = new ArrayList<>();'
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Membuat ArrayList',
       'ArrayList dibuat dengan new ArrayList<>() dan menyimpan kumpulan objek dengan tipe yang sama.',
       'ArrayList<Integer> nilai = new ArrayList<>();
nilai.add(80);
nilai.add(90);'
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Menambah dan Menghapus',
       'Method add menambah elemen di akhir, remove menghapus berdasarkan indeks, dan size memberi tahu jumlah elemen.',
       'nilai.add(85);
nilai.remove(0);
int jumlah = nilai.size();'
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Daftar Nilai',
       'Daftar nilai memakai ArrayList agar jumlah data bisa bertambah tanpa harus menentukan ukuran sejak awal.',
       'ArrayList<Double> ipk = new ArrayList<>();
ipk.add(3.75);
ipk.add(3.50);

for (double nilai : ipk) {
  System.out.println(nilai);
}'
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami ArrayList sebagai struktur data dinamis. Selanjutnya, kamu akan menyusun operasi pada ArrayList dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 22: EXERCISES LEVEL 46 — ArrayList (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun buat ArrayList',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.ArrayList;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "ArrayList<String> nama = new ArrayList<>();"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun buat ArrayList'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun add element',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.ArrayList;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "ArrayList<Integer> nilai = new ArrayList<>();"},
           {"id": "t7", "text": "nilai.add(80);"},
           {"id": "t8", "text": "nilai.add(90);"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun add element'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun get dan set',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.ArrayList;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "ArrayList<String> nama = new ArrayList<>();"},
           {"id": "t7", "text": "nama.add(\"Budi\");"},
           {"id": "t8", "text": "String pertama = nama.get(0);"},
           {"id": "t9", "text": "nama.set(0, \"Sari\");"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun get dan set'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun remove dan size',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.ArrayList;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "ArrayList<Integer> nilai = new ArrayList<>();"},
           {"id": "t7", "text": "nilai.add(80);"},
           {"id": "t8", "text": "nilai.add(90);"},
           {"id": "t9", "text": "nilai.remove(0);"},
           {"id": "t10", "text": "int jumlah = nilai.size();"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun remove dan size'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun iterasi ArrayList',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.ArrayList;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "ArrayList<Integer> nilai = new ArrayList<>();"},
           {"id": "t7", "text": "nilai.add(80);"},
           {"id": "t8", "text": "for (int n : nilai) {"},
           {"id": "t9", "text": "System.out.println(n);"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun iterasi ArrayList'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 23: MATERIALS LEVEL 47 — Stack
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Stack',
       'Stack (tumpukan) adalah struktur data berurutan yang bekerja dengan prinsip LIFO, yaitu elemen terakhir yang dimasukkan akan keluar pertama.',
       'import java.util.Stack;

Stack<String> tumpukan = new Stack<>();'
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Push dan Pop',
       'Method push menambahkan elemen ke puncak stack, sedangkan pop mengambil dan menghapus elemen paling atas.',
       'tumpukan.push("A");
tumpukan.push("B");
String top = tumpukan.pop();'
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Peek dan Empty',
       'Method peek melihat elemen puncak tanpa menghapusnya, dan empty memeriksa apakah stack masih kosong.',
       'if (!tumpukan.empty()) {
  System.out.println(tumpukan.peek());
}'
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Tumpukan Buku',
       'Stack dipakai untuk menyimpan urutan pembatalan, misalnya membatalkan aksi terakhir yang dilakukan pengguna.',
       'Stack<String> buku = new Stack<>();
buku.push("Novel");
buku.push("Komik");

while (!buku.empty()) {
  System.out.println(buku.pop());
}'
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami stack dan operasi push, pop, peek, serta empty. Selanjutnya, kamu akan menyusun program stack dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 24: EXERCISES LEVEL 47 — Stack (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun push',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.Stack;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "Stack<String> tumpukan = new Stack<>();"},
           {"id": "t7", "text": "tumpukan.push(\"A\");"},
           {"id": "t8", "text": "tumpukan.push(\"B\");"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun push'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pop',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.Stack;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "Stack<String> tumpukan = new Stack<>();"},
           {"id": "t7", "text": "tumpukan.push(\"A\");"},
           {"id": "t8", "text": "tumpukan.push(\"B\");"},
           {"id": "t9", "text": "String atas = tumpukan.pop();"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pop'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun peek',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.Stack;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "Stack<String> tumpukan = new Stack<>();"},
           {"id": "t7", "text": "tumpukan.push(\"A\");"},
           {"id": "t8", "text": "String lihat = tumpukan.peek();"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun peek'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun isEmpty',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.Stack;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "Stack<String> tumpukan = new Stack<>();"},
           {"id": "t7", "text": "tumpukan.push(\"A\");"},
           {"id": "t8", "text": "if (tumpukan.empty()) {"},
           {"id": "t9", "text": "System.out.println(\"Kosong\");"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun isEmpty'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun stack fitur undo',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.Stack;"},
           {"id": "t2", "text": "public"},
           {"id": "t3", "text": "class"},
           {"id": "t4", "text": "Main"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "Stack<String> undo = new Stack<>();"},
           {"id": "t7", "text": "undo.push(\"Ketik\");"},
           {"id": "t8", "text": "undo.push(\"Hapus\");"},
           {"id": "t9", "text": "String aksi = undo.pop();"},
           {"id": "t10", "text": "System.out.println(aksi);"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun stack fitur undo'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 25: MATERIALS LEVEL 48 — Queue
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Queue',
       'Queue (antrean) adalah struktur data berurutan dengan prinsip FIFO, yaitu elemen pertama yang dimasukkan akan keluar pertama.',
       'import java.util.LinkedList;
import java.util.Queue;

Queue<String> antrean = new LinkedList<>();'
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Add dan Poll',
       'Method add memasukkan elemen ke bagian belakang antrean, sedangkan poll mengambil dan menghapus elemen paling depan.',
       'antrean.add("A");
antrean.add("B");
String depan = antrean.poll();'
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'FIFO dan LIFO',
       'Queue memakai FIFO untuk antrean, sedangkan stack memakai LIFO. Perbedaannya terlihat pada urutan elemen yang dikeluarkan.',
       '// FIFO: A, B, C
// LIFO: C, B, A'
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Antrean Pesanan',
       'Queue dipakai untuk memproses pesanan sesuai urutan masuknya.',
       'Queue<String> pesanan = new LinkedList<>();
pesanan.add("Pesanan 1");
pesanan.add("Pesanan 2");

while (!pesanan.isEmpty()) {
  System.out.println(pesanan.poll());
}'
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami queue dan prinsip FIFO. Selanjutnya, kamu akan menyusun program antrean dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 26: EXERCISES LEVEL 48 — Queue (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun queue add',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.LinkedList;"},
           {"id": "t2", "text": "import java.util.Queue;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Queue<String> antrean = new LinkedList<>();"},
           {"id": "t8", "text": "antrean.add(\"A\");"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun queue add'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun queue poll',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.LinkedList;"},
           {"id": "t2", "text": "import java.util.Queue;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Queue<String> antrean = new LinkedList<>();"},
           {"id": "t8", "text": "antrean.add(\"A\");"},
           {"id": "t9", "text": "antrean.add(\"B\");"},
           {"id": "t10", "text": "String depan = antrean.poll();"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun queue poll'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun peek queue',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.LinkedList;"},
           {"id": "t2", "text": "import java.util.Queue;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Queue<String> antrean = new LinkedList<>();"},
           {"id": "t8", "text": "antrean.add(\"A\");"},
           {"id": "t9", "text": "antrean.add(\"B\");"},
           {"id": "t10", "text": "String lihat = antrean.peek();"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun peek queue'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun antrean pesanan',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.LinkedList;"},
           {"id": "t2", "text": "import java.util.Queue;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Queue<String> pesanan = new LinkedList<>();"},
           {"id": "t8", "text": "pesanan.add(\"Pesanan 1\");"},
           {"id": "t9", "text": "pesanan.add(\"Pesanan 2\");"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun antrean pesanan'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun queue dengan loop',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.LinkedList;"},
           {"id": "t2", "text": "import java.util.Queue;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Queue<String> antrean = new LinkedList<>();"},
           {"id": "t8", "text": "antrean.add(\"A\");"},
           {"id": "t9", "text": "while (!antrean.isEmpty()) {"},
           {"id": "t10", "text": "System.out.println(antrean.poll());"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun queue dengan loop'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 27: MATERIALS LEVEL 49 — Linked List
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Linked List',
       'Linked list (daftar berantai) menyimpan elemen dalam node yang saling terhubung lewat penunjuk next.',
       'class Node {
  int data;
  Node next;
}'
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Node dan Next',
       'Setiap node menyimpan data dan referensi ke node berikutnya. Node terakhir memiliki next bernilai null.',
       'node1.next = node2;
node2.next = null;'
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Menambah di Akhir',
       'Untuk menambahkan node di akhir, telusuri daftar sampai node terakhir lalu sambungkan next-nya.',
       'Node temp = head;
while (temp.next != null) {
  temp = temp.next;
}
temp.next = nodeBaru;'
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Daftar Node',
       'Daftar node dipakai untuk membuat struktur data berantai sendiri tanpa bergantung pada kelas bawaan Java.',
       'class LinkedList {
  Node head;

  void tambah(Node baru) {
    if (head == null) {
      head = baru;
      return;
    }
    Node temp = head;
    while (temp.next != null) {
      temp = temp.next;
    }
    temp.next = baru;
  }
}'
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami struktur node dan penyusunan daftar berantai. Selanjutnya, kamu akan menyusun linked list dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 28: EXERCISES LEVEL 49 — Linked List (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun class node',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "Node"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int data;"},
           {"id": "t5", "text": "Node next;"},
           {"id": "t6", "text": "Node(int data)"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "this.data = data;"},
           {"id": "t9", "text": "this.next = null;"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun class node'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun tambah node',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Node node1 = new Node(1);"},
           {"id": "t7", "text": "Node node2 = new Node(2);"},
           {"id": "t8", "text": "node1.next = node2;"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun tambah node'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun traversal node',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Node node1 = new Node(1);"},
           {"id": "t7", "text": "Node node2 = new Node(2);"},
           {"id": "t8", "text": "node1.next = node2;"},
           {"id": "t9", "text": "Node temp = node1;"},
           {"id": "t10", "text": "while (temp != null) {"},
           {"id": "t11", "text": "System.out.println(temp.data);"},
           {"id": "t12", "text": "temp = temp.next;"},
           {"id": "t13", "text": "}"},
           {"id": "t14", "text": "}"},
           {"id": "t15", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14", "t15"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun traversal node'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun insert di tengah',
       $json${
         "tokens": [
           {"id": "t1", "text": "public"},
           {"id": "t2", "text": "class"},
           {"id": "t3", "text": "Main"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "public static void main(String[] args) {"},
           {"id": "t6", "text": "Node node1 = new Node(1);"},
           {"id": "t7", "text": "Node node2 = new Node(2);"},
           {"id": "t8", "text": "Node tengah = new Node(9);"},
           {"id": "t9", "text": "node1.next = tengah;"},
           {"id": "t10", "text": "tengah.next = node2;"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun insert di tengah'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun helper linked list',
       $json${
         "tokens": [
           {"id": "t1", "text": "class"},
           {"id": "t2", "text": "LinkedList"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "Node head;"},
           {"id": "t5", "text": "Node"},
           {"id": "t6", "text": "ekor(Node node)"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "if (node.next == null) return node;"},
           {"id": "t9", "text": "return ekor(node.next);"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun helper linked list'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 29: MATERIALS LEVEL 50 — HashMap
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan HashMap',
       'HashMap menyimpan pasangan kunci dan nilai, sehingga data bisa diambil langsung berdasarkan kuncinya.',
       'import java.util.HashMap;
import java.util.Map;

Map<String, Integer> nilai = new HashMap<>();'
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Put dan Get',
       'Method put menyimpan nilai untuk sebuah kunci, sedangkan get mengambil nilai berdasarkan kunci tersebut.',
       'nilai.put("Budi", 85);
int angka = nilai.get("Budi");'
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Kunci dan Nilai',
       'Kunci pada HashMap harus unik dan tipenya tidak boleh diubah, sedangkan nilai boleh bertipe bebas.',
       'nilai.put("Sari", 90);
nilai.put("Budi", 85);
nilai.put("Budi", 88);'
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Indeks NIM',
       'HashMap dipakai untuk menyimpan data mahasiswa berdasarkan NIM agar mudah dicari.',
       'Map<String, String> mahasiswa = new HashMap<>();
mahasiswa.put("22101", "Budi");
mahasiswa.put("22102", "Sari");

System.out.println(mahasiswa.get("22101"));'
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami HashMap sebagai penyimpanan pasangan kunci dan nilai. Selanjutnya, kamu akan menyusun operasi pada HashMap dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 30: EXERCISES LEVEL 50 — HashMap (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun buat map',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.HashMap;"},
           {"id": "t2", "text": "import java.util.Map;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Map<String, Integer> nilai = new HashMap<>();"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun buat map'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun put',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.HashMap;"},
           {"id": "t2", "text": "import java.util.Map;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Map<String, Integer> nilai = new HashMap<>();"},
           {"id": "t8", "text": "nilai.put(\"Budi\", 85);"},
           {"id": "t9", "text": "nilai.put(\"Sari\", 90);"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun put'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun get',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.HashMap;"},
           {"id": "t2", "text": "import java.util.Map;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Map<String, Integer> nilai = new HashMap<>();"},
           {"id": "t8", "text": "nilai.put(\"Budi\", 85);"},
           {"id": "t9", "text": "int angka = nilai.get(\"Budi\");"},
           {"id": "t10", "text": "System.out.println(angka);"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun get'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun containsKey',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.HashMap;"},
           {"id": "t2", "text": "import java.util.Map;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Map<String, Integer> nilai = new HashMap<>();"},
           {"id": "t8", "text": "nilai.put(\"Budi\", 85);"},
           {"id": "t9", "text": "boolean ada = nilai.containsKey(\"Budi\");"},
           {"id": "t10", "text": "System.out.println(ada);"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun containsKey'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun map dengan loop',
       $json${
         "tokens": [
           {"id": "t1", "text": "import java.util.HashMap;"},
           {"id": "t2", "text": "import java.util.Map;"},
           {"id": "t3", "text": "public"},
           {"id": "t4", "text": "class"},
           {"id": "t5", "text": "Main"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "Map<String, Integer> nilai = new HashMap<>();"},
           {"id": "t8", "text": "nilai.put(\"Budi\", 85);"},
           {"id": "t9", "text": "for (String kunci : nilai.keySet()) {"},
           {"id": "t10", "text": "System.out.println(kunci + \" = \" + nilai.get(kunci));"},
           {"id": "t11", "text": "}"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun map dengan loop'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 31: VERIFICATION (relatif per level)
-- ============================================
-- Level 36-50: 5 material + 5 exercise dari file ini
-- Verifikasi memakai jumlah per level, bukan total absolut, agar file ini
-- aman dijalankan berdampingan dengan seed.sql dan chunk lain.

DO $$
DECLARE
  v_level INT;
  v_mat INT;
  v_ex INT;
BEGIN
  FOR v_level IN
    SELECT unnest(ARRAY[36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50])
  LOOP
    SELECT count(*) INTO v_mat
    FROM public.materials m
    JOIN public.levels l ON l.id = m.level_id
    WHERE l.level_number = v_level AND l.language = 'java';

    IF v_mat <> 5 THEN
      RAISE EXCEPTION 'Chunk 4 verify: level % expected 5 materials, got %', v_level, v_mat;
    END IF;

    SELECT count(*) INTO v_ex
    FROM public.exercises e
    JOIN public.levels l ON l.id = e.level_id
    WHERE l.level_number = v_level AND l.language = 'java'
      AND e.type = 'drag_drop';

    IF v_ex <> 5 THEN
      RAISE EXCEPTION 'Chunk 4 verify: level % expected 5 exercises, got %', v_level, v_ex;
    END IF;
  END LOOP;
END
$$;

COMMIT;
