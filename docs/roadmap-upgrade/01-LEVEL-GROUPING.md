# 01-LEVEL-GROUPING.md — Fitur #1: Level Grouping (3 Tier)

## 1. Konteks
Dosen pengampu mata kuliah Pemrograman Dasar (JTIK semester 1) menginginkan level pembelajaran C++ dan Java yang saat ini disajikan dalam bentuk daftar linear flat (1 sampai 50) dikelompokkan ke dalam kategori tingkat kesulitan. Hal ini bertujuan untuk memberikan peta jalan belajar yang lebih terstruktur dan mengurangi kelelahan kognitif mahasiswa pemula.

## 2. Scope
- **Fase 1**: Implementasi logika pengelompokan berbasis hardcoded `level_number` langsung di sisi aplikasi Flutter.
- **Fase 3B**: Pemindahan konfigurasi tiering ke database Supabase agar dosen dapat mengubah rentang level dan kriteria tier secara dinamis melalui Admin Panel Web.

## 3. Spec Detail & Spesifikasi Teknis
- **Mapping Tiering Berbasis Nomor Level**:
  - **Level Mudah**: `level_number` 1 s/d 15 (Fokus: pengenalan sintaks dasar, tipe data, operator, dan input/output).
  - **Level Sedang**: `level_number` 16 s/d 35 (Fokus: percabangan, perulangan, fungsi/method, dan array dasar).
  - **Level Tinggi**: `level_number` 36 s/d 50 (Fokus: pointer/referensi C++, exception handling Java, struktur data dasar, dan studi kasus logika).
- **Antarmuka Pengguna (UI)**:
  - Mengubah `HomeScreen` dari single `ListView.builder` flat menjadi 3 section collapsible menggunakan widget `ExpansionTile` atau list kustom dengan header section:
    - 🟢 "Level Mudah (1-15)"
    - 🟡 "Level Sedang (16-35)"
    - 🔴 "Level Tinggi (36-50)"
  - Indikator warna badge per tier untuk memudahkan identifikasi visual.

## 4. File yang Disentuh (File:Line & Snippet)
- **`app/lib/features/home/screens/home_screen.dart:110-180`**
  - Saat ini (baris 113): 
    ```dart
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return LevelCard(level: level);
      },
    );
    ```
  - Perubahan: Direfaktorkan untuk memecah list level menjadi tiga grup berdasarkan getter tier, masing-masing dibungkus dalam widget section kustom.
- **`app/lib/features/home/widgets/level_section.dart` (BARU)**
  - Widget kustom yang menangani status buka/tutup (collapse/expand) section serta merender kartu level di dalamnya.
- **`app/lib/data/models/level_model.dart:15`**
  - Penambahan getter penentu tier:
    ```dart
    Tier get tier {
      if (levelNumber <= 15) return Tier.mudah;
      if (levelNumber <= 35) return Tier.sedang;
      return Tier.tinggi;
    }
    ```

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**: `app/test/features/home/level_grouping_test.dart` (9 test cases):
  1. `computeTier(1) -> Tier.mudah`
  2. `computeTier(15) -> Tier.mudah`
  3. `computeTier(16) -> Tier.sedang`
  4. `computeTier(35) -> Tier.sedang`
  5. `computeTier(36) -> Tier.tinggi`
  6. `computeTier(50) -> Tier.tinggi`
  7. `EmptySectionHandling`: Memastikan section kosong tampil dengan placeholder yang benar.
  8. `ExpandCollapseState`: Memastikan status interaksi buka/tutup section stabil saat scroll.
  9. `AllLevelsAccounted`: Memastikan seluruh 50 level terpetakan tanpa ada level yang terlewat.
- **Existing Test Terdampak**:
  - `app/test/features/home/home_screen_test.dart` (~5 kasus uji widget): Memerlukan penyesuaian pencarian widget (`find.byType`) karena perubahan dari single list ke 3 section collapsible.

## 6. Definition of Done (DoD)
- Home Screen berhasil merender 3 section tier dengan warna badge yang sesuai.
- Fitur collapse/expand berfungsi mulus tanpa kehilangan state scroll.
- Seluruh 50 level dapat diakses melalui tier masing-masing.
- Unit test baru dan test existing lulus 100%.

## 7. Blocker & Dependency
- Tidak ada blocker. Fitur ini berdiri sendiri sebagai peningkatan antarmuka Fase 1.

## 8. Effort Estimate
- 10 jam pengerjaan (termasuk implementasi UI, refaktoring model, dan pembaruan test suite).

## 9. Risk & Mitigasi
- **Risk**: Terjadi flickering atau penundaan render saat provider `allLevelsProvider` melakukan pemuatan ulang data (cache invalidation).
- **Mitigasi**: Menerapkan caching state lokal di dalam widget section dan memastikan struktur tree tidak melakukan rebuild penuh yang tidak perlu.
