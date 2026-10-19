# DESIGN.md — KODIRA

Design system untuk aplikasi mobile KODIRA. File ini dibaca oleh Google Stitch
dan AI coding agent untuk generate UI yang konsisten.

**Product:** KODIRA — gamified coding learning app for Android  
**Target Users:** Mahasiswa JTIK semester 1 (17–19 tahun)  
**Platform:** Android mobile, portrait, 390x844 px  
**Language:** Bahasa Indonesia (UI copy)

---

## 1. Visual Theme & Atmosphere

**Mood:** Playful but focused. Friendly, student-oriented, tidak berlebihan.

**Design philosophy:**

- Setiap elemen punya tujuan. No decoration without function.
- Layar belajar sederhana (coherence). No distractions.
- Immediate feedback terlihat (warna, animasi, ikon).
- Konsisten di semua layar.

**Inspirations:**

- **Duolingo** — playful gamification, high motivation
- **SoloLearn** — clean, easy-to-read learning UI
- **Linear** — precise typography, sharp layout

**Key visual identity:**

- Rounded corners (12–24px radius)
- Soft shadows (subtle, not dramatic)
- Generous spacing
- Emoji as visual anchor (bukan ikon UI)
- Code blocks dengan dark background dan syntax highlighting

**Density:** Comfortable. Tidak padat, tidak terlalu lega.

**Surface feel:** Light mode only. Clean white canvas dengan soft gray backgrounds.

---

## 2. Color Palette & Roles

### Primary — Indigo Focus

| Token         | Hex       | Role                                       |
| ------------- | --------- | ------------------------------------------ |
| `primary-900` | `#3D33B8` | Hover, pressed state                       |
| `primary-700` | `#5B4FE9` | **Main CTA, headers, active state, brand** |
| `primary-500` | `#7C6FF0` | Gradients, light accents                   |
| `primary-100` | `#EEF0F7` | Light backgrounds, chips                   |

### Success — Mint Growth

| Token         | Hex       | Role                                                 |
| ------------- | --------- | ---------------------------------------------------- |
| `success-700` | `#00A88E` | Hover                                                |
| `success-500` | `#00C2A8` | **Completed levels, correct answers, earned badges** |
| `success-100` | `#E6F9F5` | Light backgrounds                                    |

### Reward — Amber XP

| Token        | Hex       | Role                                |
| ------------ | --------- | ----------------------------------- |
| `reward-700` | `#E59400` | Hover                               |
| `reward-500` | `#FFB020` | **XP bars, coins, streaks, badges** |
| `reward-100` | `#FFF4E0` | Light backgrounds                   |

### Alert — Coral Lock

| Token       | Hex       | Role                                        |
| ----------- | --------- | ------------------------------------------- |
| `alert-700` | `#D94A4A` | Hover                                       |
| `alert-500` | `#FF6B6B` | **Locked levels, fatal errors, quiz timer** |
| `alert-100` | `#FFE5E5` | Light backgrounds                           |

### Neutral

| Token         | Hex       | Role                              |
| ------------- | --------- | --------------------------------- |
| `neutral-900` | `#1A1D2B` | **Text primary, code background** |
| `neutral-700` | `#4B5563` | Text secondary                    |
| `neutral-500` | `#6B7280` | Text tertiary, captions           |
| `neutral-300` | `#9CA3AF` | Placeholder, disabled text        |
| `neutral-200` | `#E5E7EB` | Divider, border                   |
| `neutral-100` | `#F7F8FC` | **Background, subtle card**       |
| `neutral-0`   | `#FFFFFF` | Card surface                      |

### Semantic

| Token     | Hex       | Role           |
| --------- | --------- | -------------- |
| `info`    | `#3B82F6` | Info messages  |
| `warning` | `#F59E0B` | Warnings       |
| `error`   | `#EF4444` | Errors         |
| `success` | `#10B981` | Success states |

### Code Syntax Highlighting

| Token           | Hex       | Role                  |
| --------------- | --------- | --------------------- |
| `code-bg`       | `#1A1D2B` | Code block background |
| `code-keyword`  | `#C792EA` | Keywords (purple)     |
| `code-variable` | `#82AAFF` | Variables (blue)      |
| `code-string`   | `#C3E88D` | Strings (green)       |
| `code-number`   | `#F78C6C` | Numbers (orange)      |
| `code-comment`  | `#6B7280` | Comments (gray)       |

**Color rules:**

- **Do not introduce colors outside this palette.** Use opacity for variants.
- Text contrast: minimum WCAG AA (4.5:1 for body, 3:1 for large text).
- Color alone is never the only differentiator. Always add icon or label.
- Light mode only. Dark mode is future work.

---

## 3. Typography Rules

### Font Family

| Function  | Font               | Fallback                          |
| --------- | ------------------ | --------------------------------- |
| UI & Body | **Inter**          | -apple-system, Roboto, sans-serif |
| Code      | **JetBrains Mono** | Courier New, monospace            |

**Bundle Inter and JetBrains Mono di assets/fonts/.**

### Type Scale

| Name       | Size | Weight | Line Height | Usage                     |
| ---------- | ---- | ------ | ----------- | ------------------------- |
| `display`  | 32px | 800    | 1.2         | Hero, splash              |
| `h1`       | 24px | 700    | 1.3         | Main screen titles        |
| `h2`       | 20px | 700    | 1.3         | Section titles            |
| `h3`       | 17px | 600    | 1.4         | Sub-sections              |
| `body-lg`  | 15px | 400    | 1.6         | Primary body text         |
| `body`     | 13px | 400    | 1.6         | Default body              |
| `body-sm`  | 12px | 400    | 1.5         | Descriptions              |
| `caption`  | 11px | 500    | 1.4         | Labels, metadata          |
| `overline` | 10px | 700    | 1.4         | Uppercase category labels |
| `code`     | 12px | 400    | 1.7         | Code blocks               |

**Typography rules:**

- Maximum 3 font sizes per screen.
- Headings max 2 lines.
- Body text minimum 13px for mobile readability.
- Line height minimum 1.4 for body.
- Avoid ALL CAPS except for short labels (overline).
- Never use pure black (`#000000`) for text. Use `neutral-900`.

---

## 4. Component Stylings

### 4.1 Button — Primary

```
Background: #5B4FE9
Text color: #FFFFFF
Font weight: 700
Font size: 14px
Padding: 15px 20px
Border radius: 12px
Min height: 48px
Shadow: 0 8px 20px rgba(91, 79, 233, 0.35)
```

**States:**

- Hover: background `primary-900`
- Pressed: scale 0.97, 100ms
- Disabled: opacity 0.4, cursor not-allowed

### 4.2 Button — Secondary

```
Background: transparent
Border: 1.5px solid #5B4FE9
Text color: #5B4FE9
Font weight: 600
Font size: 14px
Padding: 14px 20px
Border radius: 12px
Min height: 48px
```

### 4.3 Button — Text

```
Background: transparent
Text color: #5B4FE9
Font weight: 600
Font size: 13px
Padding: 8px 12px
```

### 4.4 Card — Standard

```
Background: #FFFFFF
Border radius: 16px
Padding: 16px
Shadow: 0 2px 8px rgba(26, 29, 43, 0.06)
Gap between cards: 12px
```

### 4.5 Card — Hero

```
Background: #FFFFFF
Border radius: 20px
Padding: 24px
Shadow: 0 4px 16px rgba(26, 29, 43, 0.08)
```

### 4.6 Card — Stat

```
Background: #FFFFFF
Border radius: 14px
Padding: 14px
Text align: center
```

### 4.7 Input

```
Background: #FFFFFF
Border: 1.5px solid #E5E7EB
Border (focus): 1.5px solid #5B4FE9
Border radius: 12px
Padding: 14px 16px
Text: 14px, color #1A1D2B
Placeholder: 14px, color #9CA3AF
Min height: 48px
```

### 4.8 Chip / Pill

```
Background: #F7F8FC
Border radius: 9999px
Padding: 8px 12px
Text: 12px, weight 600
Icon: 14px (optional)
```

**Variants:**

- XP chip: ⚡ icon + amber text
- Streak chip: 🔥 icon + amber text
- Badge chip: 🏆 icon + primary text

### 4.9 Badge

```
Size: 48x48 (standard) or 64x64 (large)
Border radius: 14px
Background (earned): linear-gradient(#FFB020, #FF8C00)
Background (locked): #F7F8FC
Icon: 22–28px
Label: 10px, color #6B7280
```

### 4.10 Level Node (Level Map)

```
Size: 42x42
Border radius: 12px
Status:
  - Completed: bg #00C2A8, text white
  - Active: bg #5B4FE9, text white
  - Locked: bg #E5E7EB, text #9CA3AF
```

### 4.11 Progress Bar

```
Height: 6px (standard) or 8px (large)
Border radius: 9999px
Background: #E5E7EB
Fill XP: linear-gradient(#FFB020, #FF8C00)
Fill Mastery: linear-gradient(#5B4FE9, #00C2A8)
Fill Alert: linear-gradient(#FFB020, #FF6B6B)
```

### 4.12 Code Block

```
Background: #1A1D2B
Border radius: 10px
Padding: 14px
Font: JetBrains Mono, 12px, line-height 1.7
Colors:
  - Keyword: #C792EA
  - Variable: #82AAFF
  - String: #C3E88D
  - Number: #F78C6C
  - Comment: #6B7280
```

### 4.13 Bottom Sheet

```
Border radius (top): 24px
Background: #FFFFFF
Shadow: 0 8px 24px rgba(26, 29, 43, 0.12)
Drag handle: 40x4px, #E5E7EB, radius 9999px
Padding: 20px
```

### 4.14 Toast / Snackbar

```
Background: #1A1D2B
Text: #FFFFFF, 13px
Border radius: 12px
Padding: 14px 16px
Position: bottom, 20px from bottom
Duration: 3 seconds
```

---

## 5. Layout Principles

### 5.1 Spacing Scale (4px base)

| Token      | Value | Usage                         |
| ---------- | ----- | ----------------------------- |
| `space-1`  | 4px   | Tight gaps                    |
| `space-2`  | 8px   | Element gaps                  |
| `space-3`  | 12px  | Chip padding                  |
| `space-4`  | 16px  | Small card padding            |
| `space-5`  | 20px  | **Horizontal screen padding** |
| `space-6`  | 24px  | Large card padding            |
| `space-8`  | 32px  | Section gaps                  |
| `space-12` | 48px  | Hero spacing                  |
| `space-16` | 64px  | Extra-large spacing           |

**Rules:**

- **Horizontal padding = 20px** consistently across screens.
- Card gaps = 12px.
- Section gaps = 32px.

### 5.2 Border Radius

| Token         | Value  | Usage                 |
| ------------- | ------ | --------------------- |
| `radius-xs`   | 6px    | Small chips           |
| `radius-sm`   | 8px    | Small inputs          |
| `radius-md`   | 12px   | **Buttons, inputs**   |
| `radius-lg`   | 16px   | **Standard cards**    |
| `radius-xl`   | 20px   | Hero cards            |
| `radius-2xl`  | 24px   | Modals, bottom sheets |
| `radius-full` | 9999px | Pills, avatars, FAB   |

### 5.3 Screen Structure

```
┌─────────────────────────┐
│ Status Bar (28px)       │
├─────────────────────────┤
│ Header (sticky)         │
│ - Back button           │
│ - Title                 │
│ - Action (optional)     │
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

### 5.4 Touch Targets

- Minimum: 44x44px
- Recommended: 48x48px
- Gap between buttons: minimum 8px

### 5.5 Safe Area

- Top: 28px (status bar)
- Bottom: 20px
- Horizontal: 20px

---

## 6. Depth & Elevation

| Level   | Shadow                            | Usage               |
| ------- | --------------------------------- | ------------------- |
| 0       | none                              | Flat surface        |
| 1       | `0 1px 2px rgba(26,29,43,0.05)`   | Subtle card         |
| 2       | `0 2px 8px rgba(26,29,43,0.06)`   | Standard card       |
| 3       | `0 4px 16px rgba(26,29,43,0.08)`  | Active card, FAB    |
| 4       | `0 8px 24px rgba(26,29,43,0.12)`  | Modal, bottom sheet |
| Primary | `0 8px 20px rgba(91,79,233,0.35)` | Primary button, FAB |

**Rules:**

- Never use dark shadows. Keep subtle.
- Higher elevation = closer to user (modal, FAB).
- Consistency: don't use 5 elevation levels on one screen.

---

## 7. Do's and Don'ts

### ✅ Do

- Use only colors from this palette.
- Keep horizontal padding at 20px consistently.
- Use radius 12px for buttons, 16px for cards.
- Keep shadows subtle.
- Ensure WCAG AA contrast.
- Use emoji as content anchors only.
- Test on small screens (360px).
- Use 4px grid for all spacing.

### ❌ Don't

- Never use pure black (`#000000`) for text.
- Don't use colors outside the palette.
- Don't use dark or heavy shadows.
- Don't use more than 3 font sizes per screen.
- Don't mix border radii on one screen.
- Don't use emoji inside buttons or inputs.
- Don't use ALL CAPS for body text.
- Don't use animations longer than 500ms (except celebrations).

---

## 8. Responsive Behavior

**Primary target:** Android 360–412px width.

| Breakpoint | Width     | Note         |
| ---------- | --------- | ------------ |
| Small      | 320–360px | Padding 16px |
| Standard   | 360–412px | Padding 20px |
| Large      | 412–480px | Padding 24px |
| Tablet     | > 480px   | Future work  |

**Rules:**

- Fluid layout, max width 100%.
- Images/icons: fixed size.
- Code blocks: horizontal scroll if needed.
- Portrait orientation only.

---

## 9. Icons & Emoji

### Icon Library

**Lucide** (primary).

- Sizes: 16, 20, 24, 32, 48px
- Stroke: 1.5–2px
- Color: matches text color

### Emoji as Visual Anchor

Used in body content, **not** in buttons or inputs.

| Emoji | Usage          |
| ----- | -------------- |
| 💡    | Hint           |
| 🔥    | Streak         |
| ⚡    | XP             |
| 🏆    | Badge          |
| 🎉    | Level complete |
| 🔒    | Locked         |
| 🎯    | Recommendation |

**Rules:**

- Use emoji sparingly.
- Never mix multiple emoji sets.
- Never use emoji in buttons or form inputs.

---

## 10. Motion & Animation

### Durations

| Name    | Duration | Usage                       |
| ------- | -------- | --------------------------- |
| Instant | 100ms    | Hover, tap feedback         |
| Fast    | 200ms    | Small transitions           |
| Normal  | 300ms    | Screen transitions, modals  |
| Slow    | 500ms    | Reward animations, level up |

### Easing

| Name        | Value                          | Usage                |
| ----------- | ------------------------------ | -------------------- |
| Ease Out    | `cubic-bezier(0.0, 0, 0.2, 1)` | Appearing            |
| Ease In     | `cubic-bezier(0.4, 0, 1, 1)`   | Disappearing         |
| Ease In Out | `cubic-bezier(0.4, 0, 0.2, 1)` | Standard transitions |

### Key Animations

| Event           | Animation                      |
| --------------- | ------------------------------ |
| Button tap      | Scale 0.97, 100ms              |
| Level up        | Scale + fade + confetti, 500ms |
| XP gained       | Number counts up, 300ms        |
| Streak increase | Flame pulse, 300ms             |
| Wrong answer    | Shake, 200ms                   |
| Correct answer  | Green pulse, 200ms             |

---

## 11. Accessibility

- **Contrast:** minimum WCAG AA (4.5:1 body, 3:1 large text).
- **Touch target:** minimum 44x44px.
- **Font size:** minimum 11px caption, 13px body.
- **Color independence:** never rely on color alone. Add icon or label.
- **Focus state:** clearly visible (primary border).
- **Screen reader:** labels on important icons.
- **Text scale:** respects system font size (future work).

---

## 12. Code Syntax Highlighting

For code blocks (C++ and Java):

```
Background: #1A1D2B
Border radius: 10px
Padding: 14px
Font: JetBrains Mono, 12px, line-height 1.7

Colors:
  Keyword  → #C792EA (purple)
  Variable → #82AAFF (blue)
  String   → #C3E88D (green)
  Number   → #F78C6C (orange)
  Comment  → #6B7280 (gray)
```

**Example (C++):**

```cpp
for (int i = 0; i < 5; i++) {
  cout << "Halo!" << endl;
}
```

---

## 13. Agent Prompt Guide

When using this DESIGN.md with Google Stitch or AI coding agents,
use these reference prompts.

### Quick Color Reference

```
Primary:   #5B4FE9
Success:   #00C2A8
Reward:    #FFB020
Alert:     #FF6B6B
Text:      #1A1D2B
BG:        #F7F8FC
Surface:   #FFFFFF
Border:    #E5E7EB
```

### Quick Component Reference

```
Button Primary:   bg #5B4FE9, radius 12px, padding 15px 20px, white text
Card Standard:    bg #FFFFFF, radius 16px, padding 16px, shadow subtle
Input:            border 1.5px #E5E7EB, radius 12px, height 48px
Progress Bar:     height 6px, radius full, bg #E5E7EB
Code Block:       bg #1A1D2B, radius 10px, JetBrains Mono 12px
```

### Example Prompts

**Login Screen:**

```
Design a login screen for KODIRA (Android, 390x844).
- Diagonal gradient background (#5B4FE9 → #7C6FF0)
- Centered white rounded square (88x88) with "K" logo
- App name "KODIRA" 34px bold white
- Tagline "Belajar coding, satu level sehari."
- Input "NIM" and "Password" with glassmorphism
- White button "Masuk" with indigo text
Use Inter font. All UI copy in Indonesian.
```

**Level Map Screen:**

```
Design the HOME screen of KODIRA.
- Header: "Hai, Ridho 👋" + "Level 12 — Perulangan" + avatar
- Stat chips: ⚡ 1,240 XP, 🔥 7 Streak, 🏆 8 Badge
- XP progress bar (62% filled, amber gradient)
- Vertical scrollable list of level cards:
  - Completed (mint bg with checkmark)
  - Current (indigo border + glow)
  - Locked (55% opacity, gray badge)
Use Inter font. Padding 20px horizontal.
```

**Quiz Screen:**

```
Design a quiz screen for KODIRA.
- Header: back arrow, "Kuis Level 12", counter "3 / 5"
- Red timer "⏱ 01:24"
- Progress bar (60%, indigo to purple)
- Question card with C++ code block
- 4 answer options (A/B/C/D) with 12px radius
- One option selected (indigo border, light indigo bg)
- Bottom: "Kirim Jawaban" button
Use Inter font. Code block uses JetBrains Mono.
```

---

## 14. Design Tokens Export (Flutter)

Untuk memudahkan implementasi di Flutter, siapkan `lib/app/theme.dart`:

```dart
class KodiraColors {
  static const primary = Color(0xFF5B4FE9);
  static const primaryDark = Color(0xFF3D33B8);
  static const primaryLight = Color(0xFFEEF0F7);

  static const success = Color(0xFF00C2A8);
  static const reward = Color(0xFFFFB020);
  static const alert = Color(0xFFFF6B6B);

  static const textPrimary = Color(0xFF1A1D2B);
  static const textSecondary = Color(0xFF4B5563);
  static const textTertiary = Color(0xFF6B7280);

  static const bg = Color(0xFFF7F8FC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);

  static const codeBg = Color(0xFF1A1D2B);
}

class KodiraSpacing {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s12 = 48.0;
}

class KodiraRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const full = 9999.0;
}
```

---

## 15. Keputusan yang Masih Diperlukan

- [ ] Logo KODIRA: final atau masih konsep?
- [ ] Gradient tone: lebih hangat atau lebih dingin?
- [ ] Apakah perlu custom illustration (untuk empty states)?

---

## 16. Update Log

| Tanggal    | Perubahan         |
| ---------- | ----------------- |
| 2026-10-16 | Draft awal dibuat |
