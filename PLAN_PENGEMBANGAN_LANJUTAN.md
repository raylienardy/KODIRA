# PLAN_PENGEMBANGAN_LANJUTAN.md

Dokumen perencanaan teknis lanjutan proyek **KODIRA** — aplikasi mobile Android pembelajaran pemrograman C++ dan Java bagi mahasiswa JTIK semester 1. Dokumen ini merupakan blueprint untuk fase Development (Phase 4) setelah tahap Design selesai, dan menyelaraskan implementasi dengan hasil evaluasi artikel ilmiah kelompok (ARTIKEL_KODIRA_KELOMPOK_3_SELESAI.docx).

> **Catatan penting:** Dokumen ini hanya berisi perencanaan dan panduan teknis. Tidak ada file kode atau migrasi SQL yang diubah pada langkah ini. Semua implementasi nyata dilakukan di tahap build setelah rencana ini disetujui.

---

## 1. Pendahuluan & Konteks Proyek

KODIRA bertujuan memfasilitasi pembelajaran pemrograman dasar (C++ dan Java) melalui tiga pilar utama: **gamifikasi** (XP, level, badge, streak, achievement), **AI Adaptive Mentor** (hint bertahap level 1–3, satu arah, bukan jawaban akhir), dan **Adaptive Quiz** (menyesuaikan riwayat, memuat soal level saat ini + ulasan).

Metode pengembangan: **ADDIE** (Analysis, Design, Development, Implementation, Evaluation). Status saat ini: tahap **Design** sudah selesai. Dokumen ini adalah jembatan dari Design ke Development.

---

## 2. Prinsip & Penyelarasan dengan Artikel Ilmiah

### 2.1 Standar Kurikulum KODIRA

Standar kurikulum yang harus dipertahankan dalam semua implementasi fitur baru:

| Komponen | Spesifikasi |
| :--- | :--- |
| Bahasa pemrograman | C++ dan Java |
| Jumlah level default | 15 level |
| Jumlah Tujuan Pembelajaran (TP) | 3 TP |
| TP 1: Level 1–5 | Algoritma & Struktur Dasar |
| TP 2: Level 6–10 | Variabel, Tipe Data, & Operator |
| TP 3: Level 11–15 | Percabangan |
| Materi per level | 5 slide materi |
| Latihan per level | 5 latihan |
| Soal kuis per level | 3 soal kuis |

#### Aturan Skor Mastery

| Rentang Skor Mastery (M) | Konsekuensi |
| :--- | :--- |
| M ≥ 70% | Lulus level, dapat XP, buka level berikutnya |
| 40% ≤ M < 70% | Remedial, dapat mencoba kembali latihan yang sama |
| M < 40% dan level > 10 | Level terkunci (locked), XP ditahan, wajib remedial atau konsultasi mentor |

#### Guardrail AI Adaptive Mentor

- Memberikan hint bertahap **level 1–3** (semakin spesifik seiring level hint naik).
- **Dilarang** membocorkan jawaban akhir (kode lengkap atau nilai variabel hasil).
- Berbahan bahasa Indonesia, ramah, dan spesifik tentang konsep yang perlu diperbaiki.

### 2.2 Solusi Temuan Evaluasi SUS & Postes

Dari hasil evaluasi artikel ilmiah, dua perbaikan utama diimplementasikan:

#### a. Jawaban Alternatif Setara (`alternative_answers`)

Masalah: Susunan variabel `int` yang ekuivalen (misalnya `int a; int b;` ditukar menjadi `int b; int a;`) salah dinilai karena validator hanya mencocokkan satu jawaban referensi.

Solusi: Tabel `exercises` ditambahi kolom `alternative_answers JSONB DEFAULT '[]'`. Validator latihan di Flutter akan memeriksa apakah jawaban mahasiswa cocok dengan salah satu entri dalam `alternative_answers` sebelum menandai jawaban salah atau memanggil AI untuk penilaian lanjutan.

#### b. Mentor AI & Latihan Kontekstual

Masalah: Penjelasan Mentor AI dan generator soal terlalu generik, kurang akurat untuk konsep spesifik seperti prioritas operator aritmetika dan tipe data bilangan bulat.

Solusi: Generator soal dan Mentor AI terkait dengan potongan materi dosen yang disimpan di `class_material_chunks`. Jika PDF tersedia, AI merujuk pada 2 chunk paling relevan (±800–1000 kata). Jika tidak, fallback ke teks 5 slide materi level tersebut.

---

## 3. Kebijakan Pemrosesan PDF (Tanpa Menyimpan File Biner)

Untuk menghindari duplikasi data dan pembengkakan penyimpanan, diterapkan kebijakan berikut:

### 3.1 Larangan Keras

- **Dilarang** mengunggah atau menyimpan file biner `.pdf` ke Supabase Storage.
- **Dilarang** menyimpan file PDF sebagai binary/bytea di dalam tabel database apa pun.
- Hanya **teks hasil ekstraksi** yang disimpan, dalam bentuk potongan-potongan kecil (chunks).

### 3.2 Alur Ekstraksi Client-Side

1. Dosen memilih file PDF di Web Admin Panel (browser).
2. Ekstraksi teks dilakukan langsung di sisi browser menggunakan `pdfjs-dist` atau parser teks client-side lainnya.
3. Teks hasil ekstraksi dipecah menjadi chunks ±400–600 kata per part.
4. Hanya teks chunks (beserta metadata seperti `topic_title`, `chunk_order`, `keywords`) yang dikirim ke backend dan disimpan di tabel `class_material_chunks`.
5. File PDF asli tidak tersimpan di server dan tidak dikirim ulang dalam setiap permintaan AI.

### 3.3 Fallback Materi Manual

Jika dosen menginput materi secara manual tanpa unggah PDF, sistem tetap berjalan normal dengan membaca teks 5 slide materi pada level tersebut sebagai konteks AI.

---

## 4. Rencana 4 Milestone Eksekusi

### 4.1 Milestone 1 — Database & RLS (`app/supabase/migrations/`)

Tujuan: Mengisolasi struktur kurikulum per kelas sambil mempertahankan template global 15 level, serta mendukung jawaban alternatif dan penyimpanan potongan materi.

#### 4.1.1 Perubahan Tabel `levels`

Tambahkan kolom `class_id` agar level dapat dikaitkan dengan kelas tertentu:

```sql
ALTER TABLE public.levels
  ADD COLUMN IF NOT EXISTS class_id UUID
    REFERENCES public.classes(id) ON DELETE CASCADE;

-- Ganti constraint unique global level_number menjadi unique per kelas
ALTER TABLE public.levels
  DROP CONSTRAINT IF EXISTS levels_level_number_key;

ALTER TABLE public.levels
  ADD CONSTRAINT levels_class_id_level_number_key
    UNIQUE (class_id, level_number);
```

Catatan: `class_id = NULL` berarti level adalah **template global** (15 level default yang dimiliki semua kelas). `class_id` diisi berarti level adalah versi khusus untuk kelas tersebut.

#### 4.1.2 Tabel Baru `class_material_chunks`

```sql
CREATE TABLE IF NOT EXISTS public.class_material_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID NOT NULL
    REFERENCES public.classes(id) ON DELETE CASCADE,
  level_id INT
    REFERENCES public.levels(id) ON DELETE SET NULL,
  source_title TEXT,
  chunk_order INT NOT NULL,
  topic_title TEXT,
  content_text TEXT NOT NULL,
  keywords JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_class_material_chunks_class_id
  ON public.class_material_chunks(class_id);

CREATE INDEX IF NOT EXISTS idx_class_material_chunks_level_id
  ON public.class_material_chunks(level_id);
```

Tabel ini tidak memiliki kolom file URL atau binary. Hanya teks ekstraksi dan metadata.

#### 4.1.3 Perubahan Tabel `exercises`

```sql
ALTER TABLE public.exercises
  ADD COLUMN IF NOT EXISTS alternative_answers JSONB DEFAULT '[]';
```

#### 4.1.4 Fungsi RPC `clone_default_curriculum_to_class`

Fungsi ini menyalin 15 level standar (beserta materi, latihan, dan kuisnya) dari template global ke kelas baru yang dibuat dosen.

```sql
CREATE OR REPLACE FUNCTION public.clone_default_curriculum_to_class(
  p_class_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
  v_old_level_id INT;
  v_new_level_id INT;
BEGIN
  -- Salin 15 level template global (class_id IS NULL) ke kelas target
  FOR v_old_level_id IN
    SELECT id FROM public.levels
    WHERE class_id IS NULL
    ORDER BY level_number
  LOOP
    INSERT INTO public.levels (
      level_number, title, description, topic, language, difficulty, class_id, created_at
    )
    SELECT
      level_number, title, description, topic, language, difficulty, p_class_id, NOW()
    FROM public.levels
    WHERE id = v_old_level_id
    RETURNING id INTO v_new_level_id;

    -- Salin materi level (5 slide)
    INSERT INTO public.materials (
      level_id, slide_order, title, content, code_snippet, created_at
    )
    SELECT
      v_new_level_id, slide_order, title, content, code_snippet, NOW()
    FROM public.materials
    WHERE level_id = v_old_level_id;

    -- Salin latihan level (5 latihan)
    INSERT INTO public.exercises (
      level_id, type, prompt, payload, difficulty, alternative_answers, created_at
    )
    SELECT
      v_new_level_id, type, prompt, payload, difficulty, alternative_answers, NOW()
    FROM public.exercises
    WHERE level_id = v_old_level_id;
  END LOOP;
END $$;
```

#### 4.1.5 Pembaruan Policy RLS Per-Kelas

Policy baru untuk tabel `levels`, `materials`, dan `exercises` harus membatasi akses berdasarkan `class_id` milik pengguna (melalui `class_teachers` atau `class_students`):

```sql
-- Contoh policy SELECT levels per kelas
CREATE POLICY levels_select_per_class ON public.levels
  FOR SELECT TO authenticated
  USING (
    class_id IS NULL
    OR EXISTS (
      SELECT 1 FROM public.class_teachers ct
      WHERE ct.class_id = levels.class_id AND ct.teacher_id = auth.uid()
    )
    OR EXISTS (
      SELECT 1 FROM public.class_students cs
      WHERE cs.class_id = levels.class_id AND cs.student_id = auth.uid()
    )
  );

-- Contoh policy INSERT levels (hanya teacher yang tergabung dalam kelas)
CREATE POLICY levels_insert_teacher ON public.levels
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'teacher'
    )
    AND (
      class_id IS NULL
      OR EXISTS (
        SELECT 1 FROM public.class_teachers ct
        WHERE ct.class_id = levels.class_id AND ct.teacher_id = auth.uid()
      )
    )
  );
```

Policy serupa diterapkan pada `materials` dan `exercises` dengan merujuk ke `levels.class_id` melalui join.

### 4.2 Milestone 2 — Supabase Edge Functions (`app/supabase/functions/`)

Tujuan: Memperkaya kemampuan AI dengan konteks materi kelas, meminimalkan penggunaan token, dan menghasilkan soal adaptif unik per mahasiswa.

#### 4.2.1 Fungsi Baru `ai-process-pdf`

**Input:** Array potongan teks hasil ekstraksi client-side + `class_id`.

**Alur kerja:**
1. Menerima `class_id` dan array `chunks` (tiap chunk berisi `content_text`, `topic_title`, `chunk_order`, `keywords`).
2. Menyimpan chunk ke tabel `class_material_chunks` dengan `class_id` yang sesuai.
3. Menyusun draf level lengkap: 5 materi + 5 latihan + 3 kuis per level.
4. **Deduplikasi topik:** Jika topik serupa sudah ada di kelas tersebut, tautkan chunk ke level yang sudah ada tanpa membuat level baru.
5. **Penyisipan & pergeseran otomatis:** Jika topik baru ditempatkan di tengah urutan, geser `level_number` dan `difficulty` level yang ada secara otomatis.

#### 4.2.2 Pembaruan `ai-generate-quiz`

**Perubahan utama:**
- Menghasilkan **5 soal latihan** dan **3 soal kuis adaptif**.
- Soal **unik per mahasiswa dan per sesi** berdasarkan skor mastery dan riwayat kesalahan.
- Mengambil maksimal **2 chunk** paling relevan (`LIMIT 2`, ~800–1000 kata) dari `class_material_chunks` berdasarkan `level_id` dan `class_id` mahasiswa.
- **Fallback:** Jika chunk kosong, gunakan teks 5 slide materi pada level tersebut.

**Contoh query chunk relevan:**
```sql
SELECT content_text
FROM public.class_material_chunks
WHERE class_id = $1 AND level_id = $2
ORDER BY chunk_order
LIMIT 2;
```

#### 4.2.3 Pembaruan `ai-feedback`

**Perubahan utama:**
- Mengambil maksimal **2 chunk** relevan milik kelas mahasiswa untuk memperkaya hint bertahap (level 1–3) dan penjelasan remedial.
- Guardrail tetap dijaga: hint bertahap tanpa membocorkan jawaban akhir.
- Maksimal 400 karakter per respons, bahasa Indonesia.

---

### 4.3 Milestone 3 — Web Admin Panel (`web/src/`)

Tujuan: Memperbaiki bug stabilitas dan menambahkan fitur manajemen kurikulum lengkap termasuk upload PDF, review level, dan editor manual.

#### 4.3.1 Perbaikan Bug Stabilitas

| File | Masalah | Perbaikan |
| :--- | :--- | :--- |
| `web/src/lib/supabase/client.ts` | Singleton client dapat menyebabkan state collision antar request | Pastikan pembuatan client konsisten dan tidak bocor memori; gunakan pattern yang aman untuk Next.js server/client boundary |
| `web/src/app/dashboard/page.tsx` | Pemakaian `await connection()` yang dapat menyebabkan error 400 atau hanging | Hapus atau ganti `await connection()` dengan pengecekan koneksi yang aman |
| `web/src/app/students/page.tsx` | Query gabungan `class_students` dengan `classes` dan `users` dapat menghasilkan error 400 | Pisah query: ambil `class_students` terlebih dahulu, baru ambil `classes` dan `users` secara terpisah |

#### 4.3.2 Perbarui Halaman Manajemen Kurikulum (`web/src/app/levels/`)

Fitur yang ditambahkan atau diperbarui:
- **Pemilih kelas aktif:** Dropdown untuk memilih kelas (PTIK A, PTIK B, dll.) agar manajemen level terisolasi per kelas.
- **Tombol salin template 15 level:** Memicu RPC `clone_default_curriculum_to_class` untuk mengisi kelas baru dengan kurikulum default.
- **Modal upload PDF client-side extractor:** Pengguna memilih PDF, teks diekstrak di browser, dikonversi menjadi chunks, lalu ditinjau sebelum disimpan.
- **Review & geser urutan level:** Dosen dapat mengubah `level_number` dan `difficulty` level yang sudah ada.
- **Editor penuh & form input manual:**
  - Input materi (5 slide per level) dengan `title`, `content`, `code_snippet`.
  - Input latihan (5 per level) dengan `type`, `prompt`, `payload`, `difficulty`, dan `alternative_answers`.
  - Input soal kuis (3 per level) dengan pertanyaan, opsi, jawaban, dan penjelasan.

#### 4.3.3 Struktur File yang Terlibat

- `web/src/app/levels/page.tsx` — Perbaikan dan penambahan fitur manajemen level per kelas.
- `web/src/app/levels/[id]/page.tsx` — Editor detail level (materi, latihan, kuis).
- `web/src/lib/supabase/client.ts` — Perbaikan singleton.
- `web/src/app/dashboard/page.tsx` — Perbaikan stabilitas `await connection()`.
- `web/src/app/students/page.tsx` — Pisah query untuk menghindari error 400.

---

### 4.4 Milestone 4 — Aplikasi Mobile Flutter (`app/lib/`)

Tujuan: Menyesuaikan aplikasi mobile dengan kurikulum per kelas, validasi jawaban alternatif, dan soal adaptif unik.

#### 4.4.1 Muat Daftar Berdasarkan `class_id` Aktif

Repository level (`level_repository.dart`) dan provider terkait harus memfilter daftar level berdasarkan `primary_class_id` atau `class_id` milik mahasiswa yang login, bukan mengambil semua level global secara acak.

#### 4.4.2 Validasi `alternative_answers` pada Pemeriksaan Latihan

Di `exercise_provider.dart` atau layanan pemeriksaan jawaban, sebelum menandai jawaban salah:
1. Ambil `alternative_answers` dari tabel `exercises` (kolom JSONB).
2. Bandingkan jawaban mahasiswa dengan setiap entri dalam `alternative_answers`.
3. Jika cocok salah satu, tandai jawaban benar tanpa memanggil AI.
4. Jika tidak cocok, baru panggil AI untuk penilaian logika/syntax.

#### 4.4.3 Pemanggilan Generator Latihan dan Kuis Adaptif

- Kirim `class_id` dan `user_id` ke Edge Function AI sehingga soal dihasilkan unik per mahasiswa dan per sesi.
- Jika offline atau timeout, fallback ke soal bawaan yang sudah ada di database (`exercises` untuk latihan dan kuis level tersebut).

#### 4.4.4 Struktur File yang Terlibat

- `app/lib/data/repositories/level_repository.dart` — Filter level per `class_id`.
- `app/lib/data/repositories/exercise_repository.dart` — Validasi `alternative_answers`.
- `app/lib/data/sources/remote/ai_source.dart` — Tambahkan parameter `class_id` dan `user_id` pada pemanggilan fungsi AI.
- `app/lib/features/exercise/providers/exercise_provider.dart` — Logika pemeriksaan jawaban dengan alternative answers.
- `app/lib/features/exercise/screens/code_editor_screen.dart` — Tampilan latihan yang menerima konteks kelas.

---

## 5. Guardrails & Kriteria Lulus Tiap Milestone

### 5.1 Aturan Umum

- Gunakan jalur direktori aktual proyek: `app/` untuk Flutter dan `web/src/app/` untuk Next.js.
- **Jangan ubah migrasi SQL lama** yang sudah ada; buat migrasi baru untuk perubahan baru.
- Pastikan `npm run lint`, `npm run build` (untuk web), serta `flutter analyze` (untuk mobile) lulus tanpa error pada setiap milestone sebelum melanjutkan ke milestone berikutnya.
- Tidak ada file `.env` atau API key yang di-commit ke git.

### 5.2 Kriteria Lulus Milestone 1 — Database & RLS

- [ ] Tabel `levels` memiliki kolom `class_id` nullable dengan FK ke `classes.id`.
- [ ] Constraint `UNIQUE (class_id, level_number)` terpasang, menggantikan unique global lama.
- [ ] Tabel `class_material_chunks` dibuat tanpa kolom file URL atau binary.
- [ ] Tabel `exercises` memiliki kolom `alternative_answers JSONB DEFAULT '[]'`.
- [ ] Fungsi RPC `clone_default_curriculum_to_class(p_class_id uuid)` dapat disalin 15 level lengkap ke kelas baru.
- [ ] Policy RLS untuk `levels`, `materials`, `exercises` membatasi akses per `class_id`.
- [ ] `npm run lint` dan `flutter analyze` lulus (jika ada kode Dart yang merujuk skema baru).
- [ ] Tidak ada migrasi lama yang dihapus atau diubah.

### 5.3 Kriteria Lulus Milestone 2 — Edge Functions AI

- [ ] Fungsi `ai-process-pdf` tersedia dan menerima array chunk + `class_id`.
- [ ] Chunk disimpan ke `class_material_chunks` tanpa menyimpan file PDF biner.
- [ ] Deduplikasi topik diterapkan (tidak membuat level duplikat untuk topik sama).
- [ ] Penggeseran `level_number` dan `difficulty` otomatis saat topik baru disisipkan di tengah.
- [ ] `ai-generate-quiz` menghasilkan 5 soal latihan dan 3 soal kuis, unik per mahasiswa per sesi, menggunakan maksimal 2 chunk relevan.
- [ ] `ai-feedback` mengambil maksimal 2 chunk relevan dan mematuhi guardrail hint level 1–3 tanpa jawaban akhir.
- [ ] Fallback ke teks slide materi bekerja jika chunk kosong.
- [ ] Semua Edge Function lulus validasi input dan tidak bocor PII.

### 5.4 Kriteria Lulus Milestone 3 — Web Admin Panel

- [ ] Bug `client.ts` singleton diperbaiki, tidak ada state collision.
- [ ] `await connection()` di `dashboard/page.tsx` tidak lagi menyebabkan error 400 atau hanging.
- [ ] Query di `students/page.tsx` dipisah agar bebas error 400.
- [ ] Halaman levels memiliki pemilih kelas aktif.
- [ ] Tombol salin template 15 level bekerja melalui RPC.
- [ ] Modal upload PDF client-side extractor bekerja (eksport teks, bukan file biner).
- [ ] Review dan geser urutan level bekerja.
- [ ] Editor manual untuk materi, latihan (dengan `alternative_answers`), dan kuis lengkap berfungsi.
- [ ] `npm run lint` dan `npm run build` lulus tanpa error.

### 5.5 Kriteria Lulus Milestone 4 — Aplikasi Mobile Flutter

- [ ] Daftar level difilter berdasarkan `class_id` aktif mahasiswa.
- [ ] Pemeriksaan latihan memvalidasi `alternative_answers` sebelum menandai salah.
- [ ] Pemanggilan generator latihan dan kuis mengirim `class_id` dan `user_id`.
- [ ] Fallback ke soal bawaan database bekerja saat offline atau timeout.
- [ ] `flutter analyze` lulus tanpa error.

---

## 6. Ringkasan File yang Akan Dibuat atau Diubah

Berikut adalah daftar file yang terlibat dalam 4 milestone ini, untuk referensi saat implementasi dimulai:

### Database (`app/supabase/migrations/`)
- File migrasi baru untuk penambahan `class_id` pada `levels`, tabel `class_material_chunks`, dan kolom `alternative_answers` pada `exercises`.
- File migrasi baru untuk fungsi RPC `clone_default_curriculum_to_class` dan pembaruan policy RLS.

### Edge Functions (`app/supabase/functions/`)
- `ai-process-pdf/index.ts` (baru)
- `ai-generate-quiz/index.ts` (diubah)
- `ai-feedback/index.ts` (diubah)

### Web Admin (`web/src/`)
- `web/src/lib/supabase/client.ts` (diubah — perbaikan singleton)
- `web/src/app/dashboard/page.tsx` (diubah — perbaikan stabilitas)
- `web/src/app/students/page.tsx` (diubah — pisah query)
- `web/src/app/levels/page.tsx` (diubah — manajemen kurikulum per kelas)
- `web/src/app/levels/[id]/page.tsx` (diubah atau dibuat — editor detail level)

### Mobile Flutter (`app/lib/`)
- `app/lib/data/repositories/level_repository.dart` (diubah)
- `app/lib/data/repositories/exercise_repository.dart` (diubah)
- `app/lib/data/sources/remote/ai_source.dart` (diubah)
- `app/lib/features/exercise/providers/exercise_provider.dart` (diubah)
- `app/lib/features/exercise/screens/code_editor_screen.dart` (diubah)

---

Dokumen ini adalah rencana acuan bagi AI dan developer pada tahap Development. Semua implementasi nyata harus mengikuti spesifikasi di atas dan disesuaikan dengan kondisi kode aktual di masing-masing file sebelum diedit.
