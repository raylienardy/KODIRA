-- KODIRA — Seed Quiz Chunk 2 (Level 16-50, 3 soal per level = 105 soal)
-- Tanggal: 2026-10-22
--
-- Tujuan:
--   1. Exercises bertipe quiz untuk Level 16-50 (35 level x 3 soal = 105 soal)
--   2. Melengkapi 45 soal quiz Level 1-15 yang sudah ada, sehingga seluruh
--      50 level punya 3 soal quiz (total 150 soal quiz di database)
--
-- File ini adalah file seed terpisah untuk tipe quiz. Berkas seed lain
-- (seed.sql, seed-cpp-01.sql, seed-cpp-02.sql, seed-cpp-03.sql,
-- seed-java-01.sql, seed-quiz-01.sql) tidak diubah oleh file ini.
--
-- Cara menjalankan (dari folder app/):
--   supabase db query --linked --file supabase/seed-quiz-02.sql
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
--   - language memakai cpp untuk Level 16-35 dan java untuk Level 36-50
--
-- Verifikasi di akhir memakai DO block RELATIF per level (3 quiz + 5 drag_drop)
-- ditambah cek integritas total, sehingga file ini aman dijalankan
-- berdampingan dengan berkas seed lain.

BEGIN;

-- ============================================
-- SECTION 1: QUIZ LEVEL 16 — Pengenalan Fungsi
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada deklarasi fungsi C++ berikut: int hitungLuas(int panjang, int lebar), apa arti kata int sebelum nama fungsi?',
       $json${
         "options": [
           {"id": "a", "text": "Tipe data nilai yang dikembalikan fungsi tersebut"},
           {"id": "b", "text": "Jumlah parameter yang boleh diterima fungsi"},
           {"id": "c", "text": "Nama variabel lokal yang dipakai di dalam fungsi"},
           {"id": "d", "text": "Menyimpan nomor urut parameter fungsi"}
         ],
         "answer": "a",
         "explanation": "Kata int sebelum nama fungsi adalah tipe data return, yaitu tipe nilai yang dikembalikan fungsi kepada pemanggilnya.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada deklarasi fungsi C++ berikut: int hitungLuas(int panjang, int lebar), apa arti kata int sebelum nama fungsi?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk memakai sebuah fungsi yang sudah dideklarasikan di dalam program, apa yang harus dilakukan?',
       $json${
         "options": [
           {"id": "a", "text": "Mendeklarasikan ulang fungsi dengan nama berbeda"},
           {"id": "b", "text": "Memanggil fungsi tersebut dari main atau dari fungsi lain"},
           {"id": "c", "text": "Menyimpan nama fungsi di dalam variabel lokal"},
           {"id": "d", "text": "Menyalin seluruh isi fungsi ke dalam main"}
         ],
         "answer": "b",
         "explanation": "Fungsi dijalankan dengan cara dipanggil, yaitu menuliskan namanya diikuti tanda kurung dan argumen sesuai kebutuhannya.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk memakai sebuah fungsi yang sudah dideklarasikan di dalam program, apa yang harus dilakukan?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang terjadi ketika sebuah fungsi bertipe void dipanggil di dalam program?',
       $json${
         "options": [
           {"id": "a", "text": "Fungsi tersebut mengembalikan nilai 0 secara otomatis"},
           {"id": "b", "text": "Compiler menampilkan pesan kesalahan saat dijalankan"},
           {"id": "c", "text": "Fungsi berjalan sampai selesai tanpa mengembalikan nilai apa pun"},
           {"id": "d", "text": "Program berhenti dan keluar dari fungsi main"}
         ],
         "answer": "c",
         "explanation": "Fungsi bertipe void tidak punya nilai balik, sehingga setelah selesai hanya kembali ke baris pemanggil tanpa hasil.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 16 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang terjadi ketika sebuah fungsi bertipe void dipanggil di dalam program?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 2: QUIZ LEVEL 17 — Parameter & Argumen
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Dalam pemanggilan fungsi, istilah manakah yang dipakai untuk nilai nyata yang dikirimkan ke parameter fungsi?',
       $json${
         "options": [
           {"id": "a", "text": "Variabel global"},
           {"id": "b", "text": "Argumen"},
           {"id": "c", "text": "Tipe data"},
           {"id": "d", "text": "Nilai balik"}
         ],
         "answer": "b",
         "explanation": "Argumen adalah nilai nyata yang dikirim saat fungsi dipanggil, sedangkan parameter adalah variabel placeholder di deklarasi fungsi.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Dalam pemanggilan fungsi, istilah manakah yang dipakai untuk nilai nyata yang dikirimkan ke parameter fungsi?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Ketika sebuah fungsi menerima parameter int secara bawaan nilai, apa yang terjadi pada variabel asal di luar fungsi?',
       $json${
         "options": [
           {"id": "a", "text": "Variabel asal otomatis berubah menjadi variabel global"},
           {"id": "b", "text": "Nilai variabel asal ikut berubah mengikuti perubahan di dalam fungsi"},
           {"id": "c", "text": "Nilai variabel asal tidak berubah karena fungsi bekerja pada salinan"},
           {"id": "d", "text": "Program berhenti karena variabel asal sedang dikunci"}
         ],
         "answer": "c",
         "explanation": "Bawaan nilai menyalin nilai ke dalam parameter fungsi, sehingga perubahan di dalam fungsi tidak memengaruhi variabel pemanggil.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Ketika sebuah fungsi menerima parameter int secara bawaan nilai, apa yang terjadi pada variabel asal di luar fungsi?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Saat fungsi dengan dua parameter int dipanggil dengan argumen yang ditulis terbalik urutannya, yang terjadi adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Ditolak compiler karena urutan argumen tidak boleh diubah"},
           {"id": "b", "text": "Nilai argumen kedua otomatis ditukar oleh compiler"},
           {"id": "c", "text": "Fungsi dijalankan dua kali untuk dua kemungkinan urutan"},
           {"id": "d", "text": "Nilai dipetakan ke parameter menurut urutan posisi penulisan argumen"}
         ],
         "answer": "d",
         "explanation": "Nilai argumen dipetakan ke parameter berdasarkan urutan posisi, jadi urutan penulisan harus sama dengan urutan deklarasi parameter.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 17 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Saat fungsi dengan dua parameter int dipanggil dengan argumen yang ditulis terbalik urutannya, yang terjadi adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 3: QUIZ LEVEL 18 — Return Value
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang dilakukan statement return pada sebuah fungsi bertipe int?',
       $json${
         "options": [
           {"id": "a", "text": "Menyimpan salinan fungsi ke dalam variabel int"},
           {"id": "b", "text": "Menampilkan nilai int tersebut langsung di layar"},
           {"id": "c", "text": "Menghentikan eksekusi fungsi dan mengirim nilai int ke pemanggil"},
           {"id": "d", "text": "Mengulang baris terakhir fungsi sampai selesai"}
         ],
         "answer": "c",
         "explanation": "Statement return menghentikan fungsi saat itu juga dan mengirim nilai balik sesuai tipe return yang dideklarasikan.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang dilakukan statement return pada sebuah fungsi bertipe int?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Fungsi dengan tipe return void yang dipanggil di dalam program akan...',
       $json${
         "options": [
           {"id": "a", "text": "Mengulang pemanggilan fungsi sampai tidak terjadi galat"},
           {"id": "b", "text": "Selalu mengembalikan angka 0 kepada pemanggil"},
           {"id": "c", "text": "Menghapus seluruh variabel yang dipakai di dalamnya"},
           {"id": "d", "text": "Selesai tanpa ada nilai yang diterima pemanggil"}
         ],
         "answer": "d",
         "explanation": "Karena void berarti tidak ada nilai balik, pemanggil tidak menerima apa pun dari fungsi tersebut.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Fungsi dengan tipe return void yang dipanggil di dalam program akan...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang tepat untuk menyimpan nilai balik fungsi int hitungLuas ke dalam variabel luas?',
       $json${
         "options": [
           {"id": "a", "text": "int luas = hitungLuas(4, 5);"},
           {"id": "b", "text": "int luas hitungLuas(4, 5);"},
           {"id": "c", "text": "hitungLuas(4, 5) = int luas;"},
           {"id": "d", "text": "void luas = hitungLuas(4, 5);"}
         ],
         "answer": "a",
         "explanation": "Nilai balik fungsi ditugaskan ke variabel memakai operator sama dengan, dan tipe variabel harus sesuai dengan tipe return fungsi.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 18 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang tepat untuk menyimpan nilai balik fungsi int hitungLuas ke dalam variabel luas?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 4: QUIZ LEVEL 19 — Fungsi Rekursif
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Dalam fungsi rekursif, apa yang disebut dengan kasus dasar?',
       $json${
         "options": [
           {"id": "a", "text": "Variabel global yang menyimpan hitungan rekursi"},
           {"id": "b", "text": "Header pustaka yang dibutuhkan fungsi rekursif"},
           {"id": "c", "text": "Fungsi kedua yang dipanggil setelah fungsi utama"},
           {"id": "d", "text": "Kondisi yang menghentikan pemanggilan berulang fungsi"}
         ],
         "answer": "d",
         "explanation": "Kasus dasar adalah kondisi berhenti yang mengembalikan nilai tanpa memanggil fungsi itu lagi, sehingga rekursi tidak berjalan selamanya.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Dalam fungsi rekursif, apa yang disebut dengan kasus dasar?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk menghitung faktorial secara rekursif, pemanggilan faktorial(n) di dalam dirinya sendiri harus memanggil...',
       $json${
         "options": [
           {"id": "a", "text": "faktorial(n - 1) sampai tercapai kasus dasar"},
           {"id": "b", "text": "fungsi main supaya perhitungannya diulang dari awal"},
           {"id": "c", "text": "dirinya sendiri dengan argumen yang sama persis"},
           {"id": "d", "text": "faktorial(n + 1) sampai nilai menjadi nol"}
         ],
         "answer": "a",
         "explanation": "Pola rekursi mengurangi masalah sebesar satu langkah, yaitu memanggil fungsi dengan n - 1, lalu berhenti pada kasus dasar.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk menghitung faktorial secara rekursif, pemanggilan faktorial(n) di dalam dirinya sendiri harus memanggil...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa risiko utama jika kasus dasar pada sebuah fungsi rekursif tidak pernah terpenuhi?',
       $json${
         "options": [
           {"id": "a", "text": "Nilai yang dikembalikan selalu bernilai nol"},
           {"id": "b", "text": "Program berjalan tanpa henti sampai kehabisan stack"},
           {"id": "c", "text": "Compiler otomatis mengubah fungsi rekursif menjadi perulangan"},
           {"id": "d", "text": "Program langsung berhenti dengan pesan galat saat dikompilasi"}
         ],
         "answer": "b",
         "explanation": "Tanpa kasus dasar, pemanggilan berulang tidak pernah berhenti dan akhirnya menghabiskan stack, sehingga program berhenti mendadak.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 19 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa risiko utama jika kasus dasar pada sebuah fungsi rekursif tidak pernah terpenuhi?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 5: QUIZ LEVEL 20 — Overloading Fungsi
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa arti overloading fungsi dalam C++?',
       $json${
         "options": [
           {"id": "a", "text": "Satu nama fungsi dipakai untuk beberapa versi dengan parameter berbeda"},
           {"id": "b", "text": "Satu fungsi dipanggil otomatis oleh compiler saat program berjalan"},
           {"id": "c", "text": "Beberapa fungsi berbeda dipanggil bergantian di dalam satu program"},
           {"id": "d", "text": "Fungsi yang sama ditulis ulang di dalam berkas sumber berbeda"}
         ],
         "answer": "a",
         "explanation": "Overloading memungkinkan beberapa fungsi bernama sama hidup berdampingan, selama daftar parameter atau tipe return-nya berbeda.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa arti overloading fungsi dalam C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah yang wajib berbeda agar dua fungsi dengan nama sama dapat di-overload?',
       $json${
         "options": [
           {"id": "a", "text": "Tipe data variabel global yang dipakai fungsi"},
           {"id": "b", "text": "Daftar parameter, baik tipe maupun jumlah parameternya"},
           {"id": "c", "text": "Nama variabel lokal yang dipakai di dalam fungsi"},
           {"id": "d", "text": "Urutan statement di dalam tubuh fungsi"}
         ],
         "answer": "b",
         "explanation": "Perbedaannya harus pada daftar parameter, karena compiler memilih versi fungsi dari argumen yang diberikan saat pemanggilan.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah yang wajib berbeda agar dua fungsi dengan nama sama dapat di-overload?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Ketika program memanggil print(5) dan print(5.5) pada fungsi overloading, compiler memilih versi fungsi berdasarkan...',
       $json${
         "options": [
           {"id": "a", "text": "Urutan berkas sumber yang sedang dikompilasi"},
           {"id": "b", "text": "Nilai balik yang akan dipakai program"},
           {"id": "c", "text": "Tipe data argumen yang diberikan saat pemanggilan"},
           {"id": "d", "text": "Nama variabel yang menyimpan hasil pemanggilan"}
         ],
         "answer": "c",
         "explanation": "Compiler mencocokkan tipe argumen dengan daftar parameter tiap versi fungsi untuk memilih versi yang paling sesuai.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 20 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Ketika program memanggil print(5) dan print(5.5) pada fungsi overloading, compiler memilih versi fungsi berdasarkan...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 6: QUIZ LEVEL 21 — Array 1D
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada array satu dimensi di C++, indeks elemen pertama yang valid adalah...',
       $json${
         "options": [
           {"id": "a", "text": "1"},
           {"id": "b", "text": "0"},
           {"id": "c", "text": "2"},
           {"id": "d", "text": "-1"}
         ],
         "answer": "b",
         "explanation": "Array di C++ berbasis nol, sehingga elemen pertama berada pada indeks 0 dan indeks terakhir adalah jumlah elemen dikurangi satu.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada array satu dimensi di C++, indeks elemen pertama yang valid adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang terjadi jika program mengakses indeks array yang lebih besar dari batas akhir?',
       $json${
         "options": [
           {"id": "a", "text": "Array otomatis diperbesar satu elemen"},
           {"id": "b", "text": "Program langsung berhenti dengan pesan galat saat dikompilasi"},
           {"id": "c", "text": "Perilaku tidak terdefinisi, program bisa berhenti mendadak atau membaca data lain"},
           {"id": "d", "text": "Compiler otomatis mengembalikan nilai nol"}
         ],
         "answer": "c",
         "explanation": "C++ tidak memeriksa batas array secara otomatis, sehingga akses di luar jangkauan menyebabkan perilaku tidak terdefinisi.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang terjadi jika program mengakses indeks array yang lebih besar dari batas akhir?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk array int nilai dengan ukuran 5, berapa banyak elemen int yang dapat disimpan?',
       $json${
         "options": [
           {"id": "a", "text": "6"},
           {"id": "b", "text": "0"},
           {"id": "c", "text": "4"},
           {"id": "d", "text": "5"}
         ],
         "answer": "d",
         "explanation": "Jumlah elemen array sama dengan ukuran yang diberikan saat deklarasi, yaitu lima elemen dengan indeks 0 sampai 4.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 21 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk array int nilai dengan ukuran 5, berapa banyak elemen int yang dapat disimpan?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 7: QUIZ LEVEL 22 — Array 2D
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada array dua dimensi int matriks dengan ukuran 3 baris dan 4 kolom, berapa banyak elemen int yang dialokasikan?',
       $json${
         "options": [
           {"id": "a", "text": "4"},
           {"id": "b", "text": "24"},
           {"id": "c", "text": "12"},
           {"id": "d", "text": "7"}
         ],
         "answer": "c",
         "explanation": "Jumlah elemen matriks adalah baris dikali kolom, yaitu 3 dikali 4 sama dengan 12 elemen int.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 22 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada array dua dimensi int matriks dengan ukuran 3 baris dan 4 kolom, berapa banyak elemen int yang dialokasikan?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk mengisi seluruh elemen matriks 3 baris 4 kolom memakai perulangan bersarang, urutan yang benar adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Perulangan luar untuk kolom, perulangan dalam untuk baris"},
           {"id": "b", "text": "Satu perulangan untuk semua elemen tanpa indeks kolom"},
           {"id": "c", "text": "Perulangan di dalam fungsi main dan satu lagi di luar fungsi"},
           {"id": "d", "text": "Perulangan luar untuk baris, perulangan dalam untuk kolom"}
         ],
         "answer": "d",
         "explanation": "Saat menelusuri matriks, perulangan luar menelusuri baris dan perulangan dalam menelusuri kolom pada baris tersebut.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 22 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk mengisi seluruh elemen matriks 3 baris 4 kolom memakai perulangan bersarang, urutan yang benar adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Elemen matriks pada baris kedua dan kolom ketiga ditulis dengan cara...',
       $json${
         "options": [
           {"id": "a", "text": "matriks[1][2]"},
           {"id": "b", "text": "matriks[2][3]"},
           {"id": "c", "text": "matriks[3][2]"},
           {"id": "d", "text": "matriks[2][1]"}
         ],
         "answer": "a",
         "explanation": "Baris dan kolom sama-sama berbasis nol, sehingga baris kedua ditulis dengan indeks 1 dan kolom ketiga dengan indeks 2.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 22 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Elemen matriks pada baris kedua dan kolom ketiga ditulis dengan cara...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 8: QUIZ LEVEL 23 — String Dasar
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada C++, cara yang benar untuk menyimpan teks singkat yang masih bisa diubah adalah...',
       $json${
         "options": [
           {"id": "a", "text": "text teks = \u0027Halo\u0027;"},
           {"id": "b", "text": "char teks = \"Halo\";"},
           {"id": "c", "text": "string teks = Halo;"},
           {"id": "d", "text": "char teks[] = \"Halo\";"}
         ],
         "answer": "d",
         "explanation": "Array char diisi deretan karakter yang diakhiri tanda null, dan tanda kurung kurawal ganda dipakai agar isinya bisa diubah.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 23 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada C++, cara yang benar untuk menyimpan teks singkat yang masih bisa diubah adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk membaca satu kata dari keyboard ke dalam variabel char kata berukuran 20, perintah yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "cin \u003e\u003e kata;"},
           {"id": "b", "text": "cin \u003c\u003c kata;"},
           {"id": "c", "text": "getline(cin \u003c\u003c kata);"},
           {"id": "d", "text": "printf(kata);"}
         ],
         "answer": "a",
         "explanation": "Operator \u003e\u003e membaca satu kata dan berhenti pada spasi, sedangkan operator \u003c\u003c dipakai untuk menampilkan data.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 23 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk membaca satu kata dari keyboard ke dalam variabel char kata berukuran 20, perintah yang tepat adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa fungsi tanda null di akhir array char yang menyimpan teks?',
       $json${
         "options": [
           {"id": "a", "text": "Menyalin teks ke dalam variabel lain"},
           {"id": "b", "text": "Menandai akhir string agar deretan karakter bisa dibaca sebagai teks"},
           {"id": "c", "text": "Menyimpan panjang teks di dalam array char"},
           {"id": "d", "text": "Menghapus seluruh spasi yang ada di dalam teks"}
         ],
         "answer": "b",
         "explanation": "Tanda null di akhir deretan karakter memberitahu pustaka string bahwa teks sudah selesai, sehingga panjangnya bisa dihitung.",
         "language": "cpp"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 23 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa fungsi tanda null di akhir array char yang menyimpan teks?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 9: QUIZ LEVEL 24 — Operasi String
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Fungsi strlen pada C++ digunakan untuk...',
       $json${
         "options": [
           {"id": "a", "text": "Menghitung panjang string"},
           {"id": "b", "text": "Menyalin string ke variabel lain"},
           {"id": "c", "text": "Menggabungkan dua string"},
           {"id": "d", "text": "Membandingkan dua string"}
         ],
         "answer": "a",
         "explanation": "strlen menghitung jumlah karakter dalam sebuah string dan mengembalikan nilainya bertipe size_t.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 24 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Fungsi strlen pada C++ digunakan untuk...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk menyalin seluruh isi string sumber ke string tujuan, fungsi yang digunakan adalah...',
       $json${
         "options": [
           {"id": "a", "text": "strlen"},
           {"id": "b", "text": "strcpy"},
           {"id": "c", "text": "strcat"},
           {"id": "d", "text": "strcmp"}
         ],
         "answer": "b",
         "explanation": "strcpy menyalin seluruh karakter dari sumber ke tujuan, sedangkan strlen, strcat, dan strcmp punya fungsi yang lain.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 24 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk menyalin seluruh isi string sumber ke string tujuan, fungsi yang digunakan adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Hasil perbandingan strcmp(nama1, nama2) yang bernilai 0 berarti...',
       $json${
         "options": [
           {"id": "a", "text": "String kedua lebih panjang daripada string pertama"},
           {"id": "b", "text": "Perbandingan gagal karena panjang kedua string berbeda"},
           {"id": "c", "text": "Kedua string memiliki isi yang sama"},
           {"id": "d", "text": "String pertama lebih panjang daripada string kedua"}
         ],
         "answer": "c",
         "explanation": "strcmp mengembalikan 0 saat kedua string identik, nilai negatif saat yang pertama lebih kecil, dan nilai positif saat lebih besar.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 24 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Hasil perbandingan strcmp(nama1, nama2) yang bernilai 0 berarti...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 10: QUIZ LEVEL 25 — Array & Fungsi
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Ketika array dikirim ke sebuah fungsi C++, yang sebenarnya dikirim adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Nilai panjang array saja"},
           {"id": "b", "text": "Pointer ke elemen pertama array"},
           {"id": "c", "text": "Salinan penuh seluruh isi array"},
           {"id": "d", "text": "Salinan hanya elemen pertama array"}
         ],
         "answer": "b",
         "explanation": "Nama array berubah menjadi pointer ke elemen pertamanya, sehingga yang terkirim adalah alamat, bukan salinan data.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 25 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Ketika array dikirim ke sebuah fungsi C++, yang sebenarnya dikirim adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Agar fungsi dapat mengubah isi array milik pemanggil, parameter fungsi sebaiknya memakai...',
       $json${
         "options": [
           {"id": "a", "text": "Pointer ke pointer, contoh void ubah(int **data)"},
           {"id": "b", "text": "Tipe void, contoh void ubah(void data[])"},
           {"id": "c", "text": "Referensi, contoh void ubah(int \u0026data[])"},
           {"id": "d", "text": "Nilai biasa, contoh void ubah(int data[])"}
         ],
         "answer": "c",
         "explanation": "Dengan parameter referensi, fungsi bekerja pada array asli sehingga perubahannya terlihat oleh pemanggil.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 25 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Agar fungsi dapat mengubah isi array milik pemanggil, parameter fungsi sebaiknya memakai...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kenapa sizeof di dalam fungsi yang menerima array sebagai parameter tidak bisa memberi tahu panjang array sebenarnya?',
       $json${
         "options": [
           {"id": "a", "text": "Karena sizeof selalu bernilai satu pada semua tipe data"},
           {"id": "b", "text": "Karena fungsi tidak boleh membaca variabel milik pemanggil"},
           {"id": "c", "text": "Karena panjang array selalu dihitung otomatis oleh compiler"},
           {"id": "d", "text": "Karena parameter array berubah menjadi pointer, bukan array utuh"}
         ],
         "answer": "d",
         "explanation": "Karena parameter array berubah menjadi pointer, sizeof di dalam fungsi hanya menghitung ukuran pointer, bukan panjang array.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 25 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kenapa sizeof di dalam fungsi yang menerima array sebagai parameter tidak bisa memberi tahu panjang array sebenarnya?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 11: QUIZ LEVEL 26 — Pengenalan Pointer
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Operator & pada sebuah variabel di C++ dipakai untuk...',
       $json${
         "options": [
           {"id": "a", "text": "Membuat variabel baru di dalam blok program"},
           {"id": "b", "text": "Menghapus nilai variabel dari memori"},
           {"id": "c", "text": "Mengambil alamat memori variabel tersebut"},
           {"id": "d", "text": "Menyebutkan nilai variabel di dalam fungsi"}
         ],
         "answer": "c",
         "explanation": "Operator address-of menghasilkan alamat memori variabel, yang biasanya disimpan di dalam variabel pointer.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Operator & pada sebuah variabel di C++ dipakai untuk...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Operator * pada variabel pointer dipakai untuk...',
       $json${
         "options": [
           {"id": "a", "text": "Menghitung ukuran variabel pointer di memori"},
           {"id": "b", "text": "Menyalin alamat pointer ke variabel lain"},
           {"id": "c", "text": "Membebaskan memori yang dipakai variabel pointer"},
           {"id": "d", "text": "Mengakses atau mengubah nilai pada alamat yang ditunjuk pointer"}
         ],
         "answer": "d",
         "explanation": "Dereference dipakai untuk membaca atau menulis nilai yang berada pada alamat yang disimpan pointer.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Operator * pada variabel pointer dipakai untuk...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah deklarasi variabel pointer bertipe int yang benar di C++?',
       $json${
         "options": [
           {"id": "a", "text": "int *ptr;"},
           {"id": "b", "text": "int ptr*;"},
           {"id": "c", "text": "int \u0026ptr;"},
           {"id": "d", "text": "pointer int ptr;"}
         ],
         "answer": "a",
         "explanation": "Pointer ditandai dengan tanda bintang pada nama variabel, sedangkan tanda ampersand dipakai untuk deklarasi reference.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 26 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah deklarasi variabel pointer bertipe int yang benar di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 12: QUIZ LEVEL 27 — Pointer & Array
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada C++, menuliskan p + 1 untuk pointer int p yang menunjuk elemen pertama array menghasilkan...',
       $json${
         "options": [
           {"id": "a", "text": "Nilai elemen kedua array"},
           {"id": "b", "text": "Ukuran array dalam byte"},
           {"id": "c", "text": "Pointer baru yang menunjuk elemen terakhir"},
           {"id": "d", "text": "Alamat elemen kedua array"}
         ],
         "answer": "d",
         "explanation": "Aritmetika pointer menambah ukuran tipe datanya, sehingga p + 1 bergeser satu elemen ke depan.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada C++, menuliskan p + 1 untuk pointer int p yang menunjuk elemen pertama array menghasilkan...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar untuk membaca nilai elemen kedua dari array int data berukuran 5 memakai pointer int p yang menunjuk data?',
       $json${
         "options": [
           {"id": "a", "text": "p[1]"},
           {"id": "b", "text": "p + 1"},
           {"id": "c", "text": "*p + 1"},
           {"id": "d", "text": "p(1)"}
         ],
         "answer": "a",
         "explanation": "Notasi p[1] setara dengan *(p + 1), yaitu nilai elemen kedua, sedangkan p + 1 hanya menghasilkan alamat.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar untuk membaca nilai elemen kedua dari array int data berukuran 5 memakai pointer int p yang menunjuk data?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa hubungan antara nama array int data berukuran 5 dan pointer int p yang menunjuk elemen pertamanya di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Pointer harus dideklarasikan ulang agar sama dengan array"},
           {"id": "b", "text": "Keduanya menyimpan alamat yang sama sehingga saling bisa menggantikan"},
           {"id": "c", "text": "Keduanya selalu menyimpan nilai yang berbeda satu sama lain"},
           {"id": "d", "text": "Nama array selalu menyimpan panjang array, bukan alamat"}
         ],
         "answer": "b",
         "explanation": "Nama array otomatis berubah menjadi pointer ke elemen pertama, sehingga keduanya menunjuk alamat yang sama.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 27 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa hubungan antara nama array int data berukuran 5 dan pointer int p yang menunjuk elemen pertamanya di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 13: QUIZ LEVEL 28 — Reference
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Reference di C++ dideklarasikan dengan cara...',
       $json${
         "options": [
           {"id": "a", "text": "Tipe dan nama, contoh void ubah(int \u0026nilai)"},
           {"id": "b", "text": "Tipe *nama, contoh void ubah(int *nilai)"},
           {"id": "c", "text": "Tipe const nama, contoh void ubah(const int nilai)"},
           {"id": "d", "text": "Tipe nama, contoh void ubah(int nilai)"}
         ],
         "answer": "a",
         "explanation": "Reference memakai tanda ampersand dan harus diinisialisasi saat deklarasi, sedangkan pointer memakai tanda bintang.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Reference di C++ dideklarasikan dengan cara...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa perbedaan paling mendasar antara reference dan pointer di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Pointer menyimpan salinan nilai, sedangkan reference menyimpan alamat"},
           {"id": "b", "text": "Reference tidak bisa bernilai null dan harus diinisialisasi saat deklarasi"},
           {"id": "c", "text": "Reference selalu bekerja pada tipe data primitive saja"},
           {"id": "d", "text": "Reference hanya bisa dipakai di dalam fungsi, pointer hanya di luar fungsi"}
         ],
         "answer": "b",
         "explanation": "Reference adalah alias yang wajib terinisialisasi dan tidak dapat bernilai null, sedangkan pointer boleh bernilai null.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa perbedaan paling mendasar antara reference dan pointer di C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan sebaiknya memakai reference dibandingkan pointer di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Saat fungsi hanya membutuhkan salinan nilai dari pemanggil"},
           {"id": "b", "text": "Saat menyimpan kumpulan data dengan panjang yang tidak pasti"},
           {"id": "c", "text": "Saat fungsi memang perlu mengubah nilai variabel milik pemanggil"},
           {"id": "d", "text": "Saat program perlu melakukan alokasi memori secara dinamis"}
         ],
         "answer": "c",
         "explanation": "Reference paling pas untuk mengubah data milik pemanggil, sedangkan pointer dipakai ketika butuh nilai null, aritmetika pointer, atau alokasi dinamis.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 28 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan sebaiknya memakai reference dibandingkan pointer di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 14: QUIZ LEVEL 29 — Dynamic Memory
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Operator new di C++ dipakai untuk...',
       $json${
         "options": [
           {"id": "a", "text": "Mengubah ukuran array yang sudah ada di tengah program"},
           {"id": "b", "text": "Mengalokasikan memori secara dinamis saat program berjalan"},
           {"id": "c", "text": "Membebaskan memori yang sudah tidak dipakai"},
           {"id": "d", "text": "Menyalin isi satu objek ke objek lain"}
         ],
         "answer": "b",
         "explanation": "Operator new mengalokasikan blok memori saat runtime dan mengembalikan pointer menuju blok tersebut.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Operator new di C++ dipakai untuk...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Setelah memakai new, memori yang dialokasikan sebaiknya...',
       $json${
         "options": [
           {"id": "a", "text": "Dibiarkan saja karena otomatis dibersihkan oleh compiler"},
           {"id": "b", "text": "Dihapus dengan operator free dari dalam fungsi main"},
           {"id": "c", "text": "Diberi dealokasi dengan delete agar tidak membocor"},
           {"id": "d", "text": "Dialokasikan ulang dengan new sebelum program selesai"}
         ],
         "answer": "c",
         "explanation": "Memori dari new tidak dibersihkan otomatis, sehingga harus dilepas dengan delete agar tidak terjadi kebocoran memori.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Setelah memakai new, memori yang dialokasikan sebaiknya...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar untuk membuat array int berukuran 10 secara dinamis di C++?',
       $json${
         "options": [
           {"id": "a", "text": "int data* = new int(10);"},
           {"id": "b", "text": "int *data = new[10] int;"},
           {"id": "c", "text": "int data[10] = new int[10];"},
           {"id": "d", "text": "int *data = new int[10];"}
         ],
         "answer": "d",
         "explanation": "new int[10] mengalokasikan array dinamis dan mengembalikan pointer, sedangkan delete dengan kurung siku dipakai untuk melepaskannya.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 29 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar untuk membuat array int berukuran 10 secara dinamis di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 15: QUIZ LEVEL 30 — Pointer ke Fungsi
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pointer ke fungsi di C++ berguna untuk...',
       $json${
         "options": [
           {"id": "a", "text": "Mengubah kode di dalam fungsi saat program sedang berjalan"},
           {"id": "b", "text": "Mengubah urutan pemanggilan fungsi secara otomatis"},
           {"id": "c", "text": "Menyimpan alamat sebuah fungsi sehingga bisa dipanggil lewat variabel"},
           {"id": "d", "text": "Menjalankan beberapa fungsi secara bersamaan di banyak inti"}
         ],
         "answer": "c",
         "explanation": "Function pointer menyimpan alamat sebuah fungsi sehingga fungsi tersebut bisa dipanggil melalui variabel pointer itu.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pointer ke fungsi di C++ berguna untuk...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah deklarasi function pointer yang benar untuk fungsi int tambah(int a, int b) di C++?',
       $json${
         "options": [
           {"id": "a", "text": "void *ptrTambah = tambah;"},
           {"id": "b", "text": "int *ptrTambah(int, int);"},
           {"id": "c", "text": "int ptrTambah(int, int);"},
           {"id": "d", "text": "int (*ptrTambah)(int, int);"}
         ],
         "answer": "d",
         "explanation": "Tanda bintang harus berada di dalam kurung agar menunjuk fungsi bertipe int dengan dua parameter int.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah deklarasi function pointer yang benar untuk fungsi int tambah(int a, int b) di C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa salah satu penggunaan umum function pointer di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Menyimpan fungsi callback, misalnya saat memproses kejadian antarmuka"},
           {"id": "b", "text": "Menyimpan nilai matematika agar tidak perlu dihitung berulang"},
           {"id": "c", "text": "Menggantikan fungsi bawaan pustaka seperti strlen"},
           {"id": "d", "text": "Mengubah program agar berjalan di banyak inti sekaligus"}
         ],
         "answer": "a",
         "explanation": "Function pointer umum dipakai sebagai callback, misalnya ketika pustaka memberi tahu program bahwa sebuah aksi sedang terjadi.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 30 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa salah satu penggunaan umum function pointer di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 16: QUIZ LEVEL 31 — Struct Dasar
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa kegunaan utama keyword struct di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Membuat variabel yang hanya bisa berisi satu nilai"},
           {"id": "b", "text": "Menjalankan beberapa statement secara bersamaan"},
           {"id": "c", "text": "Menyimpan kumpulan data dinamis dengan panjang yang berubah"},
           {"id": "d", "text": "Membuat tipe data baru yang mengelompokkan beberapa data terkait"}
         ],
         "answer": "d",
         "explanation": "Struct mengelompokkan beberapa variabel dengan tipe berbeda menjadi satu tipe data baru yang bisa dipakai berulang.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa kegunaan utama keyword struct di C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Setelah tipe struct Mahasiswa dideklarasikan, bagaimana cara mengakses field nama dari variabel mhs bertipe struct Mahasiswa?',
       $json${
         "options": [
           {"id": "a", "text": "mhs.nama"},
           {"id": "b", "text": "mhs::nama"},
           {"id": "c", "text": "mhs[nama]"},
           {"id": "d", "text": "nama.mhs"}
         ],
         "answer": "a",
         "explanation": "Untuk variabel struct biasa, member diakses memakai titik, sedangkan tanda panah dipakai untuk pointer menuju struct.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Setelah tipe struct Mahasiswa dideklarasikan, bagaimana cara mengakses field nama dari variabel mhs bertipe struct Mahasiswa?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar untuk mendeklarasikan variabel bertipe struct Mahasiswa di C++?',
       $json${
         "options": [
           {"id": "a", "text": "new struct mhs;"},
           {"id": "b", "text": "Mahasiswa mhs;"},
           {"id": "c", "text": "Mahasiswa struct mhs;"},
           {"id": "d", "text": "struct = Mahasiswa mhs;"}
         ],
         "answer": "b",
         "explanation": "Setelah tipe struct dideklarasikan, variabelnya ditulis seperti variabel biasa dengan menyebut nama tipenya.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 31 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar untuk mendeklarasikan variabel bertipe struct Mahasiswa di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 17: QUIZ LEVEL 32 — Struct & Array
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk menyimpan data 100 mahasiswa, pola yang paling tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Array dari struct, contoh Mahasiswa data[100]"},
           {"id": "b", "text": "Struct dari array, contoh struct data[100]"},
           {"id": "c", "text": "Satu variabel struct dengan 100 field terpisah"},
           {"id": "d", "text": "Array dari pointer ke satu variabel struct yang sama"}
         ],
         "answer": "a",
         "explanation": "Array dari struct menggabungkan keduanya, yaitu setiap elemennya menyimpan sekumpulan data mahasiswa.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk menyimpan data 100 mahasiswa, pola yang paling tepat adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Ketika memakai array dari struct, bagaimana cara mengakses field nama pada elemen kedua?',
       $json${
         "options": [
           {"id": "a", "text": "nama[1].data"},
           {"id": "b", "text": "data[1].nama"},
           {"id": "c", "text": "data[2].nama"},
           {"id": "d", "text": "data.nama[1]"}
         ],
         "answer": "b",
         "explanation": "Elemen kedua array berada pada indeks 1, lalu field di dalamnya diakses dengan notasi titik.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Ketika memakai array dari struct, bagaimana cara mengakses field nama pada elemen kedua?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk mencari semua mahasiswa yang namanya mengandung kata tertentu, pola yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Mengakses field nama langsung dari luar perulangan"},
           {"id": "b", "text": "Memanggil fungsi cetak dua kali tanpa perulangan"},
           {"id": "c", "text": "Perulangan untuk setiap elemen array, lalu cek field nama di dalamnya"},
           {"id": "d", "text": "Menyalin seluruh array ke variabel baru lalu mencocokkan nama"}
         ],
         "answer": "c",
         "explanation": "Pencarian di dalam array dilakukan dengan perulangan, dan setiap elemen dicek satu per satu terhadap kriteria yang dicari.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 32 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk mencari semua mahasiswa yang namanya mengandung kata tertentu, pola yang tepat adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 18: QUIZ LEVEL 33 — Enum
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa manfaat utama enum di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Membuat fungsi yang bisa dipanggil tanpa argumen"},
           {"id": "b", "text": "Memberi nama pada sekumpulan nilai konstanta yang saling related"},
           {"id": "c", "text": "Menyimpan data dinamis dengan panjang yang tidak tetap"},
           {"id": "d", "text": "Mengelompokkan beberapa variabel di dalam satu struct"}
         ],
         "answer": "b",
         "explanation": "Enum memberi nama yang lebih mudah dibaca untuk sekumpulan nilai konstanta, misalnya status, warna, atau jenis pesanan.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa manfaat utama enum di C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa nilai default enumerator pertama pada enum Status { Aktif, Nonaktif, Tunda }?',
       $json${
         "options": [
           {"id": "a", "text": "3"},
           {"id": "b", "text": "Aktif"},
           {"id": "c", "text": "0"},
           {"id": "d", "text": "1"}
         ],
         "answer": "c",
         "explanation": "Enumerator pertama bernilai 0 secara default, lalu bertambah satu untuk setiap enumerator berikutnya.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa nilai default enumerator pertama pada enum Status { Aktif, Nonaktif, Tunda }?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar untuk memberi nilai khusus pada enumerator di C++?',
       $json${
         "options": [
           {"id": "a", "text": "enum Status { Aktif = 1; Nonaktif = 0; Tunda = 2; };"},
           {"id": "b", "text": "const Status { Aktif = 1, Nonaktif = 0, Tunda = 2 };"},
           {"id": "c", "text": "enum Status { Aktif: 1, Nonaktif: 0, Tunda: 2 };"},
           {"id": "d", "text": "enum Status { Aktif = 1, Nonaktif = 0, Tunda = 2 };"}
         ],
         "answer": "d",
         "explanation": "Nilai khusus ditulis dengan tanda sama dengan pada enumerator yang bersangkutan, dan tanda baca di dalam kurung kurawal adalah koma.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 33 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar untuk memberi nilai khusus pada enumerator di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 19: QUIZ LEVEL 34 — Typedef & Using
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa fungsi keyword typedef dalam C++?',
       $json${
         "options": [
           {"id": "a", "text": "Menyimpan konstanta dengan nama yang lebih pendek"},
           {"id": "b", "text": "Menggabungkan beberapa statement menjadi satu blok"},
           {"id": "c", "text": "Membuat nama lain atau alias untuk suatu tipe data"},
           {"id": "d", "text": "Mengubah tipe data dasar menjadi tipe baru yang berbeda"}
         ],
         "answer": "c",
         "explanation": "typedef membuat alias untuk sebuah tipe sehingga penulisan kode menjadi lebih ringkas dan mudah dibaca.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa fungsi keyword typedef dalam C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar memakai typedef untuk membuat alias bilangan dari tipe int di C++?',
       $json${
         "options": [
           {"id": "a", "text": "typedef int bilangan = 0;"},
           {"id": "b", "text": "typedef bilangan = int;"},
           {"id": "c", "text": "using bilangan int;"},
           {"id": "d", "text": "typedef int bilangan;"}
         ],
         "answer": "d",
         "explanation": "Format typedef adalah typedef tipeTujuan namaAlias, tanpa tanda sama dengan dan tanpa nilai awal.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar memakai typedef untuk membuat alias bilangan dari tipe int di C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa perbedaan utama antara using dan typedef di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Using bisa membuat beberapa alias sekaligus dalam satu baris"},
           {"id": "b", "text": "Using hanya bisa dipakai di dalam struct"},
           {"id": "c", "text": "Typedef hanya bisa dipakai pada tipe pointer"},
           {"id": "d", "text": "Keduanya tidak bisa dipakai bersamaan dalam satu program"}
         ],
         "answer": "a",
         "explanation": "Using mendukung alias bertipe template dan bisa menggabungkan beberapa alias sekaligus, misalnya using A = int, B = double.",
         "language": "cpp"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 34 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa perbedaan utama antara using dan typedef di C++?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 20: QUIZ LEVEL 35 — Union
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa perbedaan utama antara union dengan struct di C++?',
       $json${
         "options": [
           {"id": "a", "text": "Union menyimpan seluruh anggotanya sekaligus seperti struct"},
           {"id": "b", "text": "Union tidak boleh memiliki lebih dari satu anggota"},
           {"id": "c", "text": "Union hanya boleh dipakai di dalam class"},
           {"id": "d", "text": "Union hanya menyimpan satu anggota aktif pada satu waktu dan berbagi memori"}
         ],
         "answer": "d",
         "explanation": "Semua anggota union memakai satu blok memori yang sama, sehingga nilai terakhir yang diisikan menimpa anggota sebelumnya.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa perbedaan utama antara union dengan struct di C++?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kapan penggunaan union lebih tepat dibandingkan struct?',
       $json${
         "options": [
           {"id": "a", "text": "Ketika data yang disimpan saling menggantikan dan hanya satu yang dipakai"},
           {"id": "b", "text": "Ketika semua data harus bisa diakses bersamaan"},
           {"id": "c", "text": "Ketika jumlah anggota struct terlalu banyak"},
           {"id": "d", "text": "Ketika perlu menyimpan daftar nilai dinamis"}
         ],
         "answer": "a",
         "explanation": "Union menghemat memori untuk data yang saling menggantikan, misalnya menyimpan nilai int atau float pada variabel yang sama.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kapan penggunaan union lebih tepat dibandingkan struct?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada union contoh { int a; double b; }, setelah mengisi a dengan 5 lalu b dengan 2.5, anggota yang aktif adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Tidak ada yang aktif karena union tidak boleh punya dua anggota"},
           {"id": "b", "text": "b, karena penulisan terakhir menimpa byte yang sama dengan nilai double"},
           {"id": "c", "text": "a, karena tipe int selalu lebih diutamakan"},
           {"id": "d", "text": "Keduanya aktif bersamaan dengan nilai masing-masing"}
         ],
         "answer": "b",
         "explanation": "Anggota union berbagi memori, sehingga penulisan terakhir yaitu b menimpa byte yang sama dan itulah nilai yang terbaca.",
         "language": "cpp"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 35 AND l.language = 'cpp'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada union contoh { int a; double b; }, setelah mengisi a dengan 5 lalu b dengan 2.5, anggota yang aktif adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 21: QUIZ LEVEL 36 — Pengenalan Java
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Pada program Java, statement public static void main(String[] args) berfungsi sebagai...',
       $json${
         "options": [
           {"id": "a", "text": "Titik awal yang dijalankan oleh Java Virtual Machine"},
           {"id": "b", "text": "Method yang otomatis dipanggil setiap kali objek dibuat"},
           {"id": "c", "text": "Method khusus untuk menangani galat pada program"},
           {"id": "d", "text": "Method yang wajib dipanggil sebelum program dapat dikompilasi"}
         ],
         "answer": "a",
         "explanation": "Java Virtual Machine mencari method main sebagai titik masuk program Java, sehingga alur eksekusi dimulai dari sana.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Pada program Java, statement public static void main(String[] args) berfungsi sebagai...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Perintah untuk menampilkan teks ke layar di Java adalah...',
       $json${
         "options": [
           {"id": "a", "text": "print.output(\"Halo\");"},
           {"id": "b", "text": "System.out.println(\"Halo\");"},
           {"id": "c", "text": "System.in.println(\"Halo\");"},
           {"id": "d", "text": "cout \u003c\u003c \"Halo\";"}
         ],
         "answer": "b",
         "explanation": "System.out.println mencetak teks lalu membuat baris baru, sedangkan print hanya mencetak tanpa menambah baris baru.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Perintah untuk menampilkan teks ke layar di Java adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang harus dilakukan agar sebuah program Java dapat dijalankan?',
       $json${
         "options": [
           {"id": "a", "text": "Menjalankan berkas java di dalam peramban"},
           {"id": "b", "text": "Menjalankan langsung berkas java tanpa tahap kompilasi"},
           {"id": "c", "text": "Kompilasi menjadi berkas class lalu menjalankannya dengan java"},
           {"id": "d", "text": "Menyimpan program dengan ekstensi class sejak awal"}
         ],
         "answer": "c",
         "explanation": "Java dikompilasi lebih dulu menjadi bytecode di dalam berkas class, lalu berkas itu dieksekusi oleh Java Virtual Machine.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 36 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang harus dilakukan agar sebuah program Java dapat dijalankan?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 22: QUIZ LEVEL 37 — Class & Object
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Dalam Java, class adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Variabel global yang disimpan di dalam package"},
           {"id": "b", "text": "Cetakan atau template untuk membuat object"},
           {"id": "c", "text": "Wujud nyata yang sudah siap pakai di memori"},
           {"id": "d", "text": "Method bawaan yang otomatis dipanggil Java Virtual Machine"}
         ],
         "answer": "b",
         "explanation": "Class mendefinisikan struktur data dan perilakunya, sedangkan object adalah wujud nyata yang dibuat dari class tersebut.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Dalam Java, class adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk membuat object dari class Mobil di Java, perintah yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "new Mobil = Mobil();"},
           {"id": "b", "text": "Mobil mobil = Mobil();"},
           {"id": "c", "text": "Mobil mobil = new Mobil();"},
           {"id": "d", "text": "Mobil mobil = Mobil;"}
         ],
         "answer": "c",
         "explanation": "Keyword new dipakai untuk membuat object dan hasilnya disimpan pada variabel yang bertipe class tersebut.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk membuat object dari class Mobil di Java, perintah yang tepat adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk mengubah nilai field warna pada object mobil di Java, penulisan yang benar adalah...',
       $json${
         "options": [
           {"id": "a", "text": "mobil-\u003ewarna = \"Merah\";"},
           {"id": "b", "text": "Mobil.warna = \"Merah\";"},
           {"id": "c", "text": "warna = mobil.Merah();"},
           {"id": "d", "text": "mobil.warna = \"Merah\";"}
         ],
         "answer": "d",
         "explanation": "Field publik diakses dengan notasi titik dari nama object, bukan dari nama class.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 37 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk mengubah nilai field warna pada object mobil di Java, penulisan yang benar adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 23: QUIZ LEVEL 38 — Constructor
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang dilakukan constructor pada saat sebuah object dibuat?',
       $json${
         "options": [
           {"id": "a", "text": "Menyalin isi object lain ke dalam object yang baru"},
           {"id": "b", "text": "Mengubah class menjadi interface"},
           {"id": "c", "text": "Menginisialisasi nilai awal pada field object tersebut"},
           {"id": "d", "text": "Menghapus semua nilai yang tersimpan di dalam object"}
         ],
         "answer": "c",
         "explanation": "Constructor dijalankan otomatis saat object dibuat dan biasanya dipakai untuk menyiapkan nilai awal pada field.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang dilakukan constructor pada saat sebuah object dibuat?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah deklarasi constructor yang benar untuk class Motor di Java?',
       $json${
         "options": [
           {"id": "a", "text": "public void Motor() { ... }"},
           {"id": "b", "text": "public Motor Motor() { ... }"},
           {"id": "c", "text": "Motor() public { ... }"},
           {"id": "d", "text": "public Motor() { ... }"}
         ],
         "answer": "d",
         "explanation": "Constructor memiliki nama sama dengan class, tidak punya tipe balik, dan tidak diberi modifier void maupun tipe data lain.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah deklarasi constructor yang benar untuk class Motor di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang terjadi jika sebuah class di Java tidak memiliki constructor yang ditulis eksplisit?',
       $json${
         "options": [
           {"id": "a", "text": "Java membuat constructor default yang menginisialisasi field dengan nilai bawaan"},
           {"id": "b", "text": "Object tidak bisa dibuat dari class tersebut"},
           {"id": "c", "text": "Compiler akan memaksa program berhenti"},
           {"id": "d", "text": "Semua field class tersebut harus diisi secara manual"}
         ],
         "answer": "a",
         "explanation": "Jika tidak ada constructor yang dideklarasikan, Java menyediakan constructor default yang memberi nilai nol atau null pada field.",
         "language": "java"
       }$json$::jsonb,
       3
FROM public.levels l
WHERE l.level_number = 38 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang terjadi jika sebuah class di Java tidak memiliki constructor yang ditulis eksplisit?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 24: QUIZ LEVEL 39 — Enkapsulasi
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa arti modifier private pada sebuah field di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Field tersebut tidak boleh diisi dengan nilai apa pun"},
           {"id": "b", "text": "Field tersebut otomatis dihitung ulang setiap kali dipanggil"},
           {"id": "c", "text": "Field tersebut hanya bisa diakses dari package yang sama"},
           {"id": "d", "text": "Field tersebut hanya bisa diakses dari dalam class yang sama"}
         ],
         "answer": "d",
         "explanation": "Modifier private menyembunyikan field dari akses luar class dan menjaga data agar tetap konsisten.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa arti modifier private pada sebuah field di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Agar field private tetap bisa dibaca dan diubah dari luar, class biasanya menyediakan...',
       $json${
         "options": [
           {"id": "a", "text": "Method getter dan setter sebagai pintu masuk yang terkendali"},
           {"id": "b", "text": "Method main tambahan di dalam class tersebut"},
           {"id": "c", "text": "Variabel static yang menggantikan field private"},
           {"id": "d", "text": "Field publik dengan nama yang sama persis"}
         ],
         "answer": "a",
         "explanation": "Getter dan setter memungkinkan adanya validasi dan aturan akses saat field diubah dari luar class.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Agar field private tetap bisa dibaca dan diubah dari luar, class biasanya menyediakan...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Mengapa enkapsulasi penting dalam pemrograman berorientasi objek?',
       $json${
         "options": [
           {"id": "a", "text": "Menjumlahkan seluruh field menjadi satu variabel"},
           {"id": "b", "text": "Menjaga agar data internal class tidak diubah sembarangan dari luar"},
           {"id": "c", "text": "Membuat program berjalan lebih cepat di perangkat"},
           {"id": "d", "text": "Menghilangkan kebutuhan method di dalam class"}
         ],
         "answer": "b",
         "explanation": "Dengan enkapsulasi, akses data diatur lewat method sehingga perubahan internal class tidak merusak bagian program lain.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 39 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Mengapa enkapsulasi penting dalam pemrograman berorientasi objek?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 25: QUIZ LEVEL 40 — Static & Final
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa arti modifier static pada sebuah field di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Field tersebut milik class dan hanya ada satu salinan untuk semua object"},
           {"id": "b", "text": "Field tersebut hanya bisa dibaca dan tidak bisa diubah"},
           {"id": "c", "text": "Field tersebut otomatis dihitung ulang setiap kali dipanggil"},
           {"id": "d", "text": "Field tersebut tidak boleh diakses dari luar class"}
         ],
         "answer": "a",
         "explanation": "Field static disimpan pada class, bukan pada tiap object, sehingga semua object memakai salinan yang sama.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa arti modifier static pada sebuah field di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk membuat sebuah konstanta di Java, kombinasi modifier yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "public abstract"},
           {"id": "b", "text": "static final"},
           {"id": "c", "text": "static const"},
           {"id": "d", "text": "final static const"}
         ],
         "answer": "b",
         "explanation": "static final dipakai bersama untuk konstanta yang dibagikan ke seluruh object dan nilainya tidak bisa diubah.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk membuat sebuah konstanta di Java, kombinasi modifier yang tepat adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Method static di Java dipanggil dengan cara...',
       $json${
         "options": [
           {"id": "a", "text": "Dengan operator new, contoh new Util.hitung();"},
           {"id": "b", "text": "Hanya bisa dipanggil dari dalam constructor"},
           {"id": "c", "text": "Menyebutkan nama class, contoh Util.hitung();"},
           {"id": "d", "text": "Menyebutkan nama object, contoh util.hitung();"}
         ],
         "answer": "c",
         "explanation": "Method static tidak bergantung pada object tertentu, sehingga dipanggil melalui nama class secara langsung.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 40 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Method static di Java dipanggil dengan cara...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 26: QUIZ LEVEL 41 — Inheritance Dasar
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara mendeklarasikan class Kucing yang mewarisi class Hewan di Java?',
       $json${
         "options": [
           {"id": "a", "text": "class Kucing implements Hewan { ... }"},
           {"id": "b", "text": "class Kucing extends Hewan { ... }"},
           {"id": "c", "text": "class Hewan extends Kucing { ... }"},
           {"id": "d", "text": "class Kucing inherit Hewan { ... }"}
         ],
         "answer": "b",
         "explanation": "Kata kunci extends dipakai ketika sebuah class mewarisi class lain, sedangkan implements dipakai untuk interface.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara mendeklarasikan class Kucing yang mewarisi class Hewan di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang diwariskan oleh class anak dari class induk di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Hanya method main milik class induk"},
           {"id": "b", "text": "Seluruh kode program milik class induk"},
           {"id": "c", "text": "Field dan method milik class induk yang boleh diakses oleh class anak"},
           {"id": "d", "text": "Hanya field privat milik class induk"}
         ],
         "answer": "c",
         "explanation": "Subclass mewarisi anggota yang boleh diakses, yaitu field dan method dengan hak akses protected, package, dan public.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang diwariskan oleh class anak dari class induk di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kenapa pewarisan di Java berguna dalam pemrograman berorientasi objek?',
       $json${
         "options": [
           {"id": "a", "text": "Membuat program berjalan tanpa perlu memakai class sama sekali"},
           {"id": "b", "text": "Menghilangkan semua method yang ada pada class induk"},
           {"id": "c", "text": "Memastikan seluruh field pada class menjadi private"},
           {"id": "d", "text": "Menghindari duplikasi kode dan memodelkan hubungan umum antar objek"}
         ],
         "answer": "d",
         "explanation": "Pewarisan memungkinkan class khusus memakai perilaku umum dari class induk tanpa menulis ulang kode yang sama.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 41 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kenapa pewarisan di Java berguna dalam pemrograman berorientasi objek?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 27: QUIZ LEVEL 42 — Super & Override
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Kata kunci super di Java dipakai untuk...',
       $json${
         "options": [
           {"id": "a", "text": "Membuat salinan object dari class induk"},
           {"id": "b", "text": "Menandai method agar tidak bisa dipanggil ulang"},
           {"id": "c", "text": "Memanggil constructor atau method milik class induk"},
           {"id": "d", "text": "Menyembunyikan seluruh method milik class induk"}
         ],
         "answer": "c",
         "explanation": "super memanggil constructor atau method milik class induk, misalnya untuk menjalankan inisialisasi bawaan class induk.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Kata kunci super di Java dipakai untuk...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Anotasi @Override pada sebuah method memberarti...',
       $json${
         "options": [
           {"id": "a", "text": "Method tersebut hanya boleh dipanggil satu kali saja"},
           {"id": "b", "text": "Method tersebut selalu mengembalikan nilai kosong"},
           {"id": "c", "text": "Method tersebut otomatis berjalan sebelum constructor"},
           {"id": "d", "text": "Method tersebut menggantikan method bernama sama milik class induk"}
         ],
         "answer": "d",
         "explanation": "Anotasi @Override memberi tahu compiler bahwa method itu meng-override method milik class induk, dan compiler akan memverifikasinya.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Anotasi @Override pada sebuah method memberarti...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Saat melakukan override, aturan tentang tipe return yang benar adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Tipe return harus sama atau merupakan subtype dari tipe return di class induk"},
           {"id": "b", "text": "Tipe return boleh sembarang selama nilainya benar"},
           {"id": "c", "text": "Tipe return harus selalu void"},
           {"id": "d", "text": "Tipe return harus selalu berbeda dari class induk"}
         ],
         "answer": "a",
         "explanation": "Java mengizinkan covariant return, yaitu tipe return yang sama atau lebih spesifik dari versi method pada class induk.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 42 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Saat melakukan override, aturan tentang tipe return yang benar adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 28: QUIZ LEVEL 43 — Polymorphism
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa arti polymorphism dalam pemrograman berorientasi objek?',
       $json${
         "options": [
           {"id": "a", "text": "Banyak object dengan tipe berbeda disimpan dalam satu variabel"},
           {"id": "b", "text": "Method yang bisa menerima jumlah argumen yang berbeda"},
           {"id": "c", "text": "Proses menyembunyikan detail internal dari pemanggil"},
           {"id": "d", "text": "Satu method yang sama bisa punya perilaku berbeda pada tiap tipe object"}
         ],
         "answer": "d",
         "explanation": "Polymorphism membuat pemanggilan method yang sama menghasilkan perilaku berbeda sesuai tipe object yang sebenarnya.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa arti polymorphism dalam pemrograman berorientasi objek?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa perbedaan utama antara overloading dan overriding di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Overloading terjadi di satu class dengan parameter berbeda, sedangkan overriding mengganti method milik class induk"},
           {"id": "b", "text": "Overloading selalu terjadi di dalam constructor"},
           {"id": "c", "text": "Keduanya selalu terjadi di dalam class yang sama"},
           {"id": "d", "text": "Overriding hanya boleh dilakukan pada method static"}
         ],
         "answer": "a",
         "explanation": "Overloading terjadi di satu class dengan parameter berbeda, sedangkan overriding terjadi antara class anak dan class induk dengan nama method sama.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa perbedaan utama antara overloading dan overriding di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Ketika variabel bertipe class induk menyimpan object dari class anak, method yang dipanggil adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Method paling baru di dalam berkas yang dikompilasi terakhir"},
           {"id": "b", "text": "Method milik class anak yang meng-override, sesuai tipe sebenarnya"},
           {"id": "c", "text": "Method milik class induk selalu, tanpa ada yang berubah"},
           {"id": "d", "text": "Semua method dari kedua class dijalankan sekaligus"}
         ],
         "answer": "b",
         "explanation": "Ini disebut dispatch dinamis, yaitu pada saat runtime JVM memanggil method sesuai tipe asli object, bukan sesuai tipe variabelnya.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 43 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Ketika variabel bertipe class induk menyimpan object dari class anak, method yang dipanggil adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 29: QUIZ LEVEL 44 — Abstract Class
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa ciri utama abstract class di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Class yang tidak bisa diinstansiasi dan punya method abstrak yang wajib diimplementasikan"},
           {"id": "b", "text": "Class yang harus mengimplementasikan semua interface secara otomatis"},
           {"id": "c", "text": "Class yang seluruh method-nya otomatis final"},
           {"id": "d", "text": "Class yang hanya boleh berisi atribut private"}
         ],
         "answer": "a",
         "explanation": "Abstract class menjadi kerangka dasar dan tidak bisa dibuat object secara langsung karena method abstraknya belum lengkap.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa ciri utama abstract class di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar untuk mendeklarasikan abstract class Bangun di Java?',
       $json${
         "options": [
           {"id": "a", "text": "final abstract class Bangun { ... }"},
           {"id": "b", "text": "abstract class Bangun { ... }"},
           {"id": "c", "text": "class abstract Bangun { ... }"},
           {"id": "d", "text": "abstract Bangun class { ... }"}
         ],
         "answer": "b",
         "explanation": "Modifier abstract diletakkan sebelum kata class, dan class abstrak wajib punya minimal satu method abstrak.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar untuk mendeklarasikan abstract class Bangun di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Bagaimana subclass mengimplementasikan method abstrak milik class induk abstrak?',
       $json${
         "options": [
           {"id": "a", "text": "Menandai method tersebut dengan modifier static"},
           {"id": "b", "text": "Tidak perlu melakukan apa pun karena sudah otomatis diimplementasikan"},
           {"id": "c", "text": "Menulis ulang method tersebut dan biasanya menandainya dengan @Override"},
           {"id": "d", "text": "Memanggil method abstrak tersebut langsung dari dalam constructor"}
         ],
         "answer": "c",
         "explanation": "Subclass konkret wajib mengimplementasikan seluruh method abstrak, dan notasi @Override memudahkan saat memeriksa kesesuaiannya.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 44 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Bagaimana subclass mengimplementasikan method abstrak milik class induk abstrak?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 30: QUIZ LEVEL 45 — Interface
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa peran interface di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Membatasi jumlah object yang boleh dibuat di dalam program"},
           {"id": "b", "text": "Menentukan kontrak perilaku yang harus dipenuhi oleh class pengimplementasinya"},
           {"id": "c", "text": "Menyediakan kode siap pakai yang langsung bisa dipanggil"},
           {"id": "d", "text": "Menyimpan data sementara selama program berjalan"}
         ],
         "answer": "b",
         "explanation": "Interface mendefinisikan metode yang harus ada pada class pengimplementasinya, sehingga perilakunya konsisten antar class.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa peran interface di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar untuk menyatakan class Printer mengimplementasikan interface Cetak di Java?',
       $json${
         "options": [
           {"id": "a", "text": "class Printer interface Cetak { ... }"},
           {"id": "b", "text": "interface Printer implements Cetak { ... }"},
           {"id": "c", "text": "class Printer implements Cetak { ... }"},
           {"id": "d", "text": "class Printer extends Cetak { ... }"}
         ],
         "answer": "c",
         "explanation": "Kata kunci implements dipakai untuk interface, sedangkan extends dipakai untuk mewarisi class.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar untuk menyatakan class Printer mengimplementasikan interface Cetak di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apakah satu class di Java boleh mengimplementasikan lebih dari satu interface?',
       $json${
         "options": [
           {"id": "a", "text": "Tidak, satu class hanya boleh mengimplementasikan satu interface"},
           {"id": "b", "text": "Hanya jika kedua interface berada di package yang sama"},
           {"id": "c", "text": "Hanya jika interface tersebut punya method default"},
           {"id": "d", "text": "Bisa, dengan memisahkan nama interface memakai koma"}
         ],
         "answer": "d",
         "explanation": "Satu class boleh mengimplementasikan banyak interface dengan cara memisahkan nama interface memakai koma pada klausa implements.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 45 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apakah satu class di Java boleh mengimplementasikan lebih dari satu interface?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 31: QUIZ LEVEL 46 — ArrayList
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk memakai ArrayList di Java, statement import yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "import java.ArrayList.util;"},
           {"id": "b", "text": "import array.list.ArrayList;"},
           {"id": "c", "text": "import java.util.ArrayList;"},
           {"id": "d", "text": "import java.list.ArrayList;"}
         ],
         "answer": "c",
         "explanation": "ArrayList berada pada paket java.util, sehingga cukup diimpor dengan menyebut nama kelasnya saja.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk memakai ArrayList di Java, statement import yang tepat adalah...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Manakah cara yang benar menambahkan elemen ke dalam ArrayList bernama daftar di Java?',
       $json${
         "options": [
           {"id": "a", "text": "daftar.append(\"Apel\");"},
           {"id": "b", "text": "daftar.push(\"Apel\");"},
           {"id": "c", "text": "daftar.insert(\"Apel\");"},
           {"id": "d", "text": "daftar.add(\"Apel\");"}
         ],
         "answer": "d",
         "explanation": "Method add menambahkan elemen di bagian akhir list, sedangkan append dan push bukan method bawaan dari ArrayList.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Manakah cara yang benar menambahkan elemen ke dalam ArrayList bernama daftar di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk mengambil elemen pada indeks 2 dari ArrayList bernama daftar di Java, perintah yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "daftar.get(2);"},
           {"id": "b", "text": "daftar.get(3);"},
           {"id": "c", "text": "daftar.at(2);"},
           {"id": "d", "text": "daftar[2];"}
         ],
         "answer": "a",
         "explanation": "Method get mengambil elemen berdasarkan indeks berbasis nol, dan ArrayList tidak mendukung akses memakai kurung siku seperti array biasa.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 46 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk mengambil elemen pada indeks 2 dari ArrayList bernama daftar di Java, perintah yang tepat adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 32: QUIZ LEVEL 47 — Stack
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Struktur data Stack bekerja dengan prinsip...',
       $json${
         "options": [
           {"id": "a", "text": "FIFO, yaitu elemen pertama yang dimasukkan keluar pertama"},
           {"id": "b", "text": "Mengurutkan elemen dari nilai terkecil ke terbesar"},
           {"id": "c", "text": "Menyimpan elemen secara acak tanpa urutan"},
           {"id": "d", "text": "LIFO, yaitu elemen terakhir yang dimasukkan keluar pertama"}
         ],
         "answer": "d",
         "explanation": "Stack memakai prinsip Last In First Out, sama seperti tumpukan piring yang selalu diambil dari paling atas.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Struktur data Stack bekerja dengan prinsip...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Method mana yang digunakan untuk menambahkan elemen ke atas Stack di Java?',
       $json${
         "options": [
           {"id": "a", "text": "push"},
           {"id": "b", "text": "poll"},
           {"id": "c", "text": "addFirst"},
           {"id": "d", "text": "put"}
         ],
         "answer": "a",
         "explanation": "Method push menambahkan elemen ke puncak stack, sedangkan poll dan put masing-masing dipakai oleh Queue dan Map.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Method mana yang digunakan untuk menambahkan elemen ke atas Stack di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Method mana yang mengambil sekaligus menghapus elemen puncak Stack di Java?',
       $json${
         "options": [
           {"id": "a", "text": "remove"},
           {"id": "b", "text": "pop"},
           {"id": "c", "text": "peek"},
           {"id": "d", "text": "poll"}
         ],
         "answer": "b",
         "explanation": "pop mengembalikan sekaligus menghapus elemen puncak, sedangkan peek hanya melihat elemen puncak tanpa menghapusnya.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 47 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Method mana yang mengambil sekaligus menghapus elemen puncak Stack di Java?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 33: QUIZ LEVEL 48 — Queue
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Struktur data Queue bekerja dengan prinsip...',
       $json${
         "options": [
           {"id": "a", "text": "FIFO, yaitu elemen pertama yang dimasukkan keluar pertama"},
           {"id": "b", "text": "LIFO, yaitu elemen terakhir yang dimasukkan keluar pertama"},
           {"id": "c", "text": "Penghapusan elemen di tengah list"},
           {"id": "d", "text": "Penyimpanan data dengan pasangan kunci dan nilai"}
         ],
         "answer": "a",
         "explanation": "Queue memakai prinsip First In First Out, seperti antrean yang dilayani sesuai urutan orang datang.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Struktur data Queue bekerja dengan prinsip...'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Method mana yang digunakan untuk menambahkan elemen ke bagian belakang Queue di Java?',
       $json${
         "options": [
           {"id": "a", "text": "offerBack"},
           {"id": "b", "text": "add"},
           {"id": "c", "text": "push"},
           {"id": "d", "text": "put"}
         ],
         "answer": "b",
         "explanation": "Method add menambahkan elemen di ujung belakang queue, sedangkan push digunakan oleh Stack dan put oleh Map.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Method mana yang digunakan untuk menambahkan elemen ke bagian belakang Queue di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Method mana yang mengambil sekaligus menghapus elemen depan Queue di Java?',
       $json${
         "options": [
           {"id": "a", "text": "peek"},
           {"id": "b", "text": "take"},
           {"id": "c", "text": "poll"},
           {"id": "d", "text": "pop"}
         ],
         "answer": "c",
         "explanation": "poll mengambil elemen depan lalu menghapusnya, sedangkan peek hanya melihat elemen depan tanpa menghapus.",
         "language": "java"
       }$json$::jsonb,
       4
FROM public.levels l
WHERE l.level_number = 48 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Method mana yang mengambil sekaligus menghapus elemen depan Queue di Java?'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 34: QUIZ LEVEL 49 — Linked List
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa elemen dasar dari Linked List di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Map dengan pasangan kunci dan nilai"},
           {"id": "b", "text": "Node yang menyimpan data dan penunjuk ke node berikutnya"},
           {"id": "c", "text": "Array dengan indeks yang saling terhubung"},
           {"id": "d", "text": "Variabel global yang menunjuk ke elemen pertama"}
         ],
         "answer": "b",
         "explanation": "Setiap node menyimpan data sekaligus referensi ke node berikutnya, sehingga elemen-elemennya terhubung membentuk rantai.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa elemen dasar dari Linked List di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa kelebihan utama Linked List dibanding Array di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Jumlah elemen otomatis bertambah saat program berjalan"},
           {"id": "b", "text": "Tidak pernah mengalami galat pointer kosong"},
           {"id": "c", "text": "Menyisipkan elemen di tengah list tidak menggeser seluruh elemen lain"},
           {"id": "d", "text": "Akses elemen berdasarkan indeks selalu jauh lebih cepat"}
         ],
         "answer": "c",
         "explanation": "Pada linked list, penyisipan cukup mengubah penunjuk sehingga elemen lain tidak perlu digeser seperti pada array.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa kelebihan utama Linked List dibanding Array di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk menelusuri seluruh elemen Linked List di Java, pola yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "Mengakses elemen langsung memakai indeks tanpa menelusuri node"},
           {"id": "b", "text": "Memanggil method size lalu langsung mengambil semua elemen"},
           {"id": "c", "text": "Menggunakan perulangan for dengan indeks dari nol sampai size"},
           {"id": "d", "text": "Mulai dari node pertama lalu lanjut mengikuti penunjuk next sampai null"}
         ],
         "answer": "d",
         "explanation": "Karena linked list tidak diindeks, penelusuran dilakukan berurutan dari node pertama sambil mengikuti penunjuk next.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 49 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk menelusuri seluruh elemen Linked List di Java, pola yang tepat adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- SECTION 35: QUIZ LEVEL 50 — HashMap
-- ============================================

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Apa yang disimpan oleh HashMap di Java?',
       $json${
         "options": [
           {"id": "a", "text": "Daftar pasangan data dengan indeks berurutan"},
           {"id": "b", "text": "Sekumpulan elemen yang dipesan berdasarkan urutan masuk"},
           {"id": "c", "text": "Pasangan kunci dan nilai yang diambil berdasarkan kunci"},
           {"id": "d", "text": "Nilai tunggal bertipe umum yang bisa diubah"}
         ],
         "answer": "c",
         "explanation": "HashMap menyimpan pasangan kunci dan nilai, dan nilainya bisa diambil dengan cepat berdasarkan kunci yang dicari.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Apa yang disimpan oleh HashMap di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Method mana yang digunakan untuk menambahkan pasangan kunci dan nilai ke dalam HashMap di Java?',
       $json${
         "options": [
           {"id": "a", "text": "add"},
           {"id": "b", "text": "push"},
           {"id": "c", "text": "set"},
           {"id": "d", "text": "put"}
         ],
         "answer": "d",
         "explanation": "Method put menambahkan atau memperbarui nilai untuk sebuah kunci, sedangkan add dan push milik struktur data lain.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Method mana yang digunakan untuk menambahkan pasangan kunci dan nilai ke dalam HashMap di Java?'
      AND e.type = 'quiz'
  );

INSERT INTO public.exercises (level_id, type, prompt, payload, difficulty)
SELECT l.id, 'quiz', 'Soal: Untuk memeriksa apakah sebuah kunci ada di dalam HashMap di Java, method yang tepat adalah...',
       $json${
         "options": [
           {"id": "a", "text": "containsKey"},
           {"id": "b", "text": "containsValue"},
           {"id": "c", "text": "getKey"},
           {"id": "d", "text": "hasValue"}
         ],
         "answer": "a",
         "explanation": "containsKey mengecek keberadaan sebuah kunci, sedangkan containsValue mengecek apakah suatu nilai ada di dalam map.",
         "language": "java"
       }$json$::jsonb,
       5
FROM public.levels l
WHERE l.level_number = 50 AND l.language = 'java'
  AND NOT EXISTS (
    SELECT 1 FROM public.exercises e
    WHERE e.level_id = l.id
      AND e.prompt = 'Soal: Untuk memeriksa apakah sebuah kunci ada di dalam HashMap di Java, method yang tepat adalah...'
      AND e.type = 'quiz'
  );

-- ============================================
-- VERIFIKASI: 3 quiz + 5 drag_drop per level L16-50, integritas total
-- ============================================

DO $$
DECLARE
  v_level INT;
  v_quiz INT;
  v_drag INT;
  v_total_mat INT;
  v_total_ex INT;
  v_quiz_total INT;
BEGIN
  FOR v_level IN
    SELECT unnest(ARRAY[16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50])
  LOOP
    SELECT count(*) INTO v_quiz
    FROM public.exercises e
    JOIN public.levels l ON l.id = e.level_id
    WHERE l.level_number = v_level AND e.type = 'quiz';

    IF v_quiz <> 3 THEN
      RAISE EXCEPTION 'Quiz seed verify: level % expected 3 quiz, got %', v_level, v_quiz;
    END IF;

    SELECT count(*) INTO v_drag
    FROM public.exercises e
    JOIN public.levels l ON l.id = e.level_id
    WHERE l.level_number = v_level AND e.type = 'drag_drop';

    IF v_drag <> 5 THEN
      RAISE EXCEPTION 'Quiz seed verify: level % drag_drop rusak, expected 5 got %', v_level, v_drag;
    END IF;
  END LOOP;

  SELECT count(*) INTO v_total_mat FROM public.materials;
  IF v_total_mat <> 250 THEN
    RAISE EXCEPTION 'Quiz seed verify: materials should be 250, got %', v_total_mat;
  END IF;

  SELECT count(*) INTO v_quiz_total FROM public.exercises WHERE type = 'quiz';
  IF v_quiz_total <> 150 THEN
    RAISE EXCEPTION 'Quiz seed verify: quiz total should be 150 (45 L1-15 + 105 L16-50), got %', v_quiz_total;
  END IF;

  SELECT count(*) INTO v_total_ex FROM public.exercises;
  IF v_total_ex <> 400 THEN
    RAISE EXCEPTION 'Quiz seed verify: exercises should be 400 (250 drag + 150 quiz), got %', v_total_ex;
  END IF;
END
$$;

COMMIT;
