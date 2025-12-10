# Ocus 

**Ocus** adalah aplikasi produktivitas berbasis teknik **Pomodoro** yang dirancang untuk membantu pengguna tetap fokus, mengelola tugas, dan melacak kinerja belajar atau bekerja mereka. Aplikasi ini dibangun menggunakan **Flutter** dengan antarmuka modern (Dark Mode) yang nyaman di mata.

## 📱 Fitur Unggulan

### 1. ⏱️ Timer Fokus Cerdas
* Mendukung 3 mode: **Fokus**, **Istirahat Pendek**, dan **Istirahat Panjang**.
* Durasi otomatis berjalan sesuai siklus Pomodoro (4 siklus fokus sebelum istirahat panjang).
* Notifikasi lokal saat waktu habis (mendukung mode suara & senyap).

### 2. ✅ Manajemen Tugas (To-Do List)
* Tambah, Edit, dan Hapus tugas.
* Tandai tugas sebagai selesai.
* Lihat detail tugas termasuk *deadline* dan jumlah sesi yang dibutuhkan.

### 3. 📊 Statistik & Analisis
* **Ringkasan Harian:** Melacak sesi fokus dan tugas yang diselesaikan hari ini.
* **Diagram Mingguan:** Visualisasi batang (*Bar Chart*) untuk melihat tren produktivitas selama 7 hari terakhir.
* **Kalender:** Penanda visual untuk hari-hari dengan aktivitas.

### 4. 👤 Profil & Personalisasi
* **Kustomisasi:** Ubah Nama Pengguna, Bio/Deskripsi, dan pilih Avatar (Pria/Wanita/Default).
* **Statistik Global:** Melacak total sesi seumur hidup dan total tugas selesai.
* **Pengaturan:** Kontrol notifikasi suara.
* **Reset Data:** Fitur untuk menghapus riwayat statistik jika ingin memulai dari awal.

## 🛠️ Teknologi & Paket yang Digunakan

Aplikasi ini dibangun menggunakan ekosistem Flutter yang kuat:

* **State Management:** `provider` (untuk mengelola state Timer, Task, dan Profile secara reaktif).
* **Penyimpanan Lokal:** `shared_preferences` (menyimpan riwayat sesi, tugas, dan pengaturan profil secara permanen di HP).
* **Notifikasi:** `flutter_local_notifications` (menampilkan notifikasi saat timer selesai bahkan saat aplikasi di latar belakang).
* **Visualisasi Data:** `fl_chart` (untuk diagram batang mingguan).
* **Kalender:** `table_calendar`.
* **Format Tanggal:** `intl`.
* **Ikon Launcher:** `flutter_launcher_icons`.

## 📂 Struktur Proyek

Proyek ini menggunakan struktur **Feature-First** agar mudah dikembangkan:

```text
lib/
├── core/
│   ├── notifications/  # Logika Notifikasi Lokal
│   ├── storage/        # Layanan Penyimpanan Data (Disk)
│   └── theme/          # Warna & Tema Aplikasi
├── features/
│   ├── calendar/       # Halaman Statistik
│   ├── profile/        # Halaman Profil & Pengaturan
│   ├── tasks/          # Halaman Daftar Tugas
│   └── timer/          # Halaman Utama Timer
└── main.dart           # Titik Masuk Aplikasi
