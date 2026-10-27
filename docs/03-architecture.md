# Arsitektur — KODIRA

Arsitektur teknis aplikasi mobile KODIRA.

| Field | Nilai |
|-------|-------|
| Versi | 1.0 |
| Tanggal | 2026-10-16 |
| Status | Draft |
| Basis | `docs/01-prd.md`, `docs/02-design-system.md` |

---

## 1. Ringkasan Arsitektur

KODIRA adalah aplikasi mobile Android yang berkomunikasi dengan backend 
untuk autentikasi, sinkronisasi progres, AI hint, dan code execution. 
Data lokal di HP menyimpan cache dan state agar aplikasi tetap responsif.

**Pola arsitektur:** Client-server dengan local-first caching.

```
┌──────────────────┐
│  Mobile App      │  (Flutter)
│  ─────────────   │
│  UI Layer        │
│  State Layer     │
│  Local Storage   │  (SQLite / Isar)
└────────┬─────────┘
         │ HTTPS
         │
┌────────▼─────────┐
│  Backend         │  (Supabase)
│  ─────────────   │
│  Auth            │
│  PostgreSQL      │
│  Storage         │
│  Edge Functions  │
└────────┬─────────┘
         │
         ├──────────────────┐
         │                  │
┌────────▼─────────┐  ┌────▼─────────┐
│  AI Provider     │  │  Code Runner │
│  (API berbayar)  │  │  (Judge0)    │
└──────────────────┘  └──────────────┘
```

---

## 2. Tech Stack

### 2.1 Mobile

| Layer | Pilihan | Alasan |
|-------|---------|--------|
| Framework | **Flutter** | Cross-platform, UI konsisten, hot reload, komunitas besar |
| Bahasa | **Dart** | Wajib untuk Flutter |
| State Management | **Riverpod** | Modern, type-safe, mudah di-test |
| Local DB | **Drift** | Migrasi otomatis, komunitas besar |
| HTTP Client | **Dio** | Fitur lengkap, interceptor, mudah |
| Code Editor | **flutter_code_editor** atau custom | Syntax highlighting C++/Java |
| Navigasi | **go_router** | Declarative, deep link support |

**Alternatif:** React Native. Tapi Flutter lebih dipilih karena:
- UI lebih konsisten antar device
- Performa lebih baik untuk animasi (penting untuk gamifikasi)
- Tooling lebih matang

### 2.2 Backend

| Layer | Pilihan | Alasan |
|-------|---------|--------|
| Platform | **Supabase** | Open source, PostgreSQL, real-time, auth built-in |
| Database | **PostgreSQL** | Yang dipakai Supabase, powerful |
| Auth | **Supabase Auth** + verifikasi NIM | Custom flow |
| Storage | **Supabase Storage** | Untuk materi, gambar, audio |
| Edge Functions | **Deno (Supabase Functions)** | Untuk logika yang butuh secret (AI API key) |
| Real-time | **Supabase Realtime** (opsional) | Untuk fitur sosial di masa depan |

**Alternatif:** Firebase. Tapi Supabase lebih dipilih karena:
- Open source, bisa self-host nanti
- PostgreSQL (relasional, cocok untuk mastery tracking)
- Vendor lock-in lebih rendah
- Query lebih fleksibel

### 2.3 AI

| Layer | Pilihan | Alasan |
|-------|---------|--------|
| Provider | **OpenAI GPT-4o-mini** (fallback: Gemini Flash) | Kualitas coding terbaik, harga termurah (ADR-019) |
| Model | **Model ringan** (misal GPT-4o-mini, Gemini Flash, Claude Haiku) | Biaya lebih murah, cukup untuk hint & soal |
| Fallback | **Rule-based** | Jika API gagal atau limit |
| Guardrail | Validasi server-side | Sintaks, test case, rubrik, batasan materi |

**Alasan tidak pakai on-device AI:**
- Beban HP terlalu besar
- Model kecil hasilnya tidak konsisten
- Update model lebih sulit

### 2.4 Code Runner

| Layer | Pilihan | Alasan |
|-------|---------|--------|
| Platform | **Judge0 hosted API** | Tanpa server, gratis volume awal, sandbox aman (ADR-021) |
| Alternatif | **Piston** | Open source, mudah di-deploy |
| Sandbox | Wajib | Cegah eksekusi berbahaya |

**Keputusan:** Mulai dengan **Judge0 API** (free tier untuk testing), 
nanti pertimbangkan **self-host Piston** kalau volume naik.

### 2.5 Auth

| Layer | Pilihan | Alasan |
|-------|---------|--------|
| Metode | NIM + password | Sesuai PRD |
| Verifikasi | API kampus (jika tersedia) atau manual admin | Fleksibel |
| Session | JWT dari Supabase | Standar |

### 2.6 Tools Development

| Kategori | Tools |
|----------|-------|
| IDE | VS Code + Flutter extension |
| Version Control | Git + GitHub |
| CI/CD | GitHub Actions (nanti) |
| Design | Stitch AI, Figma (opsional) |
| API Testing | Postman atau Bruno |
| Dokumentasi | Markdown di `docs/` |

---

## 3. Struktur Folder Mobile (Flutter)

```
kodira/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                 ← Root widget
│   │   ├── router.dart              ← go_router config
│   │   └── theme.dart               ← Design tokens
│   ├── core/
│   │   ├── constants/               ← Konstanta global
│   │   ├── errors/                  ← Error handling
│   │   ├── utils/                   ← Helper functions
│   │   └── network/                 ← Dio client, interceptors
│   ├── data/
│   │   ├── models/                  ← Data models
│   │   ├── repositories/            ← Repository pattern
│   │   └── sources/
│   │       ├── remote/              ← Supabase, API
│   │       └── local/               ← Isar, shared_preferences
│   ├── domain/
│   │   ├── entities/                ← Business entities
│   │   └── usecases/                ← Business logic
│   ├── features/
│   │   ├── auth/                    ← Login, register
│   │   ├── home/                    ← Peta level
│   │   ├── lesson/                  ← Materi
│   │   ├── exercise/                ← Latihan
│   │   ├── quiz/                    ← Kuis
│   │   ├── ai_mentor/               ← Hint, feedback
│   │   ├── adaptive/                ← Mastery engine
│   │   ├── profile/                 ← Profil, badge
│   │   └── profile/                 ← Settings
│   └── shared/
│       ├── widgets/                 ← Widget reusable
│       └── providers/               ← Global providers
├── assets/
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── animations/                  ← Lottie
├── test/                            ← Unit & widget tests
├── android/                         ← Konfigurasi Android
├── docs/                            ← Dokumentasi (ini)
├── reference/                       ← Referensi
└── pubspec.yaml
```

**Aturan:**
- **Feature-first:** setiap fitur di folder sendiri
- **Clean architecture ringan:** data → domain → presentation
- **Jangan campur** logic dengan UI
- **Shared widget** hanya untuk yang dipakai > 2 fitur

---

## 4. Struktur Database (PostgreSQL via Supabase)

### 4.1 Tabel Utama

**users**
```sql
id UUID PRIMARY KEY (dari auth.users)
nim TEXT UNIQUE NOT NULL
name TEXT NOT NULL
email TEXT UNIQUE
avatar_url TEXT
created_at TIMESTAMP
updated_at TIMESTAMP
```

**levels**
```sql
id SERIAL PRIMARY KEY
level_number INT UNIQUE NOT NULL
title TEXT NOT NULL
description TEXT
topic TEXT                      -- variabel, loop, dll
language TEXT                   -- cpp, java
difficulty INT                  -- 1-5
created_at TIMESTAMP
```

**materials**
```sql
id SERIAL PRIMARY KEY
level_id INT REFERENCES levels(id)
slide_order INT
title TEXT
content TEXT                    -- markdown
code_snippet TEXT
created_at TIMESTAMP
```

**exercises**
```sql
id SERIAL PRIMARY KEY
level_id INT REFERENCES levels(id)
type TEXT                       -- drag_drop, code_editor, quiz
prompt TEXT
payload JSONB                   -- data spesifik tipe
created_at TIMESTAMP
```

**user_progress**
```sql
id UUID PRIMARY KEY
user_id UUID REFERENCES users(id)
level_id INT REFERENCES levels(id)
status TEXT                     -- locked, active, completed, remedial
mastery_score FLOAT             -- 0.0 - 1.0
xp_earned INT
attempts INT
last_attempt_at TIMESTAMP
completed_at TIMESTAMP
```

**user_mastery**  ← untuk adaptive engine
```sql
id UUID PRIMARY KEY
user_id UUID REFERENCES users(id)
topic TEXT                      -- variabel, loop, dll
mastery_score FLOAT
error_count INT
last_updated TIMESTAMP
```

**user_answers**  ← dihapus setelah dinilai (retensi pendek)
```sql
id UUID PRIMARY KEY
user_id UUID
level_id INT
exercise_id INT
answer TEXT
is_correct BOOLEAN
error_type TEXT                 -- syntax, logic, fatal
created_at TIMESTAMP
-- retention 7 hari, lalu dihapus
```

**user_badges**
```sql
id UUID PRIMARY KEY
user_id UUID REFERENCES users(id)
badge_code TEXT
earned_at TIMESTAMP
```

**ai_hints**  ← cache hint dari AI
```sql
id UUID PRIMARY KEY
user_id UUID
level_id INT
hint_level INT                  -- 1, 2, 3
content TEXT
created_at TIMESTAMP
```

### 4.2 Row Level Security (RLS)

Supabase menggunakan RLS. Setiap user hanya bisa akses:
- `users`: row miliknya sendiri
- `user_progress`, `user_mastery`, `user_answers`: row miliknya
- `levels`, `materials`, `exercises`: read-only untuk semua user login

### 4.3 Retention Policy

| Tabel | Retensi |
|-------|---------|
| `user_answers` | 7 hari, lalu hapus (privasi) |
| `ai_hints` | 30 hari (cache) |
| `user_progress`, `user_mastery` | Selamanya |
| `user_badges` | Selamanya |

---

## 5. API Design

### 5.1 Endpoint Utama

#### 5.1.1 Konvensi Umum

- Base path mengikuti `API_BASE_URL` pada konfigurasi environment; seluruh path
  di bawah relatif terhadap base tersebut.
- Backend API ini adalah kontrak acuan Phase 5. Pada Phase 4 aplikasi mobile
  mengakses Supabase langsung, sehingga bentuk respons mengikuti tabel di
  §4 (Data Model).
- Semua payload memakai JSON dengan penamaan `snake_case`, waktu ISO-8601 UTC
  (`2026-10-22T08:00:00Z`), dan id berupa string bila bertipe UUID.
- Endpoint yang butuh login wajib menyertakan `Authorization: Bearer <access_token>`.
- Respons sukses dan error mengikuti envelope pada §5.2.
- Status error yang tidak relevan untuk sebuah endpoint tidak dicantumkan.
  Kode error yang dipakai: `VALIDATION_ERROR`, `UNAUTHORIZED`, `FORBIDDEN`,
  `NOT_FOUND`, `CONFLICT`, `RATE_LIMITED`, `INTERNAL_ERROR`.
- Endpoint `GET` tidak memiliki request body; parameter dikirim lewat query
  string.

| Status | Arti               | Kapan muncul                                        |
| ------ | ------------------ | --------------------------------------------------- |
| 400    | Bad Request        | Field wajib hilang, tipe salah, atau di luar aturan |
| 401    | Unauthorized       | Token tidak ada, tidak valid, atau kedaluwarsa      |
| 403    | Forbidden          | Token valid tapi tidak berhak atas resource         |
| 404    | Not Found          | Resource yang diminta tidak ada                     |
| 409    | Conflict           | Data sudah ada atau bentrok aturan bisnis           |
| 429    | Too Many Requests  | Melewati batas pada §5.3                            |
| 500    | Internal Error     | Kegagalan tak terduga di server                     |

#### 5.1.2 Auth

##### POST /auth/login

Autentikasi mahasiswa memakai NIM dan password. NIM dipetakan ke email
internal `nim_<nim>@kodira.local` pada implementasi Supabase saat ini.

**Headers**

| Header         | Wajib | Nilai              |
| -------------- | ----- | ------------------ |
| `Content-Type` | ya    | `application/json` |
| `Accept`       | tidak | `application/json` |
| `Authorization`| tidak | — (belum punya token) |

**Request body**

| Field      | Tipe   | Constraint              |
| ---------- | ------ | ----------------------- |
| `nim`      | string | 13 digit angka, unik    |
| `password` | string | minimal 6 karakter      |

```json
{
  "nim": "2402095010141",
  "password": "<password>"
}
```

**Response 200**

| Field                | Tipe   | Keterangan                              |
| -------------------- | ------ | --------------------------------------- |
| `data.access_token`  | string | JWT untuk header Authorization          |
| `data.refresh_token` | string | Token untuk memperbarui access token    |
| `data.expires_in`    | int    | Masa berlaku access token (detik)       |
| `data.user.id`       | string | UUID user                               |
| `data.user.nim`      | string | NIM 13 digit                            |
| `data.user.name`     | string | Nama lengkap                            |
| `data.user.email`    | string | Email, boleh null                       |
| `data.user.avatar_url` | string | URL avatar, boleh null                |
| `data.user.created_at` | string | Waktu pembuatan akun                  |
| `data.user.last_login` | string | Waktu login terakhir, boleh null      |

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "v1.Mr3...",
    "expires_in": 3600,
    "user": {
      "id": "aa54f7ee-81e6-4025-8515-07c23933c769",
      "nim": "2402095010141",
      "name": "Raihan",
      "email": "nim_2402095010141@kodira.local",
      "avatar_url": null,
      "created_at": "2026-10-16T02:00:00Z",
      "last_login": "2026-10-22T07:30:00Z"
    }
  },
  "meta": { "timestamp": "2026-10-22T08:00:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"NIM harus 13 digit","details":{"field":"nim"}}}
401 {"success":false,"error":{"code":"INVALID_CREDENTIALS","message":"NIM atau password salah","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Akun belum aktif","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Akun tidak ditemukan","details":{}}}
429 {"success":false,"error":{"code":"RATE_LIMITED","message":"Terlalu banyak percobaan login","details":{"retry_after_seconds":300}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Terjadi kesalahan pada server","details":{}}}
```

##### POST /auth/logout

Mengakhiri session user yang sedang login.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | tidak | `application/json` |

**Request body:** tidak ada.

**Response 200**

| Field             | Tipe | Keterangan                  |
| ----------------- | ---- | --------------------------- |
| `data.logged_out` | bool | Selalu `true` bila berhasil |

```json
{
  "success": true,
  "data": { "logged_out": true },
  "meta": { "timestamp": "2026-10-22T08:05:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"Permintaan tidak valid","details":{}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Token bukan milik user aktif","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Session tidak ditemukan","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal mengakhiri session","details":{}}}
```

##### POST /auth/refresh

Menukar refresh token dengan access token baru.

**Headers**

| Header         | Wajib | Nilai              |
| -------------- | ----- | ------------------ |
| `Content-Type` | ya    | `application/json` |
| `Authorization`| tidak | — (memakai refresh token) |

**Request body**

| Field           | Tipe   | Constraint              |
| --------------- | ------ | ----------------------- |
| `refresh_token` | string | token refresh yang valid |

```json
{
  "refresh_token": "v1.Mr3..."
}
```

**Response 200**

| Field                | Tipe   | Keterangan                        |
| -------------------- | ------ | --------------------------------- |
| `data.access_token`  | string | Access token baru                 |
| `data.refresh_token` | string | Refresh token (boleh dirotasi)    |
| `data.expires_in`    | int    | Masa berlaku access token (detik) |

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOi...",
    "refresh_token": "v1.Nx8...",
    "expires_in": 3600
  },
  "meta": { "timestamp": "2026-10-22T08:30:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"refresh_token wajib diisi","details":{"field":"refresh_token"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Refresh token tidak valid","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Refresh token sudah dicabut","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Session tidak ditemukan","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memperbarui token","details":{}}}
```

##### GET /auth/me

Data user yang sedang login.

**Headers**

| Header          | Wajib | Nilai            |
| --------------- | ----- | ---------------- |
| `Authorization` | ya    | `Bearer <token>` |
| `Accept`        | tidak | `application/json` |

**Request body:** tidak ada.

**Response 200**

| Field                | Tipe   | Keterangan                |
| -------------------- | ------ | ------------------------- |
| `data.id`            | string | UUID user                 |
| `data.nim`           | string | NIM 13 digit              |
| `data.name`          | string | Nama lengkap              |
| `data.email`         | string | Email, boleh null         |
| `data.avatar_url`    | string | URL avatar, boleh null    |
| `data.created_at`    | string | Waktu pembuatan akun      |
| `data.last_login`    | string | Waktu login terakhir      |

```json
{
  "success": true,
  "data": {
    "id": "aa54f7ee-81e6-4025-8515-07c23933c769",
    "nim": "2402095010141",
    "name": "Raihan",
    "email": "nim_2402095010141@kodira.local",
    "avatar_url": null,
    "created_at": "2026-10-16T02:00:00Z",
    "last_login": "2026-10-22T07:30:00Z"
  },
  "meta": { "timestamp": "2026-10-22T08:31:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"Permintaan tidak valid","details":{}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Akun tidak aktif","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Profil user tidak ditemukan","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat profil","details":{}}}
```

#### 5.1.3 Level & Materi

##### GET /levels

Daftar level beserta progress user yang sedang login.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Request body:** tidak ada. Filter dikirim lewat query string.

| Query     | Tipe   | Constraint                       |
| --------- | ------ | -------------------------------- |
| `language`| string | `cpp` atau `java` (opsional)     |
| `topic`   | string | nama topik (opsional)            |
| `page`    | int    | ≥ 1, default 1                   |
| `limit`   | int    | 1–100, default 50                |

**Response 200**

| Field                        | Tipe   | Keterangan                                   |
| ---------------------------- | ------ | -------------------------------------------- |
| `data[].id`                  | int    | Id level (sama dengan `level_number`)        |
| `data[].level_number`        | int    | Nomor level 1–50                             |
| `data[].title`               | string | Judul level                                  |
| `data[].description`         | string | Deskripsi, boleh null                        |
| `data[].topic`               | string | Topik, boleh null                            |
| `data[].language`            | string | `cpp` atau `java`                            |
| `data[].difficulty`          | int    | 1–3, boleh null                              |
| `data[].progress`            | object | Null bila user belum memulai level           |
| `data[].progress.status`     | string | `locked`, `active`, `completed`, `remedial`  |
| `data[].progress.mastery_score` | float | 0.0–1.0                                   |
| `data[].progress.xp_earned`  | int    | XP terbaik yang pernah diraih                |
| `data[].progress.attempts`   | int    | Jumlah percobaan                             |
| `meta.pagination.page`       | int    | Halaman saat ini                             |
| `meta.pagination.limit`      | int    | Jumlah per halaman                           |
| `meta.pagination.total`      | int    | Total level yang cocok filter                |

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "level_number": 1,
      "title": "Hello World",
      "description": "Level pertama",
      "topic": "Pengenalan",
      "language": "cpp",
      "difficulty": 1,
      "progress": {
        "status": "completed",
        "mastery_score": 0.95,
        "xp_earned": 100,
        "attempts": 1
      }
    }
  ],
  "meta": {
    "timestamp": "2026-10-22T08:40:00Z",
    "pagination": { "page": 1, "limit": 50, "total": 50 }
  }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"limit maksimal 100","details":{"field":"limit"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Akun tidak berhak mengakses katalog","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Tidak dipakai pada endpoint koleksi; hasil kosong mengembalikan data: []","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat daftar level","details":{}}}
```

##### GET /levels/:id

Detail satu level.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Path parameter**

| Field | Tipe | Constraint          |
| ----- | ---- | ------------------- |
| `id`  | int  | id level yang ada   |

**Request body:** tidak ada.

**Response 200**

| Field                     | Tipe   | Keterangan                        |
| ------------------------- | ------ | --------------------------------- |
| `data.id`                 | int    | Id level                          |
| `data.level_number`       | int    | Nomor level                       |
| `data.title`              | string | Judul level                       |
| `data.description`        | string | Deskripsi, boleh null             |
| `data.topic`              | string | Topik, boleh null                 |
| `data.language`           | string | `cpp` atau `java`                 |
| `data.difficulty`         | int    | 1–3, boleh null                   |
| `data.total_materials`    | int    | Jumlah materi (turunan)           |
| `data.total_exercises`    | int    | Jumlah latihan + kuis (turunan)   |
| `data.progress`           | object | Null bila belum dimulai           |

```json
{
  "success": true,
  "data": {
    "id": 1,
    "level_number": 1,
    "title": "Hello World",
    "description": "Level pertama",
    "topic": "Pengenalan",
    "language": "cpp",
    "difficulty": 1,
    "total_materials": 5,
    "total_exercises": 8,
    "progress": {
      "status": "completed",
      "mastery_score": 0.95,
      "xp_earned": 100,
      "attempts": 1
    }
  },
  "meta": { "timestamp": "2026-10-22T08:41:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"id harus bilangan bulat","details":{"field":"id"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Level belum terbuka untuk user ini","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Level tidak ditemukan","details":{"id":999}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat level","details":{}}}
```

##### GET /levels/:id/materials

Materi milik satu level, diurutkan berdasarkan `slide_order`.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Path parameter**

| Field | Tipe | Constraint |
| ----- | ---- | ---------- |
| `id`  | int  | id level   |

**Request body:** tidak ada.

**Response 200**

| Field                  | Tipe   | Keterangan                    |
| ---------------------- | ------ | ----------------------------- |
| `data[].id`            | int    | Id materi                     |
| `data[].level_id`      | int    | Id level pemilik              |
| `data[].slide_order`   | int    | Urutan slide mulai 1          |
| `data[].title`         | string | Judul slide, boleh null       |
| `data[].content`       | string | Isi materi (markdown/teks)    |
| `data[].code_snippet`  | string | Contoh kode, boleh null       |
| `data[].created_at`    | string | Waktu pembuatan               |

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "level_id": 1,
      "slide_order": 1,
      "title": "Pengenalan C++",
      "content": "C++ adalah bahasa ...",
      "code_snippet": "#include <iostream>\nint main() { return 0; }",
      "created_at": "2026-10-16T02:00:00Z"
    }
  ],
  "meta": { "timestamp": "2026-10-22T08:42:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"id harus bilangan bulat","details":{"field":"id"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Materi level ini belum terbuka","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Level tidak ditemukan","details":{"id":999}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat materi","details":{}}}
```

##### GET /levels/:id/exercises

Latihan dan kuis milik satu level.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Path parameter**

| Field | Tipe | Constraint |
| ----- | ---- | ---------- |
| `id`  | int  | id level   |

**Query**

| Query  | Tipe   | Constraint                                  |
| ------ | ------ | ------------------------------------------- |
| `type` | string | `drag_drop` atau `quiz` (opsional)          |
| `limit`| int    | 1–100, default 50                           |

**Request body:** tidak ada.

**Response 200**

| Field               | Tipe   | Keterangan                              |
| ------------------- | ------ | --------------------------------------- |
| `data[].id`         | int    | Id latihan                              |
| `data[].level_id`   | int    | Id level pemilik                        |
| `data[].type`       | string | `drag_drop` atau `quiz`                 |
| `data[].prompt`     | string | Pertanyaan                              |
| `data[].payload`    | object | Struktur berbeda per tipe (lihat bawah) |
| `data[].difficulty` | int    | 1–3, boleh null                         |
| `data[].created_at` | string | Waktu pembuatan                         |

Payload `drag_drop`:

| Field              | Tipe   | Keterangan                          |
| ------------------ | ------ | ----------------------------------- |
| `payload.language` | string | `cpp` atau `java`                   |
| `payload.tokens[]` | array  | `{ "id": "t1", "text": "..." }`     |
| `payload.answer`   | array  | Urutan `id` token yang benar        |

Payload `quiz`:

| Field               | Tipe   | Keterangan                          |
| ------------------- | ------ | ----------------------------------- |
| `payload.language`  | string | `cpp` atau `java`                   |
| `payload.options[]` | array  | `{ "id": "a", "text": "..." }`      |
| `payload.answer`    | string | `id` opsi yang benar                |
| `payload.explanation` | string | Penjelasan jawaban               |

```json
{
  "success": true,
  "data": [
    {
      "id": 12,
      "level_id": 1,
      "type": "quiz",
      "prompt": "Manakah metode Queue yang mengambil elemen depan lalu menghapusnya?",
      "payload": {
        "language": "java",
        "options": [
          { "id": "a", "text": "peek" },
          { "id": "b", "text": "take" },
          { "id": "c", "text": "poll" },
          { "id": "d", "text": "pop" }
        ],
        "answer": "c",
        "explanation": "poll mengambil elemen depan lalu menghapusnya."
      },
      "difficulty": 2,
      "created_at": "2026-10-16T02:00:00Z"
    }
  ],
  "meta": { "timestamp": "2026-10-22T08:43:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"type harus drag_drop atau quiz","details":{"field":"type"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Latihan level ini belum terbuka","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Level tidak ditemukan","details":{"id":999}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat latihan","details":{}}}
```

##### GET /progress

Semua progress milik user yang sedang login.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Query**

| Query      | Tipe   | Constraint                                  |
| ---------- | ------ | ------------------------------------------- |
| `level_id` | int    | Filter satu level (opsional)                |
| `status`   | string | `locked`, `active`, `completed`, `remedial` |

**Request body:** tidak ada.

**Response 200**

| Field                     | Tipe   | Keterangan                        |
| ------------------------- | ------ | --------------------------------- |
| `data[].id`               | string | UUID baris progress               |
| `data[].user_id`          | string | UUID pemilik                      |
| `data[].level_id`         | int    | Id level                          |
| `data[].status`           | string | Status level                      |
| `data[].mastery_score`    | float  | 0.0–1.0                           |
| `data[].xp_earned`        | int    | XP terbaik                        |
| `data[].attempts`         | int    | Jumlah percobaan                  |
| `data[].remedial_level_id`| int    | Level remedial, boleh null        |
| `data[].last_attempt_at`  | string | Waktu percobaan terakhir, null-able |
| `data[].completed_at`     | string | Waktu selesai, null-able          |

```json
{
  "success": true,
  "data": [
    {
      "id": "0d7f1f3e-6a0b-4c2f-9d43-1f5a2b7c8d90",
      "user_id": "aa54f7ee-81e6-4025-8515-07c23933c769",
      "level_id": 1,
      "status": "completed",
      "mastery_score": 0.95,
      "xp_earned": 100,
      "attempts": 1,
      "remedial_level_id": null,
      "last_attempt_at": "2026-10-22T07:45:00Z",
      "completed_at": "2026-10-22T07:45:00Z"
    }
  ],
  "meta": { "timestamp": "2026-10-22T08:45:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"status tidak dikenal","details":{"field":"status"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Tidak berhak membaca progress user lain","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Tidak dipakai pada endpoint koleksi; user tanpa progress mengembalikan data: []","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat progress","details":{}}}
```

##### POST /progress/start-level

Membuka level untuk dikerjakan. Idempotent: bila baris progress sudah ada,
baris yang sama dipakai dan `attempt_token` baru diterbitkan.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | ya    | `application/json` |

**Request body**

| Field      | Tipe | Constraint                          |
| ---------- | ---- | ----------------------------------- |
| `level_id` | int  | id level yang ada dan sudah terbuka |

```json
{
  "level_id": 3
}
```

**Response 200**

| Field                    | Tipe   | Keterangan                            |
| ------------------------ | ------ | ------------------------------------- |
| `data.progress.id`       | string | UUID baris progress                   |
| `data.progress.level_id` | int    | Id level                              |
| `data.progress.status`   | string | `active` atau status sebelumnya       |
| `data.progress.mastery_score` | float | 0.0–1.0                          |
| `data.progress.xp_earned`| int    | XP terbaik                            |
| `data.progress.attempts` | int    | Jumlah percobaan                      |
| `data.attempt_token`     | string | Token untuk rangkaian jawaban level ini|

```json
{
  "success": true,
  "data": {
    "progress": {
      "id": "a1b2c3d4-0000-4111-8222-333344445555",
      "level_id": 3,
      "status": "active",
      "mastery_score": 0.6,
      "xp_earned": 50,
      "attempts": 1
    },
    "attempt_token": "att_9f2c..."
  },
  "meta": { "timestamp": "2026-10-22T08:46:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"level_id wajib diisi","details":{"field":"level_id"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Level masih terkunci","details":{"level_id":9}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Level tidak ditemukan","details":{"level_id":999}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal membuka level","details":{}}}
```

##### POST /progress/submit-answer

Mengirim satu jawaban. Server menilai jawaban dan memutakhirkan mastery serta
XP level setelah seluruh soal pada `attempt_token` yang sama selesai.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | ya    | `application/json` |

**Request body**

| Field            | Tipe           | Constraint                                  |
| ---------------- | -------------- | ------------------------------------------- |
| `level_id`       | int            | id level                                    |
| `exercise_id`    | int            | id latihan milik level tersebut             |
| `answer`         | string\|array  | `drag_drop`: array id token; `quiz`: id opsi|
| `attempt_token`  | string         | token dari `start-level`                    |
| `time_spent_ms`  | int            | ≥ 0, opsional                               |
| `hint_level`     | int            | 0–3, default 0 (tanpa hint)                 |

```json
{
  "level_id": 3,
  "exercise_id": 12,
  "answer": "c",
  "attempt_token": "att_9f2c...",
  "time_spent_ms": 12000,
  "hint_level": 0
}
```

**Response 200**

| Field                        | Tipe   | Keterangan                                       |
| ---------------------------- | ------ | ------------------------------------------------ |
| `data.correct`               | bool   | Jawaban benar                                    |
| `data.explanation`           | string | Penjelasan jawaban                               |
| `data.attempt_completed`     | bool   | True bila seluruh soal level sudah dijawab       |
| `data.progress.status`       | string | Status level setelah penilaian                   |
| `data.progress.mastery_score`| float  | 0.0–1.0                                          |
| `data.progress.xp_earned`    | int    | XP terbaik; 100 jika ≥0.7, 50 jika ≥0.4, 0 bila kurang |
| `data.progress.attempts`     | int    | Jumlah percobaan setelah penilaian               |
| `data.next_level_unlocked`   | bool   | True bila level berikutnya terbuka               |

```json
{
  "success": true,
  "data": {
    "correct": true,
    "explanation": "poll mengambil elemen depan lalu menghapusnya.",
    "attempt_completed": true,
    "progress": {
      "status": "completed",
      "mastery_score": 0.8,
      "xp_earned": 100,
      "attempts": 2
    },
    "next_level_unlocked": true
  },
  "meta": { "timestamp": "2026-10-22T08:47:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"exercise_id bukan milik level ini","details":{"exercise_id":12,"level_id":3}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"attempt_token bukan milik user ini","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Latihan tidak ditemukan","details":{"exercise_id":999}}}
409 {"success":false,"error":{"code":"CONFLICT","message":"Jawaban untuk soal ini sudah dikirim","details":{"exercise_id":12}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal menyimpan jawaban","details":{}}}
```

##### GET /progress/mastery

Rata-rata mastery per topik untuk layar Profil.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Request body:** tidak ada.

**Response 200**

| Field                          | Tipe   | Keterangan                        |
| ------------------------------ | ------ | --------------------------------- |
| `data.overall`                 | float  | Rata-rata seluruh level, 0.0–1.0  |
| `data.topics[].topic`          | string | Nama topik (`Umum` bila kosong)   |
| `data.topics[].mastery`        | float  | Rata-rata mastery topik           |
| `data.topics[].levels_total`   | int    | Jumlah level pada topik           |
| `data.topics[].levels_completed` | int  | Jumlah level selesai pada topik   |

```json
{
  "success": true,
  "data": {
    "overall": 0.8,
    "topics": [
      { "topic": "Array", "mastery": 0.9, "levels_total": 3, "levels_completed": 2 },
      { "topic": "Operator", "mastery": 0.7, "levels_total": 2, "levels_completed": 1 }
    ]
  },
  "meta": { "timestamp": "2026-10-22T08:48:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"Permintaan tidak valid","details":{}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Tidak berhak membaca mastery user lain","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Tidak dipakai; user tanpa mastery mengembalikan overall 0.0 dan topics: []","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal menghitung mastery","details":{}}}
```

#### 5.1.5 AI

##### POST /ai/hint

Meminta hint bertahap untuk satu latihan. Hint selalu satu arah dan tidak
pernah berisi jawaban akhir (lihat §6.2).

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | ya    | `application/json` |

**Request body**

| Field         | Tipe   | Constraint                               |
| ------------- | ------ | ---------------------------------------- |
| `level_id`    | int    | id level                                 |
| `exercise_id` | int    | id latihan milik level                   |
| `hint_level`  | int    | 1, 2, atau 3 (makin besar makin spesifik)|
| `code`        | string | Kode user saat ini, opsional, ≤ 4000 char|
| `attempt_no`  | int    | ≥ 1, default 1                           |

```json
{
  "level_id": 3,
  "exercise_id": 12,
  "hint_level": 2,
  "code": "int main() { }",
  "attempt_no": 1
}
```

**Response 200**

| Field                  | Tipe   | Keterangan                          |
| ---------------------- | ------ | ----------------------------------- |
| `data.hint`            | string | Teks hint (tanpa jawaban akhir)     |
| `data.hint_level`      | int    | Level hint yang diberikan           |
| `data.remaining_today` | int    | Sisa kuota hint hari ini            |
| `data.fallback_used`   | bool   | True bila memakai hint template     |

```json
{
  "success": true,
  "data": {
    "hint": "Perhatikan urutan deklarasi sebelum fungsi main.",
    "hint_level": 2,
    "remaining_today": 19,
    "fallback_used": false
  },
  "meta": { "timestamp": "2026-10-22T08:50:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"hint_level harus 1, 2, atau 3","details":{"field":"hint_level"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Latihan bukan milik level yang terbuka","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Latihan tidak ditemukan","details":{"exercise_id":999}}}
429 {"success":false,"error":{"code":"RATE_LIMITED","message":"Batas hint harian tercapai","details":{"limit":20,"window":"1d"}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal membuat hint","details":{}}}
```

##### POST /ai/feedback

Meminta umpan balik setelah user menjawab.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | ya    | `application/json` |

**Request body**

| Field           | Tipe   | Constraint                          |
| --------------- | ------ | ----------------------------------- |
| `level_id`      | int    | id level                            |
| `exercise_id`   | int    | id latihan                         |
| `answer`        | string\|array | Jawaban user                 |
| `is_correct`    | bool   | Hasil penilaian jawaban             |
| `mastery_score` | float  | 0.0–1.0, opsional                   |

```json
{
  "level_id": 3,
  "exercise_id": 12,
  "answer": "c",
  "is_correct": true,
  "mastery_score": 0.8
}
```

**Response 200**

| Field              | Tipe   | Keterangan                          |
| ------------------ | ------ | ----------------------------------- |
| `data.feedback`    | string | Umpan balik singkat                 |
| `data.focus_topic` | string | Topik yang perlu diulang            |
| `data.next_step`   | string | Saran langkah berikutnya            |

```json
{
  "success": true,
  "data": {
    "feedback": "Tepat. Pahami juga perbedaan peek dan poll.",
    "focus_topic": "Struktur Data",
    "next_step": "Lanjut ke latihan berikutnya atau ulangi materi."
  },
  "meta": { "timestamp": "2026-10-22T08:51:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"is_correct wajib boolean","details":{"field":"is_correct"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Latihan bukan milik user ini","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Latihan tidak ditemukan","details":{"exercise_id":999}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal membuat feedback","details":{}}}
```

##### POST /ai/generate-question

Membuat soal variasi untuk remedial.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | ya    | `application/json` |

**Request body**

| Field                  | Tipe   | Constraint                        |
| ---------------------- | ------ | --------------------------------- |
| `level_id`             | int    | id level                          |
| `topic`                | string | topik soal                        |
| `language`             | string | `cpp` atau `java`                 |
| `difficulty`           | int    | 1–3                               |
| `exclude_exercise_ids` | array  | id latihan yang tidak boleh dipakai, opsional |

```json
{
  "level_id": 3,
  "topic": "Struktur Data",
  "language": "java",
  "difficulty": 2,
  "exclude_exercise_ids": [12, 13]
}
```

**Response 200**

| Field                    | Tipe   | Keterangan                       |
| ------------------------ | ------ | -------------------------------- |
| `data.question.type`     | string | `quiz`                           |
| `data.question.prompt`   | string | Pertanyaan                       |
| `data.question.payload`  | object | `options[]`, `answer`, `explanation` |
| `data.remaining_today`   | int    | Sisa kuota generate hari ini     |

```json
{
  "success": true,
  "data": {
    "question": {
      "type": "quiz",
      "prompt": "Manakah struktur data FIFO?",
      "payload": {
        "language": "java",
        "options": [
          { "id": "a", "text": "Stack" },
          { "id": "b", "text": "Queue" },
          { "id": "c", "text": "Tree" },
          { "id": "d", "text": "Graph" }
        ],
        "answer": "b",
        "explanation": "Queue memakai urutan first in first out."
      }
    },
    "remaining_today": 9
  },
  "meta": { "timestamp": "2026-10-22T08:52:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"difficulty harus 1-3","details":{"field":"difficulty"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Topik bukan bagian level ini","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Level tidak ditemukan","details":{"level_id":999}}}
429 {"success":false,"error":{"code":"RATE_LIMITED","message":"Batas generate soal harian tercapai","details":{"limit":10,"window":"1d"}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal membuat soal","details":{}}}
```

#### 5.1.6 Code Runner

##### POST /code/run

Menjalankan kode user tanpa menyimpan hasilnya.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | ya    | `application/json` |

**Request body**

| Field      | Tipe   | Constraint                     |
| ---------- | ------ | ------------------------------ |
| `language` | string | `cpp` atau `java`              |
| `code`     | string | 1–10000 karakter               |
| `stdin`    | string | Input program, opsional, ≤ 2000 char |

```json
{
  "language": "cpp",
  "code": "#include <iostream>\nint main() { std::cout << \"Hi\"; }",
  "stdin": ""
}
```

**Response 200**

| Field              | Tipe   | Keterangan                        |
| ------------------ | ------ | --------------------------------- |
| `data.stdout`      | string | Keluaran standar                  |
| `data.stderr`      | string | Keluaran error                    |
| `data.exit_code`   | int    | Kode keluar proses                |
| `data.duration_ms` | int    | Waktu eksekusi                    |
| `data.timed_out`   | bool   | True bila melewati batas waktu    |

```json
{
  "success": true,
  "data": {
    "stdout": "Hi",
    "stderr": "",
    "exit_code": 0,
    "duration_ms": 84,
    "timed_out": false
  },
  "meta": { "timestamp": "2026-10-22T08:53:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"code melebihi 10000 karakter","details":{"field":"code"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Eksekusi kode tidak diizinkan untuk akun ini","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Runtime bahasa tidak tersedia","details":{"language":"python"}}}
429 {"success":false,"error":{"code":"RATE_LIMITED","message":"Batas eksekusi harian tercapai","details":{"limit":50,"window":"1d"}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Sandbox gagal menjalankan kode","details":{}}}
```

##### POST /code/submit

Mengirim kode untuk diuji dengan test case level.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Content-Type`  | ya    | `application/json` |

**Request body**

| Field         | Tipe   | Constraint          |
| ------------- | ------ | ------------------- |
| `level_id`    | int    | id level            |
| `exercise_id` | int    | id latihan kode     |
| `language`    | string | `cpp` atau `java`   |
| `code`        | string | 1–10000 karakter    |

```json
{
  "level_id": 3,
  "exercise_id": 12,
  "language": "java",
  "code": "public class Main { public static void main(String[] a) {} }"
}
```

**Response 200**

| Field                       | Tipe   | Keterangan                       |
| --------------------------- | ------ | -------------------------------- |
| `data.passed`               | bool   | Semua test case lulus            |
| `data.passed_tests`         | int    | Jumlah test lulus                |
| `data.total_tests`          | int    | Jumlah test                      |
| `data.test_results[].name`  | string | Nama test                        |
| `data.test_results[].passed`| bool   | Hasil test                       |
| `data.test_results[].expected` | string | Output yang diharapkan        |
| `data.test_results[].actual`   | string | Output aktual                |
| `data.xp_earned`            | int    | XP yang diperoleh                |
| `data.status`               | string | Status level setelah submit      |

```json
{
  "success": true,
  "data": {
    "passed": false,
    "passed_tests": 1,
    "total_tests": 2,
    "test_results": [
      { "name": "test_1", "passed": true, "expected": "Hi", "actual": "Hi" },
      { "name": "test_2", "passed": false, "expected": "Hello", "actual": "Hi" }
    ],
    "xp_earned": 0,
    "status": "active"
  },
  "meta": { "timestamp": "2026-10-22T08:54:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"language harus cpp atau java","details":{"field":"language"}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Latihan kode belum terbuka","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Latihan tidak ditemukan","details":{"exercise_id":999}}}
429 {"success":false,"error":{"code":"RATE_LIMITED","message":"Batas submit harian tercapai","details":{"limit":50,"window":"1d"}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal menilai kode","details":{}}}
```

#### 5.1.7 Gamifikasi

##### GET /badges

Daftar badge yang sudah diraih user beserta tanggalnya.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Request body:** tidak ada.

**Response 200**

| Field               | Tipe   | Keterangan                                     |
| ------------------- | ------ | ---------------------------------------------- |
| `data[].badge_code` | string | `streak_3`, `streak_7`, `streak_30`, `level_5`, `level_10`, `level_25`, `xp_100`, `xp_500`, `xp_1000` |
| `data[].earned_at`  | string | Waktu badge diraih                             |
| `meta.total`        | int    | Jumlah badge yang dimiliki                     |

```json
{
  "success": true,
  "data": [
    { "badge_code": "streak_3", "earned_at": "2026-10-22T07:30:00Z" },
    { "badge_code": "xp_100", "earned_at": "2026-10-22T07:45:00Z" }
  ],
  "meta": { "timestamp": "2026-10-22T08:55:00Z", "total": 2 }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"Permintaan tidak valid","details":{}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Tidak berhak membaca badge user lain","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Tidak dipakai; user tanpa badge mengembalikan data: []","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat badge","details":{}}}
```

##### GET /achievements

Daftar achievement yang sudah diraih user beserta tanggalnya.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Request body:** tidak ada.

**Response 200**

| Field                     | Tipe   | Keterangan                                        |
| ------------------------- | ------ | ------------------------------------------------- |
| `data[].achievement_code` | string | `first_login`, `first_quiz_pass`, `complete_chapter_1` |
| `data[].earned_at`        | string | Waktu achievement diraih                          |
| `meta.total`              | int    | Jumlah achievement yang dimiliki                  |

```json
{
  "success": true,
  "data": [
    { "achievement_code": "first_login", "earned_at": "2026-10-22T07:30:00Z" },
    { "achievement_code": "first_quiz_pass", "earned_at": "2026-10-22T07:45:00Z" }
  ],
  "meta": { "timestamp": "2026-10-22T08:56:00Z", "total": 2 }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"Permintaan tidak valid","details":{}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Tidak berhak membaca achievement user lain","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"Tidak dipakai; user tanpa achievement mengembalikan data: []","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat achievement","details":{}}}
```

##### GET /streak

Info streak harian user.

**Headers**

| Header          | Wajib | Nilai              |
| --------------- | ----- | ------------------ |
| `Authorization` | ya    | `Bearer <token>`   |
| `Accept`        | tidak | `application/json` |

**Request body:** tidak ada.

**Response 200**

| Field                    | Tipe   | Keterangan                              |
| ------------------------ | ------ | --------------------------------------- |
| `data.current_streak`    | int    | Streak berjalan (hari)                  |
| `data.longest_streak`    | int    | Streak terpanjang (hari)                |
| `data.last_active_date`  | string | Tanggal aktif terakhir (`YYYY-MM-DD`)   |
| `data.is_active_today`   | bool   | True bila user sudah aktif hari ini     |

```json
{
  "success": true,
  "data": {
    "current_streak": 3,
    "longest_streak": 7,
    "last_active_date": "2026-10-22",
    "is_active_today": true
  },
  "meta": { "timestamp": "2026-10-22T08:57:00Z" }
}
```

**Error**

```text
400 {"success":false,"error":{"code":"VALIDATION_ERROR","message":"Permintaan tidak valid","details":{}}}
401 {"success":false,"error":{"code":"UNAUTHORIZED","message":"Token tidak valid atau kedaluwarsa","details":{}}}
403 {"success":false,"error":{"code":"FORBIDDEN","message":"Tidak berhak membaca streak user lain","details":{}}}
404 {"success":false,"error":{"code":"NOT_FOUND","message":"User belum punya baris streak; dianggap current_streak 0","details":{}}}
500 {"success":false,"error":{"code":"INTERNAL_ERROR","message":"Gagal memuat streak","details":{}}}
```

### 5.2 Format Response

**Success:**
```json
{
  "success": true,
  "data": { ... },
  "meta": { "timestamp": "..." }
}
```

**Error:**
```json
{
  "success": false,
  "error": {
    "code": "AI_HINT_LIMIT",
    "message": "Batas hint harian tercapai",
    "details": { ... }
  }
}
```

### 5.3 Rate Limiting

| Endpoint | Limit |
|----------|-------|
| `/ai/hint` | 20 per hari per user |
| `/ai/generate-question` | 10 per hari per user |
| `/code/run` | 50 per hari per user |
| `/auth/login` | 5 percobaan per 15 menit |

---

## 6. AI Strategy

### 6.1 Prinsip

1. **AI bukan decision maker.** Keputusan pedagogis ada di **rule-based engine**.
2. **AI hanya menghasilkan** hint, feedback, dan soal variasi.
3. **Semua output AI lewat guardrail** sebelum sampai ke user.
4. **AI tidak bisa dichat** oleh user. Satu arah.
5. **API key disimpan di server**, tidak pernah di mobile app.

### 6.2 Alur AI Hint

```
User minta hint
    ↓
Mobile kirim ke backend:
    - level_id
    - exercise_id
    - hint_level (1, 2, atau 3)
    - konteks (materi, kode user)
    ↓
Backend cek rate limit
    ↓
Backend panggil AI API
    ↓
AI generate hint
    ↓
Backend validasi (guardrail):
    - Apakah hint membocorkan jawaban?
    - Apakah sesuai topik level?
    - Apakah panjangnya wajar?
    ↓
Jika lolos → kirim ke mobile
Jika gagal → fallback ke hint template
    ↓
Mobile tampilkan
```

### 6.3 Alur Generate Soal Variasi (Remedial)

```
User gagal remedial, perlu soal baru
    ↓
Backend ambil konteks:
    - Topik level asal
    - Mastery user di topik itu
    - Error pattern user
    ↓
Backend panggil AI API
    ↓
AI generate soal + kunci jawaban
    ↓
Backend validasi (guardrail):
    - Test case (jika coding)
    - Batasan materi
    - Tidak duplikat soal existing
    ↓
Jika lolos → simpan + kirim ke mobile
Jika gagal → regenerate atau fallback template
```

### 6.4 Guardrail

| Aspek | Validasi |
|-------|----------|
| Sintaks | Kode valid? |
| Test case | Output benar? |
| Rubrik | Sesuai konsep level? |
| Batasan materi | Tidak bahas topik di luar level? |
| Kebocoran jawaban | Tidak langsung kasih solusi? |
| Panjang | Tidak terlalu panjang (>500 kata)? |
| Bahasa | Indonesia, tidak kasar |

### 6.5 AI Provider

**Keputusan awal:** API berbayar (sudah ada free tier untuk testing).

**Model kandidat:**
- OpenAI GPT-4o-mini
- Google Gemini Flash
- Anthropic Claude Haiku

**Kriteria pemilihan:**
- Biaya per 1M token
- Kecepatan respons
- Kualitas output untuk coding
- Ketersediaan di Indonesia

**Fallback:** Jika API down → rule-based hint template.

---

## 7. Adaptive Engine

### 7.1 Formula Mastery

```
M_topic = 0.45A + 0.25C + 0.20(1−E) + 0.10(1−Tn)
```

- **A** = akurasi jawaban user di topik
- **C** = rasio challenge selesai
- **E** = error berulang (dinormalisasi)
- **Tn** = waktu pengerjaan (dinormalisasi)

### 7.2 Aturan Adaptasi

| Kondisi | Respons |
|---------|---------|
| M < 0.40 | Remedial micro-lesson + Parsons problem |
| 0.40 ≤ M < 0.70 | Challenge dasar |
| M ≥ 0.70 | Challenge gabungan / lanjut level |
| Wrong answer ≥ 3 | Hint bertingkat, tanpa solusi |
| Stuck > 120 detik | Contoh kecil atau pertanyaan diagnostik |
| 2 challenge cepat & benar | Naikkan kompleksitas |
| Fatal error pada topik lama | Lock level saat ini, remedial topik lama |

### 7.3 Level Locking

- **Level ≤ 10:** tidak ada lock. Remedial topik saja.
- **Level > 10:** lock jika M < 0.40 pada topik lama.
- XP ditahan selama remedial.
- Remedial tidak memberi XP.

### 7.4 Kapan Adaptive Engine Jalan

- **Setelah submit kuis** → hitung mastery
- **Setelah submit latihan** → update mastery
- **Saat user buka level** → cek status
- **Setelah remedial** → cek threshold unlock

**Implementasi:** Rule-based engine di backend (Edge Function atau 
stored procedure PostgreSQL). Bukan AI.

---

## 8. Security

### 8.1 Data Protection

- **Transport:** HTTPS wajib
- **Storage:** password di-hash (Supabase Auth)
- **API key AI:** hanya di server, tidak di mobile
- **Jawaban user:** dihapus setelah 7 hari
- **Mastery:** anonim setelah agregasi

### 8.2 Auth Flow

```
1. User input NIM + password
2. Mobile kirim ke Supabase Auth (custom flow)
3. Backend verifikasi NIM ke kampus (jika ada API)
4. Jika valid → return JWT
5. Mobile simpan JWT dengan secure storage
6. Setiap request → JWT di header
```

### 8.3 RLS (Row Level Security)

Semua tabel user-scoped menggunakan RLS Supabase:
- User hanya bisa akses data miliknya sendiri
- Admin (jika ada nanti) bisa akses agregat

### 8.4 Rate Limiting

- Per user per endpoint
- Per IP untuk endpoint public
- Anti-abuse untuk AI & code runner

### 8.5 Code Runner Security

- Sandbox wajib (Judge0 sudah sandbox)
- Timeout eksekusi: 5 detik
- Memory limit: 256 MB
- Tidak boleh akses jaringan
- Tidak boleh akses file system

---

## 9. Deployment & Environment

### 9.1 Environment

| Env | Penggunaan |
|-----|------------|
| `local` | Development di laptop |
| `staging` | Testing sebelum release |
| `production` | Release ke user |

### 9.2 Deployment Mobile

- Build APK via `flutter build apk`
- Untuk testing: distribute via **Firebase App Distribution** atau 
  **Google Play Internal Testing**
- Release: Google Play Store (nanti)

### 9.3 Deployment Backend

- Supabase hosted (default)
- Edge Functions di-deploy via Supabase CLI
- Migrasi database via SQL migrations

### 9.4 Environment Variables

**Mobile (`.env` lokal, `.env.example` di git):**
```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
```

**Backend (Supabase secrets):**
```env
AI_API_KEY=
AI_API_URL=
AI_MODEL=
CODE_RUNNER_API_KEY=
KAMPUS_API_URL=
```

---

## 10. Performance

### 10.1 Target

| Metrik | Target |
|--------|--------|
| Waktu buka app | < 2 detik |
| Waktu load level | < 1 detik |
| Waktu respons AI | < 3 detik |
| Waktu eksekusi kode | < 5 detik |
| Ukuran APK | < 50 MB |

### 10.2 Strategi

- **Local caching:** materi, level, progress
- **Lazy loading:** gambar, animasi
- **Image optimization:** WebP, ukuran wajar
- **Code splitting:** tidak perlu di mobile
- **Debounce:** input yang sering berubah

---

## 11. Testing Strategy

### 11.1 Level Test

| Level | Tools | Target |
|-------|-------|--------|
| Unit test | `flutter_test` | Business logic, utils |
| Widget test | `flutter_test` | Komponen UI |
| Integration test | `integration_test` | Alur end-to-end |
| Manual test | Manual | UX, edge case |

### 11.2 Coverage Target

- Business logic: **minimal 70%** [TBD]
- Widget: **minimal 50%** [TBD]
- Integration: **happy path + 3 edge case** per fitur

### 11.3 Test Environment

- Local: `flutter test`
- CI: GitHub Actions (nanti)

---

## 12. Observability

### 12.1 Logging

- **Mobile:** `logger` package, level: debug, info, warn, error
- **Backend:** Supabase logs + custom logging di Edge Functions
- **Format:** JSON untuk parsing

### 12.2 Monitoring

- **Crash reporting:** Sentry (nanti)
- **Analytics:** Supabase Analytics (nanti)
- **Performance:** Flutter DevTools (development)

### 12.3 Metrics yang Dipantau

- Crash rate
- AI response time
- Code runner success rate
- Level completion rate
- Retention (DAU/MAU)

---

## 13. Risiko Teknis

| Risiko | Probabilitas | Dampak | Mitigasi |
|--------|--------------|--------|----------|
| AI API biaya membengkak | Sedang | Tinggi | Rate limit, cache, model ringan |
| AI jawaban tidak akurat | Sedang | Tinggi | Guardrail ketat, fallback rule-based |
| Code runner abuse | Rendah | Tinggi | Rate limit, sandbox, timeout |
| Supabase lock-in | Rendah | Sedang | Bisa self-host, PostgreSQL standar |
| HP mid-range lambat | Sedang | Sedang | Optimasi, lazy load, cache |
| Koneksi tidak stabil | Tinggi | Sedang | Local-first, offline fallback |
| Verifikasi NIM gagal | Sedang | Sedang | Fallback manual admin |

---

## 14. Keputusan yang Masih Diperlukan

- [x] Model AI final: OpenAI GPT-4o-mini (ADR-019)
- [x] Budget AI per bulan: ~$14/bulan (ADR-023)
- [x] Judge0: hosted API (ADR-021)
- [x] State management: Riverpod (ADR-010)
- [x] Local DB: Drift (ADR-020)
- [ ] Verifikasi NIM: API kampus atau manual? → TBD
- [ ] Crash reporting: Sentry dari awal atau nanti? → TBD
- [ ] CI/CD untuk deploy backend: TBD

---

## 15. Referensi

- `docs/00-phases.md` — roadmap fase
- `docs/01-prd.md` — product requirement
- `docs/02-design-system.md` — design system
- `reference/awesome-design-md/` — referensi design
- `reference/web-interface-guidelines/` — guideline UI

**External:**
- Flutter docs: https://docs.flutter.dev
- Supabase docs: https://supabase.com/docs
- Judge0: https://judge0.com
- Riverpod: https://riverpod.dev

---

## 16. Update Log

| Tanggal | Perubahan |
|---------|-----------|
| 2026-10-16 | Draft awal dibuat |