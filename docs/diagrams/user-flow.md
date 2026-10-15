# User Flow Diagram — KODIRA

Diagram alur interaksi pengguna dalam aplikasi KODIRA. Mencakup alur utama, logika adaptive engine, AI hint and feedback, serta mekanisme level locking.

## 1. Alur Utama

Alur utama pengguna dari splash screen hingga kembali ke home setelah menyelesaikan atau remedial level.

```mermaid
flowchart TD
    SA["Splash Screen"] --> LN["Login NIM"]
    LN --> VN{"Verifikasi NIM?"}
    VN -- Ya --> HL["Home - Peta Level"]
    VN -- Tidak --> LN
    HL --> PL["Pilih Level"]
    PL --> LT{"Level Terbuka?"}
    LT -- Ya --> MT["Materi"]
    LT -- Tidak --> LL["Level Locked"]
    MT --> EX["Latihan"]
    EX --> AQ["Kuis Adaptif"]
    AQ --> AP["Analisis Performa"]
    AP --> KM{"Keputusan Mastery?"}
    KM -- Lulus --> LU["Level Up + XP"]
    KM -- Remedial --> RT["Remedial Topik"]
    KM -- Lock --> LL
    RT --> UK["Ulang Kuis Topik"]
    UK --> KM
    LU --> HB["Kembali ke Home"]
    LL --> RH["Remedial Level Asal"]
    RH --> UL["Unlock Level"]
    UL --> AQ
```

## 2. Adaptive Engine

Logika perhitungan mastery dan keputusan unlocking atau remedial berdasarkan event pengguna.

```mermaid
flowchart TD
    UE["Event User"] --> UM["Update Mastery"]
    UM --> HM["Hitung Mastery"]
    HM --> TC{"Threshold Mastery?"}
    TC -- "M >= 70%" --> LUL["Lulus"]
    TC -- "40% <= M < 70%" --> RT["Remedial Topik"]
    TC -- "M < 40%" --> CK{"Level > 10?"}
    CK -- Ya --> LK["Lock + Remedial Level Asal"]
    CK -- Tidak --> RT
    LUL --> OUT1["Buka Level Berikutnya"]
    RT --> OUT2["Remedial Topik Saja"]
    LK --> OUT3["Remedial Level Asal"]
```

## 3. AI Hint dan Feedback

Dua sub-flow: permintaan hint sebelum submit, dan feedback setelah submit. Keduanya melewati guardrail.

```mermaid
flowchart TD
    subgraph FlowA["Flow A - Hint"]
        TR["Trigger: user minta / stuck > 120s / salah >= 3"] --> AG["AI Generate Hint"]
        AG --> GV{"Guardrail Lolos?"}
        GV -- Ya --> TH["Tampilkan Hint"]
        GV -- Tidak --> FT["Fallback Template"]
        FT --> TH
    end

    subgraph FlowB["Flow B - Setelah Submit"]
        US["User Submit Jawaban"] --> AI["AI Nilai + Feedback"]
        AI --> GV2{"Guardrail Lolos?"}
        GV2 -- Ya --> TF["Tampilkan Feedback"]
        GV2 -- Tidak --> FB["Feedback Rule-Based"]
        FB --> TF
        TF --> DH["Hapus Jawaban Mentah"]
        DH --> SM["Simpan Ringkasan Mastery"]
    end
```

## 4. Level Locking

Mekanisme penguncian level ketika mastery di bawah 40 persen serta proses remedial dan unlock.

```mermaid
flowchart TD
    ULN["User di Level N"] --> K["Kuis - Soal Level Ini + Ulasan Lama"]
    K --> J["Jawaban"]
    J --> MC{"Mastery < 40%?"}
    MC -- Tidak --> DONE["Lanjut Level Berikutnya"]
    MC -- Ya --> LV{"Level > 10?"}
    LV -- Tidak --> RT["Remedial Topik - Tanpa Lock"]
    RT --> K
    LV -- Ya --> LLN["Lock Level N+1"]
    LLN --> NR["Notifikasi Remedial"]
    NR --> RL["Remedial Level Asal - Materi + Latihan + Kuis"]
    RL --> MT{"Mastery Topik Asal Cukup?"}
    MT -- Ya --> UL["Unlock Level N+1"]
    MT -- Tidak --> AIH["AI Hint Level 3"]
    AIH --> RL
    UL --> K
    UL --> XP["XP Diberikan Setelah Level Selesai"]
```
