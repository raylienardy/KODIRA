# Seed Data Mahasiswa

## Konteks
Untuk kebutuhan pengujian fitur Leaderboard dan Admin Panel, diperlukan data mahasiswa dummy yang sudah memiliki progress level yang bervariasi.

## Scope
Penyediaan script SQL untuk seeding data mahasiswa baru.

## Spec Detail
- **Target**: 5 mahasiswa dummy (NIM sequential, 2402095010101-105).
- **Struktur**:
  - Semua mahasiswa di-assign ke kelas "PTIK B 2024".
  - Progress level bervariasi dari 3 level sampai 20 level.
  - XP bervariasi (250 XP s/d 2000 XP) untuk simulasi leaderboard.
- **Script**: `app/supabase/seed-dummy-users.sql`.

## File yang Disentuh
- `app/supabase/seed-dummy-users.sql` (BARU).

## Test Cases
- Verify 5 user dummy berhasil terdaftar di database.
- Verify leaderboard menampilkan 7 user (5 dummy + 2 existing).

## Definition of Done
- Data siap digunakan untuk testing Leaderboard secara visual.

## Blocker / Dependency
- Bergantung pada keberhasilan migrasi tabel kelas (#2C).

## Effort Estimate
- 1 jam.

## Risk
- Duplikasi data saat script dijalankan berkali-kali. Mitigasi: gunakan `INSERT ... ON CONFLICT DO NOTHING` atau `WHERE NOT EXISTS`.
