# PRD — KODIRA

Product Requirement Document untuk aplikasi mobile KODIRA.

| Field         | Nilai                    |
| ------------- | ------------------------ |
| Nama Produk   | KODIRA                   |
| Versi Dokumen | 1.0                      |
| Tanggal       | 2026-10-16               |
| Status        | Draft                    |
| Pemilik       | Kelompok 3 — PTIK B 2024 |
| Target Rilis  | [TBD]                    |

---

## 1. Ringkasan Eksekutif

KODIRA adalah aplikasi mobile Android yang membantu mahasiswa JTIK
semester 1 membangun fondasi pemrograman melalui pendekatan gamifikasi,
AI Adaptive Mentor, dan Adaptive Quiz. Aplikasi ini dirancang untuk
mengurangi ketergantungan mahasiswa pada AI yang memberi jawaban langsung,
sekaligus menjaga motivasi belajar melalui sistem level yang terstruktur.

---

## 2. Latar Belakang

### 2.1 Masalah

1. **Fondasi coding mahasiswa lemah.** Banyak mahasiswa JTIK masuk kuliah
   tanpa dasar pemrograman yang kuat, sehingga kesulitan mengikuti materi
   Pemrograman Dasar.

2. **Motivasi mudah drop.** Belajar coding menuntut latihan berulang dan
   self-efficacy yang tinggi. Mahasiswa sering menyerah di tengah jalan.

3. **Ketergantungan pada AI.** Chatbot seperti ChatGPT memudahkan mahasiswa
   mendapat jawaban instan, tetapi mengurangi proses berpikir dan
   menimbulkan ketergantungan.

4. **Media belajar yang ada belum menyatu.** Platform seperti CodeCombat,
   SoloLearn, Mimo, dan NgodingSeru.com sudah ada, tetapi:
   - Belum menyatukan gamifikasi + AI adaptif + adaptive quiz
   - Tidak dirancang khusus untuk mahasiswa JTIK Indonesia
   - Tidak menyediakan adaptive feedback yang membatasi peran AI

### 2.2 Peluang

- Gamifikasi terbukti meningkatkan motivasi dan hasil belajar
  (Zhan et al., 2022; Tsai et al., 2024).
- AI adaptive learning dapat menyesuaikan materi, tingkat kesulitan,
  latihan, dan feedback dengan kemampuan pengguna
  (Katona & Gyonyoru, 2025).
- Aplikasi mobile memungkinkan belajar kapan saja dan di mana saja.

---

## 3. Visi & Misi

**Visi:**  
Menjadi media pembelajaran pemrograman yang membuat mahasiswa JTIK
belajar coding dengan cara yang menyenangkan, terstruktur, dan mandiri.

**Misi:**

1. Menyediakan materi pemrograman terstruktur dalam 50 level linier.
2. Menjaga motivasi belajar melalui gamifikasi (XP, level, badge, streak).
3. Memberikan bantuan AI yang membuat mahasiswa berpikir, bukan
   menggantikan proses berpikir.
4. Menyesuaikan tingkat soal dan feedback dengan kemampuan tiap mahasiswa.

---

## 4. Target Pengguna

### 4.1 Primary Persona

| Atribut        | Detail                                                    |
| -------------- | --------------------------------------------------------- |
| Nama           | Mahasiswa JTIK semester 1                                 |
| Usia           | 17–19 tahun                                               |
| Latar belakang | Fresh graduate SMA/SMK, sebagian belum pernah coding      |
| Perangkat      | Android mid-range                                         |
| Konteks        | Sedang mengambil mata kuliah Pemrograman Dasar            |
| Motivasi       | Lulus mata kuliah, bisa coding, tidak mau ketinggalan     |
| Frustrasi      | Materi abstrak, dosen terbatas, AI membuat ketergantungan |

### 4.2 Secondary Persona

| Atribut    | Detail                                                |
| ---------- | ----------------------------------------------------- |
| Nama       | Dosen pengampu Pemrograman Dasar                      |
| Kebutuhan  | Media pendukung belajar mandiri mahasiswa             |
| Ekspektasi | Bisa dipakai di luar jam kuliah, tidak menambah beban |

### 4.3 Target Awal

- **Satu kelas mahasiswa JTIK semester 1** untuk uji coba.
- **1 angkatan** untuk pengembangan lanjutan.

---

## 5. Problem Statement

> Mahasiswa JTIK semester 1 kesulitan membangun fondasi pemrograman
> karena materi abstrak, motivasi mudah drop, dan AI yang mereka pakai
> memberi jawaban instan tanpa membangun pemahaman. Di sisi lain,
> media belajar yang ada belum menyatukan gamifikasi, AI adaptif, dan
> adaptive quiz dalam satu aplikasi mobile yang sesuai konteks JTIK.

---

## 6. Solusi

KODIRA menyediakan tiga pilar utama:

### 6.1 Gamifikasi

Elemen:

- **XP** — poin pengalaman dari jawaban benar dan menyelesaikan level
- **Level** — 50 level linier, satu level satu topik mikro
- **Badge** — prestasi khusus (streak, master topik, dll)
- **Streak** — keberlanjutan belajar
- **Achievement** — pencapaian jangka panjang

**Filosofi:** Gamifikasi untuk mendukung tujuan belajar dan rasa kompetensi,
bukan sekadar hiburan.

### 6.2 AI Adaptive Mentor

- Memberi **hint bertahap level 1–3**, bukan jawaban akhir
- **Satu arah** — user tidak bisa chat bebas dengan AI
- Bisa diminta di **Materi, Latihan, dan Kuis**
- Muncul otomatis saat: user minta, stuck > 120 detik, atau salah ≥ 3 kali
- Output AI divalidasi **guardrail** (sintaks, test case, rubrik, batasan materi)

**Filosofi:** AI membuat mahasiswa berpikir, bukan berpikir untuk mahasiswa.

### 6.3 Adaptive Quiz

- Menyesuaikan tingkat soal berdasarkan **riwayat kemampuan**
- Memuat **soal level saat ini + soal ulasan level sebelumnya**
- Soal **dibuat AI** berdasarkan parameter sistem, bukan template siap pakai
- Mastery dinilai 3 tingkat:
  - **M ≥ 70%** → lulus, buka level berikutnya, XP masuk
  - **40% ≤ M < 70%** → remedial topik itu saja, tanpa lock
  - **M < 40%** → lock (hanya level > 10), remedial level asal, XP ditahan

---

## 7. Fitur (MoSCoW)

### 7.1 Must Have (MVP)

| Fitur                 | Deskripsi                                              |
| --------------------- | ------------------------------------------------------ |
| Login NIM             | Autentikasi dengan NIM mahasiswa                       |
| Peta Level            | 50 level linier dengan status (selesai/aktif/terkunci) |
| Materi                | Teks, slide, code snippet per level                    |
| Latihan Drag & Drop   | Menyusun token kode                                    |
| Latihan Coding Manual | Editor kode sederhana                                  |
| Kuis Adaptif          | Pilihan ganda, isian, coding challenge                 |
| AI Hint               | Hint bertahap 1–3, satu arah                           |
| Adaptive Engine       | Mastery tracking, error pattern, level locking         |
| XP & Level            | Sistem gamifikasi dasar                                |
| Progress & Riwayat    | Progres belajar, riwayat nilai                         |
| Rekomendasi Materi    | Rekomendasi level berikutnya                           |

### 7.2 Should Have

| Fitur                | Deskripsi                                    |
| -------------------- | -------------------------------------------- |
| Badge                | Prestasi khusus                              |
| Streak               | Keberlanjutan belajar harian                 |
| Achievement          | Pencapaian jangka panjang                    |
| Code Runner          | Submit kode C++/Java, jalankan, lihat output |
| Feedback Terstruktur | Penjelasan AI setelah submit                 |

### 7.3 Could Have

| Fitur       | Deskripsi                                         |
| ----------- | ------------------------------------------------- |
| Coin        | Mata uang virtual                                 |
| Avatar      | Kustomisasi profil                                |
| Quest       | Tantangan mingguan                                |
| Leaderboard | Peringkat antar mahasiswa (opsional, tidak wajib) |
| CMS Admin   | Upload materi & soal                              |

### 7.4 Won't Have (Versi Ini)

| Fitur           | Alasan                            |
| --------------- | --------------------------------- |
| Dashboard Dosen | Fokus ke mahasiswa dulu           |
| Forum Diskusi   | Di luar scope                     |
| Chat AI Bebas   | Melanggar filosofi "AI satu arah" |
| Offline Mode    | Butuh server untuk AI & validasi  |
| iOS             | Fokus Android dulu                |

---

## 8. User Stories

### 8.1 Onboarding & Autentikasi

- Sebagai mahasiswa, saya ingin login dengan NIM agar bisa mengakses
  materi yang sesuai dengan kelas saya.
- Sebagai mahasiswa, saya ingin melihat halaman utama setelah login
  agar tahu posisi belajar saya.

### 8.2 Belajar

- Sebagai mahasiswa, saya ingin membaca materi per level agar bisa
  memahami konsep dasar sebelum latihan.
- Sebagai mahasiswa, saya ingin melihat code snippet agar bisa melihat
  contoh kode nyata.
- Sebagai mahasiswa, saya ingin minta hint saat stuck agar bisa lanjut
  tanpa langsung melihat jawaban.

### 8.3 Latihan & Kuis

- Sebagai mahasiswa, saya ingin mengerjakan latihan drag & drop agar
  bisa melatih pemahaman tanpa harus menulis kode dari nol.
- Sebagai mahasiswa, saya ingin mengerjakan kuis adaptif agar soal
  sesuai kemampuan saya.
- Sebagai mahasiswa, saya ingin menerima feedback setelah submit agar
  tahu di mana kesalahan saya.

### 8.4 Adaptive & Remedial

- Sebagai mahasiswa, saya ingin tahu topik mana yang lemah agar bisa
  memperbaikinya.
- Sebagai mahasiswa, saya ingin level terkunci jika saya salah fatal
  agar saya benar-benar paham sebelum lanjut.
- Sebagai mahasiswa, saya ingin remedi topik tertentu tanpa mengulang
  semua level agar tidak membuang waktu.

### 8.5 Gamifikasi

- Sebagai mahasiswa, saya ingin mendapat XP setiap jawaban benar agar
  ada rasa kemajuan.
- Sebagai mahasiswa, saya ingin melihat badge dan achievement agar
  termotivasi.
- Sebagai mahasiswa, saya ingin melihat streak agar termotivasi
  belajar rutin.

### 8.6 Profil & Progress

- Sebagai mahasiswa, saya ingin melihat mastery per topik agar tahu
  kekuatan dan kelemahan saya.
- Sebagai mahasiswa, saya ingin melihat riwayat level agar bisa
  melacak perkembangan.

---

## 9. User Flow Utama

```
Login (NIM)
    ↓
HOME (Peta Level)
    ↓
Pilih Level
    ↓
Materi → Latihan → Kuis Adaptif
    ↓
Analisis Performa
    ↓
Keputusan:
  ├─ M ≥ 70%    → Buka level berikutnya + XP
  ├─ 40–69%     → Remedial topik ini, tanpa lock
  └─ < 40%      → Jika level > 10: lock + remedial level asal
    ↓
Kembali ke HOME
```

---

## 10. Success Metrics

### 10.1 Metrik Kelayakan

| Metrik                       | Target |
| ---------------------------- | ------ |
| Skor validasi ahli materi    | > 80%  |
| Skor validasi ahli media     | > 80%  |
| System Usability Scale (SUS) | > 70   |
| Skor kepuasan pengguna       | > 80%  |

### 10.2 Metrik Efektivitas

| Metrik                             | Target                |
| ---------------------------------- | --------------------- |
| Peningkatan motivasi (pre vs post) | Signifikan (p < 0.05) |
| Learning gain (N-gain)             | Sedang atau tinggi    |
| Tingkat penyelesaian level         | > 60%                 |
| Engagement (waktu belajar)         | > 30 menit per sesi   |

### 10.3 Metrik Teknis

| Metrik                       | Target    |
| ---------------------------- | --------- |
| Waktu respons AI             | < 3 detik |
| Waktu load level             | < 2 detik |
| Crash rate                   | < 1%      |
| Coverage unit test (Phase 4) | [TBD]     |

---

## 11. Batasan & Asumsi

### 11.1 Batasan

- **Platform:** Android (bukan iOS)
- **Koneksi:** Online (butuh server untuk AI & validasi)
- **Bahasa:** C++ dan Java
- **Jumlah level versi awal:** 50
- **AI:** Menggunakan API berbayar (sudah ada API gratis untuk testing)
- **Data:** Disimpan lokal di HP, jawaban dihapus setelah dinilai,
  ringkasan mastery disimpan

### 11.2 Asumsi

- Mahasiswa JTIK semester 1 punya HP Android
- Koneksi internet tersedia saat menggunakan aplikasi
- Kampus menyediakan verifikasi NIM (via API atau manual)
- Dosen mendukung penggunaan aplikasi di luar jam kuliah

### 11.3 Risiko Utama

| Risiko                  | Mitigasi                                          |
| ----------------------- | ------------------------------------------------- |
| AI API biaya membengkak | Pakai model ringan, batasi token, cache respons   |
| AI jawaban tidak akurat | Guardrail: validasi sintaks, test case, rubrik    |
| Privasi data mahasiswa  | Jawaban dihapus, hanya ringkasan mastery disimpan |
| Code runner berat di HP | Pakai API eksternal (Judge0/Piston)               |
| Mahasiswa bosan         | Gamifikasi: XP, level, badge, streak              |
| Scope creep             | Disiplin MoSCoW, review per fase                  |

---

## 12. Tech Stack (High-Level)

Detail teknis ada di `docs/03-architecture.md`. Ringkas:

| Layer       | Kandidat                                         |
| ----------- | ------------------------------------------------ |
| Mobile      | Flutter atau React Native                        |
| Backend     | [TBD] — Firebase, Supabase, atau lainnya         |
| Database    | [TBD]                                            |
| AI          | API berbayar (sudah ada free tier untuk testing) |
| Code Runner | Judge0 atau Piston                               |
| Auth        | NIM (verifikasi ke kampus)                       |

---

## 13. Roadmap Rilis

Mengikuti `docs/00-phases.md`:

| Phase | Deliverable                        | Status            |
| ----- | ---------------------------------- | ----------------- |
| 0     | Foundation (docs, konvensi, tools) | Sedang dikerjakan |
| 1     | Design System                      | Belum             |
| 2     | UI Design                          | Belum             |
| 3     | Architecture                       | Belum             |
| 4     | MVP Development                    | Belum             |
| 5     | AI Integration                     | Belum             |
| 6     | Testing & Evaluation               | Belum             |
| 7     | Documentation & Presentation       | Belum             |

---

## 14. Keputusan yang Masih Diperlukan

- [ ] Tech stack final (Flutter vs React Native)
- [ ] Backend & database
- [ ] AI provider (OpenAI, Gemini, Claude, atau lainnya)
- [ ] Code runner (Judge0, Piston, atau buat sendiri)
- [ ] Jumlah level untuk MVP (5, 10, atau 15)
- [ ] Target coverage unit test
- [ ] Metode verifikasi NIM ke kampus

---

## 15. Referensi

- Tsai et al. (2024) — GAME model, self-efficacy
- Zhan et al. (2022) — Gamifikasi dalam pemrograman
- Dwiantoro et al. (2025) — AI dalam pendidikan pemrograman
- Groothuijsen et al. (2024) — Ketergantungan AI
- Akçapınar & Sidan (2024) — AI programming assistant
- Katona & Gyonyoru (2025) — AI adaptive learning
- Grey & Gordon (2023) — Gamified programming tutor
- Maryono et al. (2025) — NgodingSeru.com
- Mayer (2021) — CTML
- Daryanto (2016), Arsyad (2019) — Media pembelajaran

Daftar lengkap: lihat `artikel belum selesai uts.docx` bagian Daftar Pustaka.

---

## 16. Update Log

| Tanggal    | Perubahan         |
| ---------- | ----------------- |
| 2026-10-16 | Draft awal dibuat |
