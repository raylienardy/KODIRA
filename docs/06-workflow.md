# Workflow — KODIRA

Panduan kerja dengan opencode untuk proyek KODIRA. Tujuan: hemat token,
terarah, tidak ngelantur.

| Field   | Nilai                            |
| ------- | -------------------------------- |
| Versi   | 1.0                              |
| Tanggal | 2026-10-16                       |
| Status  | Aktif                            |
| Basis   | `AGENTS.md`, `docs/00-phases.md` |

---

## 1. Prinsip Dasar

1. **Satu prompt, satu tugas.** Jangan gabung 5 tugas jadi 1 prompt.
2. **Konteks dulu, tugas kemudian.** Agent harus tahu "kenapa" sebelum "apa".
3. **Batasan eksplisit.** Sebutkan apa yang **tidak** boleh dilakukan.
4. **DoD (Definition of Done) jelas.** Agent harus tahu kapan berhenti.
5. **Review sebelum lanjut.** Jangan lanjut task berikutnya sebelum yang sekarang oke.
6. **Commit setiap task selesai.** History bersih, mudah rollback.

---

## 2. Anatomi Prompt yang Baik

Setiap prompt sebaiknya punya 5 bagian:

```
1. KONTEKS
   - Proyek apa
   - Fase apa
   - File terkait

2. TUGAS
   - Apa yang harus dikerjakan
   - Spesifik, bukan general

3. BATASAN
   - Apa yang tidak boleh dilakukan
   - File yang tidak boleh diubah

4. DoD (Definition of Done)
   - Kriteria selesai
   - Output yang diharapkan

5. FORMAT OUTPUT
   - Bahasa
   - Struktur
   - Panjang
```

### Contoh Prompt Baik

```
KONTEKS
Proyek KODIRA, Phase 1 (Design System).
File terkait: docs/02-design-system.md, DESIGN.md.

TUGAS
Buat file lib/app/theme.dart yang berisi color tokens dari
docs/02-design-system.md.

BATASAN
- Jangan buat file lain
- Jangan ubah file yang sudah ada
- Jangan install package baru
- Hanya class KodiraColors, KodiraSpacing, KodiraRadius

DoD
- File bisa di-import di Flutter tanpa error
- Semua color token dari design system ada
- Format Dart standar (dart format)

FORMAT OUTPUT
- File .dart
- Komentar minimal, hanya untuk grup
- Setelah selesai: laporkan file yang dibuat + jumlah baris
```

### Contoh Prompt Buruk

```
Bikin theme.dart
```

Kenapa buruk:

- Tidak ada konteks
- Tidak ada batasan
- Tidak ada DoD
- Agent akan nebak-nebak

---

## 3. Template Prompt Siap Pakai

### Template 1 — Buat File Dokumentasi Baru

```
KONTEKS
Proyek KODIRA, Phase {N}.
File terkait: {file_referensi}.

TUGAS
Buat file {path_file} yang berisi {deskripsi_singkat}.

BATASAN
- Jangan buat file lain
- Jangan ubah file yang ada
- Bahasa Indonesia
- Format markdown standar

DoD
- File terbuat di path yang benar
- Isi sesuai struktur yang diminta
- Tidak ada typo

FORMAT OUTPUT
Laporkan: file yang dibuat, ringkasan 3-5 kalimat, pertanyaan jika ada.
```

### Template 2 — Buat Komponen UI

```
KONTEKS
Proyek KODIRA, Phase {N}. Framework: Flutter.
File terkait: docs/02-design-system.md, lib/app/theme.dart.

TUGAS
Buat widget {nama_widget} di {path_file}.

BATASAN
- Hanya buat file ini
- Ikuti design system (warna, spacing, radius)
- Stateless jika bisa
- Jangan install package baru

DoD
- Widget bisa dirender tanpa error
- Menggunakan token dari theme.dart
- Responsive di 360px width

FORMAT OUTPUT
Laporkan: file, baris, widget yang dibuat, test manual yang sudah dilakukan.
```

### Template 3 — Buat Service / API Call

```
KONTEKS
Proyek KODIRA, Phase {N}.
File terkait: docs/03-architecture.md, docs/04-guidelines.md.

TUGAS
Buat service {nama_service} di {path_file}.

BATASAN
- Gunakan Dio/Supabase client yang sudah ada
- Error handling sesuai guidelines
- Jangan hardcode URL atau API key
- Jangan buat file lain

DoD
- Service bisa dipanggil dari provider
- Error di-handle dengan Result type
- Tidak ada warning dari flutter analyze

FORMAT OUTPUT
Laporkan: file, method yang dibuat, contoh pemanggilan.
```

### Template 4 — Fix Bug

```
KONTEKS
Proyek KODIRA. Bug: {deskripsi_bug}.
File terkait: {file_bug}.

TUGAS
Perbaiki bug di file tersebut. Jangan ubah behavior lain.

BATASAN
- Hanya ubah file yang disebut
- Jangan refactor sekaligus
- Jangan tambah fitur baru
- Jelaskan akar masalah sebelum fix

DoD
- Bug tidak muncul lagi
- Test existing masih lulus
- Tidak ada warning baru

FORMAT OUTPUT
Laporkan: akar masalah, solusi, file yang diubah, baris yang diubah.
```

### Template 5 — Refactor

```
KONTEKS
Proyek KODIRA. File: {file_target}.
Masalah: {alasan_refactor}.

TUGAS
Refactor file tersebut tanpa mengubah behavior.

BATASAN
- Jangan ubah API publik (nama fungsi, parameter)
- Jangan ubah behavior
- Jangan tambah fitur
- Semua test harus tetap lulus

DoD
- Kode lebih rapi
- Tidak ada warning baru
- Test lulus 100%

FORMAT OUTPUT
Laporkan: apa yang diubah, kenapa, jumlah baris before/after.
```

### Template 6 — Tambah Test

```
KONTEKS
Proyek KODIRA. File yang akan ditest: {file_target}.
Coverage target: 70% business logic.

TUGAS
Buat unit test untuk {fungsi/class} di {path_test}.

BATASAN
- Hanya buat file test ini
- Jangan ubah kode yang ditest
- Fokus pada edge case
- Nama test deskriptif

DoD
- Semua test lulus
- Coverage fungsi target >= 70%
- Tidak ada test yang flaky

FORMAT OUTPUT
Laporkan: file, jumlah test, coverage, edge case yang dicakup.
```

### Template 7 — Update Dokumentasi

```
KONTEKS
Proyek KODIRA. File: {file_target}.
Alasan update: {alasan}.

TUGAS
Update file tersebut sesuai perubahan terbaru.

BATASAN
- Hanya ubah bagian yang relevan
- Jangan ubah struktur
- Pertahankan format

DoD
- Isi akurat
- Tidak ada typo
- Konsisten dengan file lain

FORMAT OUTPUT
Laporkan: bagian yang diubah, alasan.
```

### Template 8 — Baca & Rangkum

```
KONTEKS
Proyek KODIRA.

TUGAS
Baca file {file_target} dan rangkum.

BATASAN
- Jangan ubah file
- Jangan buat file baru
- Fokus pada poin utama

DoD
- Ringkasan 5-10 poin
- Tidak ada opini, hanya isi

FORMAT OUTPUT
Bullet points, maksimal 10.
```

### Template 9 — Analisis Trade-off

```
KONTEKS
Proyek KODIRA. Keputusan: {topik}.
File terkait: docs/05-decisions.md.

TUGAS
Analisis trade-off antara opsi berikut:
1. {opsi_1}
2. {opsi_2}
3. {opsi_3}

BATASAN
- Jangan pilih, hanya analisis
- Sertakan kelebihan & kekurangan tiap opsi
- Sertakan rekomendasi dengan alasan

DoD
- Analisis objektif
- Ada tabel perbandingan
- Ada rekomendasi

FORMAT OUTPUT
Tabel + rekomendasi 3-5 kalimat.
```

### Template 10 — Review Kode

```
KONTEKS
Proyek KODIRA. File: {file_target}.
Standar: docs/04-guidelines.md, reference/web-interface-guidelines/.

TUGAS
Review file tersebut.

BATASAN
- Jangan ubah file
- Fokus pada: bug, security, performance, konsistensi
- Format: file:line

DoD
- Daftar temuan
- Prioritas (critical, warning, info)
- Saran perbaikan spesifik

FORMAT OUTPUT
List temuan dengan format: file:line — masalah — saran.
```

---

## 4. Aturan Anti-Ngelantur

### 4.1 Batasan Token

Tambahkan di akhir prompt:

```
BATASAN TOKEN
- Maksimal baca {N} file
- Maksimal output {N} baris
- Jangan baca file di luar daftar berikut: {daftar_file}
- Kalau butuh baca file lain, tanya dulu
```

### 4.2 Batasan File

Selalu sebutkan:

```
FILE YANG BOLEH DIBACA
- docs/02-design-system.md
- lib/app/theme.dart

FILE YANG BOLEH DIUBAH
- lib/features/auth/login_screen.dart

FILE YANG TIDAK BOLEH DIUBAH
- Semua file lain
```

### 4.3 Kapan Agent Harus Tanya

Tambahkan:

```
ATURAN TANYA
- Jika ragu, tanya dulu. Jangan asal pilih.
- Jika ada 2 opsi, sajikan keduanya.
- Jika butuh baca file di luar daftar, tanya dulu.
- Jika tugas tidak jelas, tanya dulu.
```

### 4.4 Batasan Scope

```
JANGAN:
- Refactor kode lain
- Ubah file di luar yang disebut
- Install package baru
- Tambah fitur baru
- Ubah konfigurasi project
```

---

## 5. Alur Kerja Standar

### 5.1 Alur Harian

```
1. Buka docs/07-backlog.md
2. Pilih task berikutnya (paling atas)
3. Buka opencode
4. Pilih agent: plan atau build
5. Copy template prompt yang sesuai
6. Isi {placeholder}
7. Kirim
8. Review hasil
9. Kalau oke: commit
10. Update backlog (mark done)
11. Ulang
```

### 5.2 Alur Task Besar (Butuh Beberapa Prompt)

```
1. plan → diskusi struktur
2. Review diskusi
3. build → buat file 1
4. Review
5. build → buat file 2
6. Review
7. build → integrasi
8. Review
9. commit
```

### 5.3 Kapan Pakai `plan`

- Diskusi struktur
- Analisis trade-off
- Bikin draft (di chat)
- Review kode
- Rangkum file
- Debugging (cari akar masalah)

### 5.4 Kapan Pakai `build`

- Tulis file
- Edit file
- Buat test
- Fix bug
- Refactor
- Commit

---

## 6. Checklist Sebelum Prompt

Sebelum kirim prompt, cek:

- [ ] Sudah pilih agent yang tepat (plan/build)?
- [ ] Konteks sudah jelas? (proyek, fase, file)
- [ ] Tugas spesifik? (bukan "bikin UI")
- [ ] Batasan eksplisit? (file yang boleh/tidak boleh diubah)
- [ ] DoD jelas? (kapan selesai)
- [ ] Format output disebut? (bahasa, struktur)
- [ ] Batasan token? (maks baca file, maks output)

---

## 7. Setelah Prompt

Setelah agent selesai, cek:

- [ ] Hasil sesuai DoD?
- [ ] File yang diubah sesuai batasan?
- [ ] Tidak ada warning baru?
- [ ] Test lulus (kalau ada)?
- [ ] Format konsisten?
- [ ] Bahasa benar?
- [ ] Tidak ada file sensitif yang ke-commit?

Kalau ada yang tidak sesuai:

- **Jangan langsung accept**
- Revisi dengan prompt kecil: "Fix X di file Y, jangan ubah yang lain"
- Ulang cek

---

## 8. Contoh Alur Lengkap

### Skenario: Buat halaman login

**Step 1 — plan (diskusi)**

```
KONTEKS
Proyek KODIRA, Phase 2. Baca: docs/02-design-system.md, DESIGN.md.

TUGAS
Usulkan struktur halaman login KODIRA.

BATASAN
- Jangan tulis file
- Bahasa Indonesia
- Fokus pada komponen, bukan kode

DoD
Daftar komponen + hierarki + interaksi.

FORMAT OUTPUT
Bullet points + struktur.
```

**Step 2 — review hasil plan**
Anda baca. Kalau oke, lanjut.

**Step 3 — build (eksekusi)**

```
KONTEKS
Proyek KODIRA, Phase 2. Baca: docs/02-design-system.md.

TUGAS
Buat file lib/features/auth/login_screen.dart sesuai struktur yang
sudah disetujui di diskusi sebelumnya.

BATASAN
- Hanya buat file ini
- Jangan buat file lain
- Gunakan token dari lib/app/theme.dart
- Stateless widget
- Bahasa Indonesia untuk UI text

DoD
- Widget bisa dirender tanpa error
- Responsive 360px
- Tidak ada warning dari flutter analyze

FORMAT OUTPUT
Laporkan: file, baris, komponen, test manual.
```

**Step 4 — review hasil build**
Cek. Kalau oke, commit.

**Step 5 — commit**

```bash
git add lib/features/auth/login_screen.dart
git commit -m "feat(auth): tambah halaman login"
```

---

## 9. Tips Hemat Token

1. **Gunakan context map** (`docs/08-context-map.md`) — sebut file mana yang perlu dibaca, jangan biarkan agent baca semua.
2. **Prompt pendek tapi padat** — jangan bertele-tele.
3. **Template reusable** — copy-paste template, isi placeholder.
4. **Satu tugas per prompt** — jangan gabung.
5. **Batasi output** — "maks 50 baris" atau "ringkas 5 poin".
6. **Jangan minta agent baca file panjang** — rangkum dulu di sesi plan.
7. **Kalau error, fix kecil-kecil** — jangan regenerate semua.

---

## 10. Tips Anti-Ngelantur

1. **Sebutkan file yang boleh dibaca** — jangan biarkan agent eksplorasi bebas.
2. **Sebutkan file yang boleh diubah** — cegah agent sentuh file lain.
3. **Sebutkan larangan eksplisit** — "jangan install package", "jangan refactor".
4. **DoD spesifik** — "kode harus jalan" bukan DoD, "widget render tanpa error" DoD.
5. **Minta laporan setelah selesai** — cek apakah agent kerja sesuai.
6. **Review sebelum commit** — jangan commit buta.
7. **Kalau agent ngelantur, stop dan reset** — buka ulang dengan prompt lebih ketat.

---

## 11. Kesalahan Umum

| Kesalahan                 | Akibat                           | Perbaikan                               |
| ------------------------- | -------------------------------- | --------------------------------------- |
| Prompt "bikin UI"         | Agent nebak, hasil ngawur        | Sebut spesifik: layar apa, komponen apa |
| Tidak sebut file          | Agent baca semua file            | Sebut file yang relevan saja            |
| Tidak ada DoD             | Agent tidak tahu kapan berhenti  | Tulis DoD konkret                       |
| Gabung 5 tugas            | Agent bingung, hasil campur      | Satu tugas per prompt                   |
| Pakai plan untuk write    | Error "no write"                 | Pakai build untuk write                 |
| Pakai build untuk diskusi | Boros token, hasil langsung file | Pakai plan untuk diskusi                |
| Tidak review              | Bug masuk main                   | Selalu review sebelum commit            |

---

## 12. Referensi

- `AGENTS.md` — aturan agent
- `docs/00-phases.md` — roadmap
- `docs/04-guidelines.md` — konvensi kode
- `docs/07-backlog.md` — daftar task (akan dibuat)
- `docs/08-context-map.md` — peta file (akan dibuat)

---

## 13. Catatan Automation ADB

- Hindari tap di area navigation bar sistem Android (biasanya `y > 2100` pada device resolusi 1080x2400).
- Area ini mengirim `KEYCODE_BACK` → app pop ke layar sebelumnya.
- Koordinat aman untuk tombol bawah app: `y ≤ 2100`.
- Kalau automation "layar kembali sendiri" tanpa sebab → cek apakah tap masuk navigation bar.

---

## 14. Update Log

| Tanggal    | Perubahan                      |
| ---------- | ------------------------------ |
| 2026-10-16 | Draft awal dibuat              |
| 2026-10-20 | Tambah catatan automation ADB  |
