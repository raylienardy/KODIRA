# Design System — KODIRA

Panduan visual dan komponen untuk aplikasi mobile KODIRA.

| Field   | Nilai                                     |
| ------- | ----------------------------------------- |
| Versi   | 1.0                                       |
| Tanggal | 2026-10-16                                |
| Status  | Draft                                     |
| Basis   | DESIGN.md spec (Google Stitch compatible) |

---

## 1. Filosofi Visual

**Kata kunci:**

- Playful tapi fokus
- Ramah mahasiswa
- Tidak berlebihan
- Konsisten

**Inspirasi:**

- **Duolingo** — playful, gamifikasi jelas, motivasi tinggi
- **SoloLearn** — clean, mudah dibaca
- **Linear** — presisi, tipografi tajam

**Prinsip:**

1. Setiap elemen punya tujuan. Tidak ada hiasan tanpa fungsi.
2. Layar belajar sederhana (koherensi). Tidak ada distraksi.
3. Umpan balik langsung terlihat (warna, animasi, ikon).
4. Bahasa visual konsisten di semua layar.

---

## 2. Palet Warna

### 2.1 Primary — Indigo Focus

Warna utama untuk aksi, navigasi, dan branding.

| Nama            | Hex           | Penggunaan                             |
| --------------- | ------------- | -------------------------------------- |
| Primary/900     | `#3D33B8`     | Hover, pressed state                   |
| **Primary/700** | **`#5B4FE9`** | **Tombol utama, header, active state** |
| Primary/500     | `#7C6FF0`     | Gradient, aksen ringan                 |
| Primary/100     | `#EEF0F7`     | Background ringan, chip                |

### 2.2 Success — Mint Growth

Warna untuk status berhasil, completed, dan kemajuan positif.

| Nama            | Hex           | Penggunaan                                     |
| --------------- | ------------- | ---------------------------------------------- |
| Success/700     | `#00A88E`     | Hover                                          |
| **Success/500** | **`#00C2A8`** | **Level selesai, jawaban benar, badge earned** |
| Success/100     | `#E6F9F5`     | Background ringan                              |

### 2.3 Reward — Amber XP

Warna untuk XP, koin, streak, dan reward.

| Nama           | Hex           | Penggunaan                      |
| -------------- | ------------- | ------------------------------- |
| Reward/700     | `#E59400`     | Hover                           |
| **Reward/500** | **`#FFB020`** | **XP bar, coin, streak, badge** |
| Reward/100     | `#FFF4E0`     | Background ringan               |

### 2.4 Alert — Coral Lock

Warna untuk peringatan, level terkunci, dan error.

| Nama          | Hex           | Penggunaan                                  |
| ------------- | ------------- | ------------------------------------------- |
| Alert/700     | `#D94A4A`     | Hover                                       |
| **Alert/500** | **`#FF6B6B`** | **Level terkunci, salah fatal, timer kuis** |
| Alert/100     | `#FFE5E5`     | Background ringan                           |

### 2.5 Neutral

| Nama        | Hex       | Penggunaan                    |
| ----------- | --------- | ----------------------------- |
| Neutral/900 | `#1A1D2B` | Text primary, code background |
| Neutral/700 | `#4B5563` | Text secondary                |
| Neutral/500 | `#6B7280` | Text tertiary, caption        |
| Neutral/300 | `#9CA3AF` | Placeholder, disabled text    |
| Neutral/200 | `#E5E7EB` | Divider, border               |
| Neutral/100 | `#F7F8FC` | Background, card subtle       |
| Neutral/0   | `#FFFFFF` | Card, surface utama           |

### 2.6 Semantic

| Nama    | Hex       | Penggunaan          |
| ------- | --------- | ------------------- |
| Info    | `#3B82F6` | Info, tooltip       |
| Warning | `#F59E0B` | Peringatan ringan   |
| Error   | `#EF4444` | Error, gagal        |
| Success | `#10B981` | Sukses (alternatif) |

### 2.7 Warna Khusus

| Nama            | Hex       | Penggunaan              |
| --------------- | --------- | ----------------------- |
| Code Background | `#1A1D2B` | Blok kode               |
| Code Keyword    | `#C792EA` | Keyword C++/Java (ungu) |
| Code Variable   | `#82AAFF` | Variabel (biru)         |
| Code String     | `#C3E88D` | String (hijau)          |
| Code Number     | `#F78C6C` | Angka (oranye)          |
| Code Comment    | `#6B7280` | Komentar (abu)          |

### 2.8 Aturan Warna

- **Jangan tambahkan warna di luar palet ini.** Kalau butuh varian, gunakan opacity.
- **Kontras teks:** minimal WCAG AA (4.5:1 untuk teks normal, 3:1 untuk teks besar).
- **Warna tidak boleh menjadi satu-satunya pembeda.** Selalu tambahkan ikon atau label.
- **Light mode dulu.** Dark mode masuk future work.

---

## 3. Tipografi

### 3.1 Font Family

| Fungsi             | Font               | Fallback                          |
| ------------------ | ------------------ | --------------------------------- |
| UI & Body          | **Inter**          | -apple-system, Roboto, sans-serif |
| Heading (opsional) | **Poppins**        | Inter, sans-serif                 |
| Code               | **JetBrains Mono** | Courier New, monospace            |

**Catatan:** Pilih satu antara Inter atau Poppins untuk konsistensi. Rekomendasi: **Inter** untuk semua UI, Poppins hanya untuk display besar jika perlu.

### 3.2 Type Scale

| Nama       | Ukuran | Weight | Line Height | Penggunaan                |
| ---------- | ------ | ------ | ----------- | ------------------------- |
| Display    | 32px   | 800    | 1.2         | Judul hero, splash        |
| H1         | 24px   | 700    | 1.3         | Judul layar utama         |
| H2         | 20px   | 700    | 1.3         | Judul section             |
| H3         | 17px   | 600    | 1.4         | Sub-section               |
| Body Large | 15px   | 400    | 1.6         | Body teks utama           |
| Body       | 13px   | 400    | 1.6         | Body default              |
| Body Small | 12px   | 400    | 1.5         | Keterangan                |
| Caption    | 11px   | 500    | 1.4         | Label kecil, metadata     |
| Overline   | 10px   | 700    | 1.4         | Label uppercase, kategori |
| Code       | 12px   | 400    | 1.7         | Blok kode                 |

### 3.3 Aturan Tipografi

- **Maksimal 3 ukuran font** dalam satu layar.
- **Heading tidak lebih dari 2 baris.**
- **Body text minimal 13px** untuk keterbacaan di mobile.
- **Line height minimal 1.4** untuk body.
- **Hindari ALL CAPS** kecuali untuk label pendek (overline).
- **Jangan pakai warna teks hitam murni** (`#000000`). Pakai Neutral/900.

---

## 4. Spacing

Skala spacing berbasis **4px grid**:

| Token    | Nilai | Penggunaan                           |
| -------- | ----- | ------------------------------------ |
| space-1  | 4px   | Ikon kecil, gap tight                |
| space-2  | 8px   | Gap antar elemen                     |
| space-3  | 12px  | Padding dalam chip                   |
| space-4  | 16px  | Padding card kecil                   |
| space-5  | 20px  | **Padding horizontal standar layar** |
| space-6  | 24px  | Padding card besar                   |
| space-8  | 32px  | Gap antar section                    |
| space-10 | 40px  | Gap besar                            |
| space-12 | 48px  | Hero spacing                         |
| space-16 | 64px  | Spacing ekstra                       |

**Aturan:**

- **Padding horizontal layar = 20px.** Konsisten di semua layar.
- **Gap antar card = 12px.**
- **Gap antar section = 32px.**
- **Jangan pakai angka ganjil** selain 1, 3, 5 (dari skala).

---

## 5. Border Radius

| Token       | Nilai  | Penggunaan                |
| ----------- | ------ | ------------------------- |
| radius-xs   | 6px    | Chip kecil                |
| radius-sm   | 8px    | Input kecil, tombol kecil |
| radius-md   | 12px   | Tombol standar, input     |
| radius-lg   | 16px   | Card standar              |
| radius-xl   | 20px   | Card besar, hero          |
| radius-2xl  | 24px   | Modal, bottom sheet       |
| radius-full | 9999px | Pill, avatar, FAB         |

**Aturan:**

- Tombol utama: **12px**
- Card: **16px** (standar) atau **20px** (hero)
- Avatar: **full** (bulat penuh)
- Input: **12px**

---

## 6. Elevation & Shadow

| Level          | Shadow                            | Penggunaan                  |
| -------------- | --------------------------------- | --------------------------- |
| Elevation 0    | none                              | Flat surface                |
| Elevation 1    | `0 1px 2px rgba(26,29,43,0.05)`   | Card subtle                 |
| Elevation 2    | `0 2px 8px rgba(26,29,43,0.06)`   | Card standar                |
| Elevation 3    | `0 4px 16px rgba(26,29,43,0.08)`  | Card aktif, FAB             |
| Elevation 4    | `0 8px 24px rgba(26,29,43,0.12)`  | Modal, bottom sheet         |
| Shadow Primary | `0 8px 20px rgba(91,79,233,0.35)` | Tombol primary, FAB primary |

**Aturan:**

- **Jangan pakai shadow gelap.** Shadow harus subtle.
- **Elevation tinggi = elemen lebih dekat ke user** (modal, FAB).
- **Konsisten:** jangan ada 5 level elevation di satu layar.

---

## 7. Komponen

### 7.1 Tombol

**Primary Button**

- Background: `#5B4FE9`
- Text: `#FFFFFF`, weight 700, 14px
- Padding: 15px 20px
- Radius: 12px
- Shadow: Shadow Primary
- Height: minimal 48px (touch target)

**Secondary Button**

- Background: transparent
- Border: 1.5px `#5B4FE9`
- Text: `#5B4FE9`, weight 600
- Padding: 14px 20px
- Radius: 12px

**Text Button**

- Background: transparent
- Text: `#5B4FE9`, weight 600, 13px
- Padding: 8px 12px

**Disabled State**

- Opacity: 0.4
- Cursor: not-allowed

### 7.2 Card

**Standard Card**

- Background: `#FFFFFF`
- Radius: 16px
- Padding: 16px
- Shadow: Elevation 2
- Gap antar card: 12px

**Hero Card**

- Radius: 20px
- Padding: 24px
- Shadow: Elevation 3

**Stat Card**

- Radius: 14px
- Padding: 14px
- Text center

### 7.3 Input

- Background: `#FFFFFF` atau `#F7F8FC`
- Border: 1.5px `#E5E7EB`
- Border (focus): 1.5px `#5B4FE9`
- Radius: 12px
- Padding: 14px 16px
- Text: 14px, `#1A1D2B`
- Placeholder: 14px, `#9CA3AF`
- Height: minimal 48px

### 7.4 Chip / Pill

- Background: `#F7F8FC`
- Radius: full
- Padding: 8px 12px
- Text: 12px, weight 600
- Icon: 14px (opsional)

**Varian:**

- XP chip: ikon ⚡ + text amber
- Streak chip: ikon 🔥 + text amber
- Badge chip: ikon 🏆 + text primary

### 7.5 Badge

- Ukuran: 48x48 (standar) atau 64x64 (besar)
- Radius: 14px
- Background earned: gradient `#FFB020` → `#FF8C00`
- Background locked: `#F7F8FC`
- Ikon: 22–28px
- Label: 10px, `#6B7280`

### 7.6 Level Node (Peta Level)

- Ukuran: 42x42 (badge angka)
- Radius: 12px
- Status:
  - **Selesai:** background `#00C2A8`, text white
  - **Aktif:** background `#5B4FE9`, text white
  - **Terkunci:** background `#E5E7EB`, text `#9CA3AF`

### 7.7 Progress Bar

- Height: 6px (standar) atau 8px (besar)
- Radius: full
- Background: `#E5E7EB`
- Fill XP: gradient `#FFB020` → `#FF8C00`
- Fill Mastery: gradient `#5B4FE9` → `#00C2A8`
- Fill Alert: gradient `#FFB020` → `#FF6B6B`

### 7.8 Code Block

- Background: `#1A1D2B`
- Radius: 10px
- Padding: 14px
- Font: JetBrains Mono, 12px, line-height 1.7
- Warna:
  - Keyword: `#C792EA`
  - Variable: `#82AAFF`
  - String: `#C3E88D`
  - Number: `#F78C6C`
  - Comment: `#6B7280`

### 7.9 Bottom Sheet

- Radius top: 24px
- Background: `#FFFFFF`
- Shadow: Elevation 4
- Drag handle: 40x4px, `#E5E7EB`, radius full
- Padding: 20px

### 7.10 Toast / Snackbar

- Background: `#1A1D2B`
- Text: `#FFFFFF`, 13px
- Radius: 12px
- Padding: 14px 16px
- Posisi: bottom, 20px dari bawah
- Durasi: 3 detik

---

## 8. Ikonografi

**Set ikon:** Heroicons atau Lucide (konsisten satu set).

**Ukuran:**

- Small: 16px
- Standar: 20px
- Medium: 24px
- Large: 32px
- Hero: 48px

**Emoji sebagai visual anchor (bukan ikon UI):**

- 💡 Hint
- 🔥 Streak
- ⚡ XP
- 🏆 Badge
- 🎉 Level complete
- 🔒 Locked
- 🎯 Recommendation

**Aturan:**

- Emoji hanya di body content, **bukan** di tombol atau input.
- Jangan campur banyak set ikon.

---

## 9. Motion & Animation

### 9.1 Durasi

| Nama    | Durasi | Penggunaan               |
| ------- | ------ | ------------------------ |
| Instant | 100ms  | Hover, tap feedback      |
| Fast    | 200ms  | Transisi kecil           |
| Normal  | 300ms  | Transisi layar, modal    |
| Slow    | 500ms  | Animasi reward, level up |

### 9.2 Easing

| Nama        | Nilai                          | Penggunaan       |
| ----------- | ------------------------------ | ---------------- |
| Ease Out    | `cubic-bezier(0.0, 0, 0.2, 1)` | Muncul           |
| Ease In     | `cubic-bezier(0.4, 0, 1, 1)`   | Menghilang       |
| Ease In Out | `cubic-bezier(0.4, 0, 0.2, 1)` | Transisi standar |

### 9.3 Animasi Penting

| Event            | Animasi                            |
| ---------------- | ---------------------------------- |
| Tap tombol       | Scale 0.97, 100ms                  |
| Naik level       | Scale + fade + confetti, 500ms     |
| Dapat XP         | Angka naik dari 0 ke target, 300ms |
| Streak bertambah | Flame pulse, 300ms                 |
| Salah jawab      | Shake, 200ms                       |
| Benar jawab      | Green pulse, 200ms                 |

---

## 10. Layout Principles

### 10.1 Grid

- **Base:** 4px grid
- **Margin horizontal:** 20px
- **Max content width:** full width (mobile-first)
- **Gap antar card:** 12px
- **Gap antar section:** 32px

### 10.2 Struktur Layar

```
┌─────────────────────────┐
│ Status Bar (28px)       │
├─────────────────────────┤
│ Header (sticky)         │
│ - Back button           │
│ - Title                 │
│ - Action (opsional)     │
├─────────────────────────┤
│                         │
│ Content (scrollable)    │
│                         │
│                         │
├─────────────────────────┤
│ Bottom Area (sticky)    │
│ - Primary CTA           │
│ - Safe area (20px)      │
└─────────────────────────┘
```

### 10.3 Safe Area

- **Top:** 28px (status bar)
- **Bottom:** 20px (safe padding)
- **Horizontal:** 20px

### 10.4 Touch Target

- **Minimum:** 44x44px
- **Rekomendasi:** 48x48px
- **Gap antar tombol:** minimal 8px

---

## 11. Do's & Don'ts

### ✅ Do

- Gunakan warna dari palet ini saja
- Konsisten 20px padding horizontal
- Radius 12px untuk tombol, 16px untuk card
- Shadow subtle
- Kontras WCAG AA
- Emoji hanya di body content
- Test di layar kecil (360px)

### ❌ Don't

- Jangan pakai hitam murni (`#000000`) untuk teks
- Jangan pakai warna di luar palet
- Jangan pakai shadow gelap/tebal
- Jangan pakai lebih dari 3 font size per layar
- Jangan pakai border radius berbeda-beda di satu layar
- Jangan pakai emoji di dalam tombol
- Jangan pakai ALL CAPS untuk body text
- Jangan pakai animasi lebih dari 500ms (kecuali celebration)

---

## 12. Aksesibilitas

- **Kontras:** minimal WCAG AA (4.5:1 teks normal, 3:1 teks besar)
- **Touch target:** minimal 44x44px
- **Font minimal:** 11px untuk caption, 13px untuk body
- **Warna bukan satu-satunya pembeda:** tambahkan ikon atau label
- **Focus state:** terlihat jelas (border primary)
- **Screen reader:** label pada ikon penting
- **Mode teks besar:** future work (opsional)

---

## 13. Responsive Behavior

Target utama: **Android 360–412px width.**

| Breakpoint | Lebar     | Catatan      |
| ---------- | --------- | ------------ |
| Small      | 320–360px | Padding 16px |
| Standar    | 360–412px | Padding 20px |
| Large      | 412–480px | Padding 24px |
| Tablet     | > 480px   | Future work  |

**Aturan:**

- Layout fluid, max width 100%
- Gambar/ikon: fixed size
- Code block: horizontal scroll jika perlu

---

## 14. Referensi

- `reference/awesome-design-md/` — 84 contoh design system
- `reference/web-interface-guidelines/` — pedoman UI Vercel
- `docs/00-phases.md` — Phase 1 (Design System)
- `docs/01-prd.md` — PRD KODIRA
- `DESIGN.md` (root) — versi Stitch-compatible dari dokumen ini

**Inspirasi visual:**

- Duolingo — playful gamifikasi
- SoloLearn — clean learning UI
- Linear — tipografi presisi
- Stripe — gradient elegan

---

## 15. Keputusan yang Masih Diperlukan

- [ ] Font final: Inter atau Poppins?
- [ ] Dark mode masuk MVP atau future work? (Rekomendasi: future work)
- [ ] Library ikon final (Heroicons vs Lucide)
- [ ] Logo KODIRA: final atau masih konsep?
- [ ] Tone warna gradient (lebih hangat atau lebih dingin?)

---

## 16. Update Log

| Tanggal    | Perubahan         |
| ---------- | ----------------- |
| 2026-10-16 | Draft awal dibuat |
