# 02D-ADMIN-DESIGN-SYSTEM.md — Design System Admin Panel KODIRA

## 1. Konteks & Tujuan

KODIRA Admin Panel adalah platform web berbasis Next.js 15 dan React 19 yang dirancang khusus untuk dosen dan guru JTIK dalam mengelola kegiatan pembelajaran pemrograman C++ dan Java. Fokus utama dari design system ini adalah menciptakan antarmuka yang profesional, efisien, dan data-heavy, namun tetap mempertahankan identitas visual brand KODIRA yang sudah mapan di aplikasi mobile.

Dokumen ini berfungsi sebagai spesifikasi visual tunggal bagi pengembang untuk memastikan setiap komponen UI—mulai dari tabel kompleks hingga dashboard analitik—memiliki standar kualitas tinggi sekelas "high-end agency". Kita menghindari pola visual generatif atau template default shadcn/ui yang membosankan dengan melakukan override menyeluruh terhadap tokens warna, tipografi, dan ritme spasial.

## 2. Brand Identity (Consistency Bridge)

Admin panel ini menggunakan palet warna yang diekstraksi langsung dari `KodiraColors` di aplikasi mobile untuk menjamin jembatan kognitif yang mulus antara platform dosen dan mahasiswa.

### 2.1 Palet Warna Utama (Exact Values)

| Kategori | Token | Hex | Penggunaan Utama |
|---|---|---|---|
| **Primary** | `primary-700` | `#5B4FE9` | Brand color, main CTA, active states, focus rings. |
| | `primary-900` | `#3D33B8` | Hover state untuk primary buttons, deep accents. |
| | `primary-100` | `#EEF0F7` | Background menu aktif, subtle highlights. |
| **Success** | `success-500` | `#00C2A8` | Indikator kelulusan, penyelesaian level, status aktif. |
| **Alert** | `alert-500` | `#FF6B6B` | Status terkunci, error kritis, tombol destruktif. |
| | `alert-700` | `#D94A4A` | Hover state untuk elemen destruktif. |
| **Warning** | `warning-500` | `#FBBF24` | Status remedial, perhatian sedang, pending review. |
| **Reward** | `reward-500` | `#FFB020` | Badge mahasiswa, akumulasi XP, streak milestones. |
| **Neutral** | `neutral-900` | `#1A1D2B` | Teks utama, sidebar background, code canvas. |
| | `neutral-700` | `#4B5563` | Teks sekunder, deskripsi, icons. |
| | `neutral-200` | `#E5E7EB` | Dividers, borders, subtle grids. |
| | `neutral-100` | `#F7F8FC` | App background, card surface hover. |
| | `neutral-0` | `#FFFFFF` | Card surface, modal background, topbar. |
| | `code-bg` | `#1A1D2B` | Background code block, preview materi (sama dengan neutral-900) |

### 2.2 Tipografi (Hierarchy of Information)

Sistem tipografi menggunakan Inter sebagai font antarmuka utama karena keterbacaannya yang luar biasa pada layar monitor, dan JetBrains Mono untuk blok kode guna memberikan nuansa teknis yang presisi.

- **UI Font**: Inter (Google Fonts) — Variable font preferred.
- **Code Font**: JetBrains Mono — Untuk preview materi dan editor mini.

| Style | Size | Weight | Line Height | Tracking | Penggunaan |
|---|---|---|---|---|---|
| **Display** | 32px | 800 (ExtraBold) | 1.2 | -0.02em | Page Hero, Dashboard Stats Besar |
| **H1** | 28px | 700 (Bold) | 1.3 | -0.01em | Title Halaman Utama |
| **H2** | 24px | 700 (Bold) | 1.3 | -0.01em | Section Headers, Modal Titles |
| **H3** | 20px | 600 (SemiBold) | 1.4 | 0 | Sub-section, Card Titles |
| **Body Large** | 16px | 400 (Regular) | 1.6 | 0 | Intro paragraphs, Lead text |
| **Body** | 14px | 400 (Regular) | 1.6 | 0 | **Default UI**, Table cells, Descriptions |
| **Body Semi** | 14px | 600 (SemiBold) | 1.6 | 0 | Form labels, Navigation items |
| **Caption** | 12px | 400 (Regular) | 1.4 | 0.01em | Metadata, Table headers, Tooltips |
| **Overline** | 11px | 600 (SemiBold) | 1.2 | 0.2em | Small badges, section labels (UPPERCASE) |

### 2.3 Spacing & Radius (The Grid)

Menerapkan basis 4px (Soft Grid) untuk konsistensi vertikal dan horizontal.

- **Radius (Border Radius)**:
  - `sm`: 8px (Inner components, checkboxes)
  - `md`: 12px (Buttons, Input fields, Badges)
  - `lg`: 16px (Cards, Dashboard widgets)
  - `xl`: 20px (Modals, Large dialogs)
  - `xl2`: 24px (Surface enclosures)

- **Spacing (Scale)**:
  - `space-1`: 4px | `space-2`: 8px | `space-3`: 12px | `space-4`: 16px
  - `space-6`: 24px | `space-8`: 32px | `space-12`: 48px | `space-16`: 64px

## 3. Layout System (Structural Anatomy)

Tata letak dirancang untuk meminimalkan gangguan dan memaksimalkan area kerja data.

### 3.1 Sidebar (The Control Center)
- **Lebar**: 240px (Fixed).
- **Warna**: `neutral-900` (Dark Sidebar) untuk kontras tinggi dengan area konten.
- **Header**: Logo KODIRA (32px) + Teks "KODIRA Admin" (H3 SemiBold, White).
- **Navigasi**:
  - Tinggi item: 44px.
  - State Aktif: Background `primary-700` dengan 15% opacity, teks `primary-500`, border-left 3px `primary-700`.
  - State Hover: Background `neutral-700` dengan 20% opacity.
- **Footer**: Profile summary teacher (Avatar 32px, Nama, Role) + Tombol Sign Out.

### 3.2 Topbar (The Utility Belt)
- **Tinggi**: 64px (Sticky).
- **Warna**: `neutral-0` dengan border-bottom 1px `neutral-200`.
- **Elemen**: Breadcrumb (kiri), Search Global (tengah), Notifications & Settings (kanan).
- **Elevasi**: Saat scroll, tambahkan `shadow-sm` untuk memisahkan dari konten.

### 3.3 Content Area (The Workspace)
- **Padding**: 32px di semua sisi (space-8).
- **Max-width**: 1440px (Containerized) untuk menjaga keterbacaan pada monitor ultrawide.
- **Background**: `neutral-100` (#F7F8FC) untuk memberikan kedalaman visual pada kartu putih.

## 4. Component Library (Premium Customizations)

### 4.1 Buttons
Setiap button memiliki efek haptic mikro (subtle scale pada click).

| Varian | Style | Hover |
|---|---|---|
| **Primary** | Bg: `#5B4FE9`, Text: White | Bg: `#3D33B8`, Shadow: `md` |
| **Secondary** | Bg: White, Border: `neutral-200` | Bg: `neutral-100`, Border: `neutral-300` |
| **Destructive** | Bg: `#FF6B6B`, Text: White | Bg: `#D94A4A`, Scale: 1.02 |
| **Ghost** | Bg: Transparan, Text: `neutral-700` | Bg: `primary-100`, Text: `primary-700` |

### 4.2 Data Table (The Core)
Tabel harus mampu menangani ratusan baris data mahasiswa tanpa mengorbankan performa.
- **Header**: Sticky, background `neutral-100`, teks SemiBold uppercase (12px).
- **Row**: Tinggi minimum 56px, hover state `bg-neutral-50`.
- **Pagination**: Terintegrasi di footer tabel, "Showing X to Y of Z" di kiri, navigasi halaman di kanan.
- **Empty State**: Ilustrasi minimalis (Lottie atau SVG) + tombol aksi primer.

### 4.3 Forms & Inputs
- **Label**: Berada di atas input, SemiBold 13px, `neutral-700`.
- **Input**: Border 1px `neutral-200`, focus ring 3px `primary-700` dengan 15% alpha.
- **Validation**: Error message berwarna `alert-500` muncul dengan animasi slide-down 150ms.

## 5. Micro-Interactions & Motion

Motion adalah pembeda antara dashboard murah dan alat profesional. Kita menggunakan `framer-motion` untuk semua transisi.

- **Page Transitions**: Fade-in (opacity 0 -> 1) dan slide-up (10px) selama 250ms.
- **Hover Transitions**: Durasi 200ms `ease-out` untuk perubahan background dan shadow.
- **Modal Open**: Spring physics (mass: 0.5, stiffness: 300) untuk efek elastis yang memuaskan.
- **Toast Notifications**: Slide-in dari kanan atas, menghilang otomatis setelah 4 detik kecuali di-hover.

## 6. Aksesibilitas (WCAG 2.2 AA)

Admin panel wajib inklusif bagi seluruh tenaga pengajar.
- **Kontras**: Teks utama wajib memiliki rasio kontras minimal 4.5:1 terhadap background.
- **Focus States**: Tidak boleh menghilangkan `outline` tanpa pengganti visual (gunakan focus ring primer kita).
- **Keyboard Navigation**: Seluruh aksi (Create, Edit, Delete) wajib dapat diakses via tombol `Tab` dan `Enter`.
- **ARIA Labels**: Setiap icon-only button wajib memiliki `aria-label` yang deskriptif.

## 7. Strategi Implementasi (Fase 3B)

1. **Tailwind 4 Setup**: Konfigurasi `tailwind.config.ts` untuk menggunakan variabel CSS yang didefinisikan di `globals.css`.
2. **Shadcn Override**: Melakukan modifikasi pada folder `components/ui` untuk memaksa penggunaan Radius 12px-20px dan palet KODIRA.
3. **Skeleton Loading**: Setiap halaman wajib memiliki state skeleton yang menyerupai layout asli untuk mengurangi layout shift (CLS).

## 8. Definition of Done (Visual)

- [ ] Tidak ada penggunaan warna biru standar Tailwind (#3B82F6) kecuali untuk link informasi spesifik.
- [ ] Semua button menggunakan `Radius: md (12px)`.
- [ ] Tabel memiliki header sticky dan hover state yang jelas.
- [ ] Typography konsisten menggunakan Inter (UI) dan JetBrains Mono (Code).
- [ ] WCAG 2.2 AA Contrast check passed pada semua halaman utama.
- [ ] Dark mode dipersiapkan melalui CSS variables (walaupun belum diaktifkan di MVP).

## 9. Future Work (Design Debt)

- **Dark Mode**: Implementasi otomatis berdasarkan sistem OS.
- **Data Visualization**: Library chart kustom menggunakan `recharts` dengan palet warna KODIRA.
- **Command Palette (Cmd+K)**: Navigasi cepat untuk mencari mahasiswa atau kelas.
- **Multi-select Actions**: Bar aksi melayang di bawah layar saat lebih dari satu baris tabel dipilih.
