# Fitur #4 — Manajemen Password & Keamanan Akun

## 1. Konteks
Keamanan akun merupakan prioritas utama dalam sistem pembelajaran digital. Mahasiswa memerlukan fasilitas mandiri untuk mengubah kata sandi mereka di aplikasi mobile, dan dosen memerlukan wewenang administratif untuk mengatur ulang kata sandi mahasiswa yang lupa atau terkunci di web admin.

## 2. Scope
Implementasi fitur Ganti Password di aplikasi mobile (Fase 1) dan Reset Password oleh Dosen di Web Admin (Fase 3B).

## 3. Spec Detail & Spesifikasi Teknis
### Fitur #4A (Mobile - Ganti Password)
- **Menu Navigasi**: Menu *"Ganti Password"* di dalam navigasi *Sidebar Drawer* (menggantikan tombol profil lama).
- **Layar Baru**: `ChangePasswordScreen` (`app/lib/features/profile/screens/change_password_screen.dart`).
- **Form Input**:\n  - Password Lama (wajib diisi dan diverifikasi).
  - Password Baru (minimal 6 karakter).
  - Konfirmasi Password Baru (harus sama dengan password baru).
- **Strength Meter (Indikator Kekuatan Password)**:
  - **Lemah**: ≤ 6 karakter.
  - **Sedang**: 8+ karakter dengan kombinasi angka & huruf (RegExp: `^(?=.*[0-9])(?=.*[a-zA-Z]).{8,}$`).
  - **Kuat**: 10+ karakter dengan kombinasi angka, huruf, dan simbol khusus (RegExp: `^(?=.*[0-9])(?=.*[a-zA-Z])(?=.*[!@#$%^&*]).{10,}$`).
- **Validasi Backend & Supabase Auth**:
  - Verifikasi kecocokan password lama menggunakan metode `reauthenticate` atau `signInWithPassword`.
  - Pembaruan password baru menggunakan `supabaseClient.auth.updateUser(UserAttributes(password: newPassword))`.

### Fitur #4B (Web - Reset Password)
- Terintegrasi di halaman *Student Management* pada Admin Web.
- Tombol *"Reset Password"* pada setiap baris data mahasiswa.
- Sistem menghasilkan password sementara, mencatat log aktivitas admin, dan mengirimkan notifikasi kepada mahasiswa.

## 4. File yang Disentuh (File:Line & Snippet)
- **`app/lib/features/auth/providers/auth_provider.dart`** (Penambahan method baru di repository):
  - `Future<void> updatePassword({required String newPassword})`:\n    ```dart
    await _client.auth.updateUser(supa.UserAttributes(password: newPassword));
    ```
  - `Future<void> reauthenticate({required String email, required String password})`:\n    ```dart
    await _client.auth.signInWithPassword(email: email, password: password);
    ```
- **`app/lib/features/profile/screens/change_password_screen.dart` (BARU)**.
- **`admin/src/app/(dashboard)/students/page.tsx`** (Trigger tombol reset password admin).

## 5. Test Cases & Skenario Pengujian
- **File Test Baru**: `app/test/features/auth/change_password_test.dart` (5 kasus uji):
  1. `ValidOldPassword`: Password lama benar → update password sukses.
  2. `InvalidOldPassword`: Password lama salah → menampilkan pesan error inline.
  3. `StrengthMeterWeak`: Input `"123456"` → indikator menampilkan label "Lemah".
  4. `StrengthMeterMedium`: Input `"Password123"` → indikator menampilkan label "Sedang".
  5. `StrengthMeterStrong`: Input `"Passw0rd!@#"` → indikator menampilkan label "Kuat".

## 6. Definition of Done (DoD)
- Mahasiswa dapat mengubah password mereka secara mandiri dari aplikasi mobile dengan validasi kekuatan password yang ketat.
- Dosen dapat mereset password mahasiswa dari panel admin web.

## 7. Blocker & Dependency
- Fitur #4B bergantung pada kesiapan infrastruktur Admin MVP (#2C).

## 8. Effort Estimate
- 2 jam (Mobile implementation) + 1 jam (Web admin implementation).

## 9. Risk & Mitigasi
- **Risk**: Mahasiswa lupa password lama sehingga terkunci dari aplikasi mobile.
- **Mitigasi**: Menyediakan petunjuk bantuan pada layar login untuk menghubungi dosen pengampu (admin) guna melakukan reset password melalui web admin.
