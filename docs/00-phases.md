# Roadmap Pengembangan KODIRA

## 1. Prinsip Kerja
- Fase = fondasi dulu, jangan lompat.
- Satu fase selesai sebelum lanjut.
- Setiap fase punya kriteria selesai yang jelas.
- Iterasi singkat bila temuan penting.

## 2. Daftar Fase
| No | Nama Fase | Fokus Utama |
|----|------------|-------------|
| 0 | Foundation | Setup docs, konvensi, tools |
| 1 | Design System | Warna, tipografi, komponen, DESIGN.md |
| 2 | UI Design | Mockup, wireframe, alur (Stitch AI) |
| 3 | Architecture | Tech stack, DB, API, strategi AI |
| 4 | MVP Development | Fitur inti tanpa AI |
| 5 | AI Integration | Mentor adaptif, quiz adaptif, guardrail |
| 6 | Testing & Evaluation | UAT, QA, metrik keberhasilan |
| 7 | Documentation & Presentation | Laporan, demo, proposal akademik |

## 3. Detail Setiap Fase
### Phase 0 – Foundation
- Tujuan: Siapkan pondasi kerja tim.
- Deliverable: docs/ terstruktur, repo init, CI lint, template README.
- Dependency: Tidak ada.
- Estimasi waktu: [TBD]
- Kriteria selesai: Repo ter‑init, semua folder ada, CI lulus.
- Risiko utama: Konflik konfigurasi CI, kurangnya standar penamaan.

### Phase 1 – Design System
- Tujuan: Definisikan identitas visual & komponen reusable.
- Deliverable: DESIGN.md, style guide, component library.
- Dependency: Phase 0.
- Estimasi waktu: [TBD]
- Kriteria selesai: Semua token warna, tipografi, komponen dasar terdokumentasi, contoh implementasi.
- Risiko utama: Inkonsistensi warna/tipografi, revisi berulang pada komponen.

### Phase 2 – UI Design
- Tujuan: Buat tampilan akhir berbasis design system.
- Deliverable: Mockup high‑fidelity, wireframe, flow diagram.
- Dependency: Phase 1.
- Estimasi waktu: [TBD]
- Kriteria selesai: Semua screen utama memiliki mockup, review UI oleh tim.
- Risiko utama: Kebutuhan revisi UI setelah prototyping, overload fitur visual.

### Phase 3 – Architecture
- Tujuan: Tentukan arsitektur teknis & strategi AI.
- Deliverable: Diagram arsitektur, spesifikasi DB, kontrak API, rencana AI (model, endpoint).
- Dependency: Phase 2.
- Estimasi waktu: [TBD]
- Kriteria selesai: Dokumen arsitektur disetujui, keputusan stack final.
- Risiko utama: Pilihan teknologi tidak kompatibel, under‑estimasi beban AI.

### Phase 4 – MVP Development
- Tujuan: Implementasi fitur inti tanpa AI.
- Deliverable: Modul level, gamifikasi dasar, navigasi, data lokal.
- Dependency: Phase 3.
- Estimasi waktu: [TBD]
- Kriteria selesai: Sejumlah level inti berfungsi [TBD], tes unit untuk modul inti [TBD].
- Risiko utama: Scope creep pada fitur inti, performa pada device rendah.

### Phase 5 – AI Integration
- Tujuan: Tambahkan mentor adaptif & quiz AI.
- Deliverable: Service AI, hint generator, adaptive quiz engine.
- Dependency: Phase 4.
- Estimasi waktu: [TBD]
- Kriteria selesai: AI response sesuai kebijakan guardrail, integrasi diuji di device.
- Risiko utama: Model AI tidak akurat, pelanggaran privasi data.

### Phase 6 – Testing & Evaluation
- Tujuan: Validasi kualitas & pencapaian KPI.
- Deliverable: Test plan, hasil UAT, laporan evaluasi (ADDIE – Implement & Evaluate).
- Dependency: Phase 5.
- Estimasi waktu: [TBD]
- Kriteria selesai: Semua test case lulus, skor mastery ≥70 % pada user pilot.
- Risiko utama: Bug tersembunyi muncul di produksi, metrik tidak mencerminkan realita penggunaan.

### Phase 7 – Documentation & Presentation
- Tujuan: Siapkan materi akhir proyek.
- Deliverable: Dokumen akhir (proposal, laporan), presentasi demo, video walkthrough.
- Dependency: Phase 6.
- Estimasi waktu: [TBD]
- Kriteria selesai: Semua dokumen selesai, demo siap dipresentasikan.
- Risiko utama: Dokumentasi tidak lengkap, deadline akademik ketat.

## 4. Mapping ke ADDIE
| Fase KODIRA | Tahap ADDIE |
|-------------|-------------|
| (Sebelum Phase 0) | Analysis — selesai di proposal |
| Phase 0-3 | Design |
| Phase 4-5 | Development |
| Phase 6 | Implementation & Evaluation |
| Phase 7 | Di luar siklus ADDIE (deliverable akademik) |

## 5. Aturan Transisi
- Selesai fase: Semua deliverable selesai, checklist “kriteria selesai” terpenuhi, dan sign‑off oleh kedua anggota tim.
- Review: Pertemuan singkat (30 menit) untuk verifikasi checklist.
- Rollback: Jika ada blocker kritis, tetap di fase tersebut sampai teratasi.
- Progress update: Setiap akhir minggu, update status di `docs/00-phases.md` (✔/✖).

## 6. Keputusan yang masih diperlukan
- Estimasi waktu tiap fase (hari/minggu).
- Nilai spesifik untuk kriteria selesai Phase 4 (jumlah level inti, persentase tes unit).
- Penetapan detail mitigasi risiko (opsional).