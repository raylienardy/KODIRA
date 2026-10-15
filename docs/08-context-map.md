# Context Map — KODIRA

Peta file: untuk setiap task, file mana yang perlu dibaca. Tujuan:
opencode tidak baca semua file, hemat token, tetap terarah.

| Field   | Nilai                |
| ------- | -------------------- |
| Versi   | 1.0                  |
| Tanggal | 2026-10-16           |
| Status  | Aktif                |
| Basis   | `docs/07-backlog.md` |

---

## 1. Cara Pakai

Saat mengirim prompt ke opencode, **selalu sertakan daftar file** dari
file ini. Contoh:

```

KONTEKS
Task P4-001 dari backlog.
File wajib dibaca:

- docs/01-prd.md (bagian 8.1)
- docs/03-architecture.md (bagian 4, 5, 8)
- docs/02-design-system.md (bagian 7.3)
  File opsional:
- docs/04-guidelines.md (bagian 2)

```

**Aturan:**

- **Wajib dibaca** = harus dibaca, agent tidak boleh lanjut tanpa ini
- **Opsional** = dibaca hanya jika butuh
- **Jangan dibaca** = jangan sentuh, meskipun agent penasaran

---

## 2. Legend

| Kode | Arti                              |
| ---- | --------------------------------- |
| 📕   | File wajib dibaca                 |
| 📖   | File opsional (dibaca jika perlu) |
| ❌   | Jangan dibaca untuk task ini      |

---

## 3. Phase 0 — Foundation (DONE)

Tidak ada task aktif. Skip.

---

## 4. Phase 1 — Design System

### P1-001: Setup Project Flutter

| File                                      | Status |
| ----------------------------------------- | ------ |
| `docs/00-phases.md` (bagian Phase 1)      | 📕     |
| `docs/03-architecture.md` (bagian 2.1, 3) | 📕     |
| `docs/04-guidelines.md` (bagian 2)        | 📖     |
| Semua file lain                           | ❌     |

**Prompt siap pakai:**

```

Task P1-001 dari backlog. Baca:

- docs/03-architecture.md bagian 2.1 & 3
  Buat project Flutter di folder app/. DoD sesuai backlog.

```

---

### P1-002: Setup Folder Structure

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/03-architecture.md` (bagian 3) | 📕     |
| `docs/04-guidelines.md` (bagian 7)   | 📕     |
| Semua file lain                      | ❌     |

---

### P1-003: Buat Theme.dart

| File                                           | Status |
| ---------------------------------------------- | ------ |
| `docs/02-design-system.md` (bagian 2, 3, 4, 5) | 📕     |
| `DESIGN.md` (bagian 14)                        | 📕     |
| `docs/03-architecture.md` (bagian 3)           | 📖     |
| Semua file lain                                | ❌     |

**Prompt siap pakai:**

```

Task P1-003 dari backlog. Baca:

- docs/02-design-system.md
- DESIGN.md bagian 14 (Flutter tokens)
  Buat file app/lib/app/theme.dart. DoD sesuai backlog.

```

---

### P1-004: Setup Linter Rules

| File                                   | Status |
| -------------------------------------- | ------ |
| `docs/04-guidelines.md` (bagian 2)     | 📕     |
| `docs/03-architecture.md` (bagian 2.1) | 📖     |
| Semua file lain                        | ❌     |

---

### P1-005: Setup Font Assets

| File                                  | Status |
| ------------------------------------- | ------ |
| `docs/02-design-system.md` (bagian 3) | 📕     |
| `DESIGN.md` (bagian 3)                | 📕     |
| Semua file lain                       | ❌     |

---

### P1-006: Setup CI

| File                                  | Status |
| ------------------------------------- | ------ |
| `docs/04-guidelines.md` (bagian 3, 4) | 📕     |
| `docs/05-decisions.md` (ADR-017)      | 📖     |
| Semua file lain                       | ❌     |

---

### P1-007: Setup Pre-commit Hook

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/04-guidelines.md` (bagian 3.5) | 📕     |
| `docs/05-decisions.md` (ADR-018)     | 📖     |
| Semua file lain                      | ❌     |

---

### P1-008: Dokumentasi Setup

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/03-architecture.md` (bagian 2) | 📕     |
| `docs/04-guidelines.md` (bagian 13)  | 📕     |
| `README.md` (jika sudah ada)         | 📖     |
| Semua file lain                      | ❌     |

---

## 5. Phase 2 — UI Design

### P2-001: Regenerate Stitch dengan DESIGN.md

| File                       | Status |
| -------------------------- | ------ |
| `DESIGN.md`                | 📕     |
| `docs/02-design-system.md` | 📖     |
| Semua file lain            | ❌     |

**Agent:** Manual (bukan opencode). Upload `DESIGN.md` ke Stitch.

---

### P2-002: Export to Figma

Manual. Tidak perlu opencode.

---

### P2-003: Build Interactive Prototype

Manual di Figma. Tidak perlu opencode.

---

### P2-004: User Flow Diagram

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/01-prd.md` (bagian 9)          | 📕     |
| `docs/03-architecture.md` (bagian 7) | 📕     |
| `docs/07-backlog.md` (P2-004)        | 📕     |
| Semua file lain                      | ❌     |

---

### P2-005: Wireframe (opsional)

Manual. Tidak perlu opencode.

---

### P2-006: Screenshot untuk Proposal

Manual. Tidak perlu opencode.

---

## 6. Phase 3 — Architecture

### P3-001: Finalisasi Tech Stack

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/05-decisions.md` (semua ADR)   | 📕     |
| `docs/03-architecture.md` (bagian 2) | 📕     |
| `docs/01-prd.md` (bagian 12)         | 📖     |
| Semua file lain                      | ❌     |

**Agent:** `plan`

---

### P3-002: Database Schema Final

| File                                               | Status |
| -------------------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 4)               | 📕     |
| `docs/01-prd.md` (bagian 6, 10)                    | 📕     |
| `docs/05-decisions.md` (ADR-004, ADR-005, ADR-009) | 📖     |
| Semua file lain                                    | ❌     |

**Agent:** `plan`

---

### P3-003: API Contract Final

| File                                       | Status |
| ------------------------------------------ | ------ |
| `docs/03-architecture.md` (bagian 5, 6, 7) | 📕     |
| `docs/01-prd.md` (bagian 6)                | 📕     |
| Semua file lain                            | ❌     |

**Agent:** `plan`

---

### P3-004: Setup Supabase Project

Manual. Tidak perlu opencode.

---

### P3-005: Migrasi Database

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/03-architecture.md` (bagian 4) | 📕     |
| `docs/07-backlog.md` (P3-005)        | 📕     |
| Semua file lain                      | ❌     |

**Agent:** `build`

---

### P3-006: Setup AI Provider

Manual. Tidak perlu opencode.

---

### P3-007: Setup Judge0

Manual. Tidak perlu opencode.

---

## 7. Phase 4 — MVP Development

### P4-001: Auth — Login NIM

| File                                         | Status |
| -------------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.1)                | 📕     |
| `docs/03-architecture.md` (bagian 4, 5, 8.2) | 📕     |
| `docs/02-design-system.md` (bagian 7.3, 7.1) | 📕     |
| `docs/04-guidelines.md` (bagian 2)           | 📖     |
| `docs/05-decisions.md` (ADR-009)             | 📖     |
| Semua file lain                              | ❌     |

**Prompt siap pakai:**

```

Task P4-001 dari backlog.
File wajib dibaca:

- docs/01-prd.md bagian 8.1
- docs/03-architecture.md bagian 4, 5, 8.2
- docs/02-design-system.md bagian 7.1, 7.3
  Buat login screen + auth repository di app/lib/features/auth/.
  DoD sesuai backlog.

```

---

### P4-002: Routing & Navigation

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/03-architecture.md` (bagian 3) | 📕     |
| `docs/01-prd.md` (bagian 9)          | 📕     |
| `docs/04-guidelines.md` (bagian 2.6) | 📖     |
| Semua file lain                      | ❌     |

---

### P4-003: Home / Level Map

| File                                         | Status |
| -------------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.6)                | 📕     |
| `docs/02-design-system.md` (bagian 7.6, 7.7) | 📕     |
| `docs/03-architecture.md` (bagian 4)         | 📕     |
| `DESIGN.md` (bagian 13, contoh Level Map)    | 📖     |
| Semua file lain                              | ❌     |

---

### P4-004: Materi Screen

| File                                    | Status |
| --------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.2)           | 📕     |
| `docs/02-design-system.md` (bagian 7.8) | 📕     |
| `DESIGN.md` (bagian 12)                 | 📕     |
| Semua file lain                         | ❌     |

---

### P4-005: Latihan Drag & Drop

| File                                         | Status |
| -------------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.3)                | 📕     |
| `docs/02-design-system.md` (bagian 7.1, 7.2) | 📕     |
| `docs/03-architecture.md` (bagian 5)         | 📕     |
| Semua file lain                              | ❌     |

---

### P4-006: Latihan Coding Manual

| File                                    | Status |
| --------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.3)           | 📕     |
| `docs/03-architecture.md` (bagian 5, 6) | 📕     |
| `docs/05-decisions.md` (ADR-011)        | 📖     |
| Semua file lain                         | ❌     |

---

### P4-007: Kuis Adaptif (UI)

| File                                              | Status |
| ------------------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.3)                     | 📕     |
| `docs/02-design-system.md` (bagian 7.1, 7.2, 7.7) | 📕     |
| `DESIGN.md` (bagian 13, contoh Quiz)              | 📕     |
| Semua file lain                                   | ❌     |

---

### P4-008: Hasil & Feedback Screen

| File                                              | Status |
| ------------------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.4)                     | 📕     |
| `docs/02-design-system.md` (bagian 7.1, 7.2, 7.7) | 📕     |
| `docs/03-architecture.md` (bagian 7)              | 📕     |
| Semua file lain                                   | ❌     |

---

### P4-009: XP & Level System

| File                                    | Status |
| --------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 6.1, 10.2)     | 📕     |
| `docs/03-architecture.md` (bagian 4, 7) | 📕     |
| `docs/05-decisions.md` (ADR-004)        | 📖     |
| Semua file lain                         | ❌     |

---

### P4-010: Badge & Achievement

| File                                    | Status |
| --------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 6.1, 7.1)      | 📕     |
| `docs/02-design-system.md` (bagian 7.5) | 📕     |
| `docs/03-architecture.md` (bagian 4)    | 📕     |
| Semua file lain                         | ❌     |

---

### P4-011: Profil & Progress

| File                                              | Status |
| ------------------------------------------------- | ------ |
| `docs/01-prd.md` (bagian 8.6)                     | 📕     |
| `docs/02-design-system.md` (bagian 7.2, 7.5, 7.7) | 📕     |
| `docs/03-architecture.md` (bagian 4)              | 📕     |
| Semua file lain                                   | ❌     |

---

### P4-012: Local Storage

| File                                      | Status |
| ----------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 2.1, 4) | 📕     |
| `docs/05-decisions.md` (ADR-008)          | 📖     |
| Semua file lain                           | ❌     |

---

### P4-013: Repository Pattern

| File                                    | Status |
| --------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 3, 5) | 📕     |
| `docs/04-guidelines.md` (bagian 2, 7)   | 📕     |
| Semua file lain                         | ❌     |

---

### P4-014: Error Handling & Loading States

| File                                     | Status |
| ---------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 5.2)   | 📕     |
| `docs/04-guidelines.md` (bagian 2.7)     | 📕     |
| `docs/02-design-system.md` (bagian 7.10) | 📖     |
| Semua file lain                          | ❌     |

---

## 8. Phase 5 — AI Integration

### P5-001: AI Service Setup

| File                                      | Status |
| ----------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 2.3, 6) | 📕     |
| `docs/01-prd.md` (bagian 6.2)             | 📕     |
| `docs/05-decisions.md` (ADR-006, ADR-007) | 📕     |
| Semua file lain                           | ❌     |

**Prompt siap pakai:**

```

Task P5-001 dari backlog.
File wajib dibaca:

- docs/03-architecture.md bagian 2.3 & 6
- docs/01-prd.md bagian 6.2
- docs/05-decisions.md ADR-006 & ADR-007
  Buat Edge Function di app/supabase/functions/ai/ untuk proxy AI.
  AI satu arah, bukan chatbot. DoD sesuai backlog.

```

---

### P5-002: Hint Generator

| File                                   | Status |
| -------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 6.2) | 📕     |
| `docs/01-prd.md` (bagian 6.2)          | 📕     |
| `docs/05-decisions.md` (ADR-007)       | 📕     |
| Semua file lain                        | ❌     |

---

### P5-003: Feedback Generator

| File                                        | Status |
| ------------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 6.2, 6.4) | 📕     |
| `docs/01-prd.md` (bagian 6.2)               | 📕     |
| Semua file lain                             | ❌     |

---

### P5-004: Adaptive Quiz Engine

| File                                               | Status |
| -------------------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 7)               | 📕     |
| `docs/01-prd.md` (bagian 6.3)                      | 📕     |
| `docs/05-decisions.md` (ADR-004, ADR-005, ADR-006) | 📕     |
| Semua file lain                                    | ❌     |

**Catatan:** Ini task paling kritis. Formula mastery + rule-based engine.

---

### P5-005: AI Question Generator

| File                                   | Status |
| -------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 6.3) | 📕     |
| `docs/01-prd.md` (bagian 6.3)          | 📕     |
| Semua file lain                        | ❌     |

---

### P5-006: Guardrail Validator

| File                                   | Status |
| -------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 6.4) | 📕     |
| `docs/05-decisions.md` (ADR-006)       | 📕     |
| Semua file lain                        | ❌     |

---

### P5-007: Code Runner Integration

| File                                           | Status |
| ---------------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 2.4, 5, 8.5) | 📕     |
| `docs/05-decisions.md` (ADR-011)               | 📕     |
| Semua file lain                                | ❌     |

---

### P5-008: End-to-End AI Flow

| File                                    | Status |
| --------------------------------------- | ------ |
| `docs/03-architecture.md` (bagian 6, 7) | 📕     |
| `docs/01-prd.md` (bagian 6.2, 6.3)      | 📕     |
| Semua file lain                         | ❌     |

---

## 9. Phase 6 — Testing & Evaluation

### P6-001: Unit Test Coverage

| File                                  | Status |
| ------------------------------------- | ------ |
| `docs/04-guidelines.md` (bagian 4)    | 📕     |
| `docs/05-decisions.md` (ADR-015)      | 📕     |
| `docs/03-architecture.md` (bagian 11) | 📕     |
| Semua file lain                       | ❌     |

---

### P6-002: Widget Test

| File                               | Status |
| ---------------------------------- | ------ |
| `docs/04-guidelines.md` (bagian 4) | 📕     |
| Semua file lain                    | ❌     |

---

### P6-003: Integration Test

| File                               | Status |
| ---------------------------------- | ------ |
| `docs/04-guidelines.md` (bagian 4) | 📕     |
| `docs/01-prd.md` (bagian 9)        | 📖     |
| Semua file lain                    | ❌     |

---

### P6-004: Uji Coba Pengguna

Manual. Tidak perlu opencode.

---

### P6-005: Analisis Hasil

| File                          | Status |
| ----------------------------- | ------ |
| `docs/01-prd.md` (bagian 10)  | 📕     |
| `docs/00-phases.md` (Phase 6) | 📕     |
| Semua file lain               | ❌     |

---

### P6-006: Perbaikan Berdasarkan Feedback

| File                                     | Status |
| ---------------------------------------- | ------ |
| `docs/09-evaluation.md` (hasil analisis) | 📕     |
| `docs/07-backlog.md` (task terkait)      | 📕     |
| Semua file lain                          | ❌     |

---

## 10. Phase 7 — Documentation & Presentation

### P7-001: Update Artikel Final

| File                             | Status |
| -------------------------------- | ------ |
| `docs/09-evaluation.md`          | 📕     |
| `artikel belum selesai uts.docx` | 📕     |
| `docs/03-architecture.md`        | 📖     |
| Semua file lain                  | ❌     |

---

### P7-002: Slide Presentasi Final

| File                           | Status |
| ------------------------------ | ------ |
| `KODIRA_Presentasi UTS 1.pptx` | 📕     |
| `docs/01-prd.md`               | 📖     |
| Semua file lain                | ❌     |

---

### P7-003: Demo Video

Manual. Tidak perlu opencode.

---

### P7-004: Source Code Cleanup

| File                                | Status |
| ----------------------------------- | ------ |
| `docs/04-guidelines.md` (bagian 11) | 📕     |
| `app/lib/` (semua file)             | 📕     |
| Semua file lain                     | ❌     |

---

### P7-005: README Final

| File                                 | Status |
| ------------------------------------ | ------ |
| `docs/03-architecture.md` (bagian 2) | 📕     |
| `docs/04-guidelines.md` (bagian 13)  | 📕     |
| Semua file lain                      | ❌     |

---

### P7-006: Arsip & Handover

| File                 | Status |
| -------------------- | ------ |
| `docs/00-phases.md`  | 📕     |
| `docs/07-backlog.md` | 📕     |
| Semua file lain      | ❌     |

---

## 11. Task yang Butuh `plan` Dulu

Sebelum `build`, task-task ini harus lewat `plan` dulu:

| Task   | Alasan                          |
| ------ | ------------------------------- |
| P3-001 | Keputusan tech stack final      |
| P3-002 | Desain schema database          |
| P3-003 | Kontrak API                     |
| P5-004 | Adaptive engine (paling kritis) |
| P6-005 | Analisis hasil                  |
| P7-001 | Struktur artikel final          |
| P7-002 | Struktur slide final            |

**Pola:**

```

1. plan → diskusi & draft di chat
2. Review
3. build → tulis ke file

```

---

## 12. Task yang Full `build`

Task-task ini bisa langsung `build`:

| Task                                 | Alasan                |
| ------------------------------------ | --------------------- |
| P1-001 s/d P1-008                    | Setup teknis          |
| P4-001 s/d P4-014                    | Implementasi fitur    |
| P5-001 s/d P5-003, P5-005 s/d P5-008 | Implementasi AI       |
| P6-001 s/d P6-003                    | Test                  |
| P6-006                               | Perbaikan             |
| P7-004, P7-005, P7-006               | Cleanup & dokumentasi |

---

## 13. Aturan File yang TIDAK Boleh Dibaca

Untuk setiap task, **JANGAN** baca:

- `reference/awesome-design-md/` (kecuali butuh inspirasi)
- `reference/web-interface-guidelines/` (kecuali task UI/UX)
- File `.docx` atau `.pptx` (kecuali task dokumentasi)
- File di `docs/` yang tidak disebut di task

**Alasan:** hemat token, hindari distraksi.

---

## 14. Contoh Prompt Lengkap

### Contoh 1 — Task Kecil (S)

```

KONTEKS
Task P1-003 dari backlog.
File wajib dibaca:

- docs/02-design-system.md
- DESIGN.md bagian 14
  File opsional:
- docs/03-architecture.md bagian 3
  Jangan baca file lain.

TUGAS
Buat app/lib/app/theme.dart dengan class KodiraColors,
KodiraSpacing, KodiraRadius, KodiraTextStyles.

BATASAN

- Hanya buat file ini
- Jangan install package
- Format Dart standar

DoD
Sesuai backlog P1-003.

FORMAT OUTPUT
Laporkan: file, baris, token yang dipakai.

```

### Contoh 2 — Task Besar (L)

```

KONTEKS
Task P4-003 dari backlog.
File wajib dibaca:

- docs/01-prd.md bagian 8.6
- docs/02-design-system.md bagian 7.6, 7.7
- docs/03-architecture.md bagian 4
  File opsional:
- DESIGN.md bagian 13 (contoh Level Map)
- docs/04-guidelines.md bagian 2
  Jangan baca file lain.

TUGAS
Buat Home / Level Map screen di app/lib/features/home/.

BATASAN

- Hanya file di folder features/home/
- Gunakan token dari theme.dart
- Stateless jika bisa
- Jangan install package
- Jangan ubah file lain

DoD
Sesuai backlog P4-003.

FORMAT OUTPUT
Laporkan: file, baris, komponen, test manual, token.

```

---

## 15. Update Log

| Tanggal    | Perubahan                   |
| ---------- | --------------------------- |
| 2026-10-16 | Draft awal, mapping 55 task |
