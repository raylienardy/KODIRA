-- KODIRA — Seed Chunk 3 (C++ Level 26-35 materials + exercises)
-- Tanggal: 2026-10-20
--
-- Tujuan:
--   1. Materials Level 26-35 (10 level x 5 slide = 50 slide)
--   2. Exercises drag_drop Level 26-35 (10 level x 5 exercise = 50 exercise)
--
-- File ini adalah CHUNK 3 dari 4 file seed:
--   1. seed-cpp-01.sql  — L2 exercises, L4-15
--   2. seed-cpp-02.sql             — L16-25
--   3. seed-cpp-03.sql  (file ini) — L26-35
--   4. seed-java-01.sql             — L36-50
--   File seed.sql (L1-3), seed-cpp-01.sql, dan seed-cpp-02.sql tetap
--   dipertahankan dan tidak diubah oleh file ini.
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/seed-cpp-03.sql
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
-- SECTION 1: MATERIALS LEVEL 26 — Pengenalan Pointer
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Pointer',
       'Pointer adalah variabel yang menyimpan alamat memori dari variabel lain, bukan nilai itu sendiri.',
       'int nilai = 10;
int *ptr = &nilai;'
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Deklarasi Pointer',
       'Tulis tipe data, tanda bintang, lalu nama pointer. Tanda bintang menandakan variabel ini menyimpan alamat.',
       'int *ptr;
double *harga;'
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Operator Address-of dan Dereference',
       'Operator & mengambil alamat memori, sedangkan operator * membaca atau menulis nilai pada alamat tersebut.',
       'int nilai = 10;
int *ptr = &nilai;

cout << ptr;   // alamat nilai
cout << *ptr;  // nilai 10'
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Mengubah Nilai',
       'Pointer bisa dipakai untuk mengubah nilai variabel asal tanpa menyalinnya.',
       'void ubah(int *p) {
  *p = 100;
}

int main() {
  int nilai = 10;
  ubah(&nilai);
  cout << nilai;
}'
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami dasar pointer, deklarasinya, serta cara membaca dan menulis lewat alamat. Selanjutnya, kamu akan menyusun program pointer dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 2: EXERCISES LEVEL 26 — Pengenalan Pointer (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "*"},
           {"id": "t3", "text": "ptr"},
           {"id": "t4", "text": "="},
           {"id": "t5", "text": "nullptr"},
           {"id": "t6", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi pointer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun inisialisasi pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai = 10;"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "*ptr"},
           {"id": "t5", "text": "="},
           {"id": "t6", "text": "&nilai"},
           {"id": "t7", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun inisialisasi pointer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun address-of',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai = 10;"},
           {"id": "t3", "text": "int *ptr = &nilai;"},
           {"id": "t4", "text": "int"},
           {"id": "t5", "text": "main()"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "cout << ptr;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun address-of'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun dereference',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai = 10;"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "main()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "int *ptr = &nilai;"},
           {"id": "t7", "text": "cout << *ptr;"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun dereference'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pointer ubah nilai',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "ubah(int *p)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "*p = 100;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "int nilai = 10;"},
           {"id": "t10", "text": "ubah(&nilai);"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pointer ubah nilai'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 3: MATERIALS LEVEL 27 — Pointer & Array
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Array sebagai Pointer',
       'Nama array sebenarnya adalah pointer ke elemen pertamanya, sehingga nama array bisa dipakai untuk menghitung alamat elemen.',
       'int data[3] = {10, 20, 30};
int *ptr = data;'
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Pointer Aritmetika',
       'Penambahan pada pointer berpindah ke elemen berikutnya, bukan menambah nilai yang tersimpan di dalamnya.',
       'int *ptr = data;
cout << *ptr;      // 10
cout << *(ptr + 1); // 20'
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Loop dengan Pointer',
       'Pointer dapat dijelajah dengan menaikkan nilainya, sama seperti memakai indeks array.',
       'for (int *p = data; p < data + 3; p++) {
  cout << *p;
}'
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Cari Elemen',
       'Cari elemen dengan berjalan menggunakan pointer dan berhenti saat nilainya ditemukan.',
       'int *cari(int data[], int n, int target) {
  for (int i = 0; i < n; i++) {
    if (data[i] == target) {
      return &data[i];
    }
  }
  return nullptr;
}'
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami hubungan pointer dan array beserta aritmetika pointer. Selanjutnya, kamu akan menyusun program pointer array dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 4: EXERCISES LEVEL 27 — Pointer & Array (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pointer ke array',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "data[3] = {10, 20, 30};"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "*ptr"},
           {"id": "t5", "text": "="},
           {"id": "t6", "text": "data"},
           {"id": "t7", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pointer ke array'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pointer aritmetika',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "data[3] = {10, 20, 30};"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "main()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "int *ptr = data;"},
           {"id": "t7", "text": "cout << *(ptr + 1);"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pointer aritmetika'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun loop pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "data[3] = {10, 20, 30};"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "main()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "for (int *p = data; p < data + 3; p++) {"},
           {"id": "t7", "text": "cout << *p;"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun loop pointer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun akses via pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "data[3] = {10, 20, 30};"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "main()"},
           {"id": "t5", "text": "{"},
           {"id": "t6", "text": "int *ptr = data;"},
           {"id": "t7", "text": "cout << data[1] << ptr[1];"},
           {"id": "t8", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun akses via pointer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun cari elemen',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "*cari(int data[], int n, int target)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "for (int i = 0; i < n; i++) {"},
           {"id": "t5", "text": "if (data[i] == target) {"},
           {"id": "t6", "text": "return &data[i];"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "return nullptr;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun cari elemen'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 5: MATERIALS LEVEL 28 — Reference
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Reference',
       'Reference adalah nama lain untuk variabel yang sudah ada. Perubahan lewat reference mengubah variabel aslinya.',
       'int nilai = 10;
int &ref = nilai;'
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Deklarasi Reference',
       'Tulis tipe data, tanda ampersand, lalu nama reference. Reference harus diinisialisasi saat deklarasi.',
       'int &ref = nilai;'
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Pass by Reference',
       'Saat reference dikirim ke fungsi, fungsi bekerja pada variabel asal sehingga perubahannya terlihat di pemanggil.',
       'void ubah(int &ref) {
  ref = 100;
}'
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Tukar Nilai',
       'Fungsi tukar dengan reference bisa menukar isi dua variabel tanpa memakai variabel bantu.',
       'void tukar(int &a, int &b) {
  int temp = a;
  a = b;
  b = temp;
}'
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami reference sebagai nama lain dari variabel. Selanjutnya, kamu akan menyusun fungsi dengan reference dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 6: EXERCISES LEVEL 28 — Reference (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi reference',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "nilai = 10;"},
           {"id": "t3", "text": "int"},
           {"id": "t4", "text": "&ref"},
           {"id": "t5", "text": "="},
           {"id": "t6", "text": "nilai"},
           {"id": "t7", "text": ";"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi reference'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi reference',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "ubah(int &ref)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "ref = 100;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "int nilai = 10;"},
           {"id": "t10", "text": "ubah(nilai);"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi reference'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun tukar nilai',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "tukar(int &a, int &b)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int temp = a;"},
           {"id": "t5", "text": "a = b;"},
           {"id": "t6", "text": "b = temp;"},
           {"id": "t7", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun tukar nilai'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun reference dalam loop',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int data[3] = {1, 2, 3};"},
           {"id": "t5", "text": "int total = 0;"},
           {"id": "t6", "text": "for (int &x : data) {"},
           {"id": "t7", "text": "total += x;"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun reference dalam loop'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi inkrement',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "inkrement(int &n)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "n++;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "int x = 5;"},
           {"id": "t10", "text": "inkrement(x);"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi inkrement'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 7: MATERIALS LEVEL 29 — Dynamic Memory
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Dynamic Memory',
       'Dynamic memory dialokasikan saat program berjalan memakai operator new dan dibebaskan dengan delete.',
       'int *p = new int(10);
*p = 20;
delete p;
p = nullptr;'
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Operator New dan Delete',
       'new mengembalikan alamat memori baru, sedangkan delete membebaskan memori tersebut agar tidak bocor.',
       'int *angka = new int;
*angka = 42;
delete angka;
angka = nullptr;'
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Array Dinamis',
       'Array dinamis berukuran variabel, dipakai saat ukuran array tidak diketahui saat program ditulis.',
       'int n = 5;
int *data = new int[n];
for (int i = 0; i < n; i++) {
  data[i] = i * 2;
}
delete[] data;'
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Alokasi Array',
       'Selalu lepaskan memori dinamis dengan delete untuk satu elemen atau delete[] untuk array.',
       'int *data = new int[100];
// pakai data
delete[] data;
data = nullptr;'
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami alokasi dan pelepasan memori secara dinamis. Selanjutnya, kamu akan menyusun program dynamic memory dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 8: EXERCISES LEVEL 29 — Dynamic Memory (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun alokasi new',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int"},
           {"id": "t5", "text": "*p"},
           {"id": "t6", "text": "="},
           {"id": "t7", "text": "new int(10);"},
           {"id": "t8", "text": "*p"},
           {"id": "t9", "text": "="},
           {"id": "t10", "text": "20;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun alokasi new'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun delete',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int"},
           {"id": "t5", "text": "*angka"},
           {"id": "t6", "text": "="},
           {"id": "t7", "text": "new int;"},
           {"id": "t8", "text": "*angka"},
           {"id": "t9", "text": "="},
           {"id": "t10", "text": "42;"},
           {"id": "t11", "text": "delete angka;"},
           {"id": "t12", "text": "angka = nullptr;"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun delete'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun array dinamis',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int n = 5;"},
           {"id": "t5", "text": "int *data = new int[n];"},
           {"id": "t6", "text": "for (int i = 0; i < n; i++) {"},
           {"id": "t7", "text": "data[i] = i * 2;"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "delete[] data;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun array dinamis'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun new dengan input loop',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int n = 5;"},
           {"id": "t5", "text": "int *data = new int[n];"},
           {"id": "t6", "text": "for (int i = 0; i < n; i++) {"},
           {"id": "t7", "text": "cin >> data[i];"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "delete[] data;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun new dengan input loop'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun manajemen memori',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int *data = new int[100];"},
           {"id": "t5", "text": "data[0] = 1;"},
           {"id": "t6", "text": "delete[] data;"},
           {"id": "t7", "text": "data = nullptr;"},
           {"id": "t8", "text": "if (data == nullptr) {"},
           {"id": "t9", "text": "cout << \"Memori dibebaskan\";"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun manajemen memori'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 9: MATERIALS LEVEL 30 — Pointer ke Fungsi
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pointer ke Fungsi',
       'Function pointer adalah variabel yang menyimpan alamat sebuah fungsi, sehingga fungsi bisa dipanggil lewat variabel itu.',
       'int tambah(int a, int b) {
  return a + b;
}

int (*ptr)(int, int) = tambah;'
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Deklarasi dan Penugasan',
       'Tanda asterisk diletakkan di dalam kurung bersama nama variabel, lalu tipe parameter fungsi dituliskan setelahnya.',
       'int (*ptr)(int, int);
ptr = tambah;'
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Fungsi sebagai Argumen',
       'Function pointer sering dikirim sebagai argumen ke fungsi lain, misalnya sebagai fungsi komparator.',
       'void urutkan(int data[], int n, int (*banding)(int, int));'
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Fungsi Komparator',
       'Dua fungsi dengan nama berbeda dapat dipakai pada satu variabel function pointer bertipe sama.',
       'bool lebihBesar(int a, int b) {
  return a > b;
}

bool lebihKecil(int a, int b) {
  return a < b;
}'
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami function pointer dan penggunaannya. Selanjutnya, kamu akan menyusun program pointer ke fungsi dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 10: EXERCISES LEVEL 30 — Pointer ke Fungsi (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi function pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "sapa()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Halo\" << endl;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "void"},
           {"id": "t7", "text": "(*ptr)()"},
           {"id": "t8", "text": "="},
           {"id": "t9", "text": "sapa;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi function pointer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun penugasan pointer fungsi',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "sapa()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Halo\" << endl;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "void"},
           {"id": "t7", "text": "(*ptr)()"},
           {"id": "t8", "text": "="},
           {"id": "t9", "text": "sapa;"},
           {"id": "t10", "text": "int"},
           {"id": "t11", "text": "main()"},
           {"id": "t12", "text": "{"},
           {"id": "t13", "text": "ptr();"},
           {"id": "t14", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun penugasan pointer fungsi'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pemanggilan via pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "sapa()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "cout << \"Halo\" << endl;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "void (*ptr)() = sapa;"},
           {"id": "t10", "text": "ptr();"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pemanggilan via pointer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun fungsi komparator',
       $json${
         "tokens": [
           {"id": "t1", "text": "bool"},
           {"id": "t2", "text": "lebihBesar(int a, int b)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "return a > b;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "bool"},
           {"id": "t7", "text": "lebihKecil(int a, int b)"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "return a < b;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun fungsi komparator'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun array of function pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "void"},
           {"id": "t2", "text": "naik(int &x)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "x++;"},
           {"id": "t5", "text": "}"},
           {"id": "t6", "text": "void"},
           {"id": "t7", "text": "turun(int &x)"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "x--;"},
           {"id": "t10", "text": "}"},
           {"id": "t11", "text": "void"},
           {"id": "t12", "text": "(*fungsi[2])(int &)"},
           {"id": "t13", "text": "="},
           {"id": "t14", "text": "{ naik, turun };"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun array of function pointer'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 11: MATERIALS LEVEL 31 — Struct Dasar
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Struct',
       'Struct menggabungkan beberapa variabel dengan tipe berbeda menjadi satu kesatuan yang disebut member.',
       'struct Mahasiswa {
  string nama;
  int nim;
  float ipk;
};'
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Deklarasi Struct',
       'Struct ditulis dengan kata kunci struct, nama struct, lalu daftar member di dalam kurung kurawal.',
       'struct Point {
  int x;
  int y;
};'
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Variabel Struct',
       'Setelah struct dideklarasikan, buat variabel bertipe struct tersebut lalu isi setiap member-nya.',
       'Point p;
p.x = 10;
p.y = 20;'
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Data Mahasiswa',
       'Struct mahasiswa menyimpan nama, NIM, dan IPK sebagai satu unit data.',
       'Mahasiswa mhs;
mhs.nama = "Budi";
mhs.nim = 22101;
mhs.ipk = 3.75;

cout << mhs.nama << endl;'
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami deklarasi struct dan akses member-nya. Selanjutnya, kamu akan menyusun program struct dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 12: EXERCISES LEVEL 31 — Struct Dasar (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi struct',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Mahasiswa"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "string nama;"},
           {"id": "t5", "text": "int nim;"},
           {"id": "t6", "text": "float ipk;"},
           {"id": "t7", "text": "};"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi struct'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun variabel struct',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Point"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int x;"},
           {"id": "t5", "text": "int y;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "Point p;"},
           {"id": "t11", "text": "p.x = 10;"},
           {"id": "t12", "text": "p.y = 20;"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun variabel struct'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun akses member',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Point"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int x;"},
           {"id": "t5", "text": "int y;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "Point p;"},
           {"id": "t11", "text": "cout << p.x;"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun akses member'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun struct dengan input',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Mahasiswa"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "string nama;"},
           {"id": "t5", "text": "int nim;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "Mahasiswa mhs;"},
           {"id": "t11", "text": "cin >> mhs.nama;"},
           {"id": "t12", "text": "cout << mhs.nim;"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun struct dengan input'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun array of struct',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Point"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int x;"},
           {"id": "t5", "text": "int y;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "Point data[3];"},
           {"id": "t11", "text": "data[0].x = 1;"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun array of struct'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 13: MATERIALS LEVEL 32 — Struct & Array
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Array of Struct',
       'Array bisa menyimpan kumpulan struct dengan satu nama, sehingga banyak data dapat diproses dalam satu loop.',
       'Mahasiswa mhs[3];'
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Loop pada Struct Array',
       'Gunakan loop untuk membaca atau menampilkan setiap member pada array of struct.',
       'for (int i = 0; i < 3; i++) {
  cout << mhs[i].nama << endl;
}'
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Pencarian Data',
       'Cari struct tertentu dengan memeriksa member kunci satu per satu sampai ditemukan.',
       'for (int i = 0; i < 3; i++) {
  if (mhs[i].nim == 22101) {
    cout << mhs[i].nama;
    break;
  }
}'
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Data Mahasiswa',
       'Array struct dipakai untuk menyimpan data beberapa mahasiswa beserta nilai mata kuliahnya.',
       'struct Nilai {
  string nama;
  int nilai[3];
};'
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami array of struct serta cara mencari data di dalamnya. Selanjutnya, kamu akan menyusun program struct array dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 14: EXERCISES LEVEL 32 — Struct & Array (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun array of struct data',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Point"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int x;"},
           {"id": "t5", "text": "int y;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "Point data[3];"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun array of struct data'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun loop struct array',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Point"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int x;"},
           {"id": "t5", "text": "};"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "Point data[3];"},
           {"id": "t10", "text": "for (int i = 0; i < 3; i++) {"},
           {"id": "t11", "text": "data[i].x = i;"},
           {"id": "t12", "text": "}"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun loop struct array'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun pencarian nama',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "cariNama(Mhs mhs[], int n, string target)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "for (int i = 0; i < n; i++) {"},
           {"id": "t5", "text": "if (mhs[i].nama == target) {"},
           {"id": "t6", "text": "return i;"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "return -1;"},
           {"id": "t10", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun pencarian nama'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun tambah data',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Mhs"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "string nama;"},
           {"id": "t5", "text": "};"},
           {"id": "t6", "text": "int"},
           {"id": "t7", "text": "main()"},
           {"id": "t8", "text": "{"},
           {"id": "t9", "text": "Mhs mhs[3];"},
           {"id": "t10", "text": "mhs[0].nama = \"Budi\";"},
           {"id": "t11", "text": "cout << mhs[0].nama;"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun tambah data'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun rekap nilai',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "totalSkor(Nilai data[], int n)"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int total = 0;"},
           {"id": "t5", "text": "for (int i = 0; i < n; i++) {"},
           {"id": "t6", "text": "total += data[i].skor;"},
           {"id": "t7", "text": "}"},
           {"id": "t8", "text": "return total;"},
           {"id": "t9", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun rekap nilai'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 15: MATERIALS LEVEL 33 — Enum
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Enum',
       'Enum atau enumerasi adalah tipe data yang berisi daftar nilai konstanta bernama.',
       'enum Status {
  LUNAS,
  BELUM_LUNAS
};'
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Deklarasi Enum',
       'Tulis keyword enum, nama tipe, lalu daftar konstanta di dalam kurung kurawal.',
       'enum Hari {
  SENIN,
  SELASA,
  RABU
};'
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Nilai Default dan Kustom',
       'Secara default konstanta bernilai 0, 1, 2, dan seterusnya. Nilai kustom bisa ditulis manual.',
       'enum Level {
  RENDAH = 1,
  SEDANG = 5,
  TINGGI = 10
};'
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Status Nilai',
       'Enum membuat kondisi lebih mudah dibaca karena memakai nama konstanta yang jelas.',
       'enum Status {
  LUNAS,
  BELUM_LUNAS
};

Status s = LUNAS;
if (s == LUNAS) {
  cout << "Sudah lunas";
}'
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami enum beserta deklarasi dan nilainya. Selanjutnya, kamu akan menyusun program enum dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 16: EXERCISES LEVEL 33 — Enum (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi enum',
       $json${
         "tokens": [
           {"id": "t1", "text": "enum"},
           {"id": "t2", "text": "Status"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "LUNAS,"},
           {"id": "t5", "text": "BELUM_LUNAS,"},
           {"id": "t6", "text": "GAGAL"},
           {"id": "t7", "text": "};"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi enum'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nilai enum',
       $json${
         "tokens": [
           {"id": "t1", "text": "enum"},
           {"id": "t2", "text": "Status"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "LUNAS,"},
           {"id": "t5", "text": "BELUM_LUNAS"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "Status"},
           {"id": "t8", "text": "s"},
           {"id": "t9", "text": "="},
           {"id": "t10", "text": "LUNAS;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nilai enum'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun nilai kustom',
       $json${
         "tokens": [
           {"id": "t1", "text": "enum"},
           {"id": "t2", "text": "Level"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "RENDAH = 1,"},
           {"id": "t5", "text": "SEDANG = 5,"},
           {"id": "t6", "text": "TINGGI = 10"},
           {"id": "t7", "text": "};"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun nilai kustom'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun switch enum',
       $json${
         "tokens": [
           {"id": "t1", "text": "int"},
           {"id": "t2", "text": "main()"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "Status s = LUNAS;"},
           {"id": "t5", "text": "switch (s) {"},
           {"id": "t6", "text": "case LUNAS:"},
           {"id": "t7", "text": "cout << \"Lunas\";"},
           {"id": "t8", "text": "break;"},
           {"id": "t9", "text": "case BELUM_LUNAS:"},
           {"id": "t10", "text": "cout << \"Belum\";"},
           {"id": "t11", "text": "break;"},
           {"id": "t12", "text": "}"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun switch enum'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun cast enum',
       $json${
         "tokens": [
           {"id": "t1", "text": "enum"},
           {"id": "t2", "text": "Status"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "LUNAS,"},
           {"id": "t5", "text": "BELUM_LUNAS"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "int kode = static_cast<int>(LUNAS);"},
           {"id": "t11", "text": "cout << kode;"},
           {"id": "t12", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun cast enum'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 17: MATERIALS LEVEL 34 — Typedef & Using
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Typedef',
       'Typedef memberi nama lain untuk sebuah tipe data sehingga kode jadi lebih ringkas dan mudah dibaca.',
       'typedef int bilangan;
bilangan nilai = 10;'
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Alias Tipe Data',
       'Alias bisa dipakai untuk tipe dasar maupun untuk struct yang punya banyak member.',
       'typedef struct {
  int x;
  int y;
} Titik;'
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Using Sejak C++11',
       'Keyword using membuat alias dengan tampilan yang lebih jelas dibanding typedef.',
       'using bilangan = int;
using Titik = struct TitikData;'
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Matriks dengan Alias',
       'Alias membuat kode yang memakai matriks berukuran tetap jadi lebih mudah dibaca.',
       'using Matriks = int[3][3];
Matriks nilai;'
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami typedef dan using untuk membuat alias tipe data. Selanjutnya, kamu akan menyusun program alias dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 18: EXERCISES LEVEL 34 — Typedef & Using (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun typedef dasar',
       $json${
         "tokens": [
           {"id": "t1", "text": "typedef"},
           {"id": "t2", "text": "int"},
           {"id": "t3", "text": "bilangan;"},
           {"id": "t4", "text": "bilangan"},
           {"id": "t5", "text": "nilai"},
           {"id": "t6", "text": "="},
           {"id": "t7", "text": "10;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun typedef dasar'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun typedef struct',
       $json${
         "tokens": [
           {"id": "t1", "text": "typedef"},
           {"id": "t2", "text": "struct"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int x;"},
           {"id": "t5", "text": "int y;"},
           {"id": "t6", "text": "}"},
           {"id": "t7", "text": "Titik;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun typedef struct'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun using alias',
       $json${
         "tokens": [
           {"id": "t1", "text": "using"},
           {"id": "t2", "text": "bilangan"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "int;"},
           {"id": "t5", "text": "bilangan"},
           {"id": "t6", "text": "nilai = 10;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun using alias'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun typedef function pointer',
       $json${
         "tokens": [
           {"id": "t1", "text": "typedef"},
           {"id": "t2", "text": "void"},
           {"id": "t3", "text": "(*callback)(int);"},
           {"id": "t4", "text": "void"},
           {"id": "t5", "text": "panggil(int x)"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "cout << x << endl;"},
           {"id": "t8", "text": "}"},
           {"id": "t9", "text": "void (*fn)(int) = panggil;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun typedef function pointer'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun alias struct',
       $json${
         "tokens": [
           {"id": "t1", "text": "using"},
           {"id": "t2", "text": "Titik"},
           {"id": "t3", "text": "="},
           {"id": "t4", "text": "TitikData;"},
           {"id": "t5", "text": "int"},
           {"id": "t6", "text": "main()"},
           {"id": "t7", "text": "{"},
           {"id": "t8", "text": "Titik p;"},
           {"id": "t9", "text": "p.x = 5;"},
           {"id": "t10", "text": "cout << p.x;"},
           {"id": "t11", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun alias struct'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 19: MATERIALS LEVEL 35 — Union
-- ============================================

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 1, 'Pengenalan Union',
       'Union menyimpan beberapa member pada alamat memori yang sama, sehingga hanya satu member yang aktif pada satu waktu.',
       'union Data {
  int i;
  float f;
};'
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 1
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 2, 'Perbedaan Struct dan Union',
       'Struct memberi alamat berbeda untuk setiap member, sedangkan union memakai satu alamat bersama.',
       'struct S {
  int a;
  int b;
};  // 8 byte

union U {
  int a;
  int b;
};  // 4 byte'
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 2
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 3, 'Union dan Akses Member',
       'Member union diakses seperti struct, tetapi nilai yang dibaca adalah tipe member terakhir yang ditulis.',
       'union Data {
  int i;
  float f;
};

Data d;
d.i = 10;
d.f = 3.14;  // menimpa nilai yang sama'
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 3
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 4, 'Contoh: Data Nilai',
       'Union sering dipakai untuk menyimpan salah satu dari beberapa tipe pada variabel yang sama.',
       'union Nilai {
  int angka;
  float desimal;
};

Nilai n;
n.angka = 10;
cout << n.angka;'
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 4
  );

INSERT INTO public.materials (level_id, slide_order, title, content, code_snippet)
SELECT l.id, 5, 'Latihan Selanjutnya',
       'Kamu sudah memahami konsep union dan perbedaannya dengan struct. Selanjutnya, kamu akan menyusun program union dan mengerjakan kuis.',
       NULL
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.materials m
    WHERE m.level_id = l.id AND m.slide_order = 5
  );

-- ============================================
-- SECTION 20: EXERCISES LEVEL 35 — Union (drag_drop)
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun deklarasi union',
       $json${
         "tokens": [
           {"id": "t1", "text": "union"},
           {"id": "t2", "text": "Data"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int i;"},
           {"id": "t5", "text": "float f;"},
           {"id": "t6", "text": "char c;"},
           {"id": "t7", "text": "};"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun deklarasi union'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun akses union',
       $json${
         "tokens": [
           {"id": "t1", "text": "union"},
           {"id": "t2", "text": "Data"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int i;"},
           {"id": "t5", "text": "float f;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "Data d;"},
           {"id": "t11", "text": "d.i = 10;"},
           {"id": "t12", "text": "cout << d.i;"},
           {"id": "t13", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun akses union'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun perbandingan struct union',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "S"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int a;"},
           {"id": "t5", "text": "int b;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "union"},
           {"id": "t8", "text": "U"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "int a;"},
           {"id": "t11", "text": "int b;"},
           {"id": "t12", "text": "};"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun perbandingan struct union'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun union dengan struct',
       $json${
         "tokens": [
           {"id": "t1", "text": "struct"},
           {"id": "t2", "text": "Nilai"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "string nama;"},
           {"id": "t5", "text": "union"},
           {"id": "t6", "text": "{"},
           {"id": "t7", "text": "int i;"},
           {"id": "t8", "text": "float f;"},
           {"id": "t9", "text": "} data;"},
           {"id": "t10", "text": "};"},
           {"id": "t11", "text": "Nilai n;"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun union dengan struct'
      AND e.type = 'drag_drop'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'drag_drop', 'Susun input union',
       $json${
         "tokens": [
           {"id": "t1", "text": "union"},
           {"id": "t2", "text": "Data"},
           {"id": "t3", "text": "{"},
           {"id": "t4", "text": "int i;"},
           {"id": "t5", "text": "float f;"},
           {"id": "t6", "text": "};"},
           {"id": "t7", "text": "int"},
           {"id": "t8", "text": "main()"},
           {"id": "t9", "text": "{"},
           {"id": "t10", "text": "Data d;"},
           {"id": "t11", "text": "cout << \"Masukkan angka: \";"},
           {"id": "t12", "text": "cin >> d.i;"},
           {"id": "t13", "text": "cout << d.i;"},
           {"id": "t14", "text": "}"}
         ],
         "answer": ["t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "t10", "t11", "t12", "t13", "t14"],
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Susun input union'
      AND e.type = 'drag_drop'
  );

-- ============================================
-- SECTION 21: VERIFICATION (relatif per level)
-- ============================================
-- Level 26-35: 5 material + 5 exercise dari file ini
-- Verifikasi memakai jumlah per level, bukan total absolut, agar file ini
-- aman dijalankan berdampingan dengan seed.sql dan chunk lain.

DO $$
DECLARE
  v_level INT;
  v_mat INT;
  v_ex INT;
BEGIN
  FOR v_level IN
    SELECT unnest(ARRAY[26, 27, 28, 29, 30, 31, 32, 33, 34, 35])
  LOOP
    SELECT count(*) INTO v_mat
    FROM public.materials m
    JOIN public.levels l ON l.id = m.level_id
    WHERE l.level_number = v_level AND l.language = 'cpp';

    IF v_mat <> 5 THEN
      RAISE EXCEPTION 'Chunk 3 verify: level % expected 5 materials, got %', v_level, v_mat;
    END IF;

    SELECT count(*) INTO v_ex
    FROM public.exercises e
    JOIN public.levels l ON l.id = e.level_id
    WHERE l.level_number = v_level AND l.language = 'cpp'
      AND e.type = 'drag_drop';

    IF v_ex <> 5 THEN
      RAISE EXCEPTION 'Chunk 3 verify: level % expected 5 exercises, got %', v_level, v_ex;
    END IF;
  END LOOP;
END
$$;

COMMIT;
