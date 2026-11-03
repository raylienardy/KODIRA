# Fitur #6 — XP Bertingkat & Streak Multiplier

## Konteks
Sebelumnya, setiap level memberikan nilai XP tetap sebesar 100 XP. Hal ini tidak mencerminkan tingkat kesulitan materi (level dasar vs level mahir).

## Scope
Implementasi perolehan XP berbasis tier level dan pengali bonus streak harian.

## Spec Detail
- **Aturan XP Baru**:
  - **Mudah (Level 1-15)**: 50 XP (Lulus), 25 XP (Remedial), 0 XP (Gagal).
  - **Sedang (Level 16-35)**: 100 XP (Lulus), 50 XP (Remedial), 0 XP (Gagal).
  - **Tinggi (Level 36-50)**: 150 XP (Lulus), 75 XP (Remedial), 0 XP (Gagal).
- **Streak Multiplier**:
  - Hari ke-7: Pengali 1.5×
  - Hari ke-30: Pengali 2.0×
  - Hari ke-60+: Pengali 2.5×
- **Migration Strategy**: Inkremental. XP mahasiswa yang sudah ada (contoh: Ridho 150 XP) dipertahankan apa adanya. Level baru yang diselesaikan pasca-update akan menggunakan aturan XP bertingkat.

## File yang Disentuh
- `app/lib/data/repositories/progress_logic.dart` (Modifikasi logika kalkulasi XP).
- `app/lib/features/quiz/screens/quiz_screen.dart` (Mengirim parameter tier level ke fungsi simpan progress).
- `app/lib/features/quiz/widgets/result_dialog.dart` (Menampilkan perolehan XP termasuk bonus streak).

## Test Cases
- Verify perolehan XP level 1 adalah 50 XP.
- Verify perolehan XP level 20 adalah 100 XP.
- Verify perolehan XP level 40 adalah 150 XP.
- Verify bonus perkalian streak aktif pada hari ke-7 (×1.5).

## Definition of Done
- XP bertingkat dan bonus streak terhitung otomatis saat kuis diselesaikan.
- Data XP mahasiswa lama tidak terhapus (inkremental).

## Blocker / Dependency
- Memerlukan informasi tier level (#1).

## Effort Estimate
- 2 jam.

## Risk
- Perubahan signature method pada `ProgressLogic.computeXp` memicu test gagal. Mitigasi: memperbarui unit test terkait (`progress_logic_test.dart`).
