# Fitur #8 — Sistem Gelar (Title Progression)

## 1. Konteks
Memberikan pengakuan formal atas pencapaian jangka panjang mahasiswa melalui gelar akademik yang ditampilkan di profil dan leaderboard. Gelar ini berfungsi sebagai motivasi intrinsik bagi mahasiswa untuk menyelesaikan seluruh level C++ dan Java.

## 2. Scope
Katalog gelar progresif, mekanisme penganugerahan otomatis berdasarkan jumlah level yang diselesaikan per bahasa, dan integrasi tampilan di Profil & Leaderboard.

## 3. Spec Detail & Katalog Gelar
- **Rantai Gelar C++**:
  1. **Pemula** (Default, 0 level)
  2. **Pelajar C++** (5 level C++ selesai)
  3. **Ahli C++** (20 level C++ selesai)
  4. **Master C++** (35 level C++ selesai — seluruh level C++)

- **Rantai Gelar Java**:
  5. **Pelajar Java** (5 level Java selesai)
  6. **Master Java** (15 level Java selesai — seluruh level Java)

- **Gelar Ultimate**:
  7. **Grand Master** (50 level total selesai — C++ & Java)

- **Strategi Penyimpanan**: Menggunakan tabel existing `user_badges` dengan prefix kode `title_*` (contoh: `title_pelajar_cpp`, `title_grand_master`). Tidak memerlukan tabel baru karena struktur badge sudah mendukung kode unik per pengguna.

## 4. File yang Disentuh (File:Line & Pseudocode)
- **`app/lib/data/repositories/title_logic.dart` (BARU)**
  - **Pseudocode `computeMissingTitles`**:
    ```dart
    static Set<String> computeMissingTitles({
      required Set<String> existingTitleCodes,
      required int cppLevelsCompleted,
      required int javaLevelsCompleted,
    }) {
      final required = <String>{};
      // Rantai C++
      if (cppLevelsCompleted >= 5) required.add('title_pelajar_cpp');
      if (cppLevelsCompleted >= 20) required.add('title_ahli_cpp');
      if (cppLevelsCompleted >= 35) required.add('title_master_cpp');
      // Rantai Java
      if (javaLevelsCompleted >= 5) required.add('title_pelajar_java');
      if (javaLevelsCompleted >= 15) required.add('title_master_java');
      // Grand Master
      if (cppLevelsCompleted >= 35 && javaLevelsCompleted >= 15) {
        required.add('title_grand_master');
      }
      // Kembalikan hanya gelar yang belum dimiliki
      return required.difference(existingTitleCodes);
    }
    ```
- **`app/lib/features/profile/widgets/profile_header.dart:28`**
  - Tambahan rendering gelar aktif:
    ```dart
    // Ambil gelar tertinggi dari user_badges WHERE badge_code LIKE 'title_%'
    String activeTitle = TitleLogic.getHighestTitle(userBadges);
    Text(activeTitle, style: Theme.of(context).textTheme.titleMedium);
    ```
- **`app/lib/features/leaderboard/widgets/leaderboard_item.dart`**
  - Tampilkan ikon gelar di samping nama pengguna di leaderboard.

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**: `app/test/data/repositories/title_logic_test.dart` (8 kasus uji):
  1. `NoTitle`: 0 level C++ + 0 Java → kosong (Pemula default tidak disimpan).
  2. `PelajarCpp`: 5 level C++ → `title_pelajar_cpp`.
  3. `AhliCpp`: 20 level C++ → `title_ahli_cpp` + `title_pelajar_cpp`.
  4. `MasterCpp`: 35 level C++ → 3 gelar C++ lengkap.
  5. `PelajarJava`: 5 level Java → `title_pelajar_java`.
  6. `MasterJava`: 15 level Java → `title_master_java` + `title_pelajar_java`.
  7. `GrandMaster`: 35 C++ + 15 Java → semua 7 gelar.
  8. `NoDuplicateAward`: Memastikan gelar yang sudah dimiliki (sudah ada di `user_badges`) tidak dikembalikan ulang oleh `computeMissingTitles`.

- **Existing Test Terdampak**: `app/test/data/repositories/badge_logic_test.dart` (25 kasus) — **TIDAK BREAK** karena menggunakan tabel yang sama dengan prefix kode berbeda (`title_*` vs `streak_*`, `level_*`, `xp_*`).

## 6. Definition of Done (DoD)
- Mahasiswa memperoleh gelar secara otomatis dan langsung terlihat di profil serta leaderboard saat threshold level tercapai.
- Tidak ada konflik penyimpanan dengan sistem badge existing.

## 7. Blocker & Dependency
- Bergantung pada Fitur #1 (Level Grouping) untuk menentukan `level.language` (C++ vs Java) saat menghitung `cppLevelsCompleted` dan `javaLevelsCompleted`.

## 8. Effort Estimate
- 3 jam (Logic, UI Profile & Leaderboard, Unit Test).

## 9. Risk & Mitigasi
- **Risk**: Kebingungan visual jika gelar dan badge tampil berdekatan tanpa pemisahan yang jelas.
- **Mitigasi**: Desain visual yang membedakan — Gelar ditampilkan di header profil dan kolom nama leaderboard; Badge ditampilkan di grid "Katalog Lencana" terpisah.