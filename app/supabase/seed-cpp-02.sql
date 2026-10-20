-- KODIRA — Seed Chunk 2 (C++ Level 16-25 materials + exercises)
-- Tanggal: 2026-10-20
--
-- Tujuan:
--   1. Materials Level 16-25 (10 level x 5 slide = 50 slide)
--   2. Exercises drag_drop Level 16-25 (10 level x 5 exercise = 50 exercise)
--
-- File ini adalah CHUNK 2 dari 4 file seed:
--   1. seed-cpp-01.sql  — L2 exercises, L4-15
--   2. seed-cpp-02.sql  (file ini) — L16-25
--   3. seed-cpp-03.sql             — L26-35
--   4. seed-java-01.sql             — L36-50
--   File seed.sql (L1-3) dan seed-cpp-01.sql tetap dipertahankan dan tidak diubah.
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/seed-cpp-02.sql
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
--   - kurung kurawal {} dan kurung lingkung () pada kode rakitan harus balance
--
-- Verifikasi di akhir memakai DO block RELATIF per level (5 material + 5 exercise),
-- bukan angka absolut, sehingga file ini aman dijalankan berdampingan dengan chunk lain.

BEGIN;

-- ============================================
-- SECTION 1: MATERIALS LEVEL 16 — Pengenalan Fungsi
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Fungsi',
       'Fungsi adalah potongan kode yang dapat dipanggil berulang kali. Fungsi membuat program lebih rapi dan mudah diubah.',
       'void sapaan() {
  cout << "Halo, selamat datang!";
}'
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Mendeklarasikan Fungsi',
       'Tulis tipe return, nama fungsi, lalu daftar parameter di dalam kurung. Kurung kurawal berisi isi fungsi.',
       'void tampilNilai() {
  cout << "Nilai kamu 80";
}'
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Memanggil Fungsi',
       'Panggil fungsi dengan menulis nama fungsi dan kurung kurawal di dalam main. Fungsi harus dideklarasikan sebelum dipanggil.',
       'int main() {
  tampilNilai();
  return 0;
}'
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Fungsi Sapaan',
       'Fungsi sapaan dipanggil dua kali di dalam main. Perhatikan bahwa isi fungsi hanya ditulis satu kali.',
       'void sapaan() {
  cout << "Halo!" << endl;
}

int main() {
  sapaan();
  sapaan();
  return 0;
}'
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami cara membuat dan memanggil fungsi sederhana. Selanjutnya, kamu akan menyusun deklarasi fungsi dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 2: EXERCISES LEVEL 16 — Pengenalan Fungsi (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi fungsi',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "sapaan()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Halo\";"},
           {"id": "t5", "text": "cout << endl;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi fungsi'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan fungsi',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "sapaan();"},
           {"id": "t5", "text": "return 0;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan fungsi'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi tanpa return',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "tampil()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Nilai 80\";"},
           {"id": "t5", "text": "cout << endl;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi tanpa return'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi dengan argumen',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "sapaan(string nama)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout"},
           {"id": "t5", "text": "<< \"Halo, \" << nama;"},
           {"id": "t6", "text": "cout << endl;"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi dengan argumen'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun dua fungsi',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "sapa()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Halo\";"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "sapa();"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun dua fungsi'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 3: MATERIALS LEVEL 17 — Parameter & Argumen
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Konsep Parameter',
       'Parameter adalah variabel yang dideklarasikan pada daftar parameter fungsi. Nilainya diambil dari argumen saat fungsi dipanggil.',
       'void cetakNilai(int nilai) {
  cout << "Nilai: " << nilai;
}'
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Parameter Formal dan Aktual',
       'Parameter formal milik definisi fungsi, sedangkan parameter aktual adalah nilai nyata yang dikirim saat pemanggilan.',
       'cetakNilai(85);'
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Pass by Value',
       'Pada pass by value, nilai argumen disalin ke parameter sehingga perubahan di dalam fungsi tidak memengaruhi variabel asal.',
       'void ubah(int x) {
  x = 100;
}

int main() {
  int a = 10;
  ubah(a);
  cout << a;
}'
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Fungsi Luas',
       'Fungsi luas menerima dua parameter dan mengembalikan hasil perkalian keduanya ke pemanggil.',
       'double luas(double panjang, double lebar) {
  return panjang * lebar;
}'
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami parameter dan argumen beserta cara pengiriman nilainya. Selanjutnya, kamu akan menyusun fungsi berparameter dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 4: EXERCISES LEVEL 17 — Parameter & Argumen (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi berparameter',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "cetakNilai(int nilai)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << nilai;"},
           {"id": "t5", "text": "cout << endl;"},
           {"id": "t6", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi berparameter'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan argumen',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int nilai = 85;"},
           {"id": "t5", "text": "cetakNilai(nilai);"},
           {"id": "t6", "text": "cout << endl;"},
           {"id": "t7", "text": "return 0;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan argumen'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun dua parameter',
       $json${
         "tokens": [
           {"id": "t1", "text": "double"},
           {"id": "t2", "text": "luas(double p, double l)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "double"},
           {"id": "t5", "text": "hasil = p * l;"},
           {"id": "t6", "text": "cout << hasil;"},
           {"id": "t7", "text": "return hasil;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun dua parameter'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pass by value',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "ubah(int x)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "x = 100;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "int a = 10;"},
           {"id": "t10", "text": "ubah(a);"},
           {"id": "t11", "text": "cout << a;"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pass by value'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi hitung luas',
       $json${
         "tokens": [
           {"id": "t1", "text": "double"},
           {"id": "t2", "text": "luas(double p, double l)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return p * l;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "double hasil = luas(5.0, 3.0);"},
           {"id": "t10", "text": "cout << hasil;"},
           {"id": "t11", "text": "return 0;"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi hitung luas'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 5: MATERIALS LEVEL 18 — Return Value
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Return',
       'Return menghentikan fungsi dan mengembalikan nilai ke pemanggil. Nilai tersebut bisa langsung dipakai atau disimpan dalam variabel.',
       'int tambah(int a, int b) {
  return a + b;
}'
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Tipe Data Return',
       'Tipe data return ditulis sebelum nama fungsi. Fungsi yang mengembalikan nilai harus punya return pada setiap jalur keluarnya.',
       'double luas(double p, double l) {
  return p * l;
}'
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Fungsi Tanpa Return',
       'Fungsi dengan return void tidak menghasilkan nilai. Fungsi seperti ini hanya melakukan tindakan, misalnya mencetak keluatan.',
       'void sapa() {
  cout << "Halo";
}'
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Fungsi Maksimum',
       'Fungsi maksimum membandingkan dua nilai dan mengembalikan yang lebih besar kepada pemanggil.',
       'int maksimum(int a, int b) {
  if (a > b) {
    return a;
  }
  return b;
}'
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami cara mengembalikan nilai dari sebuah fungsi. Selanjutnya, kamu akan menyusun fungsi dengan return dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 6: EXERCISES LEVEL 18 — Return Value (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi return',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "tambah(int a, int b)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return a + b;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "int hasil = tambah(3, 4);"},
           {"id": "t10", "text": "cout << hasil;"},
           {"id": "t11", "text": "return 0;"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi return'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun return tipe double',
       $json${
         "tokens": [
           {"id": "t1", "text": "double"},
           {"id": "t2", "text": "luas(double p, double l)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return p * l;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "double hasil = luas(4.0, 2.5);"},
           {"id": "t10", "text": "cout << hasil;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun return tipe double'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun return ke variabel',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "kuadrat(int x)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return x * x;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "int hasil = kuadrat(5);"},
           {"id": "t10", "text": "cout << hasil;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun return ke variabel'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi maksimum',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "maksimum(int a, int b)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "if (a > b) {"},
           {"id": "t5", "text": "return a;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "return b;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi maksimum'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi dua nilai',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "tukar(int a, int b)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int temp = a;"},
           {"id": "t5", "text": "a = b;"},
           {"id": "t6", "text": "b = temp;"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "int"},
           {"id": "t9", "text": "main()"},
           {"id": "t10", "text": "{"},
           {"id": "t11", "text": "tukar(1, 2);"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi dua nilai'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 7: MATERIALS LEVEL 19 — Fungsi Rekursif
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Rekursi',
       'Fungsi rekursif memanggil dirinya sendiri untuk menyelesaikan masalah yang bisa dipecah menjadi masalah yang lebih kecil.',
       'int faktorial(int n) {
  if (n <= 1) return 1;
  return n * faktorial(n - 1);
}'
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Kasus Dasar dan Kasus Rekursif',
       'Setiap fungsi rekursif wajib punya kasus dasar yang menghentikan pemanggilan, dan kasus rekursif yang memanggil dirinya sendiri.',
       'int hitungMundur(int n) {
  if (n == 0) return 0;
  return hitungMundur(n - 1);
}'
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Alur Pemanggilan Fungsi',
       'Setiap pemanggilan membuat frame baru di stack. Kasus dasar menghentikan rantai pemanggilan lalu mengembalikan nilai ke pemanggil sebelumnya.',
       '// faktorial(3)
// 3 * faktorial(2)
// 3 * 2 * faktorial(1)
// 3 * 2 * 1 = 6'
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Fungsi Faktorial',
       'Faktorial dihitung dengan mengalikan bilangan dengan faktorial dari bilangan yang lebih kecil.',
       'int faktorial(int n) {
  if (n <= 1) {
    return 1;
  }
  return n * faktorial(n - 1);
}'
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami fungsi rekursif beserta kasus dasarnya. Selanjutnya, kamu akan menyusun fungsi rekursif dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 8: EXERCISES LEVEL 19 — Fungsi Rekursif (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi rekursif dasar',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "hitungMundur(int n)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "if (n == 0) {"},
           {"id": "t5", "text": "return 0;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "return hitungMundur(n - 1);"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi rekursif dasar'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun faktorial',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "faktorial(int n)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "if (n <= 1) {"},
           {"id": "t5", "text": "return 1;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "return n * faktorial(n - 1);"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun faktorial'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fibonacci',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "fibonacci(int n)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "if (n <= 1) {"},
           {"id": "t5", "text": "return n;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "return fibonacci(n - 1) + fibonacci(n - 2);"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fibonacci'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun kasus dasar',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "pangkat(int basis, int p)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "if (p == 0) {"},
           {"id": "t5", "text": "return 1;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "return basis * pangkat(basis, p - 1);"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun kasus dasar'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun rekursi countdown',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "countdown(int n)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "if (n == 0) {"},
           {"id": "t5", "text": "return;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "cout << n << endl;"},
           {"id": "t8", "text": "countdown(n - 1);"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun rekursi countdown'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 9: MATERIALS LEVEL 20 — Overloading Fungsi
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Overloading',
       'Overloading memungkinkan beberapa fungsi memiliki nama sama selama daftar parameternya berbeda.',
       'int tambah(int a, int b) {
  return a + b;
}

double tambah(double a, double b) {
  return a + b;
}'
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Beda Tipe Parameter',
       'Fungsi dengan tipe parameter berbeda dipilih otomatis sesuai tipe argumen yang dipakai saat pemanggilan.',
       'tambah(3, 4);
tambah(3.5, 4.5);'
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Beda Jumlah Parameter',
       'Overloading juga bisa membedakan jumlah parameter, misalnya fungsi luas untuk persegi panjang dan untuk persegi.',
       'double luas(double s) {
  return s * s;
}

double luas(double p, double l) {
  return p * l;
}'
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Hitung Luas',
       'Dua fungsi luas dengan nama sama tetap bisa dipanggil karena daftar parameternya berbeda.',
       'int main() {
  cout << luas(5.0) << endl;
  cout << luas(4.0, 3.0) << endl;
  return 0;
}'
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami overloading fungsi berdasarkan tipe dan jumlah parameter. Selanjutnya, kamu akan menyusun fungsi overloading dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 10: EXERCISES LEVEL 20 — Overloading Fungsi (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun overload int dan double',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "tambah(int a, int b)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return a + b;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "double"},
           {"id": "t7", "text": "tambah(double a, double b)"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "return a + b;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun overload int dan double'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun overload jumlah parameter',
       $json${
         "tokens": [
           {"id": "t1", "text": "double"},
           {"id": "t2", "text": "luas(double s)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return s * s;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "double"},
           {"id": "t7", "text": "luas(double p, double l)"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "return p * l;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun overload jumlah parameter'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi luas overload',
       $json${
         "tokens": [
           {"id": "t1", "text": "double"},
           {"id": "t2", "text": "luas(double p, double l)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return p * l;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "cout << luas(4.0, 3.0);"},
           {"id": "t10", "text": "return 0;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi luas overload'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan overload',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "tambah(int a, int b)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return a + b;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "cout << tambah(3, 4);"},
           {"id": "t10", "text": "return 0;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan overload'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun overload cetak',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "cetak(int x)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << x << endl;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "void"},
           {"id": "t7", "text": "cetak(char x)"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "cout << x << endl;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun overload cetak'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 11: MATERIALS LEVEL 21 — Array 1D
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Array',
       'Array menyimpan sekumpulan data bertipe sama pada satu nama variabel dan diakses lewat indeks.',
       'int nilai[5] = {70, 80, 90, 85, 95};'
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Deklarasi Array',
       'Tulis tipe data, nama, lalu ukuran array di dalam kurung siku. Indeks array dimulai dari nol.',
       'int nilai[5];
nilai[0] = 70;
nilai[1] = 80;'
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Inisialisasi Array',
       'Array bisa diisi langsung saat deklarasi. Jika jumlah nilai lebih sedikit dari ukuran array, sisanya diisi nol.',
       'double ipk[3] = {3.75, 3.50};'
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Rata-Rata Nilai',
       'Gunakan loop untuk menjumlahkan seluruh isi array lalu bagi dengan banyaknya elemen.',
       'int nilai[5] = {70, 80, 90, 85, 95};
int total = 0;
for (int i = 0; i < 5; i++) {
  total += nilai[i];
}
cout << total / 5;'
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami deklarasi dan akses elemen array. Selanjutnya, kamu akan menyusun array satu dimensi dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 12: EXERCISES LEVEL 21 — Array 1D (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi array',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai"},
           {"id": "t3", "text": "["},
           {"id": "t4", "text": "5"},
           {"id": "t5", "text": "]"},
           {"id": "t6", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi array'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun inisialisasi array',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai[5] ="},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "70,"},
           {"id": "t5", "text": "80,"},
           {"id": "t6", "text": "90"},
           {"id": "t7", "text": "};"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun inisialisasi array'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun akses indeks',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai[3];"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "main()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "nilai[0] = 70;"},
           {"id": "t7", "text": "cout << nilai[0];"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun akses indeks'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun array dengan loop',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai[3] = {70, 80, 90};"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "main()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "int total = 0;"},
           {"id": "t7", "text": "for (int i = 0; i < 3; i++) {"},
           {"id": "t8", "text": "total += nilai[i];"},
           {"id": "t9", "text": "}"},
           {"id": "t10", "text": "cout << total;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun array dengan loop'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun array satu dimensi lengkap',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "double ipk[3] = {3.75, 3.5, 3.9};"},
           {"id": "t5", "text": "double total = 0;"},
           {"id": "t6", "text": "for (int i = 0; i < 3; i++) {"},
           {"id": "t7", "text": "total += ipk[i];"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "cout << total / 3;"},
           {"id": "t10", "text": "return 0;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun array satu dimensi lengkap'
      AND e.type = 'drag_drop'
  );

-- @@CHUNK02_PART2@@
