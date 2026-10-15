# KODIRA

Aplikasi mobile Android untuk pembelajaran pemrograman berbasis
gamifikasi dan AI adaptif bagi mahasiswa JTIK semester 1.

[![Status](https://img.shields.io/badge/status-development-yellow)]()
[![Platform](https://img.shields.io/badge/platform-Android-green)]()
[![Framework](https://img.shields.io/badge/framework-Flutter-blue)]()

---

## Tentang

KODIRA membantu mahasiswa JTIK membangun fondasi pemrograman melalui:

- **Gamifikasi** — XP, level, badge, streak
- **AI Adaptive Mentor** — hint bertahap, bukan jawaban
- **Adaptive Quiz** — menyesuaikan riwayat & mastery

**Target:** 50 level linier, C++ (level 1–35), Java (level 36–50).

---

## Dokumentasi

Semua dokumentasi ada di folder `docs/`. Baca sesuai kebutuhan:

| Dokumen                                                | Untuk apa                                  |
| ------------------------------------------------------ | ------------------------------------------ |
| [`docs/00-phases.md`](docs/00-phases.md)               | Roadmap fase pengembangan                  |
| [`docs/01-prd.md`](docs/01-prd.md)                     | Product requirement                        |
| [`docs/02-design-system.md`](docs/02-design-system.md) | Design system (warna, tipografi, komponen) |
| [`docs/03-architecture.md`](docs/03-architecture.md)   | Arsitektur teknis                          |
| [`docs/04-guidelines.md`](docs/04-guidelines.md)       | Konvensi kode & workflow                   |
| [`docs/05-decisions.md`](docs/05-decisions.md)         | Log keputusan (ADR)                        |
| [`docs/06-workflow.md`](docs/06-workflow.md)           | Cara kerja dengan opencode                 |
| [`docs/07-backlog.md`](docs/07-backlog.md)             | Daftar task                                |
| [`docs/08-context-map.md`](docs/08-context-map.md)     | Peta file untuk tiap task                  |
| [`docs/09-cp-tp.md`](docs/09-cp-tp.md)                 | Capaian & tujuan pembelajaran              |
| [`AGENTS.md`](AGENTS.md)                               | Instruksi untuk AI agent                   |
| [`DESIGN.md`](DESIGN.md)                               | Design system (format Stitch)              |
| [`CONTRIBUTING.md`](CONTRIBUTING.md)                   | Panduan kontribusi                         |

---

## Quick Start

### Prasyarat

- **Flutter SDK** 3.44.6 — [Install](https://docs.flutter.dev/get-started/install)
- **Dart** 3.12.2 (bundled with Flutter)
- **Git** — [Install](https://git-scm.com/)
- **VS Code** + Flutter extension (opsional, direkomendasikan)
- **Akun Supabase** (untuk backend)

### Setup

```bash
# 1. Clone repo
git clone https://github.com/<username>/kodira.git
cd kodira

# 2. Masuk ke folder app
cd app

# 3. Install dependencies
flutter pub get

# 4. Setup environment
cp .env.example .env
# Isi .env dengan kredensial (minta ke tim)

# 5. Jalankan
flutter run
```

### Setup Pre-commit Hook

```bash
# Dari root project
bash scripts/install-hooks.sh
```

### CI (GitHub Actions)

CI otomatis dijalankan pada setiap push atau pull‑request ke branch `main` melalui workflow `.github/workflows/ci.yml`. Workflow melakukan instalasi dependensi, format check, static analysis, dan menjalankan test (jika ada). Lihat badge status pada README atau tab **Actions** di GitHub.


---

## Struktur Project

```
kodira/
├── app/                         # Kode Flutter (folder utama)
│   ├── lib/
│   │   ├── app/                 # Konfigurasi app, router, theme
│   │   ├── core/                # Constants, errors, utils, network
│   │   ├── data/                # Models, repositories, sources
│   │   ├── domain/              # Entities, use‑cases
│   │   ├── features/            # Semua fitur (auth, home, …)
│   │   └── shared/              # Widgets & providers global
│   ├── test/                     # Unit & widget tests
│   └── pubspec.yaml
├── docs/                        # Dokumentasi
├── reference/                    # Referensi desain
├── scripts/                     # pre‑commit & install‑hooks
├── AGENTS.md
├── DESIGN.md
├── CONTRIBUTING.md
├── README.md
└── .gitignore
```

---

## Tech Stack

| Layer       | Teknologi                   |
| ----------- | --------------------------- |
| Mobile      | Flutter + Dart              |
| State       | Riverpod                    |
| Local DB    | Isar / Drift                |
| Backend     | Supabase (PostgreSQL)       |
| AI          | API berbayar (model ringan) |
| Code Runner | Judge0                      |

Detail: [`docs/03-architecture.md`](docs/03-architecture.md)

---

## Kontribusi

Baca [`CONTRIBUTING.md`](CONTRIBUTING.md) dulu. Ringkasnya:

1. Buat branch dari `main`
2. Kerjakan task dari `docs/07-backlog.md`
3. Commit dengan format Conventional Commits
4. Push & buat Pull Request
5. Minta review dari teman tim

---

## Roadmap

| Phase | Fokus                        | Status      |
| ----- | ---------------------------- | ----------- |
| 0     | Foundation                   | ✅ Selesai  |
| 1     | Design System                | 🚧 Berjalan |
| 2     | UI Design                    | ⏳          |
| 3     | Architecture                 | ⏳          |
| 4     | MVP Development              | ⏳          |
| 5     | AI Integration               | ⏳          |
| 6     | Testing & Evaluation         | ⏳          |
| 7     | Documentation & Presentation | ⏳          |

Detail: [`docs/00-phases.md`](docs/00-phases.md)

---

## Tim

**Kelompok 3 — PTIK B 2024**

- Muhammad Ridho Satriadi (2402095010141)
- Raynato Lienardy (2402095010152)

**Dosen Pengampu:**  
Kurnia Wahyu Prima, S.Pd., M.Pd

---

## Lisensi

Proyek akademik. Tidak untuk distribusi komersial tanpa izin.

---

## Kontak

Ada pertanyaan? Buka issue di GitHub, atau hubungi tim langsung.
