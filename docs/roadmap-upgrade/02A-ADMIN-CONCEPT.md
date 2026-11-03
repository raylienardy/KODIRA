# Fitur #2A — Admin Panel (Konsep & Arsitektur Sistem)

## 1. Konteks
KODIRA memerlukan platform web admin yang terintegrasi dengan backend Supabase yang sama untuk memudahkan pengelolaan data kelas, pengunggahan materi berbasis AI, dan pemantauan analitik perkembangan belajar mahasiswa secara real-time.

## 2. Scope
Definisi lengkap arsitektur sistem, pemilihan tech stack, pemetaan modul fungsional, dan alur kerja (workflow) operasional untuk Admin Web Panel.

## 3. Spec Detail & Arsitektur Sistem
- **Tech Stack**: Next.js 15 (App Router), React 19, TypeScript, Tailwind CSS 4, shadcn/ui, dan Supabase JS Client v2.
- **Monorepo Structure**: Ditempatkan dalam folder `/admin` di root repositori utama KODIRA.
- **Arsitektur Hubungan (Diagram Text-based)**:
  ```
  ┌──────────────┐       ┌─────────────┐       ┌──────────────┐
  │ Next.js 15   │──────▶│ Supabase    │──────▶│ Edge Function│
  │ (Admin Panel)│       │ Auth + DB   │       │ (AI Parser)  │
  └──────────────┘       └─────────────┘       └──────────────┘
         │                      │                     │
         │                      │                     ▼
         │                      │              ┌──────────────┐
         │                      └─────────────▶│ Groq API     │
         ▼                                     └──────────────┘
  ┌──────────────┐
  │ Flutter App  │ (Consume same Supabase PostgreSQL via RLS)
  └──────────────┘
  ```

- **Modul Fungsional Utama**:
  1. **Teacher Authentication**: Login & register dosen dengan verifikasi domain email `@ub.ac.id` (auto-approve) atau antrean NIDN manual review.
  2. **Class Management**: CRUD kelas perkuliahan, kode join 6-karakter alfanumerik, dan assignment dosen/mahasiswa.
  3. **AI Content Generator**: Unggah dokumen materi (PDF/Word), parsing otomatis menjadi slide, latihan, dan kuis interaktif.
  4. **Student Analytics**: Dashboard pemantauan aktivitas login, tingkat penyelesaian level, dan identifikasi topik tersulit.
  5. **User Administration**: Manajemen akun mahasiswa termasuk impor massal via CSV dan reset password.

- **API Contract & Flow**:
  - Dosen mengunggah PDF materi ke Supabase Storage (`materials` bucket).
  - Trigger webhook memanggil Edge Function untuk memparsing teks via LLM.
  - Hasil parse disimpan di tabel staging level, siap direview dan dipublikasikan oleh dosen ke aplikasi Flutter mahasiswa.

## 4. File yang Disentuh (Konsep & Arsitektur)
- `admin/` (Direktori root modul Next.js).
- `.github/workflows/ci.yml` (Penambahan job testing dan linting admin).
- `app/supabase/migrations/` (Kumpulan file migrasi SQL pendukung kelas).

> **Penting**: Spesifikasi detail desain visual untuk panel ini diatur dalam `docs/roadmap-upgrade/02D-ADMIN-DESIGN-SYSTEM.md`. Alur kerja pengguna (user flow) dan inventori layar didefinisikan dalam `docs/roadmap-upgrade/02E-ADMIN-USER-FLOW.md`.

## 5. Test Cases & Skenario Pengujian
- Desain arsitektur diuji melalui review code dan validasi kesesuaian skema database Supabase existing.
- Uji simulasi alur end-to-end dari unggah dokumen PDF hingga terbitnya level baru di aplikasi mobile.

## 6. Definition of Done (DoD)
- Dokumen desain arsitektur disetujui dan seluruh spesifikasi modul didefinisikan secara konkrit tanpa ambiguitas.
- Rencana migrasi skema database disetujui oleh tim.

## 7. Blocker & Dependency
- Memerlukan kesiapan tabel migrasi multi-kelas (Fitur #2C).

## 8. Effort Estimate
- 4 jam perancangan dan validasi dokumen.

## 9. Risk & Mitigasi
- **Risk**: Kompleksitas pengelolaan monorepo (Flutter + Next.js dalam satu repo git).
- **Mitigasi**: Memisahkan direktori secara ketat dan menggunakan CI workflow matrix terpisah untuk linting masing-masing project.
