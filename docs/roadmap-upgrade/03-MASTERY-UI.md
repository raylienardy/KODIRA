# Fitur #3 — Mastery UI Breakdown

## Konteks
Saat ini mahasiswa seringkali bingung melihat skor penguasaan (misal 85%) padahal mereka merasa sudah menjawab semua soal dengan benar. Hal ini dikarenakan adanya komponen waktu dan konsistensi dalam formula `AdaptiveEngine`.

## Scope
Transparansi formula mastery kepada pengguna melalui antarmuka breakdown detail.

## Spec Detail
- **Trigger**: Menambahkan fungsi `onTap` pada mastery bar di halaman profil mahasiswa.
- **Antarmuka**: Menampilkan dialog bottom sheet yang memuat persentase breakdown:
  - **A (Akurasi)**: Berdasarkan persentase jawaban benar.
  - **C (Konsistensi)**: Berdasarkan riwayat pengerjaan sebelumnya.
  - **E (Error Rate)**: Berdasarkan jenis kesalahan (Sintaks/Logika).
  - **Tn (Time Taken)**: Berdasarkan kecepatan pengerjaan dibandingkan batas waktu.
- **Formula (Informasi)**: `M = 0.45A + 0.25C + 0.20(1-E) + 0.10(1-Tn)`.
- **Tips**: Memberikan instruksi "Untuk mencapai 100%: Kerjakan lebih cepat, ulangi kuis tanpa bantuan hint, dan pertahankan akurasi tinggi di level berikutnya."

## File yang Disentuh
- `app/lib/features/profile/widgets/mastery_section.dart` (Tambahkan `onTap` event).
- `app/lib/features/profile/widgets/mastery_breakdown_sheet.dart` (BARU: Widget dialog breakdown).
- `app/lib/features/adaptive/services/adaptive_engine.dart` (Opsional: Mengekspos nilai komponen internal jika belum publik).

## Test Cases
- Verify dialog muncul saat mastery bar ditekan.
- Verify kalkulasi yang ditampilkan di dialog sesuai dengan nilai mastery utama.
- Verify tombol tutup (dismiss) berfungsi.

## Definition of Done
- Mahasiswa dapat melihat detail penyebab skor mastery mereka tidak mencapai 100%.

## Blocker / Dependency
- Tidak ada.

## Effort Estimate
- 3 jam.

## Risk
- Kebingungan pengguna terhadap kompleksitas istilah teknis (Akurasi/Konsistensi). Mitigasi: menggunakan label bahasa Indonesia yang lebih sederhana (Contoh: "Ketepatan Jawaban", "Kecepatan Pengerjaan").
