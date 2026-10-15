# Guidelines — KODIRA

Pedoman pengembangan untuk proyek KODIRA.

| Field   | Nilai                                          |
| ------- | ---------------------------------------------- |
| Versi   | 1.0                                            |
| Tanggal | 2026-10-16                                     |
| Status  | Draft                                          |
| Basis   | `docs/00-phases.md`, `docs/03-architecture.md` |

---

## 1. Prinsip Umum

1. **Konsisten > sempurna.** Lebih baik konsisten dengan konvensi ini
   daripada sempurna tapi berbeda-beda.
2. **Baca dulu, tulis kemudian.** Pahami konteks sebelum ubah kode.
3. **Kecil dan sering.** Commit kecil, PR kecil, perubahan kecil.
4. **Jelas > pintar.** Kode yang mudah dibaca lebih baik dari kode pintar
   yang sulit dipahami.
5. **Test sebelum commit.** Jangan commit kode yang belum jalan.

---

## 2. Coding Style — Dart/Flutter

### 2.1 Format

- Gunakan **`dart format`** sebelum commit.
- Line length: **80 karakter** (default Dart).
- Indentasi: **2 spasi** (bukan tab).

### 2.2 Penamaan

| Jenis    | Konvensi                | Contoh                  |
| -------- | ----------------------- | ----------------------- |
| Class    | PascalCase              | `LevelMapScreen`        |
| Widget   | PascalCase              | `LevelCard`             |
| Function | camelCase               | `loadLevelData()`       |
| Variable | camelCase               | `currentLevel`          |
| Constant | lowerCamelCase          | `defaultPadding`        |
| Private  | underscore prefix       | `_internalState`        |
| File     | snake_case              | `level_map_screen.dart` |
| Folder   | snake_case              | `ai_mentor/`            |
| Enum     | PascalCase + lowerCamel | `LevelStatus.active`    |

### 2.3 Struktur File

Urutan di dalam file:

```dart
// 1. Import
import 'package:flutter/material.dart';
import 'package:kodira/core/theme.dart';

// 2. Konstanta
const _defaultPadding = 20.0;

// 3. Class / Widget
class LevelCard extends StatelessWidget {
  // 3a. Fields
  final Level level;
  final VoidCallback onTap;

  // 3b. Constructor
  const LevelCard({
    super.key,
    required this.level,
    required this.onTap,
  });

  // 3c. Methods
  @override
  Widget build(BuildContext context) {
    return Container(/* ... */);
  }
}

// 4. Private helpers
Widget _buildBadge(int number) { /* ... */ }
```

### 2.4 Import

Urutkan import dengan 3 grup, dipisah baris kosong:

```dart
// 1. Dart & Flutter
import 'dart:async';
import 'package:flutter/material.dart';

// 2. External packages
import 'package:riverpod/riverpod.dart';
import 'package:go_router/go_router.dart';

// 3. Internal (project)
import 'package:kodira/core/theme.dart';
import 'package:kodira/features/home/home_screen.dart';
```

**Aturan:**

- Jangan pakai relative import kecuali dalam satu folder.
- Pakai absolute import: `package:kodira/...`.

### 2.5 Widget Rules

- **Pecah widget besar** jadi widget kecil (< 200 baris).
- **Stateless > Stateful** jika bisa.
- **`const`** di mana pun bisa, untuk performa.
- **Jangan nested terlalu dalam** (> 5 level). Pecah jadi widget.
- **Named parameters** untuk semua fungsi publik.
- **`super.key`** untuk widget constructor.

### 2.6 State Management

- Pakai **Riverpod** untuk state global.
- Pakai **`StatefulWidget`** hanya untuk state lokal (animasi, form).
- **Jangan** simpan state di `BuildContext`.
- **Jangan** panggil API langsung dari widget. Pakai provider/repository.

### 2.7 Error Handling

- Pakai **`Result` type** atau **sealed class** untuk operasi yang bisa gagal.
- **Jangan** `try-catch` kosong. Selalu log atau tampilkan ke user.
- **`debugPrint`** untuk development, bukan `print`.
- **`throw`** dengan tipe spesifik, bukan `Exception` generic.

```dart
// Contoh
sealed class ApiResult<T> {}
class Success<T> extends ApiResult<T> { final T data; }
class Failure<T> extends ApiResult<T> { final ApiError error; }
```

### 2.8 Komentar

- **Komentar untuk "kenapa", bukan "apa".**
- **Dokumentasi** fungsi publik dengan `///`.
- **Jangan** komentar kode yang jelas.
- **Hapus** komentar mati sebelum commit.

```dart
// ❌ Salah — jelas dari kode
// Tambah 1 ke counter
counter += 1;

// ✅ Benar — menjelaskan keputusan
// Kita pakai +2 karena counter awal selalu -1 dari database
counter += 2;

// ✅ Dokumentasi fungsi publik
/// Menghitung mastery berdasarkan akurasi, completed, error, dan waktu.
/// Formula: 0.45A + 0.25C + 0.20(1-E) + 0.10(1-Tn)
double calculateMastery({...}) { /* ... */ }
```

---

## 3. Git Workflow

### 3.1 Branch Strategy

```
main          ← stable, production-ready
├── develop   ← integrasi fitur (opsional, untuk tim > 2)
├── feat/*    ← fitur baru
├── fix/*     ← perbaikan bug
├── docs/*    ← dokumentasi
└── chore/*   ← tugas rutin
```

**Untuk tim 2 orang:** bisa langsung ke `main` dengan PR review,
tapi lebih aman pakai `develop` sebagai staging.

**Aturan:**

- **Jangan commit langsung ke `main`** kecuali hotfix.
- **Satu branch = satu tujuan.**
- **Hapus branch setelah merge.**
- **Rebase dari `main`** sebelum merge (bukan merge `main` ke branch).

### 3.2 Nama Branch

Format: `<type>/<deskripsi-singkat>`

| Type     | Contoh                      |
| -------- | --------------------------- |
| feat     | `feat/level-map-screen`     |
| fix      | `fix/xp-calculation-bug`    |
| docs     | `docs/update-prd`           |
| chore    | `chore/update-dependencies` |
| refactor | `refactor/adaptive-engine`  |
| test     | `test/mastery-formula`      |

**Aturan:**

- Lowercase, pakai dash (`-`), bukan underscore.
- Deskripsi singkat (2-4 kata).
- Bahasa Inggris.

### 3.3 Commit Message

Format: **Conventional Commits**

```
<type>(<scope>): <deskripsi>

[optional body]

[optional footer]
```

**Type:**

- `feat` — fitur baru
- `fix` — perbaikan bug
- `docs` — dokumentasi
- `style` — formatting, tidak ubah logic
- `refactor` — refactor, tidak ubah behavior
- `test` — tambah/ubah test
- `chore` — build, tools, dependency

**Scope (opsional):** bagian yang diubah (`auth`, `home`, `quiz`, `ai`, dll).

**Contoh:**

```
feat(auth): tambah login dengan NIM
fix(quiz): perbaiki kalkulasi mastery di edge case
docs: update roadmap Phase 3
refactor(ai): extract hint generator ke service
chore: update flutter ke 3.24
```

**Aturan:**

- **Imperatif, present tense**: "tambah" bukan "menambah" atau "ditambahkan".
- **Jangan titik di akhir.**
- **Baris pertama maksimal 72 karakter.**
- **Body (opsional)** jika butuh penjelasan.
- **Bahasa:** Indonesia atau Inggris, tapi **konsisten** (pilih satu).

**Rekomendasi:** Bahasa Indonesia untuk deskripsi, karena timnya orang Indonesia.

### 3.4 Pull Request

**Template PR:**

```markdown
## Apa yang diubah?

- Deskripsi singkat perubahan

## Kenapa?

- Alasan perubahan (link ke issue jika ada)

## Bagaimana cara test?

- Langkah-langkah verifikasi

## Screenshot (jika UI)

- Before / After

## Checklist

- [ ] Sudah di-test lokal
- [ ] Tidak ada warning baru
- [ ] Dokumentasi diupdate (jika perlu)
- [ ] Sudah rebase dari main
```

**Aturan:**

- **PR kecil** lebih baik dari PR besar. Idealnya < 400 baris.
- **Review minimal 1 orang** (teman Anda) sebelum merge.
- **Jangan merge PR sendiri** untuk perubahan signifikan.
- **Squash commit** saat merge untuk history bersih.

### 3.5 Yang Tidak Boleh Di-commit

Sudah ada di `.gitignore`, tapi garis bawahi:

- ❌ `.env` atau file dengan secret
- ❌ `node_modules/`, `.dart_tool/`
- ❌ `build/`, `*.apk`
- ❌ File dari IDE (`.idea/`, `.vscode/` kecuali settings)
- ❌ `local.properties`, `key.properties`
- ❌ `*.jks`, `*.keystore`

**Sebelum commit, cek:**

```bash
git diff --cached
git status
```

Kalau ada file sensitif, **jangan commit**. Hapus dari staging:

```bash
git reset HEAD <file>
```

---

## 4. Testing

### 4.1 Prinsip

- **Test dulu, baru feature** (kalau bisa).
- **Test yang penting**, bukan semua.
- **Satu test, satu assertion.**
- **Test harus independen** — tidak bergantung urutan.

### 4.2 Level Test

| Level       | Tools              | Fokus                          |
| ----------- | ------------------ | ------------------------------ |
| Unit        | `flutter_test`     | Business logic, utils, formula |
| Widget      | `flutter_test`     | Komponen UI, state             |
| Integration | `integration_test` | Alur end-to-end                |

### 4.3 Apa yang Wajib Di-test

**Wajib:**

- Formula mastery (`calculateMastery()`)
- Adaptive engine (rule-based logic)
- Parsing jawaban user
- Validasi input
- Repository (dengan mock)

**Sunnah:**

- Widget tampilan
- Form validation
- Routing

**Tidak wajib:**

- UI murni tanpa logic
- Third-party code
- Config

### 4.4 Struktur Test

```dart
// test/features/adaptive/mastery_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/features/adaptive/mastery.dart';

void main() {
  group('calculateMastery', () {
    test('returns 1.0 when perfect', () {
      final result = calculateMastery(
        accuracy: 1.0,
        completedRatio: 1.0,
        errorRate: 0.0,
        normalizedTime: 0.0,
      );
      expect(result, 1.0);
    });

    test('returns 0.0 when all zero', () {
      final result = calculateMastery(
        accuracy: 0.0,
        completedRatio: 0.0,
        errorRate: 1.0,
        normalizedTime: 1.0,
      );
      expect(result, 0.0);
    });

    test('handles mastery below 0.40 correctly', () {
      // Edge case: remedial threshold
      final result = calculateMastery(
        accuracy: 0.3,
        completedRatio: 0.3,
        errorRate: 0.8,
        normalizedTime: 0.7,
      );
      expect(result, lessThan(0.40));
    });
  });
}
```

### 4.5 Naming Test

Format: `<method> <expected behavior> when <condition>`

- ✅ `calculateMastery returns 1.0 when perfect`
- ✅ `LevelCard shows lock icon when level locked`
- ❌ `test1`
- ❌ `test mastery`

### 4.6 Menjalankan Test

```bash
flutter test                        # semua test
flutter test test/features/         # folder tertentu
flutter test test/features/auth/    # file tertentu
flutter test --coverage             # dengan coverage
```

**Coverage target:** [TBD] — rekomendasi 70% untuk business logic.

---

## 5. Code Review

### 5.1 Prinsip Review

- **Review untuk kualitas**, bukan untuk ego.
- **Fokus pada logic**, bukan preferensi pribadi.
- **Komentar spesifik**, bukan general.
- **Pujian juga penting** — jangan hanya kritik.

### 5.2 Checklist Reviewer

- [ ] Apakah kode **jalan** sesuai tujuan?
- [ ] Apakah ada **test**?
- [ ] Apakah **mudah dibaca**?
- [ ] Apakah **konsisten** dengan konvensi?
- [ ] Apakah ada **security issue**?
- [ ] Apakah ada **performance issue**?
- [ ] Apakah **dokumentasi** diupdate?
- [ ] Apakah **tidak ada file sensitif** yang ke-commit?

### 5.3 Cara Komentar

**Baik:**

- "Baris 42: Variabel `x` bisa diganti nama `levelCount` agar lebih jelas."
- "Baris 78: Ini bisa di-`const` untuk performa."
- "Bagus, test-nya lengkap!"

**Kurang baik:**

- "Kode jelek."
- "Kenapa begini?"
- "Salah."

### 5.4 Response ke Review

- **Jangan defensif.**
- **Tanya kalau tidak setuju**, dengan alasan.
- **Terima kalau memang benar.**
- **Jangan merge sebelum semua komentar di-resolve.**

---

## 6. Documentation

### 6.1 Apa yang Harus Didokumentasi

**Wajib:**

- Fungsi publik dengan `///`
- Keputusan penting (di `docs/05-decisions.md`)
- Cara setup project (di `README.md`)
- Cara kontribusi (di `CONTRIBUTING.md`, nanti)

**Opsional:**

- Alur kompleks (diagram di `docs/`)
- API contract (di `docs/03-architecture.md`)

**Tidak wajib:**

- Kode yang jelas
- Getter/setter sederhana
- Widget murni tanpa logic

### 6.2 Format Dokumentasi Fungsi

````dart
/// Menghitung mastery user untuk satu topik.
///
/// Formula: `0.45A + 0.25C + 0.20(1-E) + 0.10(1-Tn)`
///
/// Parameter:
/// - [accuracy]: akurasi jawaban (0.0 - 1.0)
/// - [completedRatio]: rasio challenge selesai (0.0 - 1.0)
/// - [errorRate]: error berulang (0.0 - 1.0)
/// - [normalizedTime]: waktu pengerjaan ternormalisasi (0.0 - 1.0)
///
/// Mengembalikan nilai mastery 0.0 - 1.0.
///
/// Contoh:
/// ```dart
/// final m = calculateMastery(
///   accuracy: 0.8,
///   completedRatio: 1.0,
///   errorRate: 0.2,
///   normalizedTime: 0.3,
/// );
/// ```
double calculateMastery({...}) { /* ... */ }
````

### 6.3 Dokumentasi Keputusan (ADR)

Setiap keputusan teknis penting dicatat di `docs/05-decisions.md`.

**Format ADR:**

```markdown
## ADR-001: Pilih Flutter untuk Mobile

**Tanggal:** 2026-10-16
**Status:** Accepted

### Konteks

Kami perlu memilih framework mobile untuk KODIRA. Target: Android.

### Opsi

1. Flutter
2. React Native
3. Kotlin native

### Keputusan

Flutter.

### Alasan

- UI konsisten antar device
- Performa baik untuk animasi (gamifikasi)
- Tooling matang
- Komunitas besar

### Konsekuensi

- Bahasa baru: Dart
- Tidak bisa pakai library JS
- Build size sedikit lebih besar
```

---

## 7. Konvensi File & Folder

### 7.1 Struktur

```
lib/
├── main.dart
├── app/                    ← Konfigurasi app
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── core/                   ← Fondasi
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── network/
├── data/                   ← Data layer
│   ├── models/
│   ├── repositories/
│   └── sources/
│       ├── remote/
│       └── local/
├── domain/                 ← Business logic
│   ├── entities/
│   └── usecases/
├── features/               ← Fitur (feature-first)
│   ├── auth/
│   ├── home/
│   ├── lesson/
│   ├── exercise/
│   ├── quiz/
│   ├── ai_mentor/
│   ├── adaptive/
│   └── profile/
└── shared/                 ← Widget & provider global
    ├── widgets/
    └── providers/
```

### 7.2 Aturan

- **Feature-first**, bukan layer-first.
- **Satu file, satu tanggung jawab.**
- **Folder features/** hanya untuk fitur user-facing.
- **Folder core/** untuk fondasi yang dipakai semua fitur.
- **Folder shared/** untuk widget yang dipakai > 2 fitur.

### 7.3 File yang Tidak Boleh Ada

- ❌ `utils.dart` (generic, tidak jelas)
- ❌ `helpers.dart` (generic, tidak jelas)
- ❌ `misc.dart` (generic, tidak jelas)
- ❌ `temp.dart` (file sementara)

**Ganti dengan nama spesifik:**

- ✅ `date_formatter.dart`
- ✅ `mastery_calculator.dart`
- ✅ `xp_helper.dart`

---

## 8. Performance Guidelines

### 8.1 Mobile Performance

- **`const` di mana pun bisa.** Widget, list, value.
- **`ListView.builder`** untuk list panjang, bukan `ListView`.
- **`RepaintBoundary`** untuk widget yang sering repaint.
- **Hindari rebuild** dengan `select` di Riverpod.
- **Lazy load** gambar dengan `cached_network_image`.
- **Debounce** input user (search, form).

### 8.2 Network Performance

- **Cache** respons API yang jarang berubah.
- **Batch** request jika bisa.
- **Pagination** untuk list panjang.
- **Timeout** maksimal 10 detik.
- **Retry** dengan exponential backoff.

### 8.3 Database Performance

- **Index** kolom yang sering di-query (`user_id`, `level_id`).
- **Jangan N+1 query.** Pakai join atau batch.
- **Limit** hasil query.
- **Pagination** untuk list panjang.

---

## 9. Security Guidelines

### 9.1 API Key

- **Jangan hardcode** API key di kode.
- **Simpan di `.env`** untuk development.
- **Simpan di Supabase secrets** untuk production.
- **Jangan commit** `.env` ke git.

### 9.2 User Data

- **Jangan log** data sensitif (password, token, jawaban user).
- **Hapus jawaban user** setelah 7 hari.
- **Enkripsi** data sensitif di server.
- **HTTPS wajib** untuk semua request.

### 9.3 Input Validation

- **Validasi di client** untuk UX.
- **Validasi di server** untuk security.
- **Sanitize** input sebelum simpan.
- **Jangan percaya** input dari client.

### 9.4 Code Runner

- **Sandbox wajib.** Jangan eksekusi kode user di server utama.
- **Timeout** ketat (5 detik).
- **Memory limit** (256 MB).
- **Tidak boleh akses** jaringan atau file system.

---

## 10. Accessibility Guidelines

- **Kontras minimal** WCAG AA (4.5:1).
- **Touch target minimal** 44x44 px.
- **Font minimal** 11px untuk caption, 13px body.
- **Label** pada ikon penting.
- **Warna bukan satu-satunya** pembeda. Tambah ikon atau label.
- **Focus state** terlihat jelas.
- **Test dengan** `flutter semantics` (screen reader).

---

## 11. Do's & Don'ts

### ✅ Do

- Format kode dengan `dart format`.
- Test sebelum commit.
- Commit kecil dan sering.
- Review PR teman.
- Dokumentasi keputusan penting.
- Tanya kalau ragu.
- Baca konvensi sebelum menulis.

### ❌ Don't

- Commit langsung ke `main`.
- Commit file sensitif.
- Commit kode yang belum jalan.
- Merge PR sendiri tanpa review.
- Campur banyak perubahan di satu commit.
- Hardcode secret.
- Skip test.
- Abaikan warning.

---

## 12. Tools yang Dipakai

| Kategori        | Tools                       |
| --------------- | --------------------------- |
| IDE             | VS Code + Flutter extension |
| Version Control | Git + GitHub                |
| Format          | `dart format`               |
| Lint            | `flutter analyze`           |
| Test            | `flutter test`              |
| CI/CD           | GitHub Actions (nanti)      |
| Crash Report    | Sentry (nanti)              |
| API Testing     | Postman atau Bruno          |
| Design          | Stitch AI, Figma            |

---

## 13. Onboarding Developer Baru

Jika nanti ada developer baru:

1. Baca `docs/00-phases.md` — paham roadmap
2. Baca `docs/01-prd.md` — paham produk
3. Baca `docs/02-design-system.md` — paham visual
4. Baca `docs/03-architecture.md` — paham teknis
5. Baca `docs/04-guidelines.md` — paham konvensi (ini)
6. Baca `AGENTS.md` — paham aturan agent
7. Setup: install Flutter, VS Code, Git
8. Clone project, jalankan `flutter pub get`
9. Baca kode di folder `features/auth/` — contoh struktur
10. Mulai dari task kecil (fix typo, dokumentasi)

---

## 14. Keputusan yang Masih Diperlukan

- [ ] Coverage target untuk business logic: 60%, 70%, atau 80%?
- [ ] Bahasa commit: Indonesia atau Inggris? (Rekomendasi: Indonesia)
- [ ] Apakah pakai `develop` branch atau langsung `main`?
- [ ] Apakah pakai CI/CD sejak awal atau nanti?
- [ ] Apakah pakai pre-commit hook (husky, lefthook)?

---

## 15. Referensi

- `docs/00-phases.md` — roadmap fase
- `docs/01-prd.md` — product requirement
- `docs/02-design-system.md` — design system
- `docs/03-architecture.md` — arsitektur teknis
- `AGENTS.md` — aturan agent
- `reference/web-interface-guidelines/` — guideline UI Vercel
- Flutter style guide: https://dart.dev/guides/language/effective-dart/style
- Conventional Commits: https://conventionalcommits.org

---

## 16. Update Log

| Tanggal    | Perubahan         |
| ---------- | ----------------- |
| 2026-10-16 | Draft awal dibuat |
