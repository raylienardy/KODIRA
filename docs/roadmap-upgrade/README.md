# Roadmap Upgrade KODIRA

Dokumen ini berisi roadmap teknis dan fungsional untuk 8 fitur upgrade utama pada aplikasi pembelajaran pemrograman KODIRA (C++ & Java JTIK semester 1). Upgrade ini dikembangkan berdasarkan umpan balik dosen, pengujian pendahuluan, dan spesifikasi arsitektur lanjutan pasca-submit MVP.

## Urutan Baca untuk AI Agent & Developer Baru

1. **`00-OVERVIEW.md`** — Ringkasan eksekutif, status proyek saat ini (302 test PASS), pembagian fase, dan ringkasan risiko.
2. **File Fitur Spesifik (`01-LEVEL-GROUPING.md` s/d `08-TITLES.md`)** — Spesifikasi teknis per fitur beserta file yang disentuh dan test cases.
3. **Infrastruktur & Data (`09-DATA-MIGRATION.md`, `10-SEED-USERS.md`)** — Skema database, strategi migrasi inkremental, dan data dummy seed.
4. **Backlog & Handover** — Cross-check dengan `docs/07-backlog.md` dan `docs/10-handover.md` untuk menjaga konsistensi arsitektur.

## Ringkasan Fase & Estimasi Effort

| Fase | Fitur | Deskripsi Utama | Estimasi Effort | Status |
|---|---|---|---|---|
| **Fase 1** | #3, #6, #4a, #5 | Quick Wins (Mastery UI breakdown, XP bertingkat, password mobile, About static) | 10 jam | Ready to Build |
| **Fase 2** | #1, #7, #8 | Medium Features (Level grouping 3 tier, global leaderboard, system gelar/titles) | 10 jam | Pending Fase 1 |
| **Fase 3A** | #2A, #2B | Admin Web Concept & Skeleton (Next.js 15, monorepo setup `admin/`, CI matrix) | 4 jam | Pending Fase 2 |
| **Fase 3B** | #2C | Admin Web MVP & Integration (AI parser, student monitoring, bulk CSV, class migration) | 27 jam | Pending Fase 3A |
| **Total** | 8 Fitur | Keseluruhan Upgrade | ~51 jam | Planned |

## Indeks File Roadmap

- [`00-OVERVIEW.md`](./00-OVERVIEW.md) — Ringkasan komprehensif, spesifikasi final user, dan matriks ketergantungan.
- [`01-LEVEL-GROUPING.md`](./01-LEVEL-GROUPING.md) — Pengelompokan level belajar menjadi 3 tier (Mudah, Sedang, Tinggi) dengan tampilan collapsible.
- [`02A-ADMIN-CONCEPT.md`](./02A-ADMIN-CONCEPT.md) — Konsep arsitektur Admin Panel Web (Next.js 15 + Supabase) di monorepo `admin/`.
- [`02B-ADMIN-SKELETON.md`](./02B-ADMIN-SKELETON.md) — Setup awal Next.js skeleton, Tailwind 4, shadcn/ui, dan konfigurasi CI workflow.
- [`02C-ADMIN-MVP.md`](./02C-ADMIN-MVP.md) — Implementasi penuh 6 modul Admin MVP (AI parser materi, student management, monitoring).
- [`03-MASTERY-UI.md`](./03-MASTERY-UI.md) — Breakdown detail komponen mastery (A, C, E, Tn) saat tap mastery bar di profil.
- [`04-PASSWORD.md`](./04-PASSWORD.md) — Ganti password di aplikasi mobile (dengan strength meter) & reset password oleh guru di web.
- [`05-ABOUT.md`](./05-ABOUT.md) — Halaman statis informasi panduan aplikasi, sistem XP, dan FAQ dalam 6 section.
- [`06-XP-TIERING.md`](./06-XP-TIERING.md) — Sistem perolehan XP bertingkat berdasarkan tingkat kesulitan level + streak multiplier.
- [`07-LEADERBOARD.md`](./07-LEADERBOARD.md) — Peringkat mahasiswa berdasarkan total XP (global dan per kelas) dengan RLS policy aman.
- [`08-TITLES.md`](./08-TITLES.md) — Sistem gelar progresif (Pemula, Pelajar C++, Master C++, Grand Master) yang tampil di profil dan leaderboard.
- [`09-DATA-MIGRATION.md`](./09-DATA-MIGRATION.md) — Strategi migrasi database inkremental (non-retroactive) untuk multi-class dan roles.
- [`10-SEED-USERS.md`](./10-SEED-USERS.md) — Data dummy seed (5 mahasiswa, 1 kelas PTIK B 2024) untuk pengujian leaderboard dan admin panel.

## Standar Penulisan & Pemeliharaan

- Setiap file markdown wajib memuat 9 section: Konteks, Scope, Spec Detail, File yang Disentuh, Test Cases, Definition of Done, Blocker / Dependency, Effort Estimate, dan Risk.
- Commit message wajib mengikuti Conventional Commits format: `docs(roadmap): [deskripsi singkat]`.
- Dilarang menggunakan placeholder atau truncation (`// ...`, `TODO`) di dalam spesifikasi teknis maupun contoh kode.
