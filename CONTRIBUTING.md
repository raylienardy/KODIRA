# Contributing — KODIRA

Panduan kontribusi untuk proyek KODIRA. Baca ini sebelum menulis kode.

**Baca juga:** [`docs/04-guidelines.md`](docs/04-guidelines.md) untuk
konvensi kode detail.

---

## 1. Sebelum Mulai

### Setup Awal

- [ ] Sudah baca `README.md`
- [ ] Sudah setup project lokal (`flutter run` berhasil)
- [ ] Sudah setup pre-commit hook (`bash scripts/install-hooks.sh`)
- [ ] Sudah baca `docs/04-guidelines.md`
- [ ] Sudah baca `docs/07-backlog.md`

### Pahami Konteks

Sebelum ubah kode apapun, pahami:

1. **Produk** — baca `docs/01-prd.md`
2. **Arsitektur** — baca `docs/03-architecture.md`
3. **Konvensi** — baca `docs/04-guidelines.md`
4. **Keputusan** — baca `docs/05-decisions.md`

---

## 2. Alur Kontribusi

```
1. Pilih task dari backlog
        ↓
2. Buat branch baru
        ↓
3. Kerjakan task
        ↓
4. Test lokal
        ↓
5. Commit
        ↓
6. Push ke GitHub
        ↓
7. Buat Pull Request
        ↓
8. Minta review
        ↓
9. Revisi (jika ada)
        ↓
10. Merge
        ↓
11. Hapus branch
```

---

## 3. Memilih Task

Semua task ada di `docs/07-backlog.md`.

**Aturan:**

- Kerjakan **berurutan**, jangan lompat
- Cek **dependency** dulu
- Satu task = satu branch = satu PR
- Kalau task > `L` (large), pecah dulu

**Mengubah status task:**

- Mulai kerja → `Todo` → `WIP`
- Selesai → `WIP` → `Review`
- Sudah di-merge → `Review` → `Done`

---

## 4. Branch

### Format

```
<type>/<deskripsi-singkat>
```

### Type

| Type       | Untuk         | Contoh                     |
| ---------- | ------------- | -------------------------- |
| `feat`     | Fitur baru    | `feat/level-map-screen`    |
| `fix`      | Perbaikan bug | `fix/xp-calculation`       |
| `docs`     | Dokumentasi   | `docs/update-prd`          |
| `chore`    | Tugas rutin   | `chore/update-deps`        |
| `refactor` | Refactor      | `refactor/adaptive-engine` |
| `test`     | Test          | `test/mastery-formula`     |

### Aturan

- Lowercase, pakai dash (`-`), bukan underscore
- Deskripsi 2–4 kata
- Bahasa Inggris
- Satu branch = satu tujuan

### Contoh

```bash
# ✅ Benar
git checkout -b feat/login-screen
git checkout -b fix/mastery-edge-case
git checkout -b docs/update-backlog

# ❌ Salah
git checkout -b my-branch
git checkout -b update_banyak_hal
git checkout -b TASK-123
```

---

## 5. Commit

### Format

**Conventional Commits:**

```
<type>(<scope>): <deskripsi>

[body opsional]

[footer opsional]
```

### Type

- `feat` — fitur baru
- `fix` — perbaikan bug
- `docs` — dokumentasi
- `style` — format, tidak ubah logic
- `refactor` — refactor, tidak ubah behavior
- `test` — tambah/ubah test
- `chore` — build, tools, dependency

### Scope (opsional)

Bagian yang diubah: `auth`, `home`, `quiz`, `ai`, `adaptive`, `profile`.

### Contoh

```
feat(auth): tambah login dengan NIM
fix(quiz): perbaiki kalkulasi mastery edge case
docs: update roadmap Phase 3
refactor(ai): extract hint generator ke service
chore: update flutter ke 3.24
test(adaptive): tambah unit test formula mastery
```

### Aturan

- Imperatif, present tense ("tambah" bukan "menambah")
- Jangan titik di akhir
- Baris pertama max 72 karakter
- Body jika butuh penjelasan
- Bahasa: sesuai konvensi tim

### Yang Tidak Boleh

- ❌ `update` (tidak jelas update apa)
- ❌ `fix bug` (bug apa?)
- ❌ `wip` (jangan commit WIP ke `main`)
- ❌ Commit 10 file dalam satu commit tanpa alasan jelas

### Cara Commit yang Baik

```bash
# Cek dulu apa yang mau di-commit
git status
git diff --cached

# Commit
git add <file-yang-relevan>
git commit -m "feat(auth): tambah login dengan NIM"

# Jangan commit semua file tanpa cek
git add .   # ⚠️ hati-hati, cek dulu
```

---

## 6. Pull Request

### Sebelum Membuat PR

- [ ] Semua test lulus (`flutter test`)
- [ ] Tidak ada warning (`flutter analyze`)
- [ ] Sudah diformat (`dart format .`)
- [ ] Sudah rebase dari `main` (`git rebase main`)
- [ ] Tidak ada file sensitif yang ke-commit
- [ ] Dokumentasi diupdate (jika perlu)

### Template PR

```markdown
## Apa yang diubah?

- Deskripsi singkat perubahan

## Kenapa?

- Alasan perubahan
- Link ke task backlog (misal: P4-001)

## Bagaimana cara test?

- Langkah-langkah verifikasi
- Screenshot (jika UI)

## Checklist

- [ ] Sudah di-test lokal
- [ ] Tidak ada warning baru
- [ ] Dokumentasi diupdate (jika perlu)
- [ ] Sudah rebase dari main
- [ ] Tidak ada file sensitif
```

### Aturan PR

- **PR kecil** lebih baik dari PR besar
- Idealnya < 400 baris
- **Satu PR = satu task**
- **Jangan merge PR sendiri** untuk perubahan signifikan
- Review minimal 1 orang (teman tim)

---

## 7. Code Review

### Untuk Reviewer

Cek:

- [ ] Apakah kode **jalan** sesuai tujuan?
- [ ] Apakah ada **test**?
- [ ] Apakah **mudah dibaca**?
- [ ] Apakah **konsisten** dengan konvensi?
- [ ] Apakah ada **security issue**?
- [ ] Apakah ada **performance issue**?
- [ ] Apakah **dokumentasi** diupdate?
- [ ] Apakah **tidak ada file sensitif**?

### Cara Komentar

**Baik:**

- "Baris 42: Variabel `x` bisa diganti `levelCount` agar lebih jelas."
- "Baris 78: Ini bisa di-`const` untuk performa."
- "Bagus, test-nya lengkap!"

**Kurang baik:**

- "Kode jelek."
- "Kenapa begini?"
- "Salah."

### Untuk Author

- Jangan defensif
- Tanya kalau tidak setuju, dengan alasan
- Terima kalau memang benar
- Jangan merge sebelum semua komentar di-resolve

---

## 8. Yang Tidak Boleh Di-commit

Sudah ada di `.gitignore`, tapi garis bawahi:

- ❌ `.env` atau file dengan secret
- ❌ `local.properties`, `key.properties`
- ❌ `*.jks`, `*.keystore`
- ❌ `node_modules/`, `.dart_tool/`
- ❌ `build/`, `*.apk`
- ❌ File dari IDE (`.idea/`, `.vscode/` kecuali settings)

### Cara Cek Sebelum Commit

```bash
git diff --cached
git status
```

Kalau ada file sensitif, **jangan commit**. Hapus dari staging:

```bash
git reset HEAD <file>
```

Tambahkan ke `.gitignore` jika perlu.

---

## 9. Testing

### Sebelum Push

- [ ] `flutter test` lulus
- [ ] `flutter analyze` tanpa warning
- [ ] Test manual fitur yang diubah

### Menambah Test

- **Wajib** untuk business logic
- **Sunnah** untuk widget
- **Naming:** `<method> <expected> when <condition>`
- Contoh: `calculateMastery returns 1.0 when perfect`

### Coverage

Target: **70%** untuk business logic, **90%+** untuk critical logic.

```bash
flutter test --coverage
```

---

## 10. Dokumentasi

Update dokumentasi jika:

- Menambah fitur baru → update `docs/01-prd.md`
- Mengubah API → update `docs/03-architecture.md`
- Mengubah design → update `docs/02-design-system.md`
- Keputusan teknis baru → tambah ADR di `docs/05-decisions.md`
- Task selesai → update status di `docs/07-backlog.md`

**Bahasa:** Indonesia.

**Format:** Markdown standar (`#`, `##`, `###`).

---

## 11. Komunikasi

### Channel

- **Diskusi kode:** komentar di PR
- **Diskusi cepat:** chat tim (WhatsApp/Discord)
- **Keputusan penting:** tulis di `docs/05-decisions.md`

### Etika

- **Sopan** — tidak menyerang pribadi
- **Spesifik** — tunjuk baris, bukan general
- **Fokus kode**, bukan orang
- **Terima kritik** dengan baik
- **Bantu teman** kalau stuck

---

## 12. FAQ

**Q: Saya pemula Git, gimana?**  
A: Baca `docs/04-guidelines.md` bagian 3. Kalau masih bingung, tanya teman tim.

**Q: Saya nemu bug tapi bukan task saya, gimana?**  
A: Catat di `docs/07-backlog.md` sebagai task baru, atau diskusikan dulu.

**Q: Bisa langsung push ke `main`?**  
A: Tidak. Selalu bikin branch + PR + review.

**Q: Bagaimana kalau PR saya ditolak?**  
A: Normal. Baca feedback, revisi, push ulang. Jangan tersinggung.

**Q: Bisa commit file `.env`?**  
A: Tidak pernah. Kalau butuh share config, pakai `.env.example`.

**Q: Berapa lama PR harus di-review?**  
A: Idealnya < 24 jam. Kalau urgent, hubungi teman tim langsung.

**Q: Test saya gagal tapi bukan karena kode saya, gimana?**  
A: Cek apakah `main` terbaru sudah di-pull. Kalau masih gagal, lapor.

---

## 13. Referensi

- [`docs/04-guidelines.md`](docs/04-guidelines.md) — konvensi kode detail
- [`docs/06-workflow.md`](docs/06-workflow.md) — cara kerja dengan AI agent
- [`docs/07-backlog.md`](docs/07-backlog.md) — daftar task
- [Conventional Commits](https://conventionalcommits.org)
- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)

---

## 14. Update Log

| Tanggal    | Perubahan  |
| ---------- | ---------- |
| 2026-10-16 | Draft awal |
