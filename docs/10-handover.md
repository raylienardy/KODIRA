# Handover — KODIRA

Dokumen untuk developer berikutnya. Berisi status terkini, arsitektur, known issues, dan rekomendasi lanjutan.

**Terakhir update**: 2026-10-24  
**Commit HEAD**: `da20c5b40a92ec0c0c6a69d1a5bbc6d6fbe24b15`  
**Progress**: ~84% (weighted avg)  
**Test suite**: 220 PASS

---

## 1. Status Project

| Phase | Fokus | Status |
|---|---|---|
| 0-1 | Foundation + Design System | ✅ Selesai |
| 2 | UI Design (Figma/Stitch) | ✅ Selesai (4 task Review: artefak external) |
| 3 | Architecture | ✅ Selesai |
| 4 | MVP Development | ✅ **SELESAI** (12 Done / 0 Todo / 2 Skip) |
| 5 | AI Integration | ⏳ Blocked (butuh backend) |
| 6 | Testing | ⏳ Pending (Phase 5) |
| 7 | Documentation | 🚧 Dalam proses (3/6 Done) |

**MVP Features Berjalan:**
- Auth (login NIM, session restore, logout)
- Level map + progress persist
- Materi 5 slide × 50 level
- Drag & drop exercise 5 × 50 level
- Kuis 3 soal × 15 level (L1-15)
- XP + level unlock + streak + badge + achievement
- Profil 6 section

---

## 2. Yang Sudah Berjalan (Production-Ready)

**Code + Test + Runtime Verified:**
- **Auth**: login NIM, session restore (backoff retry), logout
- **Materi**: 5 slide interaktif per level, navigasi Lanjut/Back, hint button
- **Drag & Drop**: 5 exercise per level, token pool + drop zone, validasi jawaban, feedback sheet
- **Kuis**: timer 60 detik per soal, pilihan ganda 4 opsi, feedback benar/salah + explanation, auto-submit timeout
- **Result Dialog**: tier (<40% / 40-69% / ≥70%), mastery bar, XP message retake-aware, **level-up animation** (first completion pass), tombol adaptif (Lanjut/Coba Lagi/Review)
- **XP persistence**: auto-save ke `user_progress`, level unlock, skor terbaik dipertahankan
- **Streak**: auto-update on login, chip real-time di Home
- **Badge/Achievement**: auto-award milestone (9 badge + 3 achievement), check on quiz completion
- **Profil**: 6 section lengkap (header, stats, badge grid, achievement list, mastery per topik, aktivitas terakhir), pull-to-refresh, achievement tap dialog dengan tanggal
- **Error handling**: `KodiraErrorWidget` + retry button (network fail, offline), `KodiraLoadingWidget` (splash, level loader), banner retry Home (session restore failed)
- **Repository pattern**: 7 interface (IAuth, ILevel, IMaterial, IExercise, IUserProgress, IStreak, IBadge) + concrete implementation
- **Test coverage**: 220 unit + widget test, CI hijau

---

## 3. Yang Belum (Sisa Todo)

| Task | Priority | Blocker |
|---|---|---|
| Phase 5 AI Integration (8 task) | P0 | Butuh Groq API key + Supabase Edge Function |
| Phase 6 Testing (6 task) | P1 | Butuh Phase 5 selesai |
| P7-001 Artikel final | P0 | Manual (DOCX) |
| P7-002 Slide presentasi | P0 | Manual (PPTX) |
| P7-003 Demo video | P1 | Manual (video) |
| Quiz L16-50 (105 soal) | P1 | Seed manual / AI-generated |
| P3-006 AI provider key | P0 | Manual (setup Supabase secrets) |
| 4 task Phase 2 | P1 | Manual (Figma/Stitch external tool) |

**Phase 5 AI Integration** (blocked backend):
- P5-001: Hint System AI Mentor (3 level hint bertahap)
- P5-002: Quiz Adaptive (sesuaikan difficulty + topik lemah)
- P5-003: Progress Tracking AI (analisis mastery + rekomendasi)
- P5-004: Content Recommendation
- P5-005: AI Feedback Engine
- P5-006: Edge Function (Groq API proxy)
- P5-007: Judge0 Code Runner
- P5-008: Test Phase 5

---

## 4. Known Issues / Debt

1. **Quiz coverage L16-L50**: hanya L1-15 punya quiz (30% coverage). 105 soal lagi bisa di-seed dengan pola `seed-quiz-02.sql`.
2. **CircularDependencyError** di log streak/badge refresh: tertangkap di debugPrint, tidak crash, tapi log kotor. Bisa dibersihkan dengan memindahkan `invalidate(allProgressProvider)` dari `auth_provider` ke caller.
3. **Animasi level-up capture**: runtime test ter-verified di t≈3704 ms (screenshot cadence ~500 ms), target ideal 600 ms. Animasi berjalan sempurna, hanya timing capture yang terbatas.
4. **P4-006 Coding Manual**: Skip, blocked Phase 5 (Judge0 backend). Akan diimplementasi bersama code runner Phase 5.
5. **Phase 2 tasks 4 Review**: Figma/Stitch/prototype/screenshot resolusi 2x — butuh tool external, tidak bisa diselesaikan AI.

---

## 5. Arsitektur Ringkas

**Stack:**
- Flutter 3.44 + Dart 3.12
- Riverpod 2.x (state management)
- go_router 14.x (routing + guard)
- Supabase hosted (PostgreSQL + Auth + RLS)
- 24 ADR documented (`docs/05-decisions.md`)

**Struktur:** Clean Architecture, feature-first

```
app/lib/
├── app/         # router, theme, main
├── core/        # errors, network, utils, Result<T> type
├── data/        # models, repositories (7 interface + concrete)
├── features/    # auth, home, lesson, exercise, quiz, gamification, profile, adaptive, ai_mentor
└── shared/      # widgets (loading, error, empty), providers global
```

**Database schema:** 13 tabel utama (users, levels, materials, exercises, questions, user_progress, user_streaks, user_badges, user_achievements, activity_logs, auth.users)

Detail lengkap: `docs/03-architecture.md`

---

## 6. Build & Deploy

### Development

```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define-from-file=.env
```

### Release

```bash
# Split per ABI (arm64-v8a, armeabi-v7a, x86_64) untuk ukuran optimal <50MB per APK
bash scripts/build-release.sh
# Output: app/build/app/outputs/flutter-apk/*-release.apk
```

### Test

```bash
cd app
flutter test          # 220 PASS
flutter analyze       # 0 issue
dart format --set-exit-if-changed lib test  # format check
```

### Pre-commit Hook

```bash
# Dari root project
bash scripts/install-hooks.sh
```

Hook otomatis `dart format`, `flutter analyze`, dan rebuild graphify sebelum commit.

---

## 7. Rekomendasi Lanjutan (Priority Order)

1. **Phase 5 AI Integration** (estimasi 10-15 jam) — butuh Groq API key + Supabase Edge Function. Implementasi hint system 3 level bertahap, adaptive quiz, progress tracking AI.
2. **Seed quiz L16-L50** (estimasi 1 jam) — pola sama dengan `seed-quiz-02.sql`. Gunakan AI-generated atau copy pattern dari L1-15.
3. **P7-001/002/003 manual** (estimasi 2-3 jam) — artikel final DOCX, slide presentasi PPTX, demo video.
4. **Phase 6 Testing** (estimasi 3-5 jam) — butuh Phase 5 selesai. Unit coverage target 70%+, integration test, manual test checklist.
5. **Clean CircularDependencyError** (estimasi 30 menit) — pindahkan `invalidate(allProgressProvider)` dari `refreshStreak`/`refreshBadges` ke caller (LoginScreen, Home banner callback). Refactor sudah dilakukan di commit `13063b5`, tapi log warning masih muncul karena concurrent refresh.
6. **Phase 2 tasks 4 Review** (estimasi 1-2 jam manual Figma/Stitch) — artefak external, koordinasi dengan tim desain jika diperlukan.

---

## 8. Credentials (JANGAN COMMIT)

- **Supabase project ref**: `vnmrivutawqxcoklamcb`
- **Akun test**:
  - Ridho: NIM `2402095010141`, password → lihat `CATATAN-LOGIN.md` (local, tidak di-commit)
  - Test User: NIM `2402095010999`, password → lihat `CATATAN-LOGIN.md` (local, tidak di-commit)
- **Env setup**: copy `app/.env.example` → `app/.env`, isi `SUPABASE_URL` + `SUPABASE_ANON_KEY` (minta ke tim)

**PENTING**: File ini tidak boleh berisi password plaintext. Untuk akses akun, koordinasi dengan tim via kanal privat atau gunakan password manager (1Password/Bitwarden).

**Supabase URL** (public by design, safe untuk README):
```
https://vnmrivutawqxcoklamcb.supabase.co
```

**ANON_KEY** (public client key, safe untuk client-side):
Minta ke tim atau lihat `.env.example`.

---

## 9. Kontak

- **Ridho** (NIM 2402095010141) — lead dev, backend, gamification
- **Raynato** (NIM 2402095010152) — co-dev, UI/UX, testing
- **Dosen**: Kurnia Wahyu Prima, S.Pd., M.Pd. — Pemrograman Dasar (JTIK)
- **Repository**: https://github.com/raylienardy/KODIRA
- **Dokumentasi**: lihat `docs/` di root project
- **Kontak**: buka issue di GitHub, atau hubungi tim langsung via email/WhatsApp

---

**Catatan akhir:** Project ini dikembangkan dengan metode ADDIE (Analysis, Design, Development, Implementation, Evaluation) untuk mata kuliah Pemrograman Dasar semester 1. Target pengguna: mahasiswa JTIK semester 1 yang belajar C++ dan Java. Fokus: gamifikasi + adaptive learning + AI mentor.

Selamat melanjutkan! 🚀
