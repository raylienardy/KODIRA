# Fitur #2A — Admin Panel (Konsep)

## Konteks
KODIRA membutuhkan backend admin untuk mendukung manajemen materi pembelajaran yang dinamis, memantau kemajuan mahasiswa secara real-time, dan mempermudah operasional guru/dosen.

## Scope
Definisi arsitektur, pemilihan teknologi, dan pemetaan fitur utama untuk implementasi web-based admin panel.

## Spec Detail
- **Teknologi**: Next.js 15, React 19, TypeScript, Tailwind CSS 4, Supabase (reuse existing DB).
- **Struktur Folder**: Monorepo dengan folder `/admin` di root repository KODIRA.
- **Fitur Utama**:
  - **Auth**: Email domain `@ub.ac.id` (auto-approve) atau NIDN (manual review).
  - **Manajemen Kelas**: Create, Read, Update, Delete (CRUD) kelas, assign dosen & mahasiswa.
  - **AI Content Engine**: Upload dokumen (PDF/Word), parsing otomatis via Edge Functions, preview level (materi, drag&drop, kuis), approve/regenerate.
  - **Monitoring Dashboard**: Visualisasi aktivitas mahasiswa (login, level completion, topik tersulit).
  - **User Management**: Bulk CSV import, reset password mahasiswa.

## File yang Disentuh (Konsep)
- `admin/` (folder baru).
- CI workflow (`.github/workflows/ci.yml`).

## Test Cases
- Tidak berlaku untuk konsep (dijawab pada dokumen `02B-ADMIN-SKELETON.md`).

## Definition of Done
- Dokumen desain arsitektur final disetujui.
- Rencana migration database untuk mendukung multi-class dan role management disetujui.

## Blocker / Dependency
- Memerlukan fitur kelas & roles (#2C).

## Effort Estimate
- 4 jam (untuk perancangan dokumen dan persetujuan).

## Risk
- Kompleksitas monorepo dengan project Flutter. Mitigasi: pemisahan CI pipeline secara ketat antara `flutter` dan `node`.
