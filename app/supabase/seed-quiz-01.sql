-- KODIRA — Seed Quiz Chunk 1 (Level 1-15, 3 soal per level = 45 soal)
-- Tanggal: 2026-10-20
--
-- Tujuan:
--   1. Exercises bertipe quiz untuk Level 1-15 (15 level x 3 soal = 45 soal)
--   2. Latihan ini melengkapi 250 drag_drop exercise yang sudah ada
--
-- File ini adalah file seed terpisah untuk tipe quiz. Berkas seed lain
-- (seed.sql, seed-cpp-01.sql, seed-cpp-02.sql, seed-cpp-03.sql,
-- seed-java-01.sql) tidak diubah oleh file ini.
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/seed-quiz-01.sql
--
-- Idempotency:
--   Exercises tidak punya unique constraint pada (level_id, prompt).
--   Karena itu setiap INSERT memakai WHERE NOT EXISTS, bukan ON CONFLICT.
--   File ini aman dijalankan berulang; jumlah baris tidak bertambah.
--
-- Schema payload quiz (v1):
--   {
--     "options": [
--       {"id": "a", "text": "..."},
--       {"id": "b", "text": "..."},
--       {"id": "c", "text": "..."},
--       {"id": "d", "text": "..."}
--     ],
--     "answer": "a",
--     "explanation": "Penjelasan singkat kenapa jawaban itu benar.",
--     "language": "cpp"
--   }
--
-- Aturan isi soal:
--   - selalu ada 4 opsi dengan id a, b, c, dan d
--   - hanya satu opsi yang benar, id-nya ditulis pada field answer
--   - explanation berisi penjelasan singkat dalam Bahasa Indonesia
--   - opsi pengecoh dibuat masuk akal, bukan jawaban yang mustahil
--   - tidak ada opsi "semua benar" atau "semua salah"
--
-- Verifikasi di akhir memakai DO block RELATIF per level (3 quiz + 5 drag_drop)
-- ditambah cek integritas total, sehingga file ini aman dijalankan
-- berdampingan dengan berkas seed lain.

BEGIN;

-- ============================================
-- SECTION 1: QUIZ LEVEL 1 — Pengenalan Program C++
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa fungsi dari baris #include <iostream> pada program C++?',
       $json${
         "options": [
           {"id": "a", "text": "Menyimpan seluruh kode program ke dalam berkas"},
           {"id": "b", "text": "Memuat pustaka yang menyediakan objek cin dan cout"},
           {"id": "c", "text": "Menjalankan program dari baris pertama"},
           {"id": "d", "text": "Mengambil jawaban langsung dari pengguna"}
         ],
         "answer": "b",
         "explanation": "Baris include memberi tahu compiler untuk memuat pustaka iostream yang menyediakan objek cin dan cout.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa fungsi dari baris #include <iostream> pada program C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada program C++, fungsi int main() berfungsi sebagai apa?',
       $json${
         "options": [
           {"id": "a", "text": "Menyimpan data sementara ke dalam variabel"},
           {"id": "b", "text": "Menghitung nilai matematika secara otomatis"},
           {"id": "c", "text": "Titik awal eksekusi program"},
           {"id": "d", "text": "Tempat untuk membebaskan memori yang terpakai"}
         ],
         "answer": "c",
         "explanation": "Fungsi main adalah titik awal program. Semua statement di dalamnya dijalankan pertama kali setelah program dibuka.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada program C++, fungsi int main() berfungsi sebagai apa?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Dalam fungsi int main(), statement return 0; bermakna apa?',
       $json${
         "options": [
           {"id": "a", "text": "Mengulang program dari awal"},
           {"id": "b", "text": "Menghentikan program dengan kode keluar 0 yang berarti berhasil"},
           {"id": "c", "text": "Mengembalikan nilai variabel terakhir"},
           {"id": "d", "text": "Mengabaikan seluruh kesalahan yang terjadi"}
         ],
         "answer": "b",
         "explanation": "return 0 mengirim kode keluar 0 yang menandakan program selesai berjalan normal.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 1 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Dalam fungsi int main(), statement return 0; bermakna apa?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 2: QUIZ LEVEL 2 — Variabel & Konstanta
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah deklarasi variabel integer yang benar?',
       $json${
         "options": [
           {"id": "a", "text": "integer nilai = 10;"},
           {"id": "b", "text": "int nilai = 10;"},
           {"id": "c", "text": "nilai int = 10;"},
           {"id": "d", "text": "int = 10 nilai;"}
         ],
         "answer": "b",
         "explanation": "Deklarasi C++ selalu ditulis tipe data, lalu nama variabel, tanda sama dengan, nilai, dan diakhiri titik koma.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah deklarasi variabel integer yang benar?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa bedanya variabel biasa dengan variabel yang memakai kata kunci const?',
       $json${
         "options": [
           {"id": "a", "text": "Variabel const tidak bisa diubah setelah dideklarasikan"},
           {"id": "b", "text": "Variabel const hanya bisa menyimpan teks"},
           {"id": "c", "text": "Variabel const otomatis disimpan di memori statis"},
           {"id": "d", "text": "Variabel const harus diinisialisasi setiap program dijalankan"}
         ],
         "answer": "a",
         "explanation": "Kata kunci const mengunci nilai variabel setelah inisialisasi sehingga tidak bisa diubah lagi.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa bedanya variabel biasa dengan variabel yang memakai kata kunci const?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan sebaiknya memakai konstanta dalam program?',
       $json${
         "options": [
           {"id": "a", "text": "Untuk nilai yang tetap selama program berjalan, misalnya nilai pi"},
           {"id": "b", "text": "Untuk nilai yang selalu berubah pada setiap iterasi loop"},
           {"id": "c", "text": "Untuk menyimpan hasil input yang diketik pengguna"},
           {"id": "d", "text": "Untuk mendeklarasikan array yang ukurannya berubah"}
         ],
         "answer": "a",
         "explanation": "Konstanta dipakai untuk nilai yang tidak pernah berubah, misalnya nilai pi atau batas maksimum elemen array.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 2 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan sebaiknya memakai konstanta dalam program?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 3: QUIZ LEVEL 3 — Tipe Data Dasar
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Tipe data apa yang tepat untuk menyimpan bilangan bulat seperti 20 atau -5?',
       $json${
         "options": [
           {"id": "a", "text": "double"},
           {"id": "b", "text": "char"},
           {"id": "c", "text": "int"},
           {"id": "d", "text": "bool"}
         ],
         "answer": "c",
         "explanation": "Tipe int menyimpan bilangan bulat tanpa bagian desimal, sedangkan double untuk bilangan pecahan.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Tipe data apa yang tepat untuk menyimpan bilangan bulat seperti 20 atau -5?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Tipe data apa yang dipakai untuk menyimpan bilangan desimal seperti 3.75?',
       $json${
         "options": [
           {"id": "a", "text": "int"},
           {"id": "b", "text": "double"},
           {"id": "c", "text": "char"},
           {"id": "d", "text": "bool"}
         ],
         "answer": "b",
         "explanation": "Tipe double menyimpan bilangan pecahan dengan presisi ganda, sedangkan float dipakai untuk presisi tunggal.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Tipe data apa yang dipakai untuk menyimpan bilangan desimal seperti 3.75?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Tipe data apa yang dipakai untuk menyimpan satu karakter seperti huruf A?',
       $json${
         "options": [
           {"id": "a", "text": "int"},
           {"id": "b", "text": "char"},
           {"id": "c", "text": "double"},
           {"id": "d", "text": "string"}
         ],
         "answer": "b",
         "explanation": "Tipe char menyimpan satu karakter, sedangkan string dipakai untuk menyimpan rangkaian karakter.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 3 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Tipe data apa yang dipakai untuk menyimpan satu karakter seperti huruf A?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 4: QUIZ LEVEL 4 — Operator Aritmatika
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Berapa hasil dari perhitungan 10 % 3?',
       $json${
         "options": [
           {"id": "a", "text": "1"},
           {"id": "b", "text": "3"},
           {"id": "c", "text": "0"},
           {"id": "d", "text": "10"}
         ],
         "answer": "a",
         "explanation": "Operator modulo menghasilkan sisa pembagian, sehingga 10 % 3 bernilai 1.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Berapa hasil dari perhitungan 10 % 3?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Berapa hasil dari perhitungan 2 + 3 * 4?',
       $json${
         "options": [
           {"id": "a", "text": "20"},
           {"id": "b", "text": "14"},
           {"id": "c", "text": "24"},
           {"id": "d", "text": "9"}
         ],
         "answer": "b",
         "explanation": "Perkalian dihitung lebih dulu karena operator kali punya prioritas lebih tinggi, jadi 3 * 4 = 12 lalu 2 + 12 = 14.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Berapa hasil dari perhitungan 2 + 3 * 4?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Berapa hasil dari pembagian 7 / 2 bila kedua operand bertipe int?',
       $json${
         "options": [
           {"id": "a", "text": "3.5"},
           {"id": "b", "text": "4"},
           {"id": "c", "text": "3"},
           {"id": "d", "text": "2"}
         ],
         "answer": "c",
         "explanation": "Pembagian dua bilangan bulat menghasilkan bagian bulat saja, sehingga bagian desimalnya dipotong.",
         "language": "cpp"
       }$json$::jsonb,
       1
FROM public.levels l
WHERE l.level_number = 4 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Berapa hasil dari pembagian 7 / 2 bila kedua operand bertipe int?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 5: QUIZ LEVEL 5 — Operator Logika
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa hasil dari operasi logika true && false?',
       $json${
         "options": [
           {"id": "a", "text": "true"},
           {"id": "b", "text": "false"},
           {"id": "c", "text": "1"},
           {"id": "d", "text": "Tidak bisa ditentukan karena keduanya boolean"}
         ],
         "answer": "b",
         "explanation": "Operator AND (tanda &&) hanya bernilai true bila kedua kondisi bernilai true, jadi true && false menghasilkan false.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa hasil dari operasi logika true && false?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa hasil dari operasi logika true || false?',
       $json${
         "options": [
           {"id": "a", "text": "false"},
           {"id": "b", "text": "true"},
           {"id": "c", "text": "0"},
           {"id": "d", "text": "Tidak bisa ditentukan karena keduanya boolean"}
         ],
         "answer": "b",
         "explanation": "Operator OR bernilai true bila salah satu saja dari kedua kondisi bernilai true, jadi true || false menghasilkan true.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa hasil dari operasi logika true || false?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang dilakukan oleh operator NOT (tanda ! ) pada nilai boolean?',
       $json${
         "options": [
           {"id": "a", "text": "Menyamakan dua nilai"},
           {"id": "b", "text": "Membalik nilai boolean"},
           {"id": "c", "text": "Menambah satu ke nilai boolean"},
           {"id": "d", "text": "Menggabungkan dua kondisi logika"}
         ],
         "answer": "b",
         "explanation": "Operator NOT membalik nilai boolean sehingga true menjadi false dan sebaliknya.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 5 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang dilakukan oleh operator NOT (tanda ! ) pada nilai boolean?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 6: QUIZ LEVEL 6 — If Sederhana
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah penulisan if yang benar untuk memeriksa nilai lebih besar dari sepuluh?',
       $json${
         "options": [
           {"id": "a", "text": "if (nilai > 10) { ... }"},
           {"id": "b", "text": "if nilai > 10 { ... }"},
           {"id": "c", "text": "if (nilai > 10; { ... }"},
           {"id": "d", "text": "if [nilai > 10] { ... }"}
         ],
         "answer": "a",
         "explanation": "Kondisi if harus diapit tanda kurung dan blok statement diapit kurung kurawal.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah penulisan if yang benar untuk memeriksa nilai lebih besar dari sepuluh?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang terjadi pada statement di dalam blok if ketika kondisinya bernilai false?',
       $json${
         "options": [
           {"id": "a", "text": "Statement di dalam blok tetap dijalankan"},
           {"id": "b", "text": "Statement di dalam blok dilewati seluruhnya"},
           {"id": "c", "text": "Statement di dalam blok dijalankan dua kali"},
           {"id": "d", "text": "Program langsung berhenti dijalankan"}
         ],
         "answer": "b",
         "explanation": "Blok if hanya dijalankan ketika kondisi bernilai true, jika kondisi false blok tersebut dilewati.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang terjadi pada statement di dalam blok if ketika kondisinya bernilai false?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah penulisan if yang benar untuk satu statement tanpa kurung kurawal?',
       $json${
         "options": [
           {"id": "a", "text": "if (nilai > 0) cout << \"Positif\";"},
           {"id": "b", "text": "if (nilai > 0) { cout << \"Positif\";"},
           {"id": "c", "text": "if nilai > 0 cout << \"Positif\";"},
           {"id": "d", "text": "if (nilai > 0) cout << \"Positif\""}
         ],
         "answer": "a",
         "explanation": "Kurung kurawal boleh dilewati untuk satu statement, tetapi statement tetap harus diakhiri titik koma.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 6 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah penulisan if yang benar untuk satu statement tanpa kurung kurawal?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 7: QUIZ LEVEL 7 — If-Else
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah sintaks if-else yang benar?',
       $json${
         "options": [
           {"id": "a", "text": "if (nilai >= 70) { ... } else { ... }"},
           {"id": "b", "text": "if (nilai >= 70) { ... } else if { ... }"},
           {"id": "c", "text": "else if (nilai >= 70) { ... } else { ... }"},
           {"id": "d", "text": "if (nilai >= 70), else { ... }"}
         ],
         "answer": "a",
         "explanation": "Blok else ditulis setelah blok if dan tidak memakai kondisi sendiri.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah sintaks if-else yang benar?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan blok else dijalankan?',
       $json${
         "options": [
           {"id": "a", "text": "Saat kondisi pada if bernilai true"},
           {"id": "b", "text": "Saat kondisi pada if bernilai false"},
           {"id": "c", "text": "Setelah program dijalankan ulang"},
           {"id": "d", "text": "Setiap kali nilai variabel di dalam if berubah"}
         ],
         "answer": "b",
         "explanation": "Blok else adalah cabang alternatif yang berjalan ketika kondisi if tidak terpenuhi.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan blok else dijalankan?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk tiga kondisi berbeda, struktur percabangan mana yang paling tepat?',
       $json${
         "options": [
           {"id": "a", "text": "Rantai if, else if, dan else"},
           {"id": "b", "text": "Tiga blok if terpisah yang masing-masing punya kondisi sendiri"},
           {"id": "c", "text": "Satu blok switch dengan dua case"},
           {"id": "d", "text": "Perulangan while yang saling bersarang"}
         ],
         "answer": "a",
         "explanation": "Rantai if-else-if memeriksa kondisi satu per satu dari atas dan menjalankan cabang pertama yang cocok.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 7 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk tiga kondisi berbeda, struktur percabangan mana yang paling tepat?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 8: QUIZ LEVEL 8 — Nested If
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang dimaksud dengan nested if?',
       $json${
         "options": [
           {"id": "a", "text": "If yang diletakkan di dalam blok if lain"},
           {"id": "b", "text": "If yang memiliki dua kondisi sekaligus"},
           {"id": "c", "text": "If yang dijalankan dua kali berturut-turut"},
           {"id": "d", "text": "If yang ditulis tanpa kurung kurawal"}
         ],
         "answer": "a",
         "explanation": "Nested if adalah pernyataan if yang berada di dalam tubuh if atau else if lainnya sehingga membentuk pola bertingkat.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang dimaksud dengan nested if?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan nested if lebih baik dipakai daripada satu if dengan operator AND (tanda &&)?',
       $json${
         "options": [
           {"id": "a", "text": "Saat jumlah kondisi yang perlu diperiksa banyak dan bertingkat"},
           {"id": "b", "text": "Saat program harus dijalankan berulang kali"},
           {"id": "c", "text": "Saat nilai variabel bertipe teks"},
           {"id": "d", "text": "Saat program tidak punya kondisi sama sekali"}
         ],
         "answer": "a",
         "explanation": "Nested if memisahkan pengecekan secara berurutan sehingga kondisi kedua hanya diperiksa bila kondisi pertama terpenuhi.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan nested if lebih baik dipakai daripada satu if dengan operator AND (tanda &&)?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada kode if (a > 0) { if (b > 0) { ... } } dengan a bernilai 5 dan b bernilai -3, apa yang terjadi?',
       $json${
         "options": [
           {"id": "a", "text": "Statement di dalam blok paling dalam dijalankan"},
           {"id": "b", "text": "Statement di dalam blok paling dalam dilewati"},
           {"id": "c", "text": "Program berhenti dijalankan karena nilai negatif"},
           {"id": "d", "text": "Kedua blok dijalankan sekaligus"}
         ],
         "answer": "b",
         "explanation": "Kondisi luar terpenuhi karena a positif, tetapi kondisi dalam gagal karena b negatif sehingga statement terdalam dilewati.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 8 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada kode if (a > 0) { if (b > 0) { ... } } dengan a bernilai 5 dan b bernilai -3, apa yang terjadi?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 9: QUIZ LEVEL 9 — Switch-Case
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa fungsi statement break di dalam switch?',
       $json${
         "options": [
           {"id": "a", "text": "Menghentikan eksekusi switch agar tidak jatuh ke case berikutnya"},
           {"id": "b", "text": "Mengulang eksekusi case sebelumnya"},
           {"id": "c", "text": "Menghapus seluruh isi blok switch"},
           {"id": "d", "text": "Menghentikan program secara keseluruhan"}
         ],
         "answer": "a",
         "explanation": "Setiap case diakhiri break agar program berhenti pada cabang tersebut dan tidak melanjutkan ke case berikutnya.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa fungsi statement break di dalam switch?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa fungsi case default di dalam switch?',
       $json${
         "options": [
           {"id": "a", "text": "Menjalankan kode setiap kali program baru dibuka"},
           {"id": "b", "text": "Menangani nilai yang tidak cocok dengan case manapun"},
           {"id": "c", "text": "Menghapus semua case yang ada sebelumnya"},
           {"id": "d", "text": "Mengulang seluruh blok switch sampai program berhenti"}
         ],
         "answer": "b",
         "explanation": "Case default menjadi pilihan cadangan saat nilai yang diperiksa switch tidak termasuk case yang tersedia.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa fungsi case default di dalam switch?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Tipe data apa yang boleh dipakai sebagai nilai yang diperiksa switch?',
       $json${
         "options": [
           {"id": "a", "text": "bool dan double"},
           {"id": "b", "text": "double dan string"},
           {"id": "c", "text": "char dan int"},
           {"id": "d", "text": "Hanya string"}
         ],
         "answer": "c",
         "explanation": "Nilai switch harus bertipe bulat atau karakter, bukan boolean, bilangan pecahan, maupun teks.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 9 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Tipe data apa yang boleh dipakai sebagai nilai yang diperiksa switch?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 10: QUIZ LEVEL 10 — Operator Ternary
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah penulisan operator ternary yang benar?',
       $json${
         "options": [
           {"id": "a", "text": "int hasil = (nilai > 10) ? 1 : 0;"},
           {"id": "b", "text": "int hasil = (nilai > 10) : 1 ? 0;"},
           {"id": "c", "text": "int hasil = (nilai > 10) ? 1 ; 0;"},
           {"id": "d", "text": "int hasil = (nilai > 10) ?? 1 :: 0;"}
         ],
         "answer": "a",
         "explanation": "Ternary ditulis sebagai kondisi, lalu tanda tanya, nilai saat kondisi benar, tanda titik dua, dan nilai saat kondisi salah.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah penulisan operator ternary yang benar?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Ekspresi int hasil = (nilai >= 70) ? 1 : 0; setara dengan struktur if-else yang mana?',
       $json${
         "options": [
           {"id": "a", "text": "if (nilai >= 70) { hasil = 1; } else { hasil = 0; }"},
           {"id": "b", "text": "if (nilai >= 70) { hasil = 0; } else { hasil = 1; }"},
           {"id": "c", "text": "while (nilai >= 70) { hasil = 1; }"},
           {"id": "d", "text": "switch (nilai) { case 70: hasil = 1; }"}
         ],
         "answer": "a",
         "explanation": "Ternary memilih nilai 1 saat kondisi benar dan 0 saat kondisi salah, sama persis dengan cabang if-else biasa.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Ekspresi int hasil = (nilai >= 70) ? 1 : 0; setara dengan struktur if-else yang mana?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan operator ternary paling tepat dipakai?',
       $json${
         "options": [
           {"id": "a", "text": "Untuk logika panjang yang membutuhkan banyak baris"},
           {"id": "b", "text": "Untuk memilih satu nilai dari dua pilihan sederhana"},
           {"id": "c", "text": "Untuk mengulang statement berkali-kali"},
           {"id": "d", "text": "Untuk menyimpan sekumpulan data ke dalam array"}
         ],
         "answer": "b",
         "explanation": "Ternary paling pas untuk percabangan singkat yang menghasilkan satu nilai, bukan untuk logika berlapis.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 10 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan operator ternary paling tepat dipakai?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 11: QUIZ LEVEL 11 — For Loop
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa tiga bagian utama yang ada di dalam struktur perulangan for?',
       $json${
         "options": [
           {"id": "a", "text": "Inisialisasi variabel, pemeriksaan kondisi, dan perubahan variabel kontrol"},
           {"id": "b", "text": "Tipe data, nama variabel, dan nilai awal"},
           {"id": "c", "text": "Pernyataan, kondisi, dan pengulangan blok"},
           {"id": "d", "text": "Deklarasi, isi, dan penutup kurung kurawal"}
         ],
         "answer": "a",
         "explanation": "Perulangan for punya inisialisasi variabel, pemeriksaan kondisi, dan perubahan variabel kontrol pada setiap iterasi.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa tiga bagian utama yang ada di dalam struktur perulangan for?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Berapa kali statement di dalam loop dijalankan untuk for (int i = 0; i < 5; i++)?',
       $json${
         "options": [
           {"id": "a", "text": "4 kali"},
           {"id": "b", "text": "5 kali"},
           {"id": "c", "text": "6 kali"},
           {"id": "d", "text": "1 kali"}
         ],
         "answer": "b",
         "explanation": "Nilai i berjalan dari 0 sampai 4 karena syarat i kurang dari 5, sehingga statement dijalankan lima kali.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Berapa kali statement di dalam loop dijalankan untuk for (int i = 0; i < 5; i++)?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan lebih tepat memakai perulangan for daripada perulangan while?',
       $json${
         "options": [
           {"id": "a", "text": "Saat jumlah iterasi sudah diketahui sejak awal"},
           {"id": "b", "text": "Saat program harus berjalan tanpa henti"},
           {"id": "c", "text": "Saat variabel kontrol tidak pernah berubah"},
           {"id": "d", "text": "Saat statement continue dipakai di dalam loop"}
         ],
         "answer": "a",
         "explanation": "Perulangan for menggabungkan inisialisasi, kondisi, dan perubahan dalam satu baris sehingga cocok saat iterasi sudah diketahui.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 11 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan lebih tepat memakai perulangan for daripada perulangan while?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 12: QUIZ LEVEL 12 — While Loop
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang harus dipenuhi agar perulangan while tidak berjalan tanpa akhir?',
       $json${
         "options": [
           {"id": "a", "text": "Variabel kontrol selalu berubah sehingga kondisi akhirnya bernilai false"},
           {"id": "b", "text": "Kondisi di dalam while selalu bernilai true"},
           {"id": "c", "text": "Blok statement diapit kurung kurawal"},
           {"id": "d", "text": "Perintah return ditulis di awal loop"}
         ],
         "answer": "a",
         "explanation": "Perulangan while berhenti saat kondisinya false, jadi variabel kontrol wajib berubah menuju kondisi tersebut.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang harus dipenuhi agar perulangan while tidak berjalan tanpa akhir?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa penyebab paling umum perulangan while berjalan tanpa henti?',
       $json${
         "options": [
           {"id": "a", "text": "Variabel kontrol di dalam loop tidak pernah berubah"},
           {"id": "b", "text": "Kurangnya tanda titik koma di akhir statement"},
           {"id": "c", "text": "Kondisi ditulis tanpa tanda kurung"},
           {"id": "d", "text": "Blok statement di dalam loop kosong"}
         ],
         "answer": "a",
         "explanation": "Jika variabel kontrol tidak pernah diubah, kondisi while akan tetap bernilai true dan loop tidak pernah berhenti.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa penyebab paling umum perulangan while berjalan tanpa henti?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa perbedaan utama antara perulangan while dan do-while?',
       $json${
         "options": [
           {"id": "a", "text": "While selalu menjalankan blok minimal satu kali"},
           {"id": "b", "text": "Do-while selalu menjalankan blok minimal satu kali"},
           {"id": "c", "text": "Keduanya tidak memiliki perbedaan sama sekali"},
           {"id": "d", "text": "While hanya bisa dipakai pada bilangan bulat"}
         ],
         "answer": "b",
         "explanation": "Do-while menjalankan blok minimal satu kali sebelum kondisinya diperiksa, sedangkan while memeriksa kondisi lebih dulu.",
         "language": "cpp"
       }$json$::jsonb,
       2
FROM public.levels l
WHERE l.level_number = 12 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa perbedaan utama antara perulangan while dan do-while?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 13: QUIZ LEVEL 13 — Do-While Loop
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa perbedaan antara do-while dengan while?',
       $json${
         "options": [
           {"id": "a", "text": "Do-while memeriksa kondisi sebelum menjalankan blok statement"},
           {"id": "b", "text": "Do-while menjalankan blok statement dulu lalu memeriksa kondisi"},
           {"id": "c", "text": "Keduanya tidak memiliki perbedaan sama sekali"},
           {"id": "d", "text": "Do-while hanya bisa dipakai pada array"}
         ],
         "answer": "b",
         "explanation": "Do-while mengeksekusi blok sebelum kondisi diperiksa, sehingga blok selalu berjalan minimal satu kali.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa perbedaan antara do-while dengan while?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Berapa kali blok statement do-while dijalankan bila kondisi awal sudah bernilai false?',
       $json${
         "options": [
           {"id": "a", "text": "0 kali"},
           {"id": "b", "text": "1 kali"},
           {"id": "c", "text": "2 kali"},
           {"id": "d", "text": "Tidak terbatas"}
         ],
         "answer": "b",
         "explanation": "Blok do-while dijalankan lebih dulu sebelum kondisi dicek, jadi meskipun kondisi awal false blok tetap jalan satu kali.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Berapa kali blok statement do-while dijalankan bila kondisi awal sudah bernilai false?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan perulangan do-while paling tepat dipakai?',
       $json${
         "options": [
           {"id": "a", "text": "Saat input pengguna harus diminta ulang sampai nilainya valid"},
           {"id": "b", "text": "Saat jumlah iterasi sudah diketahui sejak awal"},
           {"id": "c", "text": "Saat perlu mencetak pola berbentuk bintang"},
           {"id": "d", "text": "Saat menyimpan data ke dalam array"}
         ],
         "answer": "a",
         "explanation": "Do-while cocok untuk validasi input karena blok selalu dijalankan minimal satu kali sebelum kondisi diperiksa.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 13 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan perulangan do-while paling tepat dipakai?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 14: QUIZ LEVEL 14 — Nested Loop
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang dimaksud dengan nested loop?',
       $json${
         "options": [
           {"id": "a", "text": "Dua perulangan yang salah satunya berada di dalam perulangan lain"},
           {"id": "b", "text": "Dua perulangan yang dijalankan bersamaan"},
           {"id": "c", "text": "Perulangan yang diulang dua kali berturut-turut"},
           {"id": "d", "text": "Perulangan tanpa variabel kontrol"}
         ],
         "answer": "a",
         "explanation": "Nested loop berarti satu perulangan ditempatkan di dalam tubuh perulangan lainnya sehingga loop dalam diulang untuk setiap iterasi loop luar.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang dimaksud dengan nested loop?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Berapa total iterasi statement di dalam untuk dua perulangan dengan ukuran 3 dan 3?',
       $json${
         "options": [
           {"id": "a", "text": "6 kali"},
           {"id": "b", "text": "9 kali"},
           {"id": "c", "text": "12 kali"},
           {"id": "d", "text": "3 kali"}
         ],
         "answer": "b",
         "explanation": "Jumlah iterasi total adalah perkalian iterasi luar dan iterasi dalam, yaitu 3 kali 3 sama dengan 9.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Berapa total iterasi statement di dalam untuk dua perulangan dengan ukuran 3 dan 3?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Contoh penggunaan nested loop yang tepat adalah?',
       $json${
         "options": [
           {"id": "a", "text": "Mencetak tabel perkalian berukuran 3 kali 3"},
           {"id": "b", "text": "Menyimpan satu nilai ke dalam variabel"},
           {"id": "c", "text": "Menghitung luas dari sebuah persegi"},
           {"id": "d", "text": "Membaca satu baris teks dari pengguna"}
         ],
         "answer": "a",
         "explanation": "Nested loop dipakai ketika data berbentuk tabel, misalnya mencetak tabel perkalian dari 1 sampai 3.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 14 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Contoh penggunaan nested loop yang tepat adalah?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 15: QUIZ LEVEL 15 — Break & Continue
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa fungsi statement break di dalam perulangan?',
       $json${
         "options": [
           {"id": "a", "text": "Menghentikan perulangan sepenuhnya"},
           {"id": "b", "text": "Melewati satu iterasi lalu melanjutkan perulangan"},
           {"id": "c", "text": "Mengulang iterasi terakhir sekali lagi"},
           {"id": "d", "text": "Menghapus nilai variabel kontrol perulangan"}
         ],
         "answer": "a",
         "explanation": "Break langsung menghentikan perulangan dan statement setelah loop dijalankan.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa fungsi statement break di dalam perulangan?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa fungsi statement continue di dalam perulangan?',
       $json${
         "options": [
           {"id": "a", "text": "Menghentikan seluruh program sekaligus"},
           {"id": "b", "text": "Melewati sisa statement pada iterasi itu lalu lanjut ke iterasi berikutnya"},
           {"id": "c", "text": "Mengulang blok statement dari awal"},
           {"id": "d", "text": "Menghapus isi array yang sedang diproses"}
         ],
         "answer": "b",
         "explanation": "Continue langsung lompat ke awal iterasi berikutnya tanpa menjalankan statement yang tersisa pada iterasi tersebut.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa fungsi statement continue di dalam perulangan?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa perbedaan utama antara break dan continue?',
       $json${
         "options": [
           {"id": "a", "text": "Keduanya menjalankan perintah yang sama persis"},
           {"id": "b", "text": "Break menghentikan perulangan, sedangkan continue hanya melewati satu iterasi"},
           {"id": "c", "text": "Break hanya bisa dipakai di while, sedangkan continue hanya di for"},
           {"id": "d", "text": "Continue menghentikan program, sedangkan break melanjutkan program"}
         ],
         "answer": "b",
         "explanation": "Break keluar dari perulangan sepenuhnya, sedangkan continue tetap di dalam loop dan hanya melewati iterasi yang sedang berjalan.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 15 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa perbedaan utama antara break dan continue?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 16: VERIFICATION (relatif per level + integritas total)
-- ============================================
-- Level 1-15: 3 quiz + 5 drag_drop per level
-- Verifikasi memakai jumlah per level, bukan total absolut, agar file ini
-- aman dijalankan berdampingan dengan berkas seed lain.

DO $$
DECLARE
  v_level INT;
  v_quiz INT;
  v_drag INT;
  v_total_mat INT;
  v_total_ex INT;
BEGIN
  FOR v_level IN
    SELECT unnest(ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])
  LOOP
    SELECT count(*) INTO v_quiz
    FROM public.exercises e
    JOIN public.levels l ON l.id = e.level_id
    WHERE l.level_number = v_level AND l.language = 'cpp'
      AND e.type = 'quiz';

    IF v_quiz <> 3 THEN
      RAISE EXCEPTION 'Quiz seed verify: level % expected 3 quiz, got %', v_level, v_quiz;
    END IF;

    SELECT count(*) INTO v_drag
    FROM public.exercises e
    JOIN public.levels l ON l.id = e.level_id
    WHERE l.level_number = v_level AND l.language = 'cpp'
      AND e.type = 'drag_drop';

    IF v_drag <> 5 THEN
      RAISE EXCEPTION 'Quiz seed verify: level % drag_drop rusak, expected 5 got %', v_level, v_drag;
    END IF;
  END LOOP;

  SELECT count(*) INTO v_total_mat FROM public.materials;
  IF v_total_mat <> 250 THEN
    RAISE EXCEPTION 'Quiz seed verify: materials should be 250, got %', v_total_mat;
  END IF;

  SELECT count(*) INTO v_total_ex FROM public.exercises;
  IF v_total_ex <> 295 THEN
    RAISE EXCEPTION 'Quiz seed verify: exercises should be 295 (250 drag + 45 quiz), got %', v_total_ex;
  END IF;
END
$$;

COMMIT;
