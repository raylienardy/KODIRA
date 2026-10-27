-- KODIRA — Seed Chunk 1 (C++ Level 2 exercises, Level 4-15 materials + exercises)
-- Tanggal: 2026-10-20
--
-- Tujuan:
--   1. Exercises drag_drop untuk Level 2 (Variabel & Konstanta) — 5 exercise
--   2. Materials Level 1 (5 slide) dan Level 4-15 (12 level x 5 slide = 60 slide)
--   3. Exercises drag_drop Level 4-15 (12 level x 5 exercise = 60 exercise)
--
-- File ini adalah CHUNK 1 dari 4 file seed:
--   1. seed-cpp-01.sql  (file ini) — L2 exercises, L4-15
--   2. seed-cpp-02.sql             — L16-25
--   3. seed-cpp-03.sql             — L26-35
--   4. seed-java-01.sql             — L36-50
--   File seed.sql (L1-3) tetap dipertahankan; file ini menambah materi L1.
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/seed-cpp-01.sql
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
--     "language": "cpp"
--   }
--
-- Aturan token (divalidasi di app/lib/features/exercise/screens/drag_drop_screen.dart):
--   - panjang answer harus sama dengan jumlah tokens
--   - id token unik dan tidak boleh kosong
--   - text token tidak boleh kosong
--   - semua id pada answer harus menunjuk token yang ada
--   - susunan token sesuai answer menghasilkan kode C++ yang valid secara sintaks
--
-- Verifikasi di akhir memakai DO block RELATIF per level (5 material + 5 exercise),
-- bukan angka absolut, sehingga file ini aman dijalankan berdampingan dengan chunk lain.

BEGIN;

-- ============================================
-- SECTION 1: EXERCISES LEVEL 2 — Variabel & Konstanta (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi variabel integer',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "umur"},
           {"id": "t3", "text": "= 20"},
           {"id": "t4", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi variabel integer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi konstanta',
       $json${
         "tokens": [
           {"id": "t1", "text": "const"},
           {"id": "t2", "text": "int"},
           {"id": "t3", "text": "MAX"},
           {"id": "t4", "text": "= 100"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi konstanta'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi dan assignment',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "10"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi dan assignment'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun dua variabel',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "x"},
           {"id": "t3", "text": "= 5;"},
           {"id": "t4", "text": "int"},
           {"id": "t5", "text": "y"},
           {"id": "t6", "text": "= 10;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun dua variabel'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun konstanta dan variabel',
       $json${
         "tokens": [
           {"id": "t1", "text": "const"},
           {"id": "t2", "text": "int"},
           {"id": "t3", "text": "MAX"},
           {"id": "t4", "text": "= 100;"},
           {"id": "t5", "text": "int nilai"},
           {"id": "t6", "text": "= 80;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun konstanta dan variabel'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 2A: MATERIALS LEVEL 1 — Pengenalan C++
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Apa Itu C++',
       'C++ adalah bahasa pemrograman yang digunakan untuk membuat berbagai program. Program ditulis sebagai instruksi yang kemudian diterjemahkan oleh compiler.',
       NULL
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Struktur Dasar Program',
       'Program C++ umumnya memiliki fungsi main sebagai titik awal eksekusi. Instruksi program ditulis di antara kurung kurawal fungsi tersebut.',
       'int main() {
  return 0;
}'
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Menampilkan Teks',
       'Untuk menampilkan teks ke terminal, C++ menyediakan cout dari pustaka iostream. Operator << mengirimkan nilai ke keluaran.',
       '#include <iostream>

int main() {
  std::cout << "Halo, C++!";
  return 0;
}'
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Komentar dalam Kode',
       'Komentar membantu menjelaskan kode dan tidak dijalankan oleh program. Komentar satu baris diawali dengan dua garis miring.',
       '// Program pertama
std::cout << "Halo!";'
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Siap Berlatih',
       'Kamu sudah mengenal struktur program C++ dan cara menampilkan teks. Lanjutkan dengan latihan menyusun kode dan kuis singkat.',
       NULL
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 3: MATERIALS LEVEL 4 — Operator Aritmatika
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Operator Aritmatika',
       'Operator aritmatika dipakai untuk melakukan perhitungan matematika, seperti menjumlahkan, mengurangi, mengalikan, dan membagi dua nilai.',
       'int a = 10;
int b = 3;
int hasil = a + b;'
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Penjumlahan dan Pengurangan',
       'Tanda + menjumlahkan dua nilai, sedangkan tanda - menguranginya. Kedua operator ini bekerja pada tipe data numerik seperti int dan double.',
       'int jumlah = 5 + 3;
int selisih = 5 - 3;'
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Perkalian dan Pembagian',
       'Tanda * dipakai untuk perkalian dan tanda / untuk pembagian. Pembagian dua bilangan bulat menghasilkan bagian bulat tanpa sisa.',
       'int kali = 5 * 3;
int bagi = 10 / 3;'
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Modulo dan Prioritas Operator',
       'Operator % menghasilkan sisa dari pembagian. Prioritas operator membuat perkalian dan pembagian dihitung lebih dulu daripada penjumlahan.',
       'int sisa = 10 % 3;
int hasil = 2 + 3 * 4;'
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami operator aritmetika dasar. Selanjutnya, kamu akan menyusun operasi aritmetika dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 3: EXERCISES LEVEL 4 — Operator Aritmatika (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun operasi penjumlahan',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "hasil"},
           {"id": "t3", "text": "= 5 + 3"},
           {"id": "t4", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun operasi penjumlahan'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun operasi pengurangan',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "selisih"},
           {"id": "t3", "text": "= 9 - 4"},
           {"id": "t4", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun operasi pengurangan'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun operasi perkalian',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "kali"},
           {"id": "t3", "text": "= 6 * 7"},
           {"id": "t4", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun operasi perkalian'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun operasi pembagian',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "bagi"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "20 / 4"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun operasi pembagian'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun operasi modulo',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "sisa"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "17 % 5"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun operasi modulo'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 4: MATERIALS LEVEL 5 — Operator Logika
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Operator Logika',
       'Operator logika menggabungkan beberapa kondisi menjadi satu nilai true atau false. C++ menyediakan operator &&, ||, dan !.',
       'bool lulus = (nilai >= 80) && (nilai <= 100);'
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Operator AND',
       'Operator && bernilai true hanya jika kondisi di kiri dan kondisi di kanan sama-sama bernilai true.',
       'bool lulus = nilai >= 80 && nilai <= 100;'
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Operator OR',
       'Operator || bernilai true jika salah satu saja dari kedua kondisi bernilai true. Ini berguna saat ada syarat alternatif.',
       'bool akhir = absen > 3 || nilai >= 70;'
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Operator NOT dan Perbandingan',
       'Operator ! membalik nilai boolean, sedangkan operator ==, !=, <, >, <=, dan >= dipakai untuk membandingkan dua nilai.',
       'bool belum = !(nilai >= 80);'
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami operator logika dan cara menggabungkan beberapa kondisi. Selanjutnya, kamu akan menyusun kondisi majemuk dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 5: EXERCISES LEVEL 5 — Operator Logika (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun kondisi AND',
       $json${
         "tokens": [
           {"id": "t1", "text": "bool"},
           {"id": "t2", "text": "lulus"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "(nilai >= 80) && (nilai <= 100)"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun kondisi AND'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun kondisi OR',
       $json${
         "tokens": [
           {"id": "t1", "text": "bool"},
           {"id": "t2", "text": "perlu"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "(nilai < 60) || (absen > 3)"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun kondisi OR'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun negasi NOT',
       $json${
         "tokens": [
           {"id": "t1", "text": "bool"},
           {"id": "t2", "text": "gagal"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "!(nilai >= 70)"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun negasi NOT'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun kombinasi AND dan OR',
       $json${
         "tokens": [
           {"id": "t1", "text": "bool"},
           {"id": "t2", "text": "lolos"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "(nilai >= 80) && (nilai <= 100)"},
           {"id": "t5", "text": "|| absen > 3"},
           {"id": "t6", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun kombinasi AND dan OR'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun validasi lengkap',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 60 && absen <= 3)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Lulus\";"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun validasi lengkap'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 6: MATERIALS LEVEL 6 — If Sederhana
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Percabangan',
       'Percabangan membuat program memilih tindakan berdasarkan kondisi. Blok if hanya dijalankan ketika kondisi bernilai true.',
       'int nilai = 85;
if (nilai >= 70) {
  cout << "Lulus";
}'
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Syntax If',
       'Syntax if diikuti kondisi di dalam kurung. Saat kondisi bernilai false, seluruh blok di dalam kurung dilewati.',
       'if (nilai > 90)
  cout << "Excellent";'
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Blok Kode If',
       'Gunakan kurung kurawal agar aman ketika blok berisi lebih dari satu statement.',
       'if (nilai > 90) {
  cout << "Excellent";
  cout << endl;
}'
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Memeriksa Nilai Lulus',
       'Periksa nilai di dalam if lalu cetak pesan yang sesuai. Nilai yang tidak memenuhi syarat akan melewati seluruh blok.',
       'int nilai = 55;
if (nilai >= 70) {
  cout << "Lulus";
}
cout << "Nilai kamu: " << nilai;'
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami cara memakai if agar kode hanya berjalan saat kondisi terpenuhi. Selanjutnya, kamu akan menyusun percabangan sederhana dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 7: EXERCISES LEVEL 6 — If Sederhana (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if sederhana',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai > 0)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if sederhana'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if kondisi nilai',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 70)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Lulus\";"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if kondisi nilai'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if dua baris',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai > 90)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Excellent\";"},
           {"id": "t5", "text": "cout << endl;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if dua baris'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if dengan kurung kurawal',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai > 0)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout"},
           {"id": "t5", "text": "<< \"Positif\";"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if dengan kurung kurawal'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if kondisi gabungan',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 60 && absen <= 3)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Lulus\";"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if kondisi gabungan'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 8: MATERIALS LEVEL 7 — If-Else
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Konsep If dan Else',
       'Blok if dijalankan saat kondisi true, sedangkan blok else dijalankan saat kondisi false. Keduanya tidak berjalan bersamaan.',
       'if (nilai >= 70) {
  cout << "Lulus";
} else {
  cout << "Tidak Lulus";
}'
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Syntax If-Else',
       'Tulis else tepat setelah blok if. Kondisi pada else tidak perlu diulang karena sudah diketahui bernilai false.',
       'if (nilai > 50)
  cout << "Baik";
else
  cout << "Perlu Improvement";'
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Dua Cabang Kondisi',
       'If-else memastikan program tetap berjalan untuk salah satu dari dua kondisi yang berbeda.',
       'if (absen <= 3)
  cout << "Hadir";
else
  cout << "Alpa";'
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Menentukan Status Lulus',
       'Gunakan if-else untuk menampilkan status lulus berdasarkan nilai. Perhatikan bahwa hanya satu cabang yang dieksekusi.',
       'int nilai = 85;
if (nilai >= 70) {
  cout << "Lulus";
} else {
  cout << "Tidak Lulus";
}'
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah paham memakai if-else untuk dua cabang kondisi. Selanjutnya, kamu akan menyusun percabangan dua arah dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 9: EXERCISES LEVEL 7 — If-Else (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if-else status lulus',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 70) {"},
           {"id": "t3", "text": "cout << \"Lulus\";"},
           {"id": "t4", "text": "} else {"},
           {"id": "t5", "text": "cout << \"Tidak Lulus\";"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if-else status lulus'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if-else nilai',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai > 50) {"},
           {"id": "t3", "text": "cout << \"Baik\";"},
           {"id": "t4", "text": "} else {"},
           {"id": "t5", "text": "cout << \"Perlu Improvement\";"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if-else nilai'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if-else angka genap',
       $json${
         "tokens": [
           {"id": "t1", "text": "int nilai = 4;"},
           {"id": "t2", "text": "if"},
           {"id": "t3", "text": "(nilai % 2 == 0) {"},
           {"id": "t4", "text": "cout << \"Genap\";"},
           {"id": "t5", "text": "} else {"},
           {"id": "t6", "text": "cout << \"Ganjil\";"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if-else angka genap'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if-else-if',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 80) {"},
           {"id": "t3", "text": "cout << \"A\";"},
           {"id": "t4", "text": "} else if"},
           {"id": "t5", "text": "(nilai >= 60) {"},
           {"id": "t6", "text": "cout << \"B\";"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if-else-if'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun if-else lengkap',
       $json${
         "tokens": [
           {"id": "t1", "text": "int nilai = 72;"},
           {"id": "t2", "text": "if"},
           {"id": "t3", "text": "(nilai >= 70) {"},
           {"id": "t4", "text": "cout << \"Lulus\";"},
           {"id": "t5", "text": "} else {"},
           {"id": "t6", "text": "cout << \"Tidak Lulus\";"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun if-else lengkap'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 10: MATERIALS LEVEL 8 — Nested If
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Nested If',
       'Nested if adalah if yang diletakkan di dalam blok if lain. Cara ini dipakai saat ada dua kondisi yang harus diperiksa berurutan.',
       'if (nilai >= 60) {
  if (nilai >= 80) {
    cout << "Sangat Baik";
  }
}'
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Struktur If di Dalam If',
       'Kondisi kedua hanya diperiksa ketika kondisi pertama bernilai true. Ini membuat pengecekan lebih hemat dan alurnya jelas.',
       'if (nilai >= 60) {
  if (absen <= 3) {
    cout << "Lulus";
  }
}'
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Indentasi dan Alur Program',
       'Gunakan indentasi yang konsisten agar alur nested if mudah dibaca. Setiap kurung kurawal yang dibuka harus ditutup.',
       'if (a > 0) {
  if (b > 0) {
    cout << "Keduanya positif";
  }
}'
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Rentang Nilai',
       'Contoh berikut memeriksa apakah nilai berada di rentang 80 sampai 100 dengan dua kondisi yang saling melengkapi.',
       'if (nilai >= 80) {
  if (nilai <= 100) {
    cout << "Nilai valid";
  }
}'
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah paham menggabungkan dua kondisi dengan nested if. Selanjutnya, kamu akan menyusun percabangan bertingkat dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 11: EXERCISES LEVEL 8 — Nested If (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nested if dua level',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 60) {"},
           {"id": "t3", "text": "if"},
           {"id": "t4", "text": "(nilai >= 80) {"},
           {"id": "t5", "text": "cout << \"Sangat Baik\";"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nested if dua level'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nested if rentang nilai',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 80) {"},
           {"id": "t3", "text": "if"},
           {"id": "t4", "text": "(nilai <= 100) {"},
           {"id": "t5", "text": "cout << \"Nilai valid\";"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nested if rentang nilai'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nested if batas minimum',
       $json${
         "tokens": [
           {"id": "t1", "text": "int nilai = 75;"},
           {"id": "t2", "text": "if"},
           {"id": "t3", "text": "(nilai >= 60) {"},
           {"id": "t4", "text": "if"},
           {"id": "t5", "text": "(absen <= 3) {"},
           {"id": "t6", "text": "cout << \"Lulus\";"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nested if batas minimum'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nested if nilai dan semester',
       $json${
         "tokens": [
           {"id": "t1", "text": "int semester = 3;"},
           {"id": "t2", "text": "int nilai = 78;"},
           {"id": "t3", "text": "if"},
           {"id": "t4", "text": "(semester >= 3) {"},
           {"id": "t5", "text": "if"},
           {"id": "t6", "text": "(nilai >= 75) {"},
           {"id": "t7", "text": "cout << \"Lulus\";"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nested if nilai dan semester'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nested if lengkap',
       $json${
         "tokens": [
           {"id": "t1", "text": "if"},
           {"id": "t2", "text": "(nilai >= 60) {"},
           {"id": "t3", "text": "if"},
           {"id": "t4", "text": "(nilai >= 80) {"},
           {"id": "t5", "text": "cout << \"A\";"},
           {"id": "t6", "text": "} else {"},
           {"id": "t7", "text": "cout << \"B\";"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nested if lengkap'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 12: MATERIALS LEVEL 9 — Switch-Case
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Switch-Case',
       'Switch-case memilih satu cabang berdasarkan nilai satu variabel. Cara ini cocok saat pilihan yang tersedia banyak dan tetap.',
       'switch (pilihan) {
  case 1:
    cout << "Satu";
    break;
}'
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Syntax Switch',
       'Nilai yang diperiksa switch harus bertipe bulat atau karakter, bukan boolean.',
       'switch (nilai) {
  case 1:
    break;
}'
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Case dan Break',
       'Setiap case diakhiri break agar program berhenti pada cabang tersebut. Tanpa break, eksekusi jatuh ke case berikutnya.',
       'switch (op) {
  case ''+'':
    cout << a + b;
    break;
}'
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Menu Pilihan',
       'Gunakan switch untuk membuat menu sederhana dan tangani input di luar daftar dengan cabang default.',
       'switch (menu) {
  case 1:
    cout << "Mulai";
    break;
  default:
    cout << "Pilihan tidak valid";
}'
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami switch-case untuk memilih cabang berdasarkan nilai. Selanjutnya, kamu akan menyusun menu dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 13: EXERCISES LEVEL 9 — Switch-Case (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun switch satu case',
       $json${
         "tokens": [
           {"id": "t1", "text": "switch"},
           {"id": "t2", "text": "(pilihan) {"},
           {"id": "t3", "text": "case 1:"},
           {"id": "t4", "text": "cout << \"Satu\";"},
           {"id": "t5", "text": "break;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun switch satu case'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun switch tiga case',
       $json${
         "tokens": [
           {"id": "t1", "text": "switch"},
           {"id": "t2", "text": "(pilihan) {"},
           {"id": "t3", "text": "case 1:"},
           {"id": "t4", "text": "cout << \"Satu\";"},
           {"id": "t5", "text": "break;"},
           {"id": "t6", "text": "case 2:"},
           {"id": "t7", "text": "cout << \"Dua\";"},
           {"id": "t8", "text": "break;"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun switch tiga case'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun switch dengan break',
       $json${
         "tokens": [
           {"id": "t1", "text": "switch"},
           {"id": "t2", "text": "(op) {"},
           {"id": "t3", "text": "case '+':"},
           {"id": "t4", "text": "cout << a + b;"},
           {"id": "t5", "text": "break;"},
           {"id": "t6", "text": "default:"},
           {"id": "t7", "text": "cout << \"Operasi lain\";"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun switch dengan break'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun switch dengan default',
       $json${
         "tokens": [
           {"id": "t1", "text": "switch"},
           {"id": "t2", "text": "(menu) {"},
           {"id": "t3", "text": "case 1:"},
           {"id": "t4", "text": "cout << \"Mulai\";"},
           {"id": "t5", "text": "break;"},
           {"id": "t6", "text": "default:"},
           {"id": "t7", "text": "cout << \"Pilihan tidak valid\";"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun switch dengan default'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun menu switch',
       $json${
         "tokens": [
           {"id": "t1", "text": "switch"},
           {"id": "t2", "text": "(menu) {"},
           {"id": "t3", "text": "case '1':"},
           {"id": "t4", "text": "cout << \"Mulai\";"},
           {"id": "t5", "text": "break;"},
           {"id": "t6", "text": "default:"},
           {"id": "t7", "text": "cout << \"Menu tidak valid\";"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun menu switch'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 14: MATERIALS LEVEL 10 — Operator Ternary
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Operator Ternary',
       'Operator ternary menggabungkan percabangan if-else sederhana menjadi satu baris ekspresi yang menghasilkan satu nilai.',
       'int status = (nilai >= 70) ? 1 : 0;'
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Syntax Operator Ternary',
       'Tulis kondisi, lalu tanda ?, nilai untuk kondisi true, tanda :, dan nilai untuk kondisi false.',
       'int hasil = (nilai > 10) ? 1 : 0;'
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Kapan Menggunakan Ternary',
       'Ternary cocok untuk pilihan sederhana yang menghasilkan satu nilai, bukan untuk logika panjang atau blok kode.',
       'int maks = (a > b) ? a : b;'
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Menentukan Nilai Akhir',
       'Contoh berikut mempertahankan nilai minimal tanpa menulis blok if-else.',
       'int nilaiAkhir = (nilai < 70) ? 70 : nilai;'
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami cara menulis kondisi singkat dengan operator ternary. Selanjutnya, kamu akan menyusun ekspresi ternary dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 15: EXERCISES LEVEL 10 — Operator Ternary (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun ternary sederhana',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "hasil"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "(nilai > 10) ? 1 : 0"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun ternary sederhana'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun ternary status lulus',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "lulus"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "(nilai >= 70) ? 1 : 0"},
           {"id": "t5", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun ternary status lulus'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun ternary perbandingan',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "maks"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "(a > b)"},
           {"id": "t5", "text": "? a : b"},
           {"id": "t6", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun ternary perbandingan'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun ternary bersarang',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "(nilai >= 80) ? 'A' :"},
           {"id": "t5", "text": "((nilai >= 60) ? 'B' : 'C')"},
           {"id": "t6", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun ternary bersarang'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun ternary di dalam cout',
       $json${
         "tokens": [
           {"id": "t1", "text": "cout"},
           {"id": "t2", "text": "<<"},
           {"id": "t3", "text": "((nilai >= 70) ? \"Lulus\" : \"Tidak Lulus\")"},
           {"id": "t4", "text": "<<"},
           {"id": "t5", "text": "endl"},
           {"id": "t6", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun ternary di dalam cout'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 16: MATERIALS LEVEL 11 — For Loop
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Perulangan',
       'Perulangan menjalankan blok kode berulang kali dengan jumlah pengulangan yang sudah diketahui sejak awal.',
       'for (int i = 1; i <= 5; i++) {
  cout << i << endl;
}'
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Struktur For',
       'Perulangan for punya tiga bagian: inisialisasi variabel, pemeriksaan kondisi, dan perubahan variabel kontrol.',
       'for (int i = 0; i < 10; i++) {
  // blok perulangan
}'
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Inisialisasi, Kondisi, dan Iterasi',
       'Variabel i diinisialisasi sekali, kondisi dicek setiap iterasi, dan i bertambah satu kali setelah blok selesai dijalankan.',
       'for (int i = 1; i <= 3; i++) {
  cout << i << endl;
}'
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Menghitung Total',
       'Gunakan variabel penampung di luar loop untuk menjumlahkan nilai dari 1 sampai 10.',
       'int total = 0;
for (int i = 1; i <= 10; i++) {
  total += i;
}
cout << total;'
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami struktur for beserta tiga bagiannya. Selanjutnya, kamu akan menyusun perulangan for dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 17: EXERCISES LEVEL 11 — For Loop (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun for sederhana',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 0; i < 5; i++)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << i;"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun for sederhana'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun for 1 sampai 5',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 5; i++)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << i << endl;"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun for 1 sampai 5'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun for penjumlahan',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "total = 0;"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(int i = 1; i <= 10; i++) {"},
           {"id": "t5", "text": "total += i;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun for penjumlahan'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun for dengan counter luar',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "i = 0;"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(; i < 3; i++)"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "cout << i;"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun for dengan counter luar'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun for cetak pola',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 3; i++) {"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(int j = 1; j <= i; j++) {"},
           {"id": "t5", "text": "cout << \"*\";"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun for cetak pola'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 18: MATERIALS LEVEL 12 — While Loop
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan While Loop',
       'Perulangan while berjalan selama kondisi bernilai true. Cara ini cocok saat jumlah iterasi belum diketahui sejak awal.',
       'int i = 0;
while (i < 5) {
  cout << i << endl;
  i++;
}'
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Struktur While',
       'While terdiri dari kondisi dan blok kode. Pastikan variabel kontrol selalu berubah, jika tidak perulangan tidak pernah berhenti.',
       'while (i < 5) {
  i++;
}'
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Perulangan Tak Terbatas',
       'Jika kondisi selalu bernilai true, perulangan berjalan tanpa akhir. Gunakan break untuk menghentikannya secara sadar.',
       'while (true) {
  // pastikan ada break di dalam
}'
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Hitung Mundur',
       'Hitung mundur dimulai dari angka tertentu dan berkurang satu pada setiap iterasi sampai kondisi berubah.',
       'int hitung = 3;
while (hitung > 0) {
  cout << hitung << endl;
  hitung--;
}'
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami perulangan while beserta syarat berhenti dan variabel kontrolnya. Selanjutnya, kamu akan menyusun perulangan while dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 19: EXERCISES LEVEL 12 — While Loop (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun while sederhana',
       $json${
         "tokens": [
           {"id": "t1", "text": "int i = 0;"},
           {"id": "t2", "text": "while"},
           {"id": "t3", "text": "(i < 5)"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun while sederhana'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun while decrement',
       $json${
         "tokens": [
           {"id": "t1", "text": "int hitung = 3;"},
           {"id": "t2", "text": "while"},
           {"id": "t3", "text": "(hitung > 0)"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "hitung--;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun while decrement'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun while input',
       $json${
         "tokens": [
           {"id": "t1", "text": "int nilai;"},
           {"id": "t2", "text": "while"},
           {"id": "t3", "text": "(nilai != 0)"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "cin >> nilai;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun while input'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun while akumulator',
       $json${
         "tokens": [
           {"id": "t1", "text": "int total = 0;"},
           {"id": "t2", "text": "int i = 1;"},
           {"id": "t3", "text": "while"},
           {"id": "t4", "text": "(i <= 10) {"},
           {"id": "t5", "text": "total += i;"},
           {"id": "t6", "text": "i++;"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun while akumulator'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun while pola',
       $json${
         "tokens": [
           {"id": "t1", "text": "int i = 1;"},
           {"id": "t2", "text": "while"},
           {"id": "t3", "text": "(i <= 3) {"},
           {"id": "t4", "text": "for"},
           {"id": "t5", "text": "(int j = 1; j <= i; j++) {"},
           {"id": "t6", "text": "cout << \"*\";"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun while pola'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 20: MATERIALS LEVEL 13 — Do-While Loop
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Do-While Loop',
       'Perulangan do-while menjalankan blok kode minimal satu kali sebelum kondisi diperiksa.',
       'int i = 0;
do {
  cout << i << endl;
  i++;
} while (i < 5);'
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Struktur Do-While',
       'Blok do ditulis lebih dulu, lalu while dengan kondisi di akhir dan diakhiri tanda titik koma.',
       'do {
  // blok perulangan
} while (kondisi);'
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Eksekusi Minimal Satu Kali',
       'Berbeda dengan while, do-while pasti mengeksekusi blok satu kali walau kondisi awal sudah bernilai false.',
       'do {
  cout << "Selamat datang";
} while (false);'
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Validasi Input',
       'Gunakan do-while untuk meminta input ulang sampai nilai yang dimasukkan memenuhi syarat.',
       'int nilai;
do {
  cout << "Masukkan nilai 1-100: ";
  cin >> nilai;
} while (nilai < 1 || nilai > 100);'
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami do-while yang pasti menjalankan blok minimal satu kali. Selanjutnya, kamu akan menyusun perulangan do-while dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 21: EXERCISES LEVEL 13 — Do-While Loop (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun do-while dasar',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "i = 0;"},
           {"id": "t3", "text": "do"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "i++;"},
           {"id": "t6", "text": "} while (i < 5);"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun do-while dasar'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun do-while print',
       $json${
         "tokens": [
           {"id": "t1", "text": "int i = 0;"},
           {"id": "t2", "text": "do"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << i << endl;"},
           {"id": "t5", "text": "i++;"},
           {"id": "t6", "text": "} while (i < 5);"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun do-while print'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun do-while counter',
       $json${
         "tokens": [
           {"id": "t1", "text": "int i = 0;"},
           {"id": "t2", "text": "int total = 0;"},
           {"id": "t3", "text": "do"},
           {"id": "t4", "text": "{"},
           {"id": "t5", "text": "total += i;"},
           {"id": "t6", "text": "i++;"},
           {"id": "t7", "text": "} while (i < 5);"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun do-while counter'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun do-while validasi',
       $json${
         "tokens": [
           {"id": "t1", "text": "int nilai = 0;"},
           {"id": "t2", "text": "do"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Masukkan nilai: \";"},
           {"id": "t5", "text": "cin >> nilai;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "while (nilai < 1 || nilai > 100);"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun do-while validasi'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun do-while menu',
       $json${
         "tokens": [
           {"id": "t1", "text": "int pilihan;"},
           {"id": "t2", "text": "do"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Pilih menu: \";"},
           {"id": "t5", "text": "cin >> pilihan;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "while (pilihan != 2);"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun do-while menu'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 22: MATERIALS LEVEL 14 — Nested Loop
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Nested Loop',
       'Nested loop berarti satu perulangan diletakkan di dalam perulangan lain. Loop outer berulang untuk setiap iterasi loop inner.',
       'for (int i = 1; i <= 3; i++) {
  for (int j = 1; j <= 3; j++) {
    cout << "*";
  }
}'
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Loop di Dalam Loop',
       'Perhatikan urutan variabel kontrol. Loop inner selalu selesai dulu sebelum loop outer menambah langkahnya.',
       'for (int i = 0; i < 2; i++) {
  for (int j = 0; j < 3; j++) {
    cout << i << j << " ";
  }
}'
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Menghitung Iterasi',
       'Jumlah total iterasi adalah perkalian iterasi outer dan iterasi inner. Tiga kali tiga berarti sembilan iterasi.',
       '// 3 x 3 = 9 iterasi
for (int i = 0; i < 3; i++) {
  for (int j = 0; j < 3; j++) {
    cout << i << j;
  }
}'
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Tabel Perkalian',
       'Gunakan dua loop untuk mencetak tabel perkalian dari 1 sampai 3.',
       'for (int i = 1; i <= 3; i++) {
  for (int j = 1; j <= 3; j++) {
    cout << i << " x " << j << " = " << i * j << endl;
  }
}'
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami nested loop dan cara menghitung jumlah iterasinya. Selanjutnya, kamu akan menyusun perulangan bertingkat dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 23: EXERCISES LEVEL 14 — Nested Loop (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nested loop 2x2',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 2; i++) {"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(int j = 1; j <= 2; j++) {"},
           {"id": "t5", "text": "cout << \"*\";"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nested loop 2x2'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun tabel perkalian',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 3; i++) {"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(int j = 1; j <= 3; j++) {"},
           {"id": "t5", "text": "cout << i * j << endl;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun tabel perkalian'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pola bintang',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 3; i++) {"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(int j = 1; j <= i; j++) {"},
           {"id": "t5", "text": "cout << \"*\";"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "cout << endl;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pola bintang'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nested loop penjumlahan',
       $json${
         "tokens": [
           {"id": "t1", "text": "int total = 0;"},
           {"id": "t2", "text": "for"},
           {"id": "t3", "text": "(int i = 1; i <= 3; i++) {"},
           {"id": "t4", "text": "for"},
           {"id": "t5", "text": "(int j = 1; j <= 3; j++) {"},
           {"id": "t6", "text": "total += i * j;"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "cout << total;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nested loop penjumlahan'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pola segitiga angka',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 3; i++) {"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(int j = 1; j <= i; j++) {"},
           {"id": "t5", "text": "cout << j;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "cout << endl;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pola segitiga angka'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 24: MATERIALS LEVEL 15 — Break & Continue
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Break dan Continue',
       'Break menghentikan perulangan sepenuhnya, sedangkan continue melewati sisa isi loop lalu lanjut ke iterasi berikutnya.',
       'for (int i = 1; i <= 10; i++) {
  if (i == 5) break;
}'
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Fungsi Break',
       'Break sering dipakai saat data yang dicari sudah ditemukan, sehingga perulangan dihentikan lebih awal.',
       'for (int i = 0; i < 10; i++) {
  if (data[i] == target) break;
}'
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Fungsi Continue',
       'Continue berguna untuk melewati data yang tidak perlu diproses, misalnya nilai kosong pada sebuah array.',
       'for (int i = 0; i < 10; i++) {
  if (data[i] == 0) continue;
  total += data[i];
}'
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Skip Data Kosong',
       'Kombinasi continue dengan if membuat pemrosesan data lebih aman dan ringkas.',
       'int total = 0;
for (int i = 0; i < 5; i++) {
  if (nilai[i] == 0) continue;
  total += nilai[i];
}'
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami perbedaan break dan continue di dalam perulangan. Selanjutnya, kamu akan menyusun perulangan dengan keduanya dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 25: EXERCISES LEVEL 15 — Break & Continue (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun loop dengan break',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 10; i++) {"},
           {"id": "t3", "text": "if (i == 5)"},
           {"id": "t4", "text": "break;"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun loop dengan break'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun loop dengan continue',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 1; i <= 10; i++) {"},
           {"id": "t3", "text": "if (i % 2 != 0)"},
           {"id": "t4", "text": "continue;"},
           {"id": "t5", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun loop dengan continue'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun continue pada data kosong',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "total = 0;"},
           {"id": "t3", "text": "for"},
           {"id": "t4", "text": "(int i = 0; i < 5; i++) {"},
           {"id": "t5", "text": "if (nilai[i] == 0) continue;"},
           {"id": "t6", "text": "total += nilai[i];"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun continue pada data kosong'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun break pada nilai tertentu',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 0; i < 10; i++) {"},
           {"id": "t3", "text": "if (data[i] == target)"},
           {"id": "t4", "text": "break;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "cout << \"Ditemukan\";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun break pada nilai tertentu'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun kombinasi break continue',
       $json${
         "tokens": [
           {"id": "t1", "text": "for"},
           {"id": "t2", "text": "(int i = 0; i < 10; i++) {"},
           {"id": "t3", "text": "if (data[i] == 0)"},
           {"id": "t4", "text": "continue;"},
           {"id": "t5", "text": "if (data[i] == target)"},
           {"id": "t6", "text": "break;"},
           {"id": "t7", "text": "cout << data[i];"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun kombinasi break continue'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 26: VERIFICATION (relatif per level)
-- ============================================
-- Level 1: 5 material (file ini) + 5 exercise (seed.sql)
-- Level 2: 5 material (dari seed.sql) + 5 exercise (file ini)
-- Level 4-15: 5 material + 5 exercise dari file ini
-- Verifikasi memakai jumlah per level, bukan total absolut, agar file ini
-- aman dijalankan berdampingan dengan seed.sql dan chunk lain.

DO $$
DECLARE
  v_level_number INT;
  v_count INT;
BEGIN
  FOR v_level_number IN
    SELECT unnest(ARRAY[1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
  LOOP
    SELECT count(*) INTO v_count
    FROM public.materials m
    JOIN public.levels l ON l.id = m.level_id
    WHERE l.level_number = v_level_number AND l.language = 'cpp';

    IF v_count <> 5 THEN
      RAISE EXCEPTION 'Chunk 1 verify: level % expected 5 materials, got %', v_level_number, v_count;
    END IF;

    SELECT count(*) INTO v_count
    FROM public.exercises e
    JOIN public.levels l ON l.id = e.level_id
    WHERE l.level_number = v_level_number AND l.language = 'cpp'
      AND e.type = 'drag_drop';

    IF v_count <> 5 THEN
      RAISE EXCEPTION 'Chunk 1 verify: level % expected 5 exercises, got %', v_level_number, v_count;
    END IF;
  END LOOP;
END
$$;

COMMIT;
