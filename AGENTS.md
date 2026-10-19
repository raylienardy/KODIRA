# AGENTS.md

Instruksi untuk AI agent (opencode, Stitch, dan agent lain) yang bekerja 
di proyek KODIRA.

---

## 1. Ringkasan Proyek

**KODIRA** — aplikasi mobile Android untuk pembelajaran pemrograman 
C++ dan Java bagi mahasiswa JTIK semester 1, mata kuliah Pemrograman Dasar.

Tiga pilar utama:
1. **Gamifikasi** — XP, level, badge, streak, achievement
2. **AI Adaptive Mentor** — hint bertahap 1–3, satu arah, bukan jawaban akhir
3. **Adaptive Quiz** — menyesuaikan riwayat, memuat soal level saat ini + ulasan

Metode pengembangan: **ADDIE** (Analysis, Design, Development, 
Implementation, Evaluation).

Status saat ini: tahap **Design**. Analysis sudah selesai di proposal.

---

## 2. Struktur Folder

```
kodira/
├── docs/
│   ├── 00-phases.md           ← roadmap fase (sudah ada)
│   ├── 01-prd.md              ← product requirement
│   ├── 02-design-system.md    ← warna, tipografi, komponen
│   ├── 03-architecture.md     ← tech stack, DB, API, AI
│   ├── 04-guidelines.md       ← pedoman pengembangan & UI
│   └── 05-decisions.md        ← log keputusan (ADR)
├── reference/
│   ├── web-interface-guidelines/
│   └── design-md/
├── AGENTS.md                  ← file ini
├── DESIGN.md                  ← design system untuk Stitch
├── .gitignore
└── (source code)              ← dibuat di Phase 4
```

---

## 3. Aturan Kerja Agent

### Prinsip Utama

| Agent | Izin | Fungsi |
|-------|------|--------|
| **plan** | **READ ONLY** | Membaca, menganalisis, berdiskusi, mengusulkan |
| **build** | **WRITE** | Menulis file, edit file, jalankan perintah |

**Aturan sederhana:**
- Butuh **membaca atau menganalisis** → pakai `plan`
- Butuh **menulis atau mengubah** → pakai `build`

### Contoh Pemetaan

| Tugas | Agent |
|-------|-------|
| Diskusi struktur file | plan |
| Bikin draft PRD di chat | plan |
| Tulis file PRD ke disk | build |
| Diskusi warna & tipografi | plan |
| Bikin `DESIGN.md` | build |
| Ubah 1 baris di file | build |
| Refactor besar | plan dulu, baru build |
| Baca file untuk cek konsistensi | plan |
| Perbaiki typo di dokumen | build |
| Analisis trade-off tech stack | plan |
| Install package baru | build (dengan izin user dulu) |

### Alur Kerja Standar

```
1. plan  → diskusi & analisis
2. Setuju hasil diskusi
3. build → eksekusi ke file
4. Review hasil
5. Ulang jika perlu
```

Jangan pernah lompat dari diskusi langsung ke tulis file tanpa persetujuan.

---

## 4. Aturan Bertanya

Kalau agent **ragu**, **tidak yakin**, atau ada **2 opsi berbeda**, 
agent WAJIB:

1. **Tuliskan pertanyaan spesifik** — bukan pertanyaan umum
2. **Sertakan minimal 2 opsi jawaban** — dengan trade-off masing-masing
3. **Tunggu user memilih** — jangan asal pilih sendiri
4. **Jangan berasumsi** — kalau tidak ada instruksi, tanya

**Contoh pertanyaan yang BENAR:**
```
Saya ragu memilih backend. Ada 2 opsi:
A. Firebase — cepat, gratis untuk MVP, tapi vendor lock-in
B. Supabase — open source, PostgreSQL, bisa self-host nanti

Mana yang Anda pilih?
```

**Contoh pertanyaan yang SALAH:**
```
Mau pakai backend apa?
```

---

## 5. Konvensi Penulisan

### Bahasa
- **Dokumen** (`docs/`, `AGENTS.md`, `DESIGN.md`): Bahasa Indonesia
- **Kode** (variabel, fungsi, komentar): Bahasa Inggris (standar industri)
- **Commit message**: Bahasa Inggris, format Conventional Commits

### Format Markdown
- Heading standar: `#`, `##`, `###` — jangan pakai teks tebal sebagai heading
- Tabel: format markdown dengan separator `|---|`
- List: bullet (`-`) atau numbered (`1.`) — konsisten dalam satu dokumen
- Code block: pakai triple backtick dengan nama bahasa
- Tanggal: `YYYY-MM-DD`

### Gaya Penulisan
- Kalimat singkat, aktif, tanpa filler
- Hindari jargon yang tidak perlu
- Setiap section punya tujuan jelas
- Kalau bisa tabel, jangan paragraf panjang

---

## 6. Aturan Penamaan

### Dokumen
- **File MD di `docs/`**: `NN-kebab-case.md`
  - Contoh: `00-phases.md`, `01-prd.md`, `02-design-system.md`
- **File MD di root**: `UPPERCASE.md`
  - Contoh: `AGENTS.md`, `DESIGN.md`, `README.md`

### Kode (berlaku nanti di Phase 4)
- **Flutter/Dart**: `snake_case.dart`
- **Kotlin**: `PascalCase.kt`
- **Java**: `PascalCase.java`
- **Folder**: `lowercase` atau `kebab-case`

### Git
- **Branch**:
  - `feat/<nama-fitur>` — fitur baru
  - `fix/<nama-bug>` — perbaikan bug
  - `docs/<nama-dokumen>` — dokumentasi
  - `chore/<tugas>` — tugas rutin
- **Commit**: `<type>: <deskripsi singkat>`
  - Type: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`
  - Contoh: `docs: tambah roadmap fase pengembangan`
- **Tag**: `v<major>.<minor>.<patch>` (semantic versioning)

---

## 7. Referensi yang Harus Dibaca

Sebelum mengerjakan tugas apapun, agent **WAJIB** baca:

1. **`docs/00-phases.md`** — roadmap fase & kriteria selesai
2. **File `docs/` lain yang relevan** dengan tugas
3. **`reference/`** — untuk konvensi UI & DESIGN.md
4. **`DESIGN.md`** — jika bekerja dengan UI

Agent **tidak boleh** mengerjakan berdasarkan asumsi tanpa baca referensi.

---

## 8. Batasan & Larangan Agent

### Larangan Keras
- ❌ **Jangan hapus file** tanpa konfirmasi user
- ❌ **Jangan install package baru** tanpa persetujuan user
- ❌ **Jangan commit ke git** tanpa review user
- ❌ **Jangan modifikasi `.gitignore`** tanpa alasan kuat
- ❌ **Jangan akses jaringan eksternal** kecuali untuk baca referensi
- ❌ **Jangan tulis di luar folder project** KODIRA
- ❌ **Jangan hardcode API key** atau secret di kode
- ❌ **Jangan commit file `.env`** atau file sensitif lainnya

### Wajib Dilakukan
- ✅ Baca referensi sebelum kerja
- ✅ Tanya kalau ragu
- ✅ Tulis draft di chat dulu (plan), baru tulis ke file (build)
- ✅ Update `docs/05-decisions.md` kalau ada keputusan penting
- ✅ Konsisten dengan konvensi di file ini

---

## 9. File Sensitif yang Dilarang Di-commit

Lihat `.gitignore`. Yang paling kritis:
- `.env` dan variannya
- `local.properties`
- `key.properties`
- `*.jks`, `*.keystore`
- API key apapun

Kalau agent menemukan file ini akan ter-commit, **STOP** dan lapor ke user.

---

## 10. Keputusan yang Masih Diperlukan

- Template commit message detail (apakah pakai scope?)
- Aturan untuk file test (nama, folder, coverage target)
- Konvensi untuk komponen UI (nanti setelah tech stack diputuskan)
- Section "Tooling" (IDE, SDK versi) — tunggu Phase 3

---

## 11. Update Log

| Tanggal | Perubahan |
|---------|-----------|
| 2026-10-16 | File dibuat |