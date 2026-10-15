# CP & TP — KODIRA

Pemetaan Capaian Pembelajaran (CP) dan Tujuan Pembelajaran (TP) per level.

| Field   | Nilai                                              |
| ------- | -------------------------------------------------- |
| Versi   | 1.0                                                |
| Tanggal | 2026-10-16                                         |
| Status  | Draft                                              |
| Basis   | `docs/01-prd.md`, kurikulum Pemrograman Dasar JTIK |

---

## 1. Pengertian

| Istilah      | Kepanjangan                          | Sifat                | Contoh                               |
| ------------ | ------------------------------------ | -------------------- | ------------------------------------ |
| **CPL**      | Capaian Pembelajaran Lulusan         | Umum, jangka panjang | Kompetensi lulusan JTIK              |
| **CPMK**     | Capaian Pembelajaran Mata Kuliah     | Menengah             | Kompetensi setelah Pemrograman Dasar |
| **CP**       | Capaian Pembelajaran                 | Per level            | "Memahami konsep perulangan"         |
| **TP**       | Tujuan Pembelajaran                  | Spesifik, terukur    | "Menulis for loop dengan benar"      |
| **Sub-CPMK** | Sub-Capaian Pembelajaran Mata Kuliah | Per topik            | Varian dari CP                       |

CP = payung. TP = turunan yang bisa diukur.

---

## 2. CPL (Capaian Pembelajaran Lulusan)

Mengacu pada profil lulusan JTIK:

> Mahasiswa mampu menerapkan konsep dasar pemrograman dan berpikir
> komputasional untuk menyelesaikan masalah sederhana secara mandiri,
> serta memiliki sikap belajar berkelanjutan dalam bidang teknologi.

---

## 3. CPMK (Capaian Pembelajaran Mata Kuliah — Pemrograman Dasar)

> Setelah menyelesaikan mata kuliah Pemrograman Dasar dengan KODIRA,
> mahasiswa mampu:
>
> 1. **Memahami** konsep dasar pemrograman: variabel, tipe data,
>    operator, percabangan, perulangan, fungsi, dan array dalam C++.
> 2. **Menerapkan** konsep OOP dasar (class, object, inheritance,
>    polymorphism) dalam Java.
> 3. **Menulis** kode program sederhana untuk menyelesaikan masalah
>    komputasi.
> 4. **Menganalisis** kesalahan logika dan sintaks pada kode program
>    secara mandiri.
> 5. **Mengembangkan** kemandirian belajar melalui latihan adaptif
>    dan umpan balik bertahap.

---

## 4. Struktur Level

| Bagian              | Level | Bahasa | Fokus           |
| ------------------- | ----- | ------ | --------------- |
| Dasar Pemrograman   | 1–35  | C++    | Fondasi coding  |
| OOP & Struktur Data | 36–50 | Java   | Paradigma objek |

**Prinsip:**

- Satu level = satu topik mikro
- Linier, tidak bercabang
- Level awal tanpa lock (1–10)
- Level > 10 ada lock jika mastery < 40%

---

## 5. Pemetaan CP & TP per Level

### Bagian 1 — Dasar Pemrograman (C++)

#### Level 1–5: Variabel, Tipe Data, Operator

**CP:**

> Memahami dasar penyimpanan dan manipulasi data dalam program C++.

| Level | Topik                          | TP                                                                                                                      |
| ----- | ------------------------------ | ----------------------------------------------------------------------------------------------------------------------- |
| 1     | Pengenalan Program C++         | 1. Menjelaskan struktur dasar program C++<br>2. Menulis program "Hello World"<br>3. Menggunakan `#include` dan `main()` |
| 2     | Variabel & Konstanta           | 1. Mendeklarasikan variabel dengan tipe yang tepat<br>2. Membedakan variabel dan konstanta<br>3. Menggunakan `const`    |
| 3     | Tipe Data Dasar                | 1. Membedakan `int`, `float`, `double`, `char`, `bool`<br>2. Memilih tipe data yang sesuai<br>3. Menggunakan `string`   |
| 4     | Operator Aritmatika            | 1. Menggunakan `+`, `-`, `*`, `/`, `%`<br>2. Memahami urutan operasi<br>3. Menangani pembagian bilangan bulat           |
| 5     | Operator Logika & Perbandingan | 1. Menggunakan `==`, `!=`, `<`, `>`, `<=`, `>=`<br>2. Menggunakan `&&`, `\|\|`, `!`<br>3. Membedakan `=` dan `==`       |

#### Level 6–10: Percabangan

**CP:**

> Menerapkan alur keputusan dalam program C++.

| Level | Topik            | TP                                                                                               |
| ----- | ---------------- | ------------------------------------------------------------------------------------------------ |
| 6     | If Sederhana     | 1. Menulis `if` dengan satu kondisi<br>2. Memahami blok kode<br>3. Menggunakan `{}` dengan benar |
| 7     | If-Else          | 1. Menulis `if-else` dua cabang<br>2. Memilih kondisi yang tepat<br>3. Menangani kasus else      |
| 8     | Nested If        | 1. Menulis `if` di dalam `if`<br>2. Menghindari nested berlebihan<br>3. Menggunakan `else if`    |
| 9     | Switch-Case      | 1. Menulis `switch-case`<br>2. Menggunakan `break`<br>3. Membedakan `switch` dan `if-else`       |
| 10    | Operator Ternary | 1. Menggunakan `? :`<br>2. Menyederhanakan `if-else` sederhana<br>3. Memahami keterbacaan kode   |

#### Level 11–15: Perulangan

**CP:**

> Menerapkan struktur pengulangan untuk efisiensi program C++.

| Level | Topik            | TP                                                                                                        |
| ----- | ---------------- | --------------------------------------------------------------------------------------------------------- |
| 11    | For Loop         | 1. Menulis `for` dengan sintaks benar<br>2. Menentukan kondisi berhenti<br>3. Menggabungkan dengan output |
| 12    | While Loop       | 1. Menulis `while`<br>2. Membedakan `for` dan `while`<br>3. Menghindari infinite loop                     |
| 13    | Do-While Loop    | 1. Menulis `do-while`<br>2. Membedakan dengan `while`<br>3. Kapan pakai `do-while`                        |
| 14    | Nested Loop      | 1. Menulis loop di dalam loop<br>2. Memahami kompleksitas<br>3. Membuat pola sederhana                    |
| 15    | Break & Continue | 1. Menggunakan `break`<br>2. Menggunakan `continue`<br>3. Mengontrol alur loop                            |

#### Level 16–20: Fungsi & Prosedur

**CP:**

> Memecah program menjadi bagian yang dapat digunakan ulang.

| Level | Topik               | TP                                                                                                   |
| ----- | ------------------- | ---------------------------------------------------------------------------------------------------- |
| 16    | Pengenalan Fungsi   | 1. Menjelaskan manfaat fungsi<br>2. Menulis fungsi sederhana<br>3. Memanggil fungsi                  |
| 17    | Parameter & Argumen | 1. Menulis parameter<br>2. Membedakan parameter & argumen<br>3. Menggunakan default parameter        |
| 18    | Return Value        | 1. Mengembalikan nilai<br>2. Menggunakan `return`<br>3. Membedakan `void` dan non-void               |
| 19    | Fungsi Rekursif     | 1. Memahami rekursi<br>2. Menulis base case<br>3. Menghindari infinite recursion                     |
| 20    | Overloading Fungsi  | 1. Menulis fungsi dengan nama sama<br>2. Membedakan parameter<br>3. Memahami compile-time resolution |

#### Level 21–25: Array & String

**CP:**

> Mengelola kumpulan data dalam satu variabel C++.

| Level | Topik          | TP                                                                                                |
| ----- | -------------- | ------------------------------------------------------------------------------------------------- |
| 21    | Array 1D       | 1. Mendeklarasikan array<br>2. Mengakses elemen<br>3. Iterasi array                               |
| 22    | Array 2D       | 1. Mendeklarasikan array 2D<br>2. Mengakses elemen [i][j]<br>3. Iterasi nested                    |
| 23    | String Dasar   | 1. Mendeklarasikan `string`<br>2. Menggabungkan string<br>3. Mengakses karakter                   |
| 24    | Operasi String | 1. Menggunakan `length()`, `substr()`<br>2. Mencari substring<br>3. Mengubah string               |
| 25    | Array & Fungsi | 1. Mengirim array ke fungsi<br>2. Memahami pass-by-reference<br>3. Mengembalikan array (opsional) |

#### Level 26–30: Pointer & Reference

**CP:**

> Memahami konsep alamat memori dalam C++.

| Level | Topik              | TP                                                                                                         |
| ----- | ------------------ | ---------------------------------------------------------------------------------------------------------- |
| 26    | Pengenalan Pointer | 1. Mendeklarasikan pointer<br>2. Menggunakan `&` dan `*`<br>3. Memahami alamat memori                      |
| 27    | Pointer & Array    | 1. Memahami kaitan pointer & array<br>2. Pointer arithmetic<br>3. Mengakses array via pointer              |
| 28    | Reference          | 1. Mendeklarasikan reference<br>2. Membedakan pointer & reference<br>3. Menggunakan reference di parameter |
| 29    | Dynamic Memory     | 1. Menggunakan `new` dan `delete`<br>2. Memahami memory leak<br>3. Kapan pakai dynamic                     |
| 30    | Pointer ke Fungsi  | 1. Mendeklarasikan function pointer<br>2. Memanggil via pointer<br>3. Kegunaan praktis                     |

#### Level 31–35: Struct & Enum

**CP:**

> Membuat tipe data bentukan di C++.

| Level | Topik            | TP                                                                                 |
| ----- | ---------------- | ---------------------------------------------------------------------------------- |
| 31    | Struct Dasar     | 1. Mendefinisikan `struct`<br>2. Mengakses anggota<br>3. Inisialisasi struct       |
| 32    | Struct & Array   | 1. Array of struct<br>2. Iterasi<br>3. Sorting sederhana                           |
| 33    | Enum             | 1. Mendefinisikan `enum`<br>2. Menggunakan enum di switch<br>3. Enum class (C++11) |
| 34    | Typedef & Using  | 1. Menggunakan `typedef`<br>2. Menggunakan `using`<br>3. Alias tipe data           |
| 35    | Union (opsional) | 1. Memahami `union`<br>2. Membedakan union & struct<br>3. Kapan pakai union        |

### Bagian 2 — OOP & Struktur Data (Java)

#### Level 36–40: Dasar OOP

**CP:**

> Menerapkan paradigma objek dalam program Java.

| Level | Topik                 | TP                                                                                            |
| ----- | --------------------- | --------------------------------------------------------------------------------------------- |
| 36    | Pengenalan Java & OOP | 1. Menjelaskan perbedaan C++ dan Java<br>2. Menulis program Java sederhana<br>3. Memahami JVM |
| 37    | Class & Object        | 1. Mendefinisikan `class`<br>2. Membuat `object`<br>3. Mengakses atribut & method             |
| 38    | Constructor           | 1. Menulis constructor<br>2. Overloading constructor<br>3. `this` keyword                     |
| 39    | Enkapsulasi           | 1. Menggunakan `private`, `public`<br>2. Getter & setter<br>3. Manfaat enkapsulasi            |
| 40    | Static & Final        | 1. Menggunakan `static`<br>2. Menggunakan `final`<br>3. Membedakan static & instance          |

#### Level 41–45: Inheritance & Polymorphism

**CP:**

> Menerapkan pewarisan dan polimorfisme dalam Java.

| Level | Topik             | TP                                                                                                     |
| ----- | ----------------- | ------------------------------------------------------------------------------------------------------ |
| 41    | Inheritance Dasar | 1. Menulis `extends`<br>2. Mengakses parent class<br>3. Override method                                |
| 42    | Super & Override  | 1. Menggunakan `super`<br>2. Anotasi `@Override`<br>3. Membedakan overload & override                  |
| 43    | Polymorphism      | 1. Memahami polymorphism<br>2. Upcasting & downcasting<br>3. Dynamic method dispatch                   |
| 44    | Abstract Class    | 1. Menulis `abstract class`<br>2. Abstract method<br>3. Membedakan abstract & concrete                 |
| 45    | Interface         | 1. Mendefinisikan `interface`<br>2. Implementasi interface<br>3. Membedakan interface & abstract class |

#### Level 46–50: Struktur Data Dasar

**CP:**

> Menerapkan struktur data sederhana dalam Java.

| Level | Topik       | TP                                                                                                            |
| ----- | ----------- | ------------------------------------------------------------------------------------------------------------- |
| 46    | ArrayList   | 1. Menggunakan `ArrayList`<br>2. Menambah/hapus elemen<br>3. Iterasi                                          |
| 47    | Stack       | 1. Memahami konsep LIFO<br>2. Menggunakan `Stack`<br>3. Implementasi sederhana                                |
| 48    | Queue       | 1. Memahami konsep FIFO<br>2. Menggunakan `Queue`<br>3. Implementasi sederhana                                |
| 49    | Linked List | 1. Memahami node & pointer<br>2. Implementasi singly linked list<br>3. Operasi dasar (insert, delete, search) |
| 50    | HashMap     | 1. Memahami key-value<br>2. Menggunakan `HashMap`<br>3. Iterasi & operasi dasar                               |

---

## 6. Kaitan CP-TP dengan Fitur KODIRA

| Elemen       | Fungsi di KODIRA                               |
| ------------ | ---------------------------------------------- |
| **CP**       | Menentukan topik per level (1 level = 1 CP)    |
| **TP**       | Menentukan soal latihan & kuis                 |
| **TP**       | Menjadi dasar AI membuat soal variasi          |
| **TP**       | Menjadi indikator mastery (lulus/tidak per TP) |
| **CP**       | Menentukan kapan level bisa dibuka             |
| **Sub-CPMK** | Agregat dari beberapa CP (per bagian)          |

**Alur:**

```
CP Level → TP 1, TP 2, TP 3 → Soal Kuis (per TP)
                            ↓
                       Mastery per TP
                            ↓
                       Keputusan Adaptif
```

---

## 7. Contoh Penerapan di Satu Level

**Level 11 — For Loop (C++)**

| Komponen | Isi                                                     |
| -------- | ------------------------------------------------------- |
| **CP**   | Menerapkan struktur pengulangan untuk efisiensi program |
| **TP 1** | Menulis for loop dengan sintaks yang benar              |
| **TP 2** | Menentukan kondisi berhenti yang tepat                  |
| **TP 3** | Menggabungkan for loop dengan output                    |

**Materi:** penjelasan for loop + contoh kode
**Latihan:** drag & drop menyusun for loop
**Kuis:** 5 soal

- 3 soal TP 1
- 1 soal TP 2
- 1 soal TP 3

**Mastery:** dihitung dari TP mana yang salah
**Remedial:** fokus ke TP yang belum tuntas

---

## 8. Mapping Level ke Mastery Tracking

Di database (`user_mastery`), kolom `topic` merujuk ke **TP**, bukan
ke level. Contoh:

```sql
INSERT INTO user_mastery (user_id, topic, mastery_score)
VALUES
  ('user-123', 'L11-TP1', 0.85),  -- for loop sintaks
  ('user-123', 'L11-TP2', 0.62),  -- kondisi berhenti
  ('user-123', 'L11-TP3', 0.90);  -- integrasi output
```

Dengan ini, remedial bisa fokus ke TP tertentu, bukan seluruh level.

---

## 9. Kontribusi CP-TP ke Novelty

CP-TP adalah **fondasi dari adaptive engine**:

- Mastery dihitung per TP, bukan per level → lebih granular
- Error pattern terdeteksi per TP → lebih akurat
- Remedial fokus ke TP lemah → lebih efisien
- Level lock dipicu oleh TP fundamental → lebih bermakna

Ini yang membedakan KODIRA dari platform lain yang hanya pakai
benar/salah per soal.

---

## 10. Referensi

- `docs/01-prd.md` — product requirement
- `docs/03-architecture.md` — arsitektur adaptive engine
- `docs/05-decisions.md` — ADR-004 (mastery 3 tingkat)
- Kurikulum JTIK semester 1 — Pemrograman Dasar

---

## 11. Update Log

| Tanggal    | Perubahan            |
| ---------- | -------------------- |
| 2026-10-16 | Draft awal, 50 level |
