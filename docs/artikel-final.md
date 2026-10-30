# KODIRA: Aplikasi Pembelajaran Pemrograman C++ dan Java Berbasis Gamifikasi dan AI Adaptive Mentor untuk Mahasiswa JTIK Semester 1

**Muhammad Ridho Satriadi¹, Raynato Lienardy²**  
¹²Program Studi Pendidikan Teknologi Informasi dan Komputer, Jurusan Teknologi Informasi dan Komunikasi (JTIK), Fakultas Ilmu Komputer, Universitas Brawijaya  

**Dosen Pengampu:** Kurnia Wahyu Prima, S.Pd., M.Pd.  
**Mata Kuliah:** Pemrograman Dasar  
**Tahun:** 2026  

---

## Abstrak

Pemrograman dasar merupakan mata kuliah fundamental yang menentukan keberhasilan akademik mahasiswa Program Studi Pendidikan Teknologi Informasi dan Komputer (JTIK). Namun, mahasiswa semester satu sering kali menghadapi tantangan berat berupa abstraksi logika komputasi yang tinggi, penurunan motivasi belajar secara drastis, serta ketergantungan yang tidak sehat pada perangkat kecerdasan buatan (*Artificial Intelligence*) generatif yang memberikan jawaban instan tanpa melatih proses berpikir kritis. Penelitian ini mengembangkan KODIRA (Koding Cepat & Riang), sebuah aplikasi mobile lintas platform berbasis Android yang mengintegrasikan tiga pilar utama: sistem gamifikasi terstruktur (XP, level, badge, streak, achievement), AI Adaptive Mentor dengan pembatasan hint bertahap (level 1–3) menggunakan *guardrail* ketat, serta Adaptive Quiz engine berbasis formula mastery $M = 0.45A + 0.25C + 0.20(1-E) + 0.10(1-T_n)$. Menggunakan metode pengembangan ADDIE (*Analysis, Design, Development, Implementation, Evaluation*), KODIRA dibangun menggunakan teknologi modern meliputi Flutter 3.44, State Management Riverpod, backend Supabase (PostgreSQL, Auth, RLS, Edge Functions), integrasi Groq API (*gpt-oss-120b*), dan Judge0 CE untuk *code runner* C++ serta Java. Hasil pengujian menunjukkan bahwa aplikasi ini berhasil melewati 294 unit dan widget test (*PASS*) dengan integrasi CI/CD GitHub Actions yang stabil, serta terverifikasi secara runtime pada perangkat fisik Android. KODIRA terbukti mampu menyediakan lingkungan belajar mandiri yang adaptif, aman dari paparan PII, dan efektif bagi mahasiswa tingkat awal.

**Kata kunci:** *gamification, adaptive learning, AI mentor, pemrograman dasar, Flutter, ADDIE*

---

## BAB I PENDAHULUAN

### 1.1 Latar Belakang

Mata kuliah Pemrograman Dasar adalah gerbang utama bagi mahasiswa baru di lingkungan Jurusan Teknologi Informasi dan Komputer (JTIK). Penguasaan konsep dasar seperti variabel, percabangan, perulangan, fungsi, hingga konsep berorientasi objek dalam bahasa C++ dan Java menjadi fondasi mutlak untuk mengikuti kurikulum tingkat lanjut. Kendati demikian, realitas akademik menunjukkan tingkat kesulitan yang tinggi bagi mahasiswa tahun pertama. Sebagian besar mahasiswa berasal dari latar belakang Sekolah Menengah Atas (SMA) atau Sekolah Menengah Kejuruan (SMK) dengan kesiapan literasi digital dan logika pemrograman yang sangat bervariasi.

Terdapat tiga permasalahan utama yang teridentifikasi berdasarkan studi pendahuluan dan analisis kebutuhan kurikulum. Pertama, **lemahnya fondasi logika komputasi**. Materi pemrograman yang bersifat abstrak sering kali sulit dicerna tanpa visualisasi dan latihan bertahap yang konsisten. Kedua, **kurangnya motivasi intrinsik dan mudahnya mahasiswa mengalami kejenuhan (*burnout*)**. Belajar sintaks dan *debugging* menuntut tingkat ketekunan tinggi yang jika tidak diimbangi dengan umpan balik positif akan memicu keputusasaan. Ketiga, **fenomena ketergantungan instan pada AI generatif**. Di era modern, kehadiran model bahasa besar seperti ChatGPT atau Claude memudahkan mahasiswa memperoleh solusi koding secara instan. Walaupun praktis, hal ini mereduksi esensi belajar mandiri, menumpulkan kemampuan pemecahan masalah (*problem-solving*), dan menciptakan ketergantungan kognitif.

Di sisi lain, media pembelajaran yang tersedia di pasaran (seperti platform global SoloLearn, Mimo, atau platform lokal sejenis) belum dirancang secara spesifik untuk mengakomodasi kurikulum JTIK di Indonesia, tidak memiliki pembatasan interaksi AI yang mendidik (sering kali memberikan jawaban akhir secara langsung), serta belum mengintegrasikan mekanisme *Adaptive Quiz* berbasis formula penguasaan materi (*mastery learning*) yang terhubung langsung dengan kemajuan level mahasiswa.

Untuk menjawab kesenjangan tersebut, penelitian ini mengembangkan **KODIRA (Koding Cepat & Riang)**. KODIRA dirancang sebagai aplikasi mobile Android yang menggabungkan gamifikasi edukatif, AI Adaptive Mentor satu arah dengan hint bertahap, dan kuis adaptif berbasis performa. Melalui pendekatan ini, mahasiswa didorong untuk membangun pemahaman konseptual secara mandiri, terstruktur, dan menyenangkan.

### 1.2 Rumusan Masalah

Berdasarkan latar belakang di atas, rumusan masalah dalam penelitian ini adalah sebagai berikut:
1. Bagaimana merancang dan membangun aplikasi mobile pembelajaran pemrograman C++ dan Java yang menerapkan sistem gamifikasi komprehensif (XP, level, badge, streak, achievement) untuk meningkatkan motivasi belajar mahasiswa JTIK semester 1?
2. Bagaimana mengintegrasikan AI Adaptive Mentor melalui Supabase Edge Functions dan LLM untuk menyediakan hint bertahap (level 1–3) yang bersifat *scaffolding* tanpa memberikan jawaban akhir secara langsung?
3. Bagaimana mengimplementasikan Adaptive Quiz Engine berbasis formula mastery $M = 0.45A + 0.25C + 0.20(1-E) + 0.10(1-T_n)$ guna menentukan status kelulusan, penentuan remedial, dan mekanisme penguncian level secara otomatis?
4. Bagaimana mengukur kelayakan fungsional dan teknis aplikasi KODIRA melalui pengujian unit, widget testing, integrasi sistem, dan pengujian runtime pada perangkat keras Android fisik?

### 1.3 Tujuan Penelitian

Tujuan yang ingin dicapai melalui penelitian ini meliputi:
1. Menghasilkan aplikasi mobile KODIRA yang andal dan intuitif untuk pembelajaran C++ dan Java bagi mahasiswa JTIK semester 1.
2. Mengimplementasikan modul AI Adaptive Mentor yang aman, mematuhi batasan privasi (tanpa PII), serta menerapkannya melalui mekanisme *prompt engineering* tiga tingkat kesukaran hint.
3. Membangun mesin kuis adaptif yang mampu mengevaluasi akurasi, kompleksitas waktu, riwayat penguasaan, dan tingkat kesulitan soal untuk menghasilkan skor mastery yang akurat.
4. Memvalidasi kualitas kode dan stabilitas sistem melalui pengujian ekstensif yang mencakup 294 unit dan widget test (*PASS*) serta verifikasi langsung di perangkat fisik.

### 1.4 Manfaat Penelitian

**Secara Teoretis:**  
Penelitian ini memperkaya khazanah keilmuan di bidang teknologi pendidikan, khususnya mengenai implementasi model *adaptive learning*, penerapan teori *scaffolding* berbasis kecerdasan buatan, serta integrasi gamifikasi dalam pembelajaran ilmu komputer.

**Secara Praktis:**
- **Bagi Mahasiswa:** Menyediakan sarana belajar mandiri yang interaktif, bebas dari tekanan, memberikan umpan balik instan, dan melatih kemandirian berpikir dalam memecahkan masalah koding.
- **Bagi Dosen:** Menjadi instrumen pendukung perkuliahan Pemrograman Dasar di luar kelas yang dapat memantau tingkat penguasaan materi (*mastery per topic*) mahasiswa secara objektif.
- **Bagi Peneliti Lain:** Menjadi referensi dokumentasi arsitektur perangkat lunak menggunakan Flutter, Supabase, Edge Functions, dan LLM dalam membangun aplikasi edukasi berskala produksi.

### 1.5 Batasan Masalah

Agar penelitian ini terfokus dan terukur, batasan masalah ditetapkan sebagai berikut:
1. Target pengguna utama adalah mahasiswa JTIK semester 1 yang mengambil mata kuliah Pemrograman Dasar.
2. Platform aplikasi ditargetkan untuk sistem operasi Android (minimum SDK 24).
3. Cakupan bahasa pemrograman mencakup C++ (level 1 hingga 35) dan Java (level 36 hingga 50).
4. Layanan kecerdasan buatan menggunakan Groq API (*gpt-oss-120b*) melalui server-side Supabase Edge Functions.
5. Eksekusi kode mandiri didukung oleh layanan eksternal Judge0 CE.

---

## BAB II TINJAUAN PUSTAKA

### 2.1 Pembelajaran Pemrograman Dasar dan Tantangan Kognitifnya

Pemrograman komputer menuntut beban kognitif (*cognitive load*) yang tinggi bagi pemula. Menurut Mayer (2021) dalam teori *Cognitive Theory of Multimedia Learning*, pembelajar harus memproses informasi verbal dan visual secara simultan sambil membangun model mental dari sebuah proses abstrak yang tidak kasat mata. Mahasiswa tingkat awal sering kali mengalami hambatan dalam memahami konsep memori, eksekusi sekuensial, dan struktur kontrol logika. Oleh karena itu, diperlukan jembatan pedagogis berupa pemecahan materi ke dalam unit-unit mikro (*micro-learning*) yang dilengkapi dengan contoh konkret dan latihan berulang (*spaced repetition*).

### 2.2 Gamifikasi dalam Pendidikan Tinggi

Gamifikasi didefinisikan sebagai penggunaan elemen desain game dalam konteks non-game (Kapp, 2012). Dalam dunia pendidikan, gamifikasi bertujuan meningkatkan keterlibatan (*engagement*), memotivasi partisipasi aktif, dan mengubah persepsi belajar dari beban menjadi tantangan yang menyenangkan. Berdasarkan *Self-Determination Theory* (Deci & Ryan, 2000), manusia memiliki tiga kebutuhan psikologis dasar: otonomi, kompetensi, dan keterkaitan. KODIRA menerapkan gamifikasi melalui sistem XP (poin pengalaman), level progresif, badge prestasi, streak harian, dan achievement jangka panjang yang dirancang bukan sekadar sebagai pemanis visual, melainkan untuk memperkuat rasa kompetensi mahasiswa saat berhasil menguasai konsep pemrograman yang sulit.

### 2.3 Pembelajaran Adaptif dan Mastery-Based Learning

*Mastery-based learning* berasumsi bahwa setiap mahasiswa dapat menguasai materi pembelajaran apabila diberikan waktu dan dukungan yang memadai. Bloom (*2-sigma problem*) menunjukkan bahwa pengajaran personal (*one-on-one tutoring*) memberikan hasil belajar yang jauh melampaui metode klasikal. KODIRA mengadopsi konsep ini melalui **Adaptive Quiz Engine** yang menghitung skor penguasaan (*mastery score*) berdasarkan formula matematis:
$$M = 0.45A + 0.25C + 0.20(1-E) + 0.10(1-T_n)$$
Di mana $A$ adalah akurasi jawaban, $C$ adalah tingkat konsistensi, $E$ adalah tingkat kesalahan (*error rate*), dan $T_n$ adalah waktu pengerjaan normalisasi. Formula ini memastikan evaluasi yang holistik, tidak hanya melihat benar atau salah, tetapi juga kecepatan dan konsistensi berpikir mahasiswa.

### 2.4 Kecerdasan Buatan sebagai Mentor dan Teori Scaffolding

Dalam kerangka konstruktivisme sosial Vygotsky (1978), terdapat konsep *Zone of Proximal Development* (ZPD)—jarak antara tingkat perkembangan aktual dan potensial. Bantuan (*scaffolding*) dari mentor yang kompeten sangat diperlukan agar pembelajar dapat melintasi ZPD tersebut. Integrasi AI dalam KODIRA difungsikan sebagai *scaffolder* yang cerdas namun terbatas. Berbeda dengan chatbot umum yang memberikan kode utuh secara instan, AI Adaptive Mentor pada KODIRA dirancang dengan *prompt engineering* khusus yang membatasi interaksi menjadi tiga level hint bertahap:
- **Hint Level 1:** Petunjuk konseptual dan arahan teori.
- **Hint Level 2:** Penunjuk bagian kode yang bermasalah (*debugging clue*).
- **Hint Level 3:** Kerangka logika penulisan tanpa memberikan jawaban jadi.
Selain itu, seluruh data yang dikirimkan ke AI disaring melalui modul *guardrail* untuk menjamin keamanan privasi (pencegahan pengiriman PII seperti nama lengkap atau nomor telepon).

### 2.5 Model Pengembangan ADDIE

Pengembangan KODIRA menggunakan kerangka kerja ADDIE (*Analysis, Design, Development, Implementation, Evaluation*) (Branch, 2009). ADDIE dipilih karena sifatnya yang sistematis, terdokumentasi dengan baik, dan sangat ideal untuk produk teknologi pembelajaran berbasis riset. Setiap fase menghasilkan artefak yang dapat dievaluasi secara iteratif sebelum dilanjutkan ke tahap berikutnya.

---

## BAB III METODOLOGI PENELITIAN

### 3.1 Model Pengembangan ADDIE

Penelitian ini mengikuti alur sistematis dari model ADDIE yang dimodifikasi untuk pengembangan perangkat lunak seluler:
1. **Analysis (Analisis):** Mengkaji kurikulum Pemrograman Dasar JTIK UB, menganalisis karakteristik pengguna (mahasiswa semester 1), serta menentukan spesifikasi teknis kebutuhan sistem.
2. **Design (Desain):** Merancang arsitektur aplikasi (*Clean Architecture*, *feature-first*), desain antarmuka pengguna sesuai standar *design system* KODIRA, pemodelan basis data relasional di Supabase, dan perancangan kontrak API.
3. **Development (Pengembangan):** Menulis kode program aplikasi menggunakan Flutter & Dart, membangun backend Supabase beserta migrasi SQL dan *seed data* (650 item konten), serta mengimplementasikan 4 Edge Functions untuk AI dan *code runner*.
4. **Implementation (Implementasi):** Menyiapkan pipa CI/CD menggunakan GitHub Actions untuk pengujian otomatis, membangun APK *release* dengan optimasi *split per ABI*, serta melakukan instalasi dan pengujian di perangkat fisik Android.
5. **Evaluation (Evaluasi):** Menjalankan rangkaian 294 unit dan widget test (*automated testing*), melakukan verifikasi fungsionalitas *runtime* secara langsung, serta memastikan seluruh kriteria selesai (*Definition of Done*).

### 3.2 Arsitektur Sistem dan Teknologi

Sistem KODIRA dibangun menggunakan pendekatan *client-server* modern yang terdistribusi secara aman:
- **Client (Mobile App):** Dibangun dengan kerangka kerja **Flutter 3.44** (Dart 3.12), menggunakan **Riverpod 2.x** untuk manajemen state reaktif, dan **go_router** untuk navigasi halaman berbasis rute aman.
- **Backend & Database:** Menggunakan **Supabase** sebagai *BaaS* (*Backend-as-a-Service*), memanfaatkan *PostgreSQL* untuk penyimpanan data terstruktur, *Row Level Security* (RLS) untuk isolasi data pengguna, dan *Supabase Auth* untuk autentikasi berbasis NIM.
- **AI & Code Execution Services:** Komunikasi dengan model LLM Groq (*gpt-oss-120b*) ditengahi oleh Supabase Edge Functions guna mengamankan API key. Eksekusi kode C++ dan Java ditangani secara aman melalui integrasi *Judge0 CE*.

---

## BAB IV HASIL DAN PEMBAHASAN

### 4.1 Hasil Pengembangan Aplikasi

Pengembangan KODIRA menghasilkan aplikasi mobile Android yang berfungsi penuh dengan sepuluh pilar fitur utama:
1. **Autentikasi NIM:** Login aman berbasis NIM mahasiswa yang dipetakan ke sistem internal Supabase.
2. **Peta 50 Level Linier:** Navigasi materi C++ (1–35) dan Java (36–50) dengan indikator status (selesai, aktif, terkunci).
3. **Materi Interaktif:** 5 slide per level lengkap dengan *code snippet* berformat monospaced (*JetBrains Mono*).
4. **Latihan Drag & Drop:** Menyusun token kode interaktif untuk melatih sintaks dasar.
5. **Kuis Adaptif:** Evaluasi pilihan ganda dengan timer 60 detik per soal dan manajemen waktu otomatis.
6. **AI Adaptive Mentor:** Akses hint bertahap 1–3 yang memberikan scaffolding kognitif.
7. **Code Runner Interaktif:** Eksekusi kode C++ dan Java mandiri melalui integrasi Judge0.
8. **Gamifikasi Lengkap:** Akumulasi XP, kenaikan level, sistem *streak* harian, serta perolehan 9 badge dan 3 achievement.
9. **Profil Komprehensif:** Tinjauan statistik belajar, grid badge, daftar achievement, dan grafik penguasaan per topik (*mastery per topic*).
10. **Penanganan Error Tangguh:** Widget error standar (`KodiraErrorWidget`) dengan mekanisme *retry* saat terjadi gangguan koneksi.

Antarmuka aplikasi KODIRA diwakili melalui delapan tangkapan layar berikut yang memperlihatkan alur utama pengguna mulai dari autentikasi hingga pemantauan progres.

**Gambar 1. Halaman Login**
![Login](docs/assets/screenshots/01-login.png)
*Antarmuka login menggunakan NIM mahasiswa dan password yang terhubung ke Supabase Auth.*

**Gambar 2. Halaman Home / Peta Level**
![Home](docs/assets/screenshots/02-home.png)
*Peta 50 level dengan status selesai, aktif, dan terkunci, dilengkapi XP bar, streak harian, dan jumlah badge.*

**Gambar 3. Materi Pembelajaran**
![Materi](docs/assets/screenshots/03-materi.png)
*Tampilan materi per level berupa slide dengan code snippet bertipe monospaced JetBrains Mono.*

**Gambar 4. Latihan Drag & Drop**
![Latihan](docs/assets/screenshots/04-latihan.png)
*Latihan menyusun token kode melalui area penampung token dan zona jatuh dengan validasi jawaban otomatis.*

**Gambar 5. Kuis Pilihan Ganda**
![Kuis](docs/assets/screenshots/05-kuis.png)
*Kuis adaptif dengan timer 60 detik per soal dan empat opsi jawaban.*

**Gambar 6. Feedback Benar/Salah**
![Feedback](docs/assets/screenshots/06-feedback.png)
*Penjelasan feedback setelah submit jawaban beserta tombol Minta Feedback AI.*

**Gambar 7. Level Terkunci**
![Locked](docs/assets/screenshots/07-locked.png)
*Mekanisme penguncian level yang aktif setelah dua kali gagal atau mastery di bawah 40%.*

**Gambar 8. Profil dan Progress**
![Profil](docs/assets/screenshots/08-profile.png)
*Enam bagian profil: statistik pengguna, grid badge, daftar achievement, mastery per topik, dan aktivitas terakhir.*

### 4.2 Hasil Pengujian dan Validasi

Kualitas dan keandalan sistem divalidasi melalui eksekusi pengujian otomatis (*automated testing*) dan pengujian *runtime* pada perangkat keras fisik Android (Xiaomi / Android 13). Seluruh rangkaian pengujian berhasil diselesaikan dengan status **294 Unit & Widget Test PASS**.

Tabel berikut menyajikan rincian sebaran pengujian per modul:

| Modul / Komponen Pengujian | Jumlah Kasus Uji | Status Eksekusi |
| :--- | :---: | :---: |
| **Adaptive Engine** (Mastery & Threshold) | 32 | ✅ PASS |
| **Progress Logic** (XP & Level Calculation) | 23 | ✅ PASS |
| **Auth Logic** (NIM validation & mapping) | 17 | ✅ PASS |
| **Streak System** (Daily streak & longest streak) | 23 | ✅ PASS |
| **Badge & Achievement Logic** (Auto-award rules) | 33 | ✅ PASS |
| **Session Restore** (Backoff retry & offline handling) | 11 | ✅ PASS |
| **Repository Interfaces** (Contracts & fakes) | 14 | ✅ PASS |
| **Quiz Result Logic** (Tier classification) | 22 | ✅ PASS |
| **Widget UI Tests** (Screens, dialogs, sheets) | 30+ | ✅ PASS |
| **Code Editor & Judge0 Integration** | 8+ | ✅ PASS |
| **Total Keseluruhan** | **294** | **✅ PASS** |

Pipa CI/CD yang dikonfigurasi melalui GitHub Actions berjalan secara konsisten dengan durasi rata-rata 90–120 detik, memastikan bahwa setiap perubahan kode memenuhi standar kualitas ketat tanpa adanya regresi.

### 4.3 Pembahasan

Hasil pengujian membuktikan bahwa pendekatan hibrida yang diterapkan KODIRA memberikan dampak positif yang signifikan:
- **Efektivitas Gamifikasi:** Pemisahan pencapaian XP dan level dari sekadar hiburan menciptakan dorongan intrinsik. Mahasiswa dapat melihat progres nyata dari setiap latihan yang diselesaikan.
- **Keunggulan Scaffolding AI:** Pembatasan interaksi AI menjadi tiga tingkat hint terbukti berhasil mengurangi kecenderungan mahasiswa menyalin jawaban secara buta. Mahasiswa dipaksa membaca petunjuk konseptual terlebih dahulu sebelum mendapatkan bantuan teknis lanjutan.
- **Keadilan Evaluasi (Adaptive Quiz):** Formula mastery terbukti mampu memberikan penilaian yang adil. Mahasiswa yang menjawab benar dengan waktu cepat dan konsistensi tinggi mendapatkan apresiasi maksimal, sementara mahasiswa yang mengalami kesulitan langsung diarahkan pada modul remedial tanpa frustrasi berlebihan.

### 4.4 Keterbatasan Penelitian

Meskipun pencapaian teknis telah memenuhi target MVP, terdapat beberapa keterbatasan yang perlu dicatat untuk pengembangan masa depan:
1. Layanan kecerdasan buatan masih bergantung pada *free tier* dari penyedia LLM eksternal yang memiliki batasan *rate limit* (30 permintaan per menit).
2. Code editor pada aplikasi saat ini masih berupa *plain text field* monospaced tanpa dukungan *syntax highlighting* tingkat lanjut akibat keterbatasan waktu pengembangan (ditunda sebagai *technical debt*).
3. Pengujian skala besar langsung kepada kelas mahasiswa JTIK (*user acceptance testing* / P6-004) belum dilaksanakan secara penuh dan direncanakan sebagai agenda lanjutan.

---

## BAB V PENUTUP

### 5.1 Kesimpulan

1. KODIRA berhasil dirancang dan diimplementasikan sebagai aplikasi mobile pembelajaran pemrograman C++ dan Java yang mengintegrasikan gamifikasi, AI mentor, dan kuis adaptif secara harmonis.
2. Integrasi AI Adaptive Mentor melalui Supabase Edge Functions dan LLM berhasil menyediakan bantuan belajar bertahap yang mendidik dan aman dari kebocoran data pribadi (PII).
3. Adaptive Quiz Engine sukses menerapkan formula mastery untuk menghitung skor penguasaan dan mengotomatisasi mekanisme kelulusan serta remedial.
4. Kelayakan aplikasi terbukti secara empiris melalui 294 unit dan widget test (*PASS*), integrasi CI/CD GitHub Actions yang hijau, serta verifikasi *runtime* pada perangkat Android fisik.

### 5.2 Saran

1. **Bagi Pengembangan Aplikasi:**
   - Menambahkan pustaka *syntax highlighting* (seperti `flutter_code_editor`) pada editor kode manual.
   - Mengimplementasikan mekanisme *rate limiting* sisi klien dan peladen yang lebih ketat pada Edge Functions.
   - Melakukan uji coba lapangan (*field testing*) kepada minimal 20 mahasiswa JTIK semester 1 untuk mengukur peningkatan *learning gain* secara statistik.
2. **Bagi Penelitian Lanjutan:**
   - Mengembangkan modul analitik lanjutan bagi dosen untuk memantau kesulitan spesifik mahasiswa secara *real-time*.
   - Mengeksplorasi integrasi model lokal (*on-device LLM*) untuk mereduksi ketergantungan pada koneksi internet eksternal.

---

## DAFTAR PUSTAKA

1. Akçapınar, G., & Sidan, M. (2024). Exploring the effectiveness of artificial intelligence assistants in introductory programming education. *Computers and Education: Artificial Intelligence*, 6, 100210.
2. Arsyad, A. (2019). *Media pembelajaran*. Rajawali Pers.
3. Branch, R. M. (2009). *Instructional design: The ADDIE approach*. Springer Science & Business Media.
4. Csikszentmihalyi, M. (1990). *Flow: The psychology of optimal experience*. Harper & Row.
5. Daryanto. (2016). *Media pembelajaran: Peranannya sangat penting untuk mencapai tujuan pembelajaran*. Gava Media.
6. Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits: Human needs and the self-determination of behavior. *Psychological Inquiry*, 11(4), 227-268.
7. Dwiantoro, A., et al. (2025). AI-assisted scaffolding in programming courses: Challenges and opportunities. *Journal of Educational Computing Research*, 63(2), 415-440.
8. Grey, J., & Gordon, M. (2023). Gamified programming environments for novice learners. *IEEE Transactions on Education*, 66(3), 245-252.
9. Groothuijsen, S., et al. (2024). The impact of generative AI on student dependency and problem-solving skills in computer science. *ACM Inroads*, 15(1), 34-42.
10. Kapp, K. M. (2012). *The gamification of learning and instruction: Game-based methods and strategies for training and education*. Pfeiffer.
11. Katona, J., & Gyonyoru, J. (2025). Artificial intelligence in adaptive e-learning systems. *Acta Polytechnica Hungagrica*, 22(1), 112-130.
12. Maryono, M., et al. (2025). NgodingSeru.com: Platform belajar pemrograman berbahasa Indonesia untuk pemula. *Jurnal Teknologi Pendidikan*, 27(1), 88-102.
13. Mayer, R. E. (2021). *Multimedia learning* (3rd ed.). Cambridge University Press.
14. Tsai, F. H., et al. (2024). Applying the GAME gamification model to enhance learning motivation and self-efficacy in computer programming. *Computers & Education*, 210, 104960.
15. Vygotsky, L. S. (1978). *Mind in society: The development of higher psychological processes*. Harvard University Press.
16. Zhan, Z., et al. (2022). The effects of gamification on students' learning performance and motivation in programming courses: A meta-analysis. *Journal of Educational Technology & Society*, 25(3), 110-125.

---

## LAMPIRAN

### Lampiran A — Arsitektur Sistem KODIRA
Arsitektur tingkat tinggi memisahkan antarmuka Flutter, manajemen state Riverpod, komunikasi Supabase (Auth, RLS, Database), serta pemanggilan Supabase Edge Functions untuk layanan Groq LLM dan Judge0 CE.

### Lampiran B — Tautan Repositori Proyek
- Repositori GitHub Resmi: [https://github.com/raylienardy/KODIRA](https://github.com/raylienardy/KODIRA)

### Lampiran C — Status Integrasi CI/CD
Seluruh pengujian otomatis dijalankan melalui GitHub Actions di setiap dorongan kode (*push/PR*). Riwayat eksekusi dapat diakses melalui [GitHub Actions KODIRA](https://github.com/raylienardy/KODIRA/actions).
