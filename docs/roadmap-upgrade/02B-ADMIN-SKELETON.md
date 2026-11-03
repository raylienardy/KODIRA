# Fitur #2B — Admin Panel (Skeleton & Scaffolding)

## 1. Konteks
Inisialisasi awal proyek (scaffolding) untuk aplikasi Admin Web menggunakan Next.js 15 dan React 19 agar tim pengembang dapat langsung membangun modul fungsional di atas kerangka yang konsisten dan teruji.

## 2. Scope
Inisialisasi direktori `admin/`, setup konfigurasi dasar Next.js, integrasi Supabase client, penataan routing (App Router), dan pembaruan pipeline CI GitHub Actions.

## 3. Spec Detail & Spesifikasi Teknis
- **Tech Stack**: Next.js 15, React 19, TypeScript, Tailwind CSS 4, dan shadcn/ui components.
- **Struktur Direktori**:
  ```
  admin/
  ├── package.json
  ├── tsconfig.json
  ├── tailwind.config.ts
  ├── src/
  │   ├── app/
  │   │   ├── layout.tsx
  │   │   ├── page.tsx
  │   │   ├── (auth)/
  │   │   │   └── login/
  │   │   │       └── page.tsx
  │   │   └── (dashboard)/
  │   │       ├── layout.tsx
  │   │       ├── page.tsx
  │   │       ├── classes/
  │   │       │   └── page.tsx
  │   │       ├── students/
  │   │       │   └── page.tsx
  │   │       └── materials/
  │   │           └── page.tsx
  │   └── lib/
  │       └── supabase.ts
  ```
- **Konfigurasi `package.json`**:
  ```json
  {
    "name": "kodira-admin",
    "version": "1.0.0",
    "private": true,
    "scripts": {
      "dev": "next dev",
      "build": "next build",
      "start": "next start",
      "lint": "next lint"
    },
    "dependencies": {
      "next": "^15.0.0",
      "react": "^19.0.0",
      "react-dom": "^19.0.0",
      "@supabase/supabase-js": "^2.45.0",
      "clsx": "^2.1.0",
      "tailwind-merge": "^2.2.0"
    },
    "devDependencies": {
      "typescript": "^5.0.0",
      "@types/node": "^20.0.0",
      "@types/react": "^18.3.0",
      "@types/react-dom": "^18.3.0",
      "postcss": "^8.0.0",
      "tailwindcss": "^4.0.0"
    }
  }
  ```
- **Konfigurasi Supabase Client (`admin/src/lib/supabase.ts`)**:
  ```typescript
  import { createClient } from '@supabase/supabase-js';

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error('Missing Supabase environment variables in admin panel.');
  }

  export const supabase = createClient(supabaseUrl, supabaseAnonKey);
  ```

- **Pembaruan CI Workflow (`.github/workflows/ci.yml`)**:
  Menambahkan job terpisah `admin-lint` untuk memastikan kode TypeScript pada folder `/admin` selalu teruji kualitasnya sebelum di-merge.
  ```yaml
  admin-lint:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: admin
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
          cache-dependency-path: admin/package-lock.json
      - run: npm ci
      - run: npm run lint
  ```

## 4. File yang Disentuh
- Folder `admin/` (BARU).
- `.github/workflows/ci.yml` (UPDATE).
- `.gitignore` (UPDATE: penambahan `node_modules/` dan `admin/.next/`).

## 5. Test Cases & Skenario Pengujian
- **Test Routing**: Memastikan halaman login dan dashboard admin dapat diakses melalui peramban lokal tanpa error kompilasi.
- **Test CI Matrix**: Memastikan workflow GitHub Actions menjalankan linter admin dengan sukses.

## 6. Definition of Done (DoD)
- Skeleton Next.js terinisialisasi bersih di folder `/admin`.
- Pipeline CI berhasil mendeteksi dan mengeksekusi linting untuk aplikasi admin.

## 7. Blocker & Dependency
- Tidak ada.

## 8. Effort Estimate
- 3 jam pengerjaan scaffolding dan konfigurasi CI.

## 9. Risk & Mitigasi
- **Risk**: Konflik versi dependensi Node.js di environment CI.
- **Mitigasi**: Menggunakan Node.js version pinning (v20) pada action setup-node.
