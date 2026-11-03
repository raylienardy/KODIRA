# Fitur #8 — Sistem Gelar (Title Progression)

## Konteks
Pemberian pengakuan atas pencapaian jangka panjang mahasiswa melalui gelar progresif di atas nama mereka.

## Scope
Katalog gelar dan mekanisme penganugerahan otomatis berdasarkan jumlah level yang diselesaikan per bahasa pemrograman (C++ atau Java).

## Spec Detail
- **Daftar Gelar (Progresif)**:
  - Pemula (0 level)
  - Pelajar C++ (5 level C++ selesai)
  - Ahli C++ (20 level C++ selesai)
  - Master C++ (35 level C++ selesai)
  - Pelajar Java (5 level Java selesai)
  - Master Java (15 level Java selesai)
  - Grand Master (50 level total selesai)
- **Tampilan**: Di bagian atas profil dan di samping nama pada leaderboard.
- **Implementasi**: Menggunakan logika `computeMissingTitles` dengan menyimpan kode title sebagai `badge_code` di tabel `user_badges` (reuse skema existing).

## File yang Disentuh
- `app/lib/data/repositories/title_logic.dart` (BARU: logika penentuan gelar).
- `app/lib/features/profile/widgets/profile_header.dart` (Tampilkan title di profil).
- `app/lib/features/leaderboard/widgets/leaderboard_item.dart` (Tampilkan title di leaderboard).

## Test Cases
- Verify mahasiswa dengan 5 level C++ secara otomatis mendapatkan gelar "Pelajar C++".
- Verify gelar baru muncul di profil dan leaderboard segera setelah kuis selesai.
- Verify gelar lama (contoh: Pemula) digantikan oleh gelar lebih tinggi saat threshold tercapai.

## Definition of Done
- Mahasiswa bangga dengan gelar mereka dan tampil di aplikasi.

## Blocker / Dependency
- Bergantung pada fitur Level Grouping (#1) untuk menghitung level berdasarkan topik/bahasa.

## Effort Estimate
- 3 jam.

## Risk
- Kebingungan mahasiswa jika gelar dan badge tumpang tindih. Mitigasi: desain visual yang membedakan penempatan gelar dan lencana badge agar tidak saling menggantikan fungsi.
