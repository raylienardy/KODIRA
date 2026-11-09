# Tentang KODIRA

Aplikasi pembelajaran pemrograman C++ & Java untuk mahasiswa JTIK.

---

### Section 1: Cara Naik Level

Setiap level di KODIRA mengikuti alur belajar yang konsisten:
1. Baca Materi — 5 slide materi interaktif yang menjelaskan konsep pemrograman dengan contoh kode.
2. Latihan (Exercise) — 5 soal drag & drop untuk menguji pemahaman sintaks dan logika.
3. Kuis (Quiz) — 3 soal pilihan ganda dengan timer 60 detik per soal.

Syarat Lulus: Skor kuis ≥ 70% untuk membuka level berikutnya.
- Skor 40–69% → Remedial (ulangi kuis dengan soal baru dari AI).
- Skor < 40% → Gagal (wajib pelajari ulang materi dari awal).

Kalau Anda mengerjakan kuis dengan skor < 70%, jangan khawatir — gunakan tombol 'Minta Hint AI' untuk pemahaman lebih dalam, lalu coba ulangi kuis.

---

### Section 2: Sistem XP

XP (Experience Points) adalah indikator progres belajar Anda.
- Level Mudah (1-15): 50 XP (Lulus), 25 XP (Remedial).
- Level Sedang (16-35): 100 XP (Lulus), 50 XP (Remedial).
- Level Tinggi (36-50): 150 XP (Lulus), 75 XP (Remedial).

Streak Multiplier (Bonus konsistensi harian):
- 7 hari berturut-turut: ×1.5
- 30 hari berturut-turut: ×2.0
- 60+ hari berturut-turut: ×2.5

Bonus streak diterapkan otomatis saat Anda menyelesaikan kuis.

---

### Section 3: Cara Hitung Mastery

Skor Mastery (0–100%) dihitung dari 4 komponen:
M = 0.45×A + 0.25×C + 0.20×(1−E) + 0.10×(1−Tn)

- A (Akurasi): Persentase jawaban benar (0–1).
- C (Konsistensi): Skor mastery tertinggi sebelumnya (0–1).
- E (Error Rate): 1 − A (semakin sedikit kesalahan, semakin tinggi skor).
- Tn (Time Normalized): Rata-rata waktu per soal dibagi batas waktu (semakin cepat, semakin tinggi skor).

Tips mencapai 100%:
- Jawab soal dengan benar (maksimalkan A).
- Kerjakan kuis lebih cepat tanpa menurunkan akurasi (minimalkan Tn).
- Lakukan kuis ulangan (mengisi C dari riwayat sebelumnya).

---

### Section 4: Streak & Badge

Streak: Hari aktif berturut-turut (minimal 1 kuis selesai).
- Streak putus jika tidak ada aktivitas > 24 jam.
- Badge Streak: 3 hari, 7 hari, 30 hari, 60 hari.

Badge Level: Disemat saat menyelesaikan level ke-5, 10, 25, 50.
Badge XP: Disemat saat total XP mencapai 100, 500, 1000, 2500.

---

### Section 5: Tips Belajar

1. Gunakan Hint AI — Bantu memahami logika soal tanpa memberi jawaban langsung.
2. Ulangi Kuis Remedial — Soal baru dari AI, peluang naikkan mastery.
3. Jaga Streak — Setidaknya 1 kuis per hari untuk bonus XP.
4. Fokus Mastery, bukan Hanya Lulus — Mastery tinggi = fondasi kuat untuk level lanjutan.

---

### Section 6: FAQ

Q: Lupa password, gimana?
A: Hubungi dosen pengampu untuk reset password via panel admin web.

Q: Kenapa mastery saya 85% padahal jawaban 100% benar?
A: Mastery dihitung dari Akurasi + Waktu + Konsistensi. Cepat & konsisten = 100%.

Q: Bisa pindah bahasa (C++ ↔ Java) di tengah jalan?
A: Bisa. Progress per bahasa terpisah. Pilih bahasa di awal level.

---

### Section 7: Kenapa Mastery Tidak Sampai 100%?

Mastery dihitung dari 4 komponen:
- **A (Akurasi)**: Persentase jawaban benar
- **C (Konsistensi)**: Mastery terbaik dari attempt sebelumnya
- **E (Error Rate)**: 1 - A
- **Tn (Waktu)**: Rata-rata waktu jawab per soal, dinormalisasi

Formula lengkap:

```
M = 0.45*A + 0.25*C + 0.20*(1-E) + 0.10*(1-Tn)
```

Karena E = 1 - A, formula dapat disederhanakan menjadi:

```
M = 0.65*A + 0.25*C + 0.10*(1-Tn)
```

**Catatan:** Mastery cap sekitar **96-99%** karena komponen waktu (Tn) punya bobot 10% yang tidak pernah sempurna - waktu jawab manusia minimum ~5 detik/soal, bukan 0 detik.

**Target realistis:** Lulus level butuh **>= 70%**. Topik dengan mastery **>= 95%** dianggap **sudah dikuasai (Mastered)** dan akan mendapat badge (check) di UI.

Tidak perlu mengejar angka sempurna - fokus pada pemahaman konsep.
