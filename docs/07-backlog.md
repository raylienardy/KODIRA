# Backlog — KODIRA

Daftar task proyek KODIRA. Setiap task punya ID, scope, DoD, dan status.
Gunakan bersama `docs/06-workflow.md` untuk kerja dengan opencode.

| Field   | Nilai                                      |
| ------- | ------------------------------------------ |
| Versi   | 1.0                                        |
| Tanggal | 2026-10-16                                 |
| Status  | Aktif                                      |
| Basis   | `docs/00-phases.md`, `docs/06-workflow.md` |

---

## 1. Cara Pakai

1. Buka file ini
2. Pilih task paling atas dengan status `Todo`
3. Cek dependency — pastikan sudah selesai
4. Buka `docs/06-workflow.md` → pilih template prompt sesuai tipe task
5. Isi placeholder, kirim ke opencode
6. Review hasil
7. Kalau oke → commit → update status task jadi `Done`
8. Lanjut task berikutnya

**Aturan:**

- Kerjakan berurutan, jangan lompat
- Satu task = satu commit (ideal)
- Kalau task gagal, kembali ke `Todo`, jangan paksa `Done`
- Update status setiap selesai

---

## 2. Legend

### Status

| Kode      | Arti                      |
| --------- | ------------------------- |
| `Todo`    | Belum dikerjakan          |
| `WIP`     | Sedang dikerjakan         |
| `Review`  | Selesai, menunggu review  |
| `Done`    | Selesai & sudah di-commit |
| `Blocked` | Terhalang task lain       |
| `Skip`    | Dilewati (dengan alasan)  |

### Priority

| Kode | Arti                  |
| ---- | --------------------- |
| `P0` | Kritis, blocker       |
| `P1` | Penting, harus segera |
| `P2` | Normal                |
| `P3` | Nice to have          |

### Token Estimate

| Kode | Arti        | Ukuran                   |
| ---- | ----------- | ------------------------ |
| `S`  | Small       | < 5k token               |
| `M`  | Medium      | 5–15k token              |
| `L`  | Large       | 15–30k token             |
| `XL` | Extra Large | > 30k token (pecah dulu) |

### Agent

| Kode    | Arti                        |
| ------- | --------------------------- |
| `plan`  | Diskusi/analisis (no write) |
| `build` | Eksekusi (write file)       |

---

## 3. Ringkasan Progress

| Phase                     | Total  | Done   | WIP   | Todo     |
| ------------------------- | ------ | ------ | ----- | -------- |
| Phase 0 — Foundation      | 10     | 10     | 0     | 0        |
| Phase 1 — Design System   | 8      | 8      | 0     | 0        |
| Phase 2 — UI Design       | 6      | 5      | 0     | 1        |
| Phase 3 — Architecture    | 7      | 6      | 0     | 1 (skip) |
| Phase 4 — MVP Development | 14     | 5      | 0     | 9        |
| Phase 5 — AI Integration  | 8      | 0      | 0     | 8        |
| Phase 6 — Testing         | 6      | 0      | 0     | 6        |
| Phase 7 — Documentation   | 6      | 0      | 0     | 6        |
| **Total**                 | **65** | **10** | **0** | **55**   |

---

## 4. Phase 0 — Foundation ✅

Semua task di phase ini **sudah selesai**.

| ID     | Task                            | Status  |
| ------ | ------------------------------- | ------- |
| P0-001 | Buat `.gitignore`               | ✅ Done |
| P0-002 | Buat `docs/00-phases.md`        | ✅ Done |
| P0-003 | Buat `AGENTS.md`                | ✅ Done |
| P0-004 | Buat `docs/01-prd.md`           | ✅ Done |
| P0-005 | Buat `docs/02-design-system.md` | ✅ Done |
| P0-006 | Buat `docs/03-architecture.md`  | ✅ Done |
| P0-007 | Buat `docs/04-guidelines.md`    | ✅ Done |
| P0-008 | Buat `docs/05-decisions.md`     | ✅ Done |
| P0-009 | Buat `DESIGN.md`                | ✅ Done |
| P0-010 | Buat `docs/06-workflow.md`      | ✅ Done |

---

## 5. Phase 1 — Design System

Setup project Flutter, theme, dan fondasi kode.

### P1-001: Setup Project Flutter

| Field      | Nilai   |
| ---------- | ------- |
| Status     | ✅ Done |
| Priority   | P0      |
| Token      | S       |
| Agent      | build   |
| Dependency | —       |

**Scope:**

- Buat project Flutter di `app/` (bukan root, biar docs terpisah)

**DoD:**

- [ ] `flutter create --org com.kodira app` berhasil
- [ ] `flutter run` bisa dijalankan
- [ ] `app/` terbuat dengan struktur standar

---

### P1-002: Setup Folder Structure

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | S      |
| Agent      | build  |
| Dependency | P1-001 |

**Scope:**

- Buat folder di `app/lib/` sesuai `docs/03-architecture.md`:
  `app/`, `core/`, `data/`, `domain/`, `features/`, `shared/`

**DoD:**

- [ ] Semua folder terbuat
- [ ] Ada file `.gitkeep` di folder kosong
- [ ] Struktur sesuai `docs/03-architecture.md`

---

### P1-003: Buat Theme.dart

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P1-002 |

**Scope:**

- File: `app/lib/app/theme.dart`
- Class: `KodiraColors`, `KodiraSpacing`, `KodiraRadius`, `KodiraTextStyles`
- Referensi: `docs/02-design-system.md`, `DESIGN.md` section 14

**DoD:**

- [ ] Semua token warna ada (primary, success, reward, alert, neutral)
- [ ] Semua spacing token (space-1 s/d space-16)
- [ ] Semua radius token
- [ ] Text styles (display, h1, h2, h3, body-lg, body, body-sm, caption, overline, code)
- [ ] Bisa di-import tanpa error

---

### P1-004: Setup Linter Rules

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | S      |
| Agent      | build  |
| Dependency | P1-001 |

**Scope:**

- File: `app/analysis_options.yaml`

**DoD:**

- [ ] Extend `flutter_lints`
- [ ] Tambah rules sesuai `docs/04-guidelines.md`
- [ ] `flutter analyze` lulus tanpa warning

---

### P1-005: Setup Font Assets

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | S      |
| Agent      | build  |
| Dependency | P1-003 |

**Scope:**

- Download Inter & JetBrains Mono
- Letakkan di `app/assets/fonts/`
- Update `app/pubspec.yaml`

**DoD:**

- [ ] Font terdaftar di `pubspec.yaml`
- [ ] Bisa dipakai di `theme.dart`
- [ ] Ukuran APK masih < 50 MB

---

### P1-006: Setup CI

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | M      |
| Agent      | build  |
| Dependency | P1-001 |

**Scope:**

- File: `.github/workflows/ci.yml`

**DoD:**

- [ ] Trigger: push + PR ke `main`
- [ ] Step: `flutter pub get` → `flutter analyze` → `flutter test`
- [ ] CI lulus di push pertama

---

### P1-007: Setup Pre-commit Hook

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P2     |
| Token      | S      |
| Agent      | build  |
| Dependency | P1-001 |

**Scope:**

- File: `scripts/pre-commit.sh` + setup di `.git/hooks/`

**DoD:**

- [ ] Cek file sensitif (`.env`, `.jks`)
- [ ] Jalankan `dart format`
- [ ] Jalankan `flutter analyze`
- [ ] Hook bisa di-install via `bash scripts/install-hooks.sh`

---

### P1-008: Dokumentasi Setup

| Field      | Nilai             |
| ---------- | ----------------- |
| Status     | Todo              |
| Priority   | P2                |
| Token      | S                 |
| Agent      | build             |
| Dependency | P1-001 s/d P1-007 |

**Scope:**

- File: `README.md` di root

**DoD:**

- [ ] Cara setup project (Flutter, dependencies, run)
- [ ] Cara kontribusi (branch, commit, PR)
- [ ] Link ke docs

---

## 6. Phase 2 — UI Design

Regenerate UI di Stitch dengan DESIGN.md, perbaiki interaksi.

### P2-001: Regenerate Stitch dengan DESIGN.md

| Field      | Nilai                |
| ---------- | -------------------- |
| Status     | Todo                 |
| Priority   | P0                   |
| Token      | M                    |
| Agent      | — (manual di Stitch) |
| Dependency | P0-009               |

**Scope:**

- Upload `DESIGN.md` ke Stitch
- Regenerate 8 layar

**DoD:**

- [ ] 8 layar ter-generate dengan warna konsisten
- [ ] Tipografi konsisten
- [ ] Tidak ada warna di luar palet

---

### P2-002: Export to Figma

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P1         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | P2-001     |

**Scope:**

- Export hasil Stitch ke Figma

**DoD:**

- [ ] 8 frame di Figma (390x844)
- [ ] Layer name rapi
- [ ] Warna & font sesuai

---

### P2-003: Build Interactive Prototype

| Field      | Nilai               |
| ---------- | ------------------- |
| Status     | Todo                |
| Priority   | P0                  |
| Token      | M                   |
| Agent      | — (manual di Figma) |
| Dependency | P2-002              |

**Scope:**

- Hubungkan 8 frame jadi prototype
- Transisi antar layar

**DoD:**

- [ ] Login → Home bisa diklik
- [ ] Home → Materi → Latihan → Kuis → Feedback bisa diklik
- [ ] Back button berfungsi
- [ ] Semua layar terhubung

---

### P2-004: User Flow Diagram

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | S      |
| Agent      | build  |
| Dependency | P2-003 |

**Scope:**

- File: `docs/diagrams/user-flow.md`

**DoD:**

- [ ] Diagram alur dari login sampai selesai level
- [ ] Ada alur remedial & locking
- [ ] Format Mermaid atau gambar

---

### P2-005: Wireframe Low-Fidelity (opsional)

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P3         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | P2-002     |

**Scope:**

- Kalau butuh wireframe hitam-putih untuk diskusi

**DoD:**

- [ ] Ada wireframe untuk 8 layar

---

### P2-006: Screenshot untuk Proposal

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P1         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | P2-003     |

**Scope:**

- Screenshot 8 layar untuk proposal

**DoD:**

- [ ] PNG 8 layar
- [ ] Resolusi cukup (2x)
- [ ] Konsisten

---

## 7. Phase 3 — Architecture

Finalisasi tech stack, database, API contract.

### P3-001: Finalisasi Tech Stack

| Field      | Nilai |
| ---------- | ----- |
| Status     | Todo  |
| Priority   | P0    |
| Token      | S     |
| Agent      | plan  |
| Dependency | —     |

**Scope:**

- Konfirmasi: Flutter, Supabase, Riverpod, Judge0

**DoD:**

- [ ] Update `docs/05-decisions.md` jika ada perubahan
- [ ] Tidak ada ADR berstatus `Proposed`

---

### P3-002: Database Schema Final

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | plan   |
| Dependency | P3-001 |

**Scope:**

- Review schema di `docs/03-architecture.md`
- Finalisasi tabel, kolom, tipe

**DoD:**

- [ ] Semua tabel terdefinisi
- [ ] RLS policy per tabel
- [ ] Retention policy jelas

---

### P3-003: API Contract Final

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | plan   |
| Dependency | P3-002 |

**Scope:**

- Finalisasi endpoint di `docs/03-architecture.md`

**DoD:**

- [ ] Semua endpoint terdokumentasi
- [ ] Request/response format jelas
- [ ] Rate limit per endpoint

---

### P3-004: Setup Supabase Project

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P0         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | P3-002     |

**Scope:**

- Buat project Supabase
- Setup env

**DoD:**

- [ ] Project Supabase dibuat
- [ ] `.env` lokal (tidak commit)
- [ ] `.env.example` di repo

---

### P3-005: Migrasi Database

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P3-004 |

**Scope:**

- File SQL migration di `app/supabase/migrations/`

**DoD:**

- [ ] Semua tabel terbuat
- [ ] RLS aktif
- [ ] Seed data untuk testing

---

### P3-006: Setup AI Provider

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P0         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | —          |

**Scope:**

- Daftar & dapat API key
- Simpan di Supabase secrets

**DoD:**

- [ ] API key aktif
- [ ] Test 1 request berhasil
- [ ] Key aman di server, bukan di mobile

---

### P3-007: Setup Judge0

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P1         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | —          |

**Scope:**

- Daftar Judge0 API / self-host

**DoD:**

- [ ] Bisa eksekusi C++ & Java
- [ ] Rate limit ditest

---

## 8. Phase 4 — MVP Development

Fitur inti tanpa AI dulu. Fondasi paling penting.

### P4-001: Auth — Login NIM

| Field      | Nilai          |
| ---------- | -------------- |
| Status     | Done           |
| Priority   | P0             |
| Token      | L              |
| Agent      | build          |
| Dependency | P1-003, P3-005 |

**Scope:**

- `app/lib/features/auth/`
- `app/lib/data/repositories/auth_repository.dart`

**DoD:**

- [ ] User bisa login dengan NIM + password
- [ ] Session tersimpan
- [ ] Error handling jelas
- [ ] Test unit untuk auth repository

---

### P4-002: Routing & Navigation

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Done   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-001 |

**Scope:**

- `app/lib/app/router.dart` (go_router)

**DoD:**

- [ ] Route untuk semua layar utama
- [ ] Auth guard
- [ ] Deep link (opsional)

---

### P4-003: Home / Level Map

| Field      | Nilai          |
| ---------- | -------------- |
| Status     | Done           |
| Priority   | P0             |
| Token      | L              |
| Agent      | build          |
| Dependency | P4-002, P1-003 |

**Scope:**

- `app/lib/features/home/`

**DoD:**

- [ ] Menampilkan 50 level (dari database)
- [ ] Status level: completed, active, locked
- [ ] XP bar, streak, badge
- [ ] Tap level → navigasi ke materi

---

### P4-004: Materi Screen

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-003 |

**Scope:**

- `app/lib/features/lesson/`

**DoD:**

- [ ] Menampilkan slide materi
- [ ] Code snippet dengan syntax highlighting
- [ ] Navigasi slide
- [ ] Tombol "Lanjut ke Latihan"

---

### P4-005: Latihan Drag & Drop

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | L      |
| Agent      | build  |
| Dependency | P4-004 |

**Scope:**

- `app/lib/features/exercise/drag_drop/`

**DoD:**

- [ ] Token bisa di-drag & drop
- [ ] Validasi jawaban
- [ ] Feedback visual (benar/salah)
- [ ] Tombol Reset & Periksa

---

### P4-006: Latihan Coding Manual

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | L      |
| Agent      | build  |
| Dependency | P4-004 |

**Scope:**

- `app/lib/features/exercise/code_editor/`

**DoD:**

- [ ] Editor sederhana dengan syntax highlight
- [ ] Submit → kirim ke backend
- [ ] Tampilkan hasil

---

### P4-007: Kuis Adaptif (UI)

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-004 |

**Scope:**

- `app/lib/features/quiz/`

**DoD:**

- [ ] Tampilan pilihan ganda
- [ ] Timer
- [ ] Progress bar
- [ ] Submit jawaban

---

### P4-008: Hasil & Feedback Screen

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-007 |

**Scope:**

- `app/lib/features/quiz/result_screen.dart`

**DoD:**

- [ ] Menampilkan XP, benar, mastery
- [ ] Tombol lanjut / remedial
- [ ] Animasi level up

---

### P4-009: XP & Level System

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-001 |

**Scope:**

- `app/lib/features/gamification/`

**DoD:**

- [ ] Hitung XP dari jawaban
- [ ] Naik level sesuai threshold
- [ ] Sync ke database

---

### P4-010: Badge & Achievement

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P2     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-009 |

**Scope:**

- `app/lib/features/gamification/badges/`

**DoD:**

- [ ] Badge dasar: streak, level, XP
- [ ] Achievement dasar
- [ ] Tampil di profil

---

### P4-011: Profil & Progress

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-009 |

**Scope:**

- `app/lib/features/profile/`

**DoD:**

- [ ] Info user
- [ ] Badge & achievement
- [ ] Mastery per topik
- [ ] Riwayat level

---

### P4-012: Local Storage

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P1-002 |

**Scope:**

- `app/lib/data/sources/local/`

**DoD:**

- [ ] Setup Isar / Drift
- [ ] Cache materi & progress
- [ ] Offline fallback

---

### P4-013: Repository Pattern

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-001 |

**Scope:**

- `app/lib/data/repositories/`

**DoD:**

- [ ] Repository untuk user, level, materi, quiz
- [ ] Interface bersih
- [ ] Bisa di-mock untuk test

---

### P4-014: Error Handling & Loading States

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-013 |

**Scope:**

- `app/lib/core/errors/`
- `app/lib/shared/widgets/loading.dart`, `error.dart`

**DoD:**

- [ ] Result type
- [ ] Loading indicator
- [ ] Error screen
- [ ] Retry mechanism

---

## 9. Phase 5 — AI Integration

Integrasi AI Mentor, adaptive quiz, guardrail.

### P5-001: AI Service Setup

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P3-006 |

**Scope:**

- Supabase Edge Function untuk proxy AI
- `app/lib/data/sources/remote/ai_source.dart`

**DoD:**

- [ ] AI API key aman di server
- [ ] Endpoint `/ai/hint`, `/ai/feedback`, `/ai/generate-question`
- [ ] Rate limit aktif

---

### P5-002: Hint Generator

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | L      |
| Agent      | build  |
| Dependency | P5-001 |

**Scope:**

- Supabase Edge Function `ai/hint`

**DoD:**

- [ ] Hint level 1, 2, 3
- [ ] Bukan jawaban langsung
- [ ] Guardrail validasi panjang & topik

---

### P5-003: Feedback Generator

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P5-001 |

**Scope:**

- Supabase Edge Function `ai/feedback`

**DoD:**

- [ ] Feedback terstruktur (apa salah, kenapa)
- [ ] Bahasa Indonesia
- [ ] Guardrail aktif

---

### P5-004: Adaptive Quiz Engine

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | XL     |
| Agent      | build  |
| Dependency | P5-002 |

**Scope:**

- `app/lib/features/adaptive/` (rule-based)
- Formula mastery

**DoD:**

- [ ] Hitung mastery dari event
- [ ] Threshold 0.40 & 0.70
- [ ] Level locking logic
- [ ] Test unit coverage 90%+

---

### P5-005: AI Question Generator

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | L      |
| Agent      | build  |
| Dependency | P5-001 |

**Scope:**

- Supabase Edge Function `ai/generate-question`

**DoD:**

- [ ] Generate soal variasi
- [ ] Validasi dengan test case
- [ ] Cache soal yang sudah lolos

---

### P5-006: Guardrail Validator

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P5-001 |

**Scope:**

- Validator output AI

**DoD:**

- [ ] Cek sintaks
- [ ] Cek panjang
- [ ] Cek topik
- [ ] Cek kebocoran jawaban

---

### P5-007: Code Runner Integration

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | M      |
| Agent      | build  |
| Dependency | P3-007 |

**Scope:**

- `app/lib/data/sources/remote/code_runner_source.dart`
- Endpoint `/code/run` & `/code/submit`

**DoD:**

- [ ] Eksekusi C++ berhasil
- [ ] Eksekusi Java berhasil
- [ ] Rate limit aktif
- [ ] Timeout 5 detik

---

### P5-008: End-to-End AI Flow

| Field      | Nilai             |
| ---------- | ----------------- |
| Status     | Todo              |
| Priority   | P1                |
| Token      | M                 |
| Agent      | build             |
| Dependency | P5-002 s/d P5-007 |

**Scope:**

- Integrasi semua AI ke fitur user

**DoD:**

- [ ] User bisa minta hint di materi/latihan/kuis
- [ ] Hint muncul < 3 detik
- [ ] Feedback setelah submit
- [ ] Soal variasi saat remedial

---

## 10. Phase 6 — Testing & Evaluation

Validasi kualitas & efektivitas.

### P6-001: Unit Test Coverage

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | L      |
| Agent      | build  |
| Dependency | P5-004 |

**Scope:**

- `app/test/`

**DoD:**

- [ ] Coverage business logic ≥ 70%
- [ ] Coverage adaptive engine ≥ 90%
- [ ] Semua test lulus

---

### P6-002: Widget Test

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | M      |
| Agent      | build  |
| Dependency | P4-014 |

**Scope:**

- Widget test untuk komponen utama

**DoD:**

- [ ] Coverage widget ≥ 50%
- [ ] Semua test lulus

---

### P6-003: Integration Test

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | M      |
| Agent      | build  |
| Dependency | P5-008 |

**Scope:**

- Alur end-to-end: login → level → kuis → feedback

**DoD:**

- [ ] 1 happy path + 3 edge case per fitur utama

---

### P6-004: Uji Coba Pengguna

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P0         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | P6-003     |

**Scope:**

- Uji coba ke 1 kelas mahasiswa JTIK

**DoD:**

- [ ] Minimal 20 responden
- [ ] Pre-test & post-test
- [ ] SUS questionnaire
- [ ] Data terkumpul

---

### P6-005: Analisis Hasil

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P6-004 |

**Scope:**

- File: `docs/09-evaluation.md`

**DoD:**

- [ ] Analisis N-gain
- [ ] Analisis SUS
- [ ] Insight per rumusan masalah

---

### P6-006: Perbaikan Berdasarkan Feedback

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | L      |
| Agent      | build  |
| Dependency | P6-005 |

**Scope:**

- Fix bug & improve UX dari feedback

**DoD:**

- [ ] Semua bug critical resolved
- [ ] Top 3 UX issues fixed

---

## 11. Phase 7 — Documentation & Presentation

Dokumen akhir & presentasi.

### P7-001: Update Artikel Final

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | L      |
| Agent      | build  |
| Dependency | P6-005 |

**Scope:**

- Update `artikel belum selesai uts.docx` → final

**DoD:**

- [ ] Semua BAB lengkap
- [ ] Hasil & pembahasan terisi
- [ ] Daftar pustaka 15+

---

### P7-002: Slide Presentasi Final

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P0     |
| Token      | M      |
| Agent      | build  |
| Dependency | P7-001 |

**Scope:**

- Update `KODIRA_Presentasi UTS 1.pptx` → final

**DoD:**

- [ ] Struktur Steve Jobs
- [ ] Pembuka & penutup siap
- [ ] 18 slide max

---

### P7-003: Demo Video

| Field      | Nilai      |
| ---------- | ---------- |
| Status     | Todo       |
| Priority   | P1         |
| Token      | S          |
| Agent      | — (manual) |
| Dependency | P6-006     |

**Scope:**

- Video walkthrough aplikasi

**DoD:**

- [ ] Durasi 3–5 menit
- [ ] Semua fitur utama terlihat
- [ ] Audio jelas

---

### P7-004: Source Code Cleanup

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | M      |
| Agent      | build  |
| Dependency | P6-006 |

**Scope:**

- Hapus kode mati, TODO, komentar debug

**DoD:**

- [ ] Tidak ada `print()` di production
- [ ] Tidak ada TODO tertinggal
- [ ] Semua file terpakai

---

### P7-005: README Final

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P1     |
| Token      | S      |
| Agent      | build  |
| Dependency | P7-004 |

**Scope:**

- `README.md` di root

**DoD:**

- [ ] Cara install & run
- [ ] Screenshot aplikasi
- [ ] Link dokumentasi

---

### P7-006: Arsip & Handover

| Field      | Nilai  |
| ---------- | ------ |
| Status     | Todo   |
| Priority   | P2     |
| Token      | S      |
| Agent      | build  |
| Dependency | P7-005 |

**Scope:**

- `docs/10-handover.md` — catatan untuk tim berikutnya

**DoD:**

- [ ] Apa yang sudah selesai
- [ ] Apa yang belum
- [ ] Rekomendasi lanjutan

---

## 12. Aturan Update Backlog

1. **Setiap task selesai:** ubah status ke `Done`, commit.
2. **Setiap task mulai:** ubah status ke `WIP`.
3. **Task di-review:** ubah status ke `Review`.
4. **Task blocked:** ubah status ke `Blocked`, catat alasan.
5. **Update ringkasan progress** di section 3 setiap phase selesai.
6. **Jangan hapus task** — kalau tidak jadi dikerjakan, ubah ke `Skip` dengan alasan.

---

## 13. Referensi

- `docs/00-phases.md` — roadmap fase
- `docs/06-workflow.md` — cara kerja dengan opencode
- `docs/08-context-map.md` — peta file (akan dibuat)
- `AGENTS.md` — aturan agent

---

## 14. Update Log

| Tanggal    | Perubahan           |
| ---------- | ------------------- |
| 2026-10-16 | Draft awal, 65 task |
