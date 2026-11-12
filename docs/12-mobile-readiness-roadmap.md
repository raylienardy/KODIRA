# 12 — Mobile Readiness Roadmap

**Version:** 1.1
**Date:** 2026-11-12
**HEAD:** `5332a02`
**Test Baseline:** 490 PASS (474 → 484 → 490 trajectory)
**Analyze:** 0 issues | **Format:** 0 changed
**Next Milestone:** Demo Kamis, 13 Nov 2026

**Purpose:** Single source of truth untuk mobile readiness. Menggantikan status section yang stale di `10-handover.md` dan `roadmap-upgrade/README.md`. Fokus mobile dulu, web/admin deferred.

---

## 0. Reading Guide

**Supersedes (stale, do not use as status):**
- `10-handover.md` §1 (Status Project), §3 (Sisa Todo), §7 (Rekomendasi Lanjutan) — mencerminkan HEAD `da20c5b`, 220 tests
- `roadmap-upgrade/README.md` — status "Ready to Build" / "Pending Fase 1" tidak mencerminkan realita

**Preserves (still valid as reference):**
- `09-DATA-MIGRATION.md`, `10-SEED-USERS.md` — schema/seed references
- `11-qa-teacher-dashboard.md` — 31 QA test cases (link, bukan duplikasi)
- `07-backlog.md` — detailed task IDs (link)

**If conflict:** This doc wins. Ambiguity → §9.

---

## 1. Purpose & Scope

**In-scope (mobile Flutter app):**
- Feature completion untuk demo Kamis
- Bug fixes dari peer review
- UX polish high-impact
- Mobile QA acceptance

**Out-of-scope (deferred sampai mobile stabil):**
- Web/Admin Panel (Next.js 15, #2A-#2E, #4B)
- Backend infrastructure AI (Groq API key, Supabase Edge Function) — Phase 5 items 5-8

**Definition of "mobile ready":**
- ✅ Tidak ada P0 blocker bug
- ✅ Semua P1 items selesai atau explicitly deferred dengan workaround
- ✅ `flutter test` ≥ 490 PASS maintained
- ✅ `flutter analyze` 0 issues
- ✅ Manual smoke test di device passed

---

## 2. Current State (Verified)

| Item | Status |
|---|---|
| HEAD | `5332a02` |
| Tests | **490 PASS** (0 fail) |
| Analyze | 0 issues |
| Format | 0 changed |
| Shipped hari ini | #P4 (register class code), #P5 (teacher dashboard), join_class fix, #V2-phase1 (student detail drill-down) |
| Migrations live | 15/15 (13 old + 1 V2 + 1 pending RLS fix) |
| Seed data | 7 users + PTIK24 (verified via view 9 rows) |
| **Phase 5 AI** | **PARTIAL** — UI (hint/feedback sheets) + AiRepository + AiSource done; Edge Functions + Groq API key **not confirmed deployed** → AI hint may fail in APK (verify before demo) |

**Working well:**
- Auth (register/login/reset/change password) — student + teacher roles
- Teacher flow: create class → roster → drill-down detail mastery
- Student flow: join class (post-login) + register class code (P4)
- Leaderboard global + per-class
- Quiz L1-50 (seed-quiz-02.sql verified: 3 questions/level for L16-50; L1-15 pre-existing)

**Notable gaps (dari peer review 11 Nov, lihat §4):**
- RLS recursion breaks `/join-class` and `/teacher-dashboard` — **P0**
- NIM validation may reject valid 12-digit format — **P1**
- Dosen sees student home UI after login — **P1**
- UX copy dosen/teacher-create-class minim penjelasan — **P2**

---

## 3. Critical Bug: RLS Infinite Recursion [P0]

**Symptom:** `/join-class` → "Gagal memuat kelas: infinite recursion detected in policy for relation 'class_teachers', code 42P17"

**Root cause:** Policy `class_teachers_select` (migration `20261110000001` baris ~120) punya self-referential `EXISTS` subquery:
```sql
USING (
  teacher_id = auth.uid()
  OR EXISTS (SELECT 1 FROM public.class_teachers ct
             WHERE ct.class_id = class_teachers.class_id ...)
)
```

Saat student query `class_students` → RLS evaluasi `class_students_select_teacher` → query `class_teachers` → RLS evaluasi policy recursive → infinite loop.

**Blast radius (worst case):**
- `/join-class` — confirmed broken (screenshot peer review)
- `/teacher-dashboard` — likely broken (queries `class_teachers`)
- `set_primary_class` RPC — likely broken (INSERT/UPDATE RLS eval)

**Fix plan:**
```sql
-- 20261112000002_fix_class_teachers_rls_recursion.sql
DROP POLICY IF EXISTS class_teachers_select ON public.class_teachers;
CREATE POLICY class_teachers_select ON public.class_teachers
  FOR SELECT TO authenticated
  USING (teacher_id = auth.uid());
```

**Justification:** Kode app tidak pakai kondisi `OR EXISTS (...)` — semua query existing filter `teacher_id = auth.uid()` atau `class_id = ?`. Menghapus branch 2 tidak break fitur.

**Effort:** ~30 min (migration + deploy + smoke test)
**Blocked by:** none
**Blocks:** demo dosen flow (roster → drill-down)

---

## 4. Friend Review Items (11 Nov 2026)

6 temuan dari peer review APK (build **sebelum** P4/P5/V2):

| # | Item | Kategori | Priority | Status | Next Action |
|---|---|---|---|---|---|
| R1 | RLS recursion error | **BUG** | **P0** | Open | §3 fix |
| R2 | NIM "harus 13 digit" reject 12-digit | **BUG (perlu konfirmasi)** | **P1** | Open | §9-Q3 |
| R3 | "Kelas lain?" — tidak ada field saat register | **Misunderstanding** (APK lama) | — | **Fixed di P4** | Rebuild APK, retest |
| R4 | "Apa gunanya dosen?" — UX copy kosong | **UX gap** | P2 | Open | Register copy update (~5 min) |
| R5 | "Buat kelas fungsinya apa?" — UX copy kosong | **UX gap** | P2 | Open | Create-class header card (~15 min) |
| R6 | "Dosen juga mengerjakan level?" — dosen lihat home student | **Design gap** | **P1** | Open | Role-based redirect (~20 min) |

---

## 5. Mobile Backlog (Prioritized)

### P0 — Blocker Demo (harus selesai)

| # | Task | Effort | Source |
|---|---|---|---|
| **P0-1** | **RLS recursion fix** (migration baru + deploy + smoke test) | 30 min | §3 |

### P1 — High (demo narrative breaks tanpa ini)

| # | Task | Effort | Source |
|---|---|---|---|
| **P1-1** | **NIM validation lenient** (12 atau 13 digit) — `[WAIT: Q3]` | 10 min | §4 R2 |
| **P1-2** | **Dosen role-based redirect** (`/home` → `/teacher-dashboard` if role=teacher) | 20 min | §4 R6 |
| **P1-3** | **Rebuild APK + retest friend** (verifikasi P4 field muncul, RLS fixed) | 10 min | §4 R3 |
| **P1-4** | **Verify AI hint works in APK.** Kalau `functions.invoke` fail (Edge Function not deployed / key missing): (a) deploy Edge Function + Groq key [30 min + infra access], OR (b) disable "Hint" button di quiz screen dengan label "Segera hadir" [10 min]. | 10-30 min | session 12 Nov |

### P2 — Medium (nice-to-have, demo value)

| # | Task | Effort | Source |
|---|---|---|---|
| **P2-1** | Register Dosen copy: "bisa membuat kelas, memantau progress, lihat mastery" | 5 min | §4 R4 |
| **P2-2** | Create-class header card: penjelasan flow (kode → share → join → monitor) | 15 min | §4 R5 |
| **P2-3** | Mastery UI upgrade: breakdown A/C/E/Tn di profile (spec `03-MASTERY-UI.md` §8 belum terpenuhi) | 60-90 min | roadmap #3 |
| **P2-4** | Stale model cleanup: `my_class_model.dart:21` dead code (`fromMap` unused) | 10 min | session 12 Nov |

### P3 — Low (post-demo)

| # | Task | Effort | Source |
|---|---|---|---|
| **P3-1** | Titles: title_logic + UI Profile + Leaderboard | 3 jam | roadmap #8 |
| **P3-2** | CircularDependencyError streak/badge: pindahkan `invalidate(allProgressProvider)` ke caller | 30 min | handover §4.2 |
| **P3-3** | `_PasswordField` extract ke shared widget | 20 min | 04-PASSWORD §70 |
| **P3-4** | `flutter_markdown` → `flutter_markdown_plus` migrate | 30-45 min | 05-ABOUT §133 |
| **P3-5** | Syntax highlight: add `flutter_code_editor` ke CodeEditorScreen | 45 min | backlog L756 |
| **P3-6** | ~~Quiz L16-50 seed~~ — **RESOLVED 2026-11-12**: `seed-quiz-02.sql` verified 3 questions × levels 16-50. No debt. | — | verify Q1 |
| **P3-7** | Filter `mastery_score > 0` di view `student_detail_by_class` (cosmetic "0%" misleading) | 10 min | session 12 Nov |

**Post-demo backlog total P3:** ~5.5 jam.

---

## 6. Deferred — Web/Admin Panel

**Tidak akan dikerjakan sampai mobile stable + demo passed.**

| Item | Effort | Blocker |
|---|---|---|
| #2A Admin Web Concept | 2 jam | Demo mobile |
| #2B Admin Web Skeleton | 2 jam | #2A |
| #2C Admin Web MVP + Integration | 27 jam | #2B |
| #2D Admin Design System | 3 jam | #2C |
| #2E Admin User Flows | 5 jam | #2D |
| #4B Web Reset Password | 2 jam | #2A |

**Total:** ~41 jam (moved from roadmap-upgrade to Phase 3 after mobile stable).

**Folder `admin/` saat ini:** tidak ada.

---

## 7. Tech Debt Register

| ID | Item | Effort | Priority |
|---|---|---|---|
| ~~TD-1~~ | ~~Quiz coverage L16-50~~ — **RESOLVED**: fully seeded. | — | — |
| TD-2 | CircularDependencyError log streak/badge | 30 min | P3 |
| TD-3 | Animasi level-up: t≈3704ms vs target 600ms | 45 min | P3 |
| TD-4 | Syntax highlight CodeEditorScreen (butuh `flutter_code_editor`) | 45 min | P3 |
| TD-5 | `_PasswordField` belum extract; `Colors.amber.shade700` hardcoded | 20 min | P3 |
| TD-6 | `flutter_markdown` discontinued → migrate `flutter_markdown_plus` | 45 min | P3 |
| TD-7 | `my_class_model.dart:21` `fromMap` dead code | 10 min | P2 |
| TD-8 | NIM verification method (API kampus vs manual) | decision | P3 |
| TD-9 | Crash reporting (Sentry?) belum diputuskan | decision | P3 |
| TD-10 | Coverage target masih TBD di guidelines | decision | P3 |

---

## 8. QA Acceptance Criteria

**Manual QA:** eksekusi `11-qa-teacher-dashboard.md` (31 test cases) — wajib sebelum demo. Acceptance: 100% P0 ✅, ≥90% P1 ✅, 0 blocker.

**Automated:** `flutter test` ≥ 490 PASS maintained setiap commit.

**Mobile-ready checklist sebelum demo:**
- [ ] P0 items closed (§5)
- [ ] P1 items closed atau explicitly deferred
- [ ] `flutter test` ≥ 490 PASS
- [ ] `flutter analyze` 0 issues
- [ ] `dart format` 0 changed
- [ ] APK release build success
- [ ] Manual smoke test device (student + teacher flow)
- [ ] Screenshot backup semua screen kunci

---

## 9. Ambiguities

| Q | Item | Status |
|---|---|---|
| **Q1** | ~~Quiz L16-50~~ — **RESOLVED 2026-11-12**: `seed-quiz-02.sql` contains 3 questions/level × levels 16-50 (verified). Handover §4.1 stale. | ✅ |
| **Q2** | ~~Phase 5 AI status~~ — **RESOLVED 2026-11-12**: PARTIAL. AiRepository uses `_client.functions.invoke(...)`, UI done. Backend Edge Function + Groq key unverified → see P1-4. | ✅ |
| **Q3** | NIM format: 12 atau 13 digit? | **OPEN** — Seed: 13 digit (`2402095010141`). Peer review: 12 digit (`240209501015`). Butuh konfirmasi Pak Kurnia atau cek NIM mahasiswa lain. Default: lenient regex `^\d{12,13}$`. |

---

## 10. Supersedes / References

**Supersedes:**
- `10-handover.md` §1, §3, §7 (stale status)
- `roadmap-upgrade/README.md` §status (stale)

**Preserves (still valid as reference):**
- `07-backlog.md` — detailed task IDs (P-XXX format)
- `09-DATA-MIGRATION.md` — schema reference
- `10-SEED-USERS.md` — seed reference
- `11-qa-teacher-dashboard.md` — 31 manual test cases
- `roadmap-upgrade/01-*`, `03-*`..`10-*` — spec details per fitur

---

## 11. Pre-Demo Commitments (Kamis, 13 Nov 2026)

**Must (before demo):**
- [ ] P0-1 RLS fix deployed + verified
- [ ] P1-4 AI hint verified or disabled
- [ ] APK release rebuilt + installed on device
- [ ] Manual smoke test (student + teacher flow)
- [ ] Screenshot backup: dashboard, roster, detail, leaderboard, quiz, AI hint
- [ ] Demo script: 7 min walk-through
- [ ] Q&A cheat sheet

**Should (if time permits):**
- [ ] P1-1 NIM lenient (butuh Q3 resolve)
- [ ] P1-2 dosen redirect
- [ ] P2-1 + P2-2 UX copy fixes (5+15 min)
- [ ] P3-7 filter mastery > 0

**Deferred past demo:**
- All P3 items
- All web/admin items
- TD-8..TD-10 decisions

---

## 12. Change Log

| Date | Version | Change |
|---|---|---|
| 2026-11-12 | 1.0 | Initial consolidation. Supersedes stale handover + roadmap status. Includes 6 peer review items. HEAD `5332a02`, 490 tests |
| 2026-11-12 | 1.1 | Q1+Q2 resolved via verify (Q1: fully seeded; Q2: partial). Added P1-4 (AI hint risk), removed P3-6 + TD-1. Q3 still open |
