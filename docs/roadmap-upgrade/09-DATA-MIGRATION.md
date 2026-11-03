# Migrasi Data & Skema

## Konteks
Implementasi fitur multi-kelas (#2) dan leaderboard (#7) memerlukan perubahan skema database yang signifikan. Strategi migrasi yang dipilih adalah inkremental untuk memastikan data pengguna saat ini tidak terhapus.

## Scope
Skema baru untuk kelas dan relasi, penambahan kolom user, serta kebijakan RLS.

## Spec Detail
1. **Schema Tambahan**:
   - `CREATE TABLE classes (...)`
   - `CREATE TABLE class_teachers (...)`
   - `CREATE TABLE class_students (...)`
2. **Perubahan Tabel `users`**:
   - `ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'student';`
   - `ALTER TABLE users ADD COLUMN primary_class_id INT NULL REFERENCES classes(id);`
   - `ALTER TABLE users ADD COLUMN nidn TEXT NULL;`
3. **Policies**:
   - Penambahan RLS untuk keamanan data kelas.
   - Kebijakan baca global untuk leaderboard.

## Backfill
- Mengubah status role mahasiswa existing menjadi `student`.
- Membuat kelas dummy "PTIK B 2024" sebagai container untuk semua user existing.

## Test Cases
- Verify migrasi skema tidak merusak data progress.
- Verify kebijakan RLS kelas membatasi akses data antar kelas.

## Definition of Done
- Database migrasi sukses (0 error).
- Data user existing tetap valid dan dapat mengakses materi level.

## Blocker / Dependency
- Tidak ada.

## Effort Estimate
- 2 jam (migration) + 30 menit (test).

## Risk
- Kegagalan migrasi di database produksi. Mitigasi: melakukan backup database sebelum menjalankan migrasi dan menyediakan script rollback (drop table/column).
