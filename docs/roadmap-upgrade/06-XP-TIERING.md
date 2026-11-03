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
- **`app/lib/data/repositories/progress_logic.dart:45`**
  - **Signature Lama**:
    ```dart
    static int computeXp({required double scoreRatio})
    // Logika: return scoreRatio >= 0.7 ? 100 : (scoreRatio >= 0.4 ? 50 : 0);
    ```
  - **Signature Baru**:
    ```dart
    static int computeXp({
      required double scoreRatio,
      required LevelTier tier,        // Enum: mudah/sedang/tinggi
      required int currentStreak,     // Untuk multiplier
    })
    ```
  - **Algoritma Baru**:
    ```dart
    int baseXp;
    if (scoreRatio >= 0.7) {
      baseXp = tier == LevelTier.mudah ? 50 : (tier == LevelTier.sedang ? 100 : 150);
    } else if (scoreRatio >= 0.4) {
      baseXp = tier == LevelTier.mudah ? 25 : (tier == LevelTier.sedang ? 50 : 75);
    } else {
      baseXp = 0;
    }
    double multiplier = _streakMultiplier(currentStreak);
    return (baseXp * multiplier).round();
    ```
- **`app/lib/features/quiz/screens/quiz_screen.dart:233` (`_saveProgress`)**
  - Perubahan: Mengambil `tier` dari `levelModel.tier` dan `currentStreak` dari provider, lalu meneruskannya ke `ProgressLogic.computeXp`.
- **`app/lib/features/quiz/widgets/result_dialog.dart`**
  - Menampilkan detail XP: "Base XP: 100 | Streak Bonus: ×1.5 = 150 XP Total".

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**: `app/test/data/repositories/xp_tiering_test.dart` (9 kasus):
  1. `MudahPass`: Tier Mudah, score 0.8 → 50 XP.
  2. `MudahRemedial`: Tier Mudah, score 0.5 → 25 XP.
  3. `SedangPass`: Tier Sedang, score 0.8 → 100 XP.
  4. `SedangRemedial`: Tier Sedang, score 0.5 → 50 XP.
  5. `TinggiPass`: Tier Tinggi, score 0.8 → 150 XP.
  6. `TinggiRemedial`: Tier Tinggi, score 0.5 → 75 XP.
  7. `Streak7x`: Streak 7 hari → multiplier 1.5.
  8. `Streak30x`: Streak 30 hari → multiplier 2.0.
  9. `Streak60x`: Streak 60 hari → multiplier 2.5.
- **Existing Test Terdampak**:
  - `app/test/data/repositories/progress_logic_test.dart` (23 kasus):
    - Group `computeXp` (3 kasus lama: 100/50/0 flat) → **REWRITE** untuk tier-based.
    - Kasus baru: 9 kasus di atas.

## 6. Definition of Done (DoD)
- XP bertingkat dan bonus streak terhitung otomatis saat kuis diselesaikan.
- Data XP mahasiswa lama tidak terhapus (inkremental).

## 7. Blocker & Dependency
- Memerlukan informasi tier level dari Fitur #1 (Level Grouping).

## 8. Effort Estimate
- 2 jam (Logic + UI + Test Update).

## 9. Risk & Mitigasi
- **Risk**: Perubahan signature method `ProgressLogic.computeXp` memicu test gagal di `progress_logic_test.dart`.
- **Mitigasi**: Memperbarui seluruh unit test terkait secara bersamaan dalam satu commit.