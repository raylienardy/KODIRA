# Architecture Decision Record — KODIRA

Log keputusan teknis dan produk penting untuk proyek KODIRA.

| Field   | Nilai                              |
| ------- | ---------------------------------- |
| Versi   | 1.0                                |
| Tanggal | 2026-10-16                         |
| Status  | Aktif                              |
| Format  | ADR (Architecture Decision Record) |

---

## Tentang Dokumen Ini

Setiap keputusan penting dicatat di sini dengan format ADR. Tujuannya:

- **Melacak "kenapa"** — bukan hanya "apa"
- **Menghindari debat ulang** di masa depan
- **Onboarding developer baru** lebih cepat
- **Referensi** saat ada pertanyaan "kenapa dulu kita pilih ini?"

**Status ADR:**

- `Proposed` — diusulkan, belum final
- `Accepted` — disetujui, sedang dipakai
- `Superseded` — digantikan ADR lain
- `Deprecated` — tidak dipakai lagi

---

## Daftar ADR

| #   | Judul                                        | Status   |
| --- | -------------------------------------------- | -------- |
| 001 | Target pengguna: mahasiswa JTIK semester 1   | Accepted |
| 002 | Bahasa pemrograman: C++ dan Java (terpisah)  | Accepted |
| 003 | Struktur 50 level linier                     | Accepted |
| 004 | Mastery 3 tingkat: 70% dan 40%               | Accepted |
| 005 | Level locking hanya untuk level > 10         | Accepted |
| 006 | AI sebagai pendukung, bukan decision maker   | Accepted |
| 007 | AI satu arah, bukan chatbot                  | Accepted |
| 008 | Flutter untuk mobile                         | Accepted |
| 009 | Supabase untuk backend                       | Accepted |
| 010 | Riverpod untuk state management              | Accepted |
| 011 | Judge0 untuk code runner                     | Accepted |
| 012 | Inter untuk font                             | Accepted |
| 013 | Lucide untuk ikon                            | Accepted |
| 014 | Light mode dulu, dark mode future work       | Accepted |
| 015 | Coverage target 70%                          | Accepted |
| 016 | Branch strategy: langsung `main` + PR review | Accepted |
| 017 | CI sejak Phase 0, CD nanti                   | Accepted |
| 018 | Pre-commit hook di Phase 1                   | Accepted |
| 019 | AI Provider — Multi-Provider Fallback      | Accepted |
| 020 | Local DB — Drift                             | Accepted |
| 021 | Code Runner — Judge0 Hosted API              | Accepted |
| 022 | Supabase — Hosted dulu                       | Accepted |
| 023 | Budget AI — ~$14/bulan                       | Accepted |
| 024 | Secrets never bundled in APK                 | Accepted |

---

## ADR-001: Target Pengguna

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Awalnya KODIRA dirancang untuk siswa SMP (lihat draft awal). Perlu diputuskan target final.

### Keputusan

Target: **mahasiswa JTIK semester 1, mata kuliah Pemrograman Dasar.**

### Alasan

- Mahasiswa JTIK punya masalah nyata: fondasi coding lemah
- Ketergantungan AI lebih tinggi di mahasiswa
- Konteks JTIK lebih spesifik dari SMP
- Bisa diintegrasikan dengan kurikulum kampus

### Konsekuensi

- Materi disesuaikan dengan silabus Pemrograman Dasar
- Bahasa C++ dan Java (bukan block-based seperti untuk SMP)
- Persona target lebih matang (17–19 tahun)
- Verifikasi NIM perlu (untuk memastikan mahasiswa JTIK)

---

## ADR-002: Bahasa Pemrograman

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Bahasa apa yang akan diajarkan di KODIRA?

### Opsi

1. Python saja
2. C++ saja
3. Java saja
4. C++ untuk dasar, Java untuk OOP

### Keputusan

**C++ untuk dasar (level 1–35), Java untuk OOP & struktur data (level 36–50).**

### Alasan

- C++ diajarkan di semester awal JTIK untuk dasar pemrograman
- Java dipakai untuk OOP di semester lanjut
- Terpisah = tidak membingungkan pemula
- Sesuai kurikulum JTIK

### Konsekuensi

- Dua code editor (C++ dan Java)
- Code runner harus support dua bahasa
- Materi dibagi dua fase

---

## ADR-003: Struktur 50 Level Linier

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Berapa jumlah level dan bagaimana strukturnya?

### Opsi

1. 10 level, linier
2. 50 level, linier
3. 100 level, bercabang

### Keputusan

**50 level, linier, satu level satu topik mikro.**

### Alasan

- 10 terlalu sedikit untuk cakupan materi
- 100 terlalu banyak untuk pemula
- 50 pas untuk semester 1
- Linier = tidak overwhelming, mahasiswa tidak takut melihat cabang banyak
- Satu topik per level = jelas, fokus

### Konsekuensi

- Materi harus dibagi jadi 50 topik mikro
- Setiap level punya CP (Capaian Pembelajaran) sendiri
- Level locking bisa diterapkan selektif

---

## ADR-004: Mastery 3 Tingkat

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Bagaimana menentukan kelulusan level?

### Opsi

1. Biner: lulus / tidak lulus
2. Berdasarkan persentase sederhana
3. Mastery 3 tingkat

### Keputusan

**Mastery 3 tingkat:**

- M ≥ 70% → lulus
- 40% ≤ M < 70% → remedial topik, tanpa lock
- M < 40% → lock (level > 10)

### Alasan

- Biner terlalu kaku (1 salah = remedial)
- Mastery berbasis formula: `0.45A + 0.25C + 0.20(1-E) + 0.10(1-Tn)`
- 3 tingkat membedakan kesalahan kecil vs fatal
- Lebih adil untuk mahasiswa

### Konsekuensi

- Perlu formula mastery (sudah ada di `03-architecture.md`)
- Perlu tracking per topik, bukan per level
- Perlu 3 jalur berbeda setelah kuis

---

## ADR-005: Level Locking > 10

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Apakah semua level bisa di-lock, atau hanya level tertentu?

### Keputusan

**Lock hanya berlaku untuk level > 10.** Level 1–10 tidak ada lock.

### Alasan

- Level awal = mahasiswa baru, masih adaptasi
- Lock di level awal bikin frustrasi
- Level > 10 = sudah cukup bekal, lock wajar
- "Namanya juga pemula" — sesuai diskusi tim

### Konsekuensi

- Adaptive engine harus cek level sebelum lock
- Pesan error berbeda untuk level awal vs level atas
- Level 1–10 hanya remedial topik, bukan lock

---

## ADR-006: AI sebagai Pendukung

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Seberapa besar peran AI dalam keputusan pembelajaran?

### Opsi

1. AI sebagai decision maker (menentukan semua)
2. AI sebagai pendukung (rule-based yang putuskan)

### Keputusan

**AI sebagai pendukung.** Keputusan pedagogis di **rule-based engine**.

### Alasan

- AI bisa salah, tidak konsisten
- Rule-based lebih transparan, bisa diuji
- Sesuai novelty: AI bukan fokus utama
- Guardrail lebih mudah diterapkan

### Konsekuensi

- Adaptive engine = rule-based (bukan AI)
- AI hanya: generate soal, generate hint, generate feedback
- Output AI harus lewat validator

---

## ADR-007: AI Satu Arah

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Apakah user bisa chat dengan AI, atau AI hanya merespons terbatas?

### Keputusan

**AI satu arah.** User tidak bisa chat bebas. AI hanya memberi:

- Hint bertahap (level 1–3)
- Feedback setelah submit
- Soal variasi (remedial)

### Alasan

- Risiko ketergantungan (Groothuijsen et al., 2024)
- Chat bebas = AI bisa kasih jawaban langsung
- Membatasi = memaksa user berpikir
- Sesuai filosofi: "AI membuat kamu berpikir, bukan berpikir untukmu"

### Konsekuensi

- Tidak ada chat interface
- Hint dipicu oleh: user minta, stuck > 120s, salah ≥ 3x
- Semua output AI lewat guardrail

---

## ADR-008: Flutter untuk Mobile

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Framework mobile apa yang dipakai?

### Opsi

1. Flutter (Dart)
2. React Native (JavaScript)
3. Kotlin native

### Keputusan

**Flutter.**

### Alasan

- UI konsisten antar device
- Performa baik untuk animasi (penting untuk gamifikasi)
- Tooling matang
- Komunitas besar
- Hot reload cepat

### Konsekuensi

- Tim harus belajar Dart
- Build size sedikit lebih besar
- Tidak bisa pakai library JS

---

## ADR-009: Supabase untuk Backend

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Platform backend apa yang dipakai?

### Opsi

1. Firebase
2. Supabase
3. Backend sendiri (Node.js/Laravel)

### Keputusan

**Supabase.**

### Alasan

- Open source, bisa self-host nanti
- PostgreSQL (relasional, cocok untuk mastery tracking)
- Vendor lock-in rendah
- Auth, database, storage, edge functions dalam satu paket
- Query lebih fleksibel dari Firebase

### Konsekuensi

- Pakai PostgreSQL, bukan NoSQL
- Perlu belajar SQL + RLS
- Bisa self-host kalau perlu

---

## ADR-010: Riverpod untuk State Management

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

State management apa untuk Flutter?

### Opsi

1. Provider
2. Riverpod
3. Bloc
4. GetX

### Keputusan

**Riverpod.**

### Alasan

- Modern, type-safe
- Mudah di-test
- Compile-time safety
- Tidak butuh BuildContext
- Komunitas aktif

### Konsekuensi

- Perlu belajar konsep provider
- Boilerplate sedikit lebih banyak dari GetX
- Lebih maintainable jangka panjang

---

## ADR-011: Judge0 untuk Code Runner

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Bagaimana menjalankan kode C++/Java yang di-submit user?

### Opsi

1. Judge0 API
2. Piston self-host
3. Buat sendiri

### Keputusan

**Judge0 API** untuk awal. Self-host Piston kalau volume naik.

### Alasan

- Judge0 sudah sandbox
- Support C++ dan Java
- Ada free tier untuk testing
- Tidak perlu maintain server sendiri di awal

### Konsekuensi

- Bergantung pada layanan eksternal
- Perlu rate limit untuk cegah abuse
- Migrasi ke Piston nanti jika perlu

---

## ADR-012: Inter untuk Font

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Font utama untuk UI?

### Opsi

1. Inter
2. Poppins
3. Roboto

### Keputusan

**Inter.**

### Alasan

- Netral, mudah dibaca
- Gratis, open source
- Dipakai banyak produk modern (Linear, Vercel)
- Bagus untuk UI teknis
- Poppins terlalu bulat untuk konteks coding

### Konsekuensi

- Font Inter harus di-bundle di app
- Code block tetap pakai JetBrains Mono

---

## ADR-013: Lucide untuk Ikon

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Library ikon apa yang dipakai?

### Opsi

1. Heroicons
2. Lucide
3. Material Icons

### Keputusan

**Lucide.**

### Alasan

- Modern, konsisten
- Gratis, open source
- Komunitas aktif
- Lebih fleksibel dari Heroicons
- Tersedia untuk Flutter

### Konsekuensi

- Perlu tambah package `lucide_icons` di pubspec
- Emoji tetap dipakai untuk visual anchor (bukan ikon UI)

---

## ADR-014: Light Mode Dulu

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Apakah dark mode masuk MVP?

### Keputusan

**Light mode dulu. Dark mode future work.**

### Alasan

- Fokus MVP dulu
- Dark mode = tambahan kompleksitas (2x design token)
- Belum tentu dipakai user
- Bisa ditambah setelah aplikasi stabil

### Konsekuensi

- Design system hanya untuk light mode
- Warna dark mode disiapkan nanti
- User tidak bisa switch mode di MVP

---

## ADR-015: Coverage Target 70%

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Berapa target code coverage untuk test?

### Keputusan

**70% untuk business logic. 90%+ untuk critical logic (formula mastery, adaptive engine).**

### Alasan

- 70% seimbang antara kualitas dan waktu
- 60% terlalu longgar
- 80%+ terlalu ketat untuk tim 2 orang
- Critical logic tetap harus 90%+ karena menentukan behavior

### Konsekuensi

- Perlu setup coverage report
- Critical logic didahulukan
- UI coverage tidak wajib

---

## ADR-016: Branch Strategy

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Bagaimana strategi branch Git?

### Opsi

1. Langsung `main` + PR review
2. Pakai `develop` branch + PR review
3. GitFlow lengkap

### Keputusan

**Langsung `main` + PR review.** Tidak pakai `develop`.

### Alasan

- Tim cuma 2 orang
- `develop` berguna untuk tim 5+ dengan banyak fitur paralel
- Untuk tim kecil, tambah kompleksitas
- Selama selalu PR + review, `main` tetap aman

### Konsekuensi

- ❌ Jangan push langsung ke `main`
- ✅ Selalu bikin branch fitur → PR → review → merge
- ✅ Setelah merge, hapus branch
- ✅ Rebase dari `main` sebelum merge

---

## ADR-017: CI Sejak Phase 0

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Kapan mulai pakai CI/CD?

### Keputusan

**CI sejak Phase 0. CD nanti (Phase 6+).**

### Alasan

- CI murah, gratis di GitHub Actions untuk public repo
- Setup sekali, jalan selamanya
- Bug ketangkap lebih cepat = hemat waktu
- CD belum perlu karena belum ada user

### Konsekuensi

- Perlu setup `.github/workflows/ci.yml` di Phase 0
- CI minimal: `flutter analyze` + `flutter test`
- CD ditunda sampai Phase 6

---

## ADR-018: Pre-commit Hook

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks

Apakah pakai pre-commit hook?

### Keputusan

**Pakai, dipasang di Phase 1.**

### Alasan

- Cegah commit kode yang belum diformat
- Cegah commit file sensitif (`.env`)
- Otomatis, tidak perlu ingat
- Setup sekali, hemat waktu

### Konsekuensi

- Setup hook manual atau pakai lefthook
- Hook minimal: cek file sensitif, `dart format`, `flutter analyze`
- Dipasang setelah project Flutter di-setup (Phase 1)

---

## ADR-019: AI Provider — Multi-Provider Fallback

**Tanggal:** 2026-10-16  
**Status:** Accepted  
**Revisi:** 2026-10-16 (dari single-provider ke multi-provider)

### Konteks
KODIRA butuh AI untuk hint bertahap, generate soal variasi, dan feedback. 
User ingin bisa switch provider sesuai kebutuhan (testing vs production) 
ta tanpa ubah kode.

### Opsi
1. Single provider (OpenAI saja)
2. Multi-provider dengan fallback chain

### Keputusan
Multi-provider dengan urutan prioritas:
1. **Groq** (Llama 3.3 70B) — untuk testing & development, gratis
2. **OpenAI GPT-4o-mini** — untuk production, ~$14/bulan
3. **Gemini Flash** — emergency fallback

Provider dipilih via env variable `AI_PROVIDER`. 

### Alasan
- Groq gratis, sangat cepat (LPU), kualitas Llama 3.3 70B cukup untuk testing tanpa menguras token berbayar
- Production tetap pakai OpenAI karena kualitas coding lebih tinggi
- Gemini sebagai fallback terakhir bila OpenAI down atau budget habis
- Abstraksi di Edge Function — ganti provider tanpa ubah mobile app

### Konsekuensi
- Perlu abstraksi provider di Supabase Edge Function
- 3 API key berbeda disimpan di Supabase secrets
- Format request/response dinormalisasi di Edge Function
- Testing development gratis (Groq)
- Production biaya ~$14/bulan (OpenAI)

---

## ADR-020: Local DB — Drift

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks
KODIRA butuh local database untuk cache materi, progress, dan mastery 
user agar aplikasi tetap responsif dan bisa offline-first.

### Opsi
1. Isar
2. Drift

### Keputusan
Drift.

### Alasan
- Migrasi skema otomatis (penting untuk iterasi cepat)
- Komunitas besar, dokumentasi lengkap
- Integrasi Riverpod matang
- Learning curve lebih rendah untuk tim 2 orang

### Konsekuensi
- Performa sedikit di bawah Isar untuk query besar
- Perlu optimasi indeks untuk query yang kompleks
- Menggunakan SQLite di bawahnya

---

## ADR-021: Code Runner — Judge0 Hosted API

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks
KODIRA butuh eksekusi kode C++ dan Java yang disubmit user untuk 
validasi jawaban. Butuh sandbox aman dan tidak membebani HP user.

### Opsi
1. Judge0 hosted API
2. Piston self-host
3. Judge0 self-host

### Keputusan
Judge0 hosted API.

### Alasan
- Tanpa server, hemat waktu tim kecil
- Gratis untuk volume awal (~18k request/bulan)
- Sudah sandbox, aman
- Support C++ dan Java

### Konsekuensi
- Bergantung pada layanan eksternal.
- Jika rate limit tercapai, migrasi ke self‑host Piston (~$7/bulan VPS)

---

## ADR-022: Supabase — Hosted Dulu

**Tanggal:** 2026-10-15  
**Status:** Accepted

### Konteks
Pilih hosted atau self‑host Supabase untuk backend KODIRA?

### Keputusan
Hosted dulu untuk development & MVP.

### Alasan
- Tim 2 orang, tidak perlu urus server
- Free tier cukup (500MB storage, 100k request/hari)
- Skalabilitas otomatis
- Hemat waktu setup

### Konsekuensi
- Perlu backup rutin mingguan via pg_dump
- Trigger self‑host: storage >10GB atau request >100k/hari, atau 
  ada kebijakan data on‑premise dari kampus
- Rencana migrasi ke self‑host disiapkan jika trigger tercapai

---

## ADR-023: Budget AI — ~$14/bulan

**Tanggal:** 2026-10-16  
**Status:** Accepted

### Konteks
KODIRA akan pakai OpenAI GPT-4o-mini untuk AI. Butuh estimasi budget 
per bulan untuk 1 kelas (30 mahasiswa).

### Perhitungan
- 30 user × 20 request/hari × 30 hari = 18,000 request/bulan
- Token per request: input ~800, output ~300 → total ~1,100 token
- Total ~19.8M token/bulan
- Input: 19.8M × $0.15 = $2.97
- Output: 19.8M × $0.60 = $11.88
- Total: ~$14/bulan

### Keputusan
Budget normal ~$14/bulan. Range: $0 (minimum) hingga $28 (2x normal).

### Alasan
- Masuk akal untuk project akademik
- Bisa dikontrol dengan rate limit
- Fallback ke Gemini Flash jika >2x budget

### Konsekuensi
- Perlu monitor penggunaan harian
- Set rate limit 20 hint/hari per user
- Cache respons AI yang sama
- Fallback otomatis ke Gemini Flash jika >2x budget

---

## ADR-024: Secrets never bundled in APK

**Tanggal:** 2026-10-19  
**Status:** Accepted

### Konteks

Audit keamanan menemukan `.env` di-bundle sebagai asset APK
(`pubspec.yaml` → `flutter.assets`). Siapa pun pemegang APK bisa
mengekstraknya dalam hitungan detik (`apktool`, `unzip` + `strings`) dan
membaca seluruh isinya — termasuk key AI.

### Keputusan

1. Client **hanya** berisi Supabase URL + anon key. Keduanya *public by
   design*; data dilindungi lewat RLS, bukan lewat kerahasiaan key.
2. Key AI (Groq/OpenAI/Gemini) dan Code Runner **dilarang** masuk client —
   baik lewat `.env` maupun `--dart-define`. Wajib lewat Supabase Edge
   Function / backend proxy.
3. Dev lokal: `flutter run --dart-define-from-file=.env`.
4. Release/CI: nilai di-inject via `--dart-define` dari CI secrets.

### Alasan

- Asset APK adalah file teks di dalam zip — tidak ada perlindungan sama
  sekali; audit membuktikannya.
- Supabase anon key memang didesain untuk dipublikasikan (proteksi via RLS).
- `--dart-define` adalah mekanisme resmi Flutter untuk konfigurasi
  build-time tanpa membundel file rahasia ke package.

### Konsekuensi

- `flutter run` polos akan error `SUPABASE_URL not configured` — pakai
  `--dart-define-from-file=.env`.
- Nilai `--dart-define` masih bisa diekstrak dari `libapp.so` (constant
  pool). Untuk key sensitif, satu-satunya jalur aman adalah Edge Function /
  backend proxy.
- `.env.example` tetap dipakai sebagai template pengisian `.env` lokal.
- Implementasi: `app/lib/core/network/supabase_client.dart` (urutan:
  `String.fromEnvironment` → fallback dotenv) + `pubspec.yaml` tanpa asset
  `.env`.

---

## Template ADR Baru

Saat ada keputusan baru, tambahkan dengan format berikut:

```markdown
## ADR-XXX: Judul Keputusan

**Tanggal:** YYYY-MM-DD  
**Status:** Proposed / Accepted / Superseded / Deprecated

### Konteks

Apa situasi yang memicu keputusan ini?

### Opsi

1. Opsi A
2. Opsi B
3. Opsi C

### Keputusan

Opsi apa yang dipilih?

### Alasan

Kenapa opsi ini? Trade-off-nya apa?

### Konsekuensi

Apa dampak positif dan negatif dari keputusan ini?
```

---

## Update Log

| Tanggal    | Perubahan                |
| ---------- | ------------------------ |
| 2026-10-16 | ADR-019 direvisi: dari single-provider ke multi-provider |
