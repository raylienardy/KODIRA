# 02E-ADMIN-USER-FLOW.md — User Flow Admin Panel KODIRA

## 1. Konteks

Admin Panel KODIRA dirancang untuk memfasilitasi peran pengajar (Dosen/Guru) dalam mengelola ekosistem pembelajaran pemrograman dasar secara otonom. Dokumen ini mendefinisikan alur pengguna (user flow) dari hulu ke hilir, mulai dari pendaftaran akun pengajar hingga proses pemantauan analitik mahasiswa yang kompleks. Spesifikasi ini menjadi acuan mutlak bagi implementasi Fase 3B untuk memastikan pengalaman pengguna yang logis, efisien, dan bebas hambatan.

## 2. Aktor & Peran

- **Teacher (Dosen/Guru)**: Pengguna utama admin panel. Memiliki otoritas penuh atas kelas, materi, dan data mahasiswa di kelasnya.
- **Student (Mahasiswa)**: Pengguna aplikasi mobile yang data perkembangannya dikonsumsi oleh admin panel.
- **System Admin (JTIK Admin)**: Peran super-user (backend) yang memvalidasi antrean pendaftaran dosen di luar domain UB.

## 3. Detail Alur Pengguna (User Flow)

### 3.1 Registrasi & Autentikasi Pengajar

Tujuan: Memastikan hanya pengajar sah yang dapat mengakses data mahasiswa.

1. **Landing / Login**: User masuk ke `admin.kodira.app`. Jika belum login, diarahkan ke halaman login.
2. **Registrasi**:
   - User memasukkan Nama, Email, NIP/NIDN, dan Password.
   - **Logika Verifikasi Domain**:
     - Jika email berakhiran `@ub.ac.id`, akun otomatis aktif (**Auto-Approve**).
     - Jika domain lain, akun masuk ke status `pending_verification`. User melihat pesan: "Akun Anda sedang ditinjau oleh admin JTIK".
3. **Login**: Setelah terverifikasi, user login menggunakan email dan password. Sesi disimpan secara aman di browser cookie via Supabase Auth.

### 3.2 Manajemen Kelas (The Hub)

Tujuan: Membuat wadah bagi kelompok belajar mahasiswa.

1. **Halaman /classes**: Menampilkan grid/list kelas yang diajar.
2. **Create Class**:
   - Klik button "+ Kelas Baru".
   - Mengisi Nama Kelas (contoh: "Pemrograman Dasar A"), Tahun Ajaran, dan Deskripsi.
   - Sistem men-generate **6-Character Join Code** (contoh: `KOD123`) yang bersifat unik.
3. **Class Detail**: Klik pada kelas untuk masuk ke dashboard spesifik kelas tersebut. Dashboard ini terbagi menjadi 3 tab utama: **Students**, **Materials**, dan **Analytics**.

### 3.3 Pengelolaan Mahasiswa (Student Management)

Tujuan: Administrasi akun dan akses mahasiswa ke kelas.

1. **Add Student (Manual)**: Teacher memasukkan NIM dan Nama Mahasiswa secara manual.
2. **Bulk Import (CSV)**:
   - Teacher mengunggah file `.csv` berisi daftar NIM dan Nama.
   - Sistem memvalidasi format NIM (13 digit) dan mengecek duplikasi.
   - Sistem membuat akun mahasiswa (jika belum ada) dan mendaftarkannya ke kelas tersebut secara otomatis.
3. **Reset Password**: Jika mahasiswa lupa password, Teacher dapat menekan tombol "Reset" di baris tabel mahasiswa. Sistem akan menghasilkan password sementara yang harus diberikan secara manual ke mahasiswa.
4. **Remove Student**: Mengeluarkan mahasiswa dari kelas tanpa menghapus data progress global mereka.

### 3.4 Produksi Materi Berbasis AI (Content Pipeline)

Tujuan: Transformasi dokumen statis menjadi materi interaktif di mobile.

1. **Upload PDF**: Di tab **Materials**, teacher mengunggah file PDF modul perkuliahan (maks. 10MB).
2. **AI Parsing (Edge Function)**:
   - Sistem mengirimkan PDF ke Supabase Storage.
   - Edge Function (via Groq/OpenAI) memecah bab-bab dalam PDF menjadi unit-unit pembelajaran.
   - Untuk setiap bab, AI men-generate: 5 Slide Materi, 5 Latihan Drag-and-Drop, dan 3 Soal Kuis Pilihan Ganda.
3. **Review & Edit**:
   - Hasil parse muncul sebagai daftar "Draft Level".
   - Teacher mengklik level untuk melihat dan mengedit konten yang dihasilkan AI (karena AI bisa halusinasi).
   - Teacher dapat mengubah teks, mengganti potongan kode C++/Java, atau menambahkan penjelasan tambahan.
4. **Publishing**: Setelah disetujui, teacher menekan "Publish". Level tersebut seketika muncul di aplikasi mobile mahasiswa yang terdaftar di kelas tersebut.

### 3.5 Pemantauan Analitik (Monitoring)

Tujuan: Mengidentifikasi mahasiswa yang kesulitan secara dini.

1. **Class Analytics**:
   - Grafik garis (Line Chart) menunjukkan rata-rata progres kelas setiap minggu.
   - Tabel "Topik Tersulit": Menampilkan topik (contoh: "Pointer", "Looping") dengan tingkat kesalahan tertinggi berdasarkan data `user_answers`.
2. **Student Progress**:
   - Teacher dapat mengklik nama mahasiswa untuk melihat detail progres per level.
   - Menampilkan statistik Mastery (Akurasi, Konsistensi, Waktu) milik mahasiswa tersebut.
3. **Early Warning System**: Daftar mahasiswa yang tidak aktif selama lebih dari 7 hari atau memiliki skor mastery di bawah 40% (Remedial status) diberi highlight warna oranye/merah.

## 4. Alur Mahasiswa (Mobile - Fitur Baru)

Walaupun fokus pada admin, ada alur baru di sisi mobile untuk mendukung multi-kelas:

1. **Join Class**: Di halaman profil mobile, mahasiswa menekan "Join Kelas" dan memasukkan kode 6 karakter dari dosen.
2. **Primary Class**: Mahasiswa dapat mengikuti banyak kelas, namun harus memilih satu sebagai "Primary Class". Level yang muncul di beranda utama adalah level dari Primary Class ini.
3. **Switching Class**: Mahasiswa dapat berganti Primary Class kapan saja melalui menu pengaturan kelas di mobile.

## 5. Diagram Alir Data (Data Flow)

```
[Teacher] ───(Upload PDF)───▶ [Supabase Storage]
                                      │
                                (Webhook Trigger)
                                      ▼
[Groq/AI] ◀──(Prompting)─── [Edge Function] ───(Parsed JSON)──▶ [DB Levels]
                                                                    │
                                                              (Teacher Review)
                                                                    │
[Student Mobile] ◀──(Subscription/Sync)─── [DB Levels Published] ◀──┘
```

## 6. Inventori Layar (Screen Inventory)

| Kode | Nama Layar | Deskripsi Singkat |
|---|---|---|
| AD-01 | Login | Autentikasi pengajar |
| AD-02 | Register | Pendaftaran dengan validasi NIDN/Domain |
| AD-03 | Dashboard | Ringkasan statistik semua kelas |
| AD-04 | Class List | Daftar grid kelas aktif |
| AD-05 | Class Detail | Pusat kendali per kelas (Tabs: Students, Materials, Analytics) |
| AD-06 | Material Creator | Upload PDF & Review hasil generate AI |
| AD-07 | Student Profile View | Detail statistik individu mahasiswa |
| AD-08 | Settings | Profil pengajar & preferensi notifikasi |

## 7. Penanganan Kasus Khusus (Edge Cases)

- **AI Timeout**: Jika parsing PDF memakan waktu lebih dari 60 detik, sistem akan menjalankan background job dan memberi notifikasi "Materi sedang diproses, silakan cek kembali dalam 2 menit".
- **Join Code Clash**: Walaupun probabilitas rendah, sistem akan melakukan pengecekan duplikasi kode sebelum `INSERT` ke database.
- **NIM Duplication**: Jika mahasiswa sudah terdaftar di sistem KODIRA melalui kelas dosen lain, sistem hanya akan menambahkan relasi `enrollment` tanpa membuat akun auth baru.
- **Concurrent Editing**: Jika dua pengajar (co-teaching) mengedit level yang sama, sistem akan menggunakan strategi *Last-Write-Wins* dengan peringatan visual jika ada perubahan terbaru dari user lain.

## 8. Definition of Done (DoD)

- [ ] Seluruh alur pendaftaran dosen hingga publikasi materi telah teruji secara logika.
- [ ] Integrasi antara database `users`, `classes`, dan `levels` didefinisikan dengan relasi yang benar (M:N).
- [ ] Alur penanganan error (AI failure, Auth error) sudah didokumentasikan.
- [ ] Mahasiswa dapat bergabung ke kelas via kode dan melihat materi yang relevan di mobile.
- [ ] Data analitik yang ditampilkan di admin panel akurat dan diambil dari tabel `user_progress` serta `user_answers`.

## 9. Blocker & Ketergantungan

- **Blocker**: Memerlukan penyelesaian migrasi database multi-kelas (Fitur #9).
- **Dependency**: Keberhasilan Edge Function dalam memparsing PDF secara konsisten sangat krusial bagi modul Material Creator.

## 10. Estimasi Waktu (Fase 3B)

- Implementasi Frontend Admin (Next.js + UI): 12 Jam.
- Integrasi Supabase & AI Pipeline: 10 Jam.
- Testing & Perbaikan Bug: 5 Jam.
- **Total: 27 Jam.**
