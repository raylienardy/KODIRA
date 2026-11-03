# Fitur #1 — Level Grouping

## Konteks
Dosen pengampu menginginkan level pembelajaran yang saat ini ditampilkan dalam daftar flat (1-50) dikelompokkan berdasarkan tingkat kesulitan untuk memberikan pengalaman belajar yang lebih terstruktur.

## Scope
- Fase 1: Implementasi logic grouping hardcoded berdasarkan `level_number` di sisi Flutter.
- Fase 3B: Migrasi konfigurasi ke database agar dosen bisa mengubah pengelompokan via Admin Panel.

## Spec Detail
- **Mapping Tiering**:
  - Mudah: Level 1-15
  - Sedang: Level 16-35
  - Tinggi: Level 36-50
- **UI**: 3 section collapsible di `HomeScreen` menggunakan `ExpansionTile` atau widget kustom dengan header: "Level Mudah (1-15)", "Level Sedang (16-35)", "Level Tinggi (36-50)".
- **Visual**: Badge tiering berwarna (Hijau untuk Mudah, Kuning untuk Sedang, Merah untuk Tinggi).
- **Fase 3**: Tabel `level_groupings` di database dengan kolom `tier`, `min_level`, `max_level`.

## File yang Disentuh
- `app/lib/features/home/screens/home_screen.dart` (Refactor `build` method untuk render 3 list).
- `app/lib/features/home/widgets/level_section.dart` (BARU: Widget collapsible berisi list level).
- `app/lib/data/models/level_model.dart` (Tambah getter `tier` berbasis `level_number`).

## Test Cases
- **Grouping Logic**: Verify `level_number` 1 → Mudah, 16 → Sedang, 36 → Tinggi.
- **Empty Section**: Tampilan saat tier tertentu tidak memiliki level (handle dengan pesan kosong).
- **Expand/Collapse**: Verify state buka/tutup section berfungsi stabil.
- **Data Integrity**: Verify total level di-render tetap 50, tidak ada duplikasi atau level hilang.

## Definition of Done
- Home Screen menampilkan 3 section yang dapat dicolapse.
- Warna badge indikator tier tampil dengan benar.
- Semua 50 level dapat diakses pengguna melalui tier masing-masing.

## Blocker / Dependency
- Tidak ada. Fitur ini bersifat UI-centric pada Fase 1.

## Effort Estimate
- 10 jam (termasuk unit test dan UI polishing).

## Risk
- Flickering pada list saat provider `allLevelsProvider` mengalami cache invalidation. Mitigasi: implementasi state management yang efisien pada `LevelProvider`.
