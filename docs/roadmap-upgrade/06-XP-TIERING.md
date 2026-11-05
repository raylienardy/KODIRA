# Fitur #6 — XP Bertingkat & Streak Multiplier

## 1. Konteks
Sebelumnya, setiap level memberikan nilai XP tetap sebesar 100 XP. Hal ini tidak mencerminkan tingkat kesulitan materi (level dasar vs level mahir) dan tidak menginsentifkan konsistensi belajar harian.

## 2. Scope
Implementasi perolehan XP berbasis tier level dan pengali bonus streak harian.

## 3. Spec Detail & Spesifikasi Teknis
- **Aturan XP Baru (Tier-based)**:
  - **Mudah (Level 1-15)**: 50 XP (Lulus), 25 XP (Remedial), 0 XP (Gagal).
  - **Sedang (Level 16-35)**: 100 XP (Lulus), 50 XP (Remedial), 0 XP (Gagal).
  - **Tinggi (Level 36-50)**: 150 XP (Lulus), 75 XP (Remedial), 0 XP (Gagal).
- **Streak Multiplier**:
  - Hari ke-7: Pengali 1.5×
  - Hari ke-30: Pengali 2.0×
  - Hari ke-60+: Pengali 2.5×
- **Migration Strategy**: Inkremental. XP mahasiswa yang sudah ada dipertahankan apa adanya. Level baru yang diselesaikan pasca-update akan menggunakan aturan XP bertingkat.

## 4. File yang Disentuh (File:Line & Signature)
- **`app/lib/data/repositories/progress_logic.dart:31`**
  - **Signature**:
    ```dart
    static int computeXp(int existing, int incoming) => max(existing, incoming);
    ```
  - **Logika**: XP tidak pernah turun. Tier-based reward di-handle oleh `XpLogic`.
- **`app/lib/features/quiz/screens/quiz_screen.dart:356`**
  - Perubahan: Menghapus logika XP hardcoded lama, menggunakan `XpLogic.computeAttemptXp` untuk mendapatkan `XpResult`.
- **`app/lib/features/quiz/widgets/result_dialog.dart`**
  - Terintegrasi untuk menampilkan detail hasil kuis melalui `XpResult`.

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**:
  - `app/test/data/logic/xp_logic_test.dart` (42 kasus): Test reward tier-based per tier (mudah/sedang/tinggi), per outcome (lulus/remedial/gagal), dan streak multiplier.
  - `app/test/features/quiz/widgets/result_logic_test.dart` (4 kasus)
  - `app/test/features/quiz/widgets/result_dialog_test.dart` (4 kasus)
  - `app/test/features/quiz/screens/quiz_screen_test.dart` (3 kasus integrasi)
- **Existing Test**:
  - `app/test/data/repositories/progress_logic_test.dart` (23 kasus): `computeXp` dipertahankan sebagai `max(existing, incoming)`. Test tidak diubah.

## 6. Definition of Done (DoD)
- XP bertingkat dan bonus streak terhitung otomatis saat kuis diselesaikan.
- Data XP mahasiswa lama tidak terhapus (inkremental).

## 7. Blocker & Dependency
- Tidak ada blocker. `LevelTier` enum di-derive dari `level_number` (standalone, tidak bergantung Fitur #1). Fitur #1 akan reuse enum yang sama.

## 8. Effort Estimate
- 2 jam (Logic + UI + Test Update).

## 9. Risk & Mitigasi
- **Risk**: Integrasi `XpLogic` + refactor `quiz_screen.dart` (hardcoded XP block dihapus).
- **Mitigasi**: 42 test di `xp_logic_test.dart` menjamin kalkulasi tier-based benar.

## Implementation Status (Updated pasca Fase 1b)
- Commit ref: `421996a` (foundation) + `8b3148d` (integration)
- File actual:
  - `app/lib/data/logic/xp_logic.dart` (baru — `LevelTier`, `XpResult`, `XpLogic`)
  - `app/lib/features/quiz/screens/quiz_screen.dart` (edit)
  - `app/lib/features/quiz/widgets/result_dialog.dart` (edit)
  - `app/lib/features/quiz/widgets/result_logic.dart` (edit)
- Test: 42 (xp_logic) + 4 (result_logic) + 4 (result_dialog) + 3 (quiz integration) = 53 test baru.