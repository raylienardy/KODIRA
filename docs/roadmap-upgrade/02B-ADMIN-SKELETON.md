# Fitur #2B — Admin Panel (Skeleton)

## Konteks
Setup dasar (scaffolding) untuk aplikasi Admin Web menggunakan Next.js agar tim pengembang dapat memulai implementasi fitur.

## Scope
Inisialisasi project, setup CI, dan implementasi routing dasar.

## Spec Detail
- **Project**: Next.js 15, React 19, TypeScript, Tailwind 4, shadcn/ui.
- **Struktur**:
  - `admin/src/app/(auth)/login`
  - `admin/src/app/(dashboard)/classes`
  - `admin/src/app/(dashboard)/students`
  - `admin/src/app/(dashboard)/materials`
  - `admin/src/lib/supabase.ts`
- **CI**: Update `.github/workflows/ci.yml` untuk menambahkan job `admin-lint` yang menjalankan `npm install` dan `npm run lint` di folder `/admin`.

## File yang Disentuh
- Folder `/admin` (BARU).
- `.github/workflows/ci.yml` (UPDATE).
- `.gitignore` (UPDATE: tambah `node_modules/`, `admin/.next/`).

## Test Cases
- Verify dashboard dapat diakses setelah login.
- Verify pipeline CI berhasil menjalankan linting untuk folder admin.

## Definition of Done
- Aplikasi skeleton ter-deploy ke Vercel/staging.
- Halaman login fungsional dengan Supabase Auth.
- Pipeline CI berhasil mendeteksi linting di folder admin.

## Blocker / Dependency
- Tidak ada.

## Effort Estimate
- 3 jam.

## Risk
- Masalah integrasi Supabase (CORS atau env variables). Mitigasi: memastikan konfigurasi environment variables (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`) terpasang dengan benar pada Vercel.
