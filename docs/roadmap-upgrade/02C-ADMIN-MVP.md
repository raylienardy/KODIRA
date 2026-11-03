# Fitur #2C — Admin Panel (MVP)

## 1. Konteks
Untuk mendukung manajemen pembelajaran yang dinamis, dosen membutuhkan antarmuka web khusus untuk mengelola konten dan memonitor perkembangan mahasiswa secara langsung tanpa perlu melakukan kueri database secara manual.

## 2. Scope
Pembangunan penuh 6 modul MVP Admin Web dan integrasi database Supabase untuk mendukung operasional dosen.

## 3. Spec Detail & Spesifikasi Teknis
1. **Teacher Auth (2 jam)**: Sistem autentikasi untuk dosen/guru. Menggunakan email `@ub.ac.id` untuk pendaftaran mandiri (auto-approve) atau sistem antrean verifikasi untuk NIDN/NIP melalui tabel `user_verification_queue`.
2. **AI Material Parser (6 jam)**: Antarmuka unggah file PDF/Word. File diproses melalui Cloud Function Python yang memparsing teks dan mengekstraksi menjadi struktur JSON:
   ```json
   {
     "level_id": 1,
     "materials": [{"slide": 1, "content": "Pengantar C++", "code": "cout << \"Hello\";"}],
     "exercises": [{"type": "drag_drop", "prompt": "Lengkapi sintaks output", "payload": "cout"}],
     "quiz": [{"question": "Apa fungsi cout?", "options": ["Cetak", "Input"], "answer": 0}]
   }
   ```
3. **Level Preview & Edit (4 jam)**: Modul untuk meninjau hasil parse AI. Dosen dapat mengedit konten slide, soal latihan, dan kuis sebelum diterbitkan ke aplikasi mobile.
4. **Student Management (3 jam)**: Modul daftar mahasiswa. Fitur utama: membuat akun mahasiswa baru dan impor massal (bulk import) data mahasiswa menggunakan file CSV.
   - Format CSV: `nim,name,password`.
5. **Dashboard Analytics (4 jam)**: Visualisasi data menggunakan chart.js atau Recharts yang menampilkan:
   - Frekuensi login mahasiswa.
   - Tingkat penyelesaian level.
   - Daftar materi atau soal yang paling banyak memicu remedial.
6. **Reset Password Student (1 jam)**: Tombol aksi untuk menyetel ulang kata sandi mahasiswa jika mereka terkunci dari sistem.

- **Migrasi & Deployment (6 jam)**: Migrasi skema database (`classes`, `class_teachers`, `class_students`), implementasi RLS (Row Level Security) untuk akses data, dan deployment ke Vercel.

## 4. File yang Disentuh
- `admin/src/app/(dashboard)/classes/page.tsx`
- `admin/src/app/(dashboard)/students/page.tsx`
- `admin/src/app/(dashboard)/materials/page.tsx`
- **Migration SQL**: 
  - `app/supabase/migrations/20261030000000_classes_and_roles.sql` (Migrasi skema lengkap).

## 5. Test Cases & Skenario Pengujian
- **Test AI Parser**: Mengunggah file PDF standar pemrograman dan memverifikasi output JSON sesuai dengan struktur yang diharapkan.
- **Test Import Student**: Membaca file CSV dengan 10 baris dan memverifikasi bahwa 10 akun baru terbuat di database.
- **Test Reset Password**: Menyetel ulang password mahasiswa dan memverifikasi mahasiswa tersebut dapat login dengan password baru.

## 6. Definition of Done (DoD)
- Seluruh 6 modul MVP beroperasi stabil di peramban web.
- Dosen dapat mengunggah materi baru yang langsung tersedia di aplikasi mobile secara otomatis.

## 7. Blocker & Dependency
- Bergantung pada keberhasilan migrasi tabel `classes`, `class_teachers`, `class_students`.

## 8. Effort Estimate
- 27 jam total.

## 9. Risk & Mitigasi
- **Risk**: Kegagalan ekstraksi AI pada format PDF yang memiliki layout kompleks.
- **Mitigasi**: Menyediakan antarmuka editor manual yang intuitif bagi dosen untuk memperbaiki hasil ekstraksi AI sebelum dipublikasikan.
