# Fitur #4 — Manajemen Password

## Konteks
Keamanan akun merupakan prioritas. Mahasiswa memerlukan fasilitas untuk mengubah kata sandi mereka, dan dosen memerlukan wewenang untuk mengatur ulang kata sandi mahasiswa yang lupa atau terkunci.

## Scope
Implementasi fitur Ganti Password di aplikasi mobile (Fase 1) dan Reset Password oleh Dosen di Web Admin (Fase 3B).

## Spec Detail
### Fitur #4A (Mobile - Ganti Password)
- **Menu**: Menu "Ganti Password" dalam navigasi sidebar drawer.
- **Form**: Input Password Lama, Password Baru (Minimal 6 karakter), Konfirmasi Password Baru.
- **Password Strength Meter**: Indikator kekuatan menggunakan RegExp:
  - **Lemah**: <= 6 karakter.
  - **Sedang**: 8+ karakter dengan kombinasi angka & huruf.
  - **Kuat**: 10+ karakter dengan kombinasi angka, huruf, dan simbol.
- **Validasi**: Verifikasi kecocokan password lama menggunakan metode `reauthenticate` Supabase Auth.

### Fitur #4B (Web - Reset Password)
- Antarmuka di Admin Web (Student List) untuk menyetel password baru bagi mahasiswa tertentu.
- Sistem akan menghasilkan password sementara yang kemudian harus diubah oleh mahasiswa saat login pertama kali (opsional).

## File yang Disentuh
- `app/lib/features/profile/screens/change_password_screen.dart` (BARU).
- `app/lib/features/auth/providers/auth_provider.dart` (Fungsi update password).
- `admin/src/app/(dashboard)/students/page.tsx` (Trigger reset password).

## Test Cases
- Verify password baru berhasil disimpan jika password lama benar.
- Verify strength meter berubah saat input password baru yang kompleks.
- Verify reset password dari admin web mengganti kredensial login mahasiswa.

## Definition of Done
- Mahasiswa dapat mengubah password mereka secara mandiri.
- Dosen dapat mereset password mahasiswa dari panel admin web.

## Blocker / Dependency
- Fitur #4B bergantung pada kesiapan Admin MVP (#2C).

## Effort Estimate
- 2 jam (Mobile) + 1 jam (Web).

## Risk
- Pengguna lupa password lama sehingga tidak bisa menggunakan fitur ganti password mobile. Mitigasi: menyediakan petunjuk untuk menghubungi dosen pengampu (admin) guna reset password.
