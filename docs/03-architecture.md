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
| Local DB | **Isar** atau **Drift** | Cepat, ringan, offline-first |
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
| Provider | **API berbayar** (OpenAI, Gemini, Claude, atau lainnya) | Kualitas lebih baik, tidak bebani HP |
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
| Platform | **Judge0** (self-host atau API) | Populer, mendukung C++ & Java, aman |
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

**Auth**
```
POST   /auth/login             → login NIM + password
POST   /auth/logout
POST   /auth/refresh
GET    /auth/me                → data user
```

**Level & Materi**
```
GET    /levels                 → daftar level
GET    /levels/:id             → detail level
GET    /levels/:id/materials   → materi level
GET    /levels/:id/exercises   → latihan + kuis level
```

**Progress**
```
GET    /progress               → semua progres user
POST   /progress/start-level   → mulai level
POST   /progress/submit-answer → submit jawaban
GET    /progress/mastery       → mastery per topik
```

**AI**
```
POST   /ai/hint                → minta hint (level 1-3)
POST   /ai/feedback            → minta feedback setelah submit
POST   /ai/generate-question   → generate soal variasi (remedial)
```

**Code Runner**
```
POST   /code/run               → jalankan kode (C++/Java)
POST   /code/submit            → submit + test case
```

**Gamifikasi**
```
GET    /badges                 → daftar badge user
GET    /achievements           → daftar achievement
GET    /streak                 → info streak
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

- [ ] Model AI final (GPT-4o-mini, Gemini Flash, Claude Haiku, atau lainnya)
- [ ] Budget AI per bulan
- [ ] Judge0: API hosted atau self-host?
- [ ] Verifikasi NIM: API kampus atau manual?
- [ ] State management final: Riverpod, Bloc, atau Provider?
- [ ] Local DB: Isar atau Drift?
- [ ] Apakah pakai CI/CD sejak awal atau nanti?
- [ ] Crash reporting: Sentry dari awal atau nanti?

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