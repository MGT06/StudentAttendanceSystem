# Aplikasi Absensi Sekolah

Aplikasi mobile untuk manajemen absensi siswa berbasis lokasi dengan sistem multi-role (Guru, Murid, Orang Tua).

## Deskripsi

**Aplikasi Absensi Sekolah** adalah solusi digital untuk mengelola kehadiran siswa secara real-time dengan verifikasi lokasi GPS. Aplikasi ini dirancang untuk:

- **Guru**: Memantau kehadiran siswa, melihat statistik absensi per kelas, dan mengelola data izin
- **Murid**: Melakukan absensi masuk/pulang dengan validasi lokasi, mengajukan izin/sakit, dan melihat riwayat kehadiran
- **Orang Tua**: mengkonfirmasi izin yang diajukan

**Masalah yang diselesaikan:**
- Menghilangkan proses absensi manual yang memakan waktu
- Mencegah kecurangan absensi dengan validasi GPS (radius 150m dari sekolah)
- Memberikan transparansi kehadiran siswa kepada orang tua secara real-time
- Otomatis menandai siswa alpha jika tidak absen hingga jam 12 siang

## Fitur Utama

### Untuk Murid
- Absensi masuk/pulang dengan validasi lokasi GPS
- Pengajuan izin, sakit, atau pulang awal dengan upload bukti
- Riwayat kehadiran lengkap dengan status keterlambatan
- Validasi waktu absensi (masuk sebelum jam 07:00, pulang setelah jam 15:20)

### Untuk Guru
- Dashboard statistik kehadiran (Hadir, Izin, Sakit, Alpha)
- Monitoring kehadiran per kelas secara real-time
- Riwayat absensi dengan filter tanggal dan kelas
- Persetujuan izin siswa

### Untuk Orang Tua
- Konfirmasi izin yang diajukan anak

### Fitur Sistem
- Autentikasi berbasis role (Guru, Murid, Orang Tua)
- Validasi lokasi GPS (radius 150m dari sekolah)
- Auto-alpha untuk siswa yang tidak absen hingga jam 12:00
- Export laporan absensi ke PDF

## Tech Stack

### Frontend (Mobile)
- **Flutter** 3.2.3+ - Cross-platform mobile framework
- **http** ^1.1.0 - REST API client
- **image_picker** ^1.0.4 - Image selection
- **geolocator** ^10.1.0 - GPS location services
- **pdf** ^3.10.4 - PDF generation
- **printing** ^5.11.0 - PDF printing

### Backend
- **PHP** - Server-side scripting
- **MySQL** 8.0.30 - Relational database
- **REST API** - API architecture

### Database Schema
- `users` - User authentication & profiles
- `murid` - Student data
- `orang_tua` - Parent data
- `kelas` - Class management
- `absensi` - Attendance records
- `relasi_orang_tua_murid` - Parent-student relationships

## Cara Menjalankan Project

### Prerequisites
- Flutter SDK 3.2.3 atau lebih tinggi
- Android Studio / VS Code
- PHP 8.0+
- MySQL 8.0+
- laragon (untuk local development)

### Setup Backend

1. **Install laragon dan jalankan Apache & MySQL**

2. **Import Database**
   ```bash
   # Buka phpMyAdmin (http://localhost/phpmyadmin)
   # Buat database baru bernama 'absensi'
   # Import file absensi.sql
   ```

3. **Setup API Backend**
   ```bash
   # Letakkan folder API di htdocs
   # Path: C:/laragon/www/API_absen/api/
   ```

4. **Konfigurasi Database**
   - Edit file koneksi database di folder API
   - Sesuaikan username, password, dan nama database

### Setup Flutter App

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd absensi
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Base URL**
   - Buka `lib/services/API_services.dart`
   - Ubah `baseUrl` sesuai IP server Anda:
   ```dart
   // Untuk Android Emulator
   static const String baseUrl = 'http://10.0.2.2/API_absen/api';
   
   // Untuk Real Device (ganti dengan IP komputer Anda)
   static const String baseUrl = 'http://192.168.x.x/API_absen/api';
   ```

4. **Konfigurasi Lokasi Sekolah**
   - Buka `lib/screen/murid_screen.dart`
   - Sesuaikan koordinat GPS sekolah:
   ```dart
   final double sekolahLat = -6.252915153626877;
   final double sekolahLng = 107.06096700833123;
   final double maxDistanceMeter = 150; // Radius dalam meter
   ```

5. **Run Aplikasi**
   ```bash
   # Untuk Android
   flutter run
   
   # Atau pilih device dari VS Code/Android Studio
   ```

### Login Credentials (Demo)

**Murid:**
- Username: `Given`
- Password: `given123`

**Guru:**
- Username: `Marissa`
- Password: `marissa123`

**Orang Tua:**
- Username: `orangtua`
- Password: `orangtua123`

## Screenshots

### Login Screen
<img width="289" height="651" alt="Cuplikan layar 2026-04-26 231926" src="https://github.com/user-attachments/assets/139f49c9-43c8-472c-8731-ee18f0953fe5" />

### Dashboard Murid
<img width="289" height="650" alt="Cuplikan layar 2026-04-26 232003" src="https://github.com/user-attachments/assets/c021411c-f38a-4fa4-a605-88ee38cc5bfa" />

### Absensi Murid
<img width="291" height="650" alt="Cuplikan layar 2026-04-26 232012" src="https://github.com/user-attachments/assets/8f1388da-365b-4244-983b-e350c5e80a56" />

### History Absensi Murid
<img width="290" height="651" alt="Cuplikan layar 2026-04-26 232024" src="https://github.com/user-attachments/assets/a9ce5ddf-60cc-4d4a-b9c5-4513c8830a03" />

### Dashboard Guru
<img width="291" height="647" alt="Cuplikan layar 2026-04-26 232103" src="https://github.com/user-attachments/assets/308457bf-50bd-43c6-bdde-c4a07907d231" />

### History Absensi (Guru)
<img width="293" height="644" alt="Cuplikan layar 2026-04-26 232127" src="https://github.com/user-attachments/assets/bccef633-4b62-4b25-9034-f1ceaa964054" />

### Status Izin (Guru)
<img width="292" height="649" alt="Cuplikan layar 2026-04-26 232135" src="https://github.com/user-attachments/assets/8e99456b-5d59-4b3f-ab36-bbaeba916582" />

### Dashboard Orang Tua
<img width="292" height="649" alt="Cuplikan layar 2026-04-26 232158" src="https://github.com/user-attachments/assets/d0a207ca-f49a-4eb1-87d3-f02bed287cd2" />

---

# API Documentation

### Base URL
```
http://10.0.2.2/API_absen/api
```

### Endpoints

| Method | Endpoint | Fungsi | Parameters |
|--------|----------|--------|------------|
| **POST** | `/login.php` | Autentikasi user (Guru/Murid/Orang Tua) | `username`, `password` |
| **POST** | `/absensi.php` | Submit absensi (masuk/pulang/izin/sakit/pulang awal) | `murid_id`, `jenis`, `keterangan`, `bukti_file` (optional) |
| **GET** | `/absensi.php` | Get riwayat absensi murid | `murid_id`, `tanggal` (optional) |
| **GET** | `/absensi_summary.php` | Get statistik kehadiran harian (Guru) | `tanggal` (optional) |
| **GET** | `/kelas_aktif_summary.php` | Get ringkasan kehadiran per kelas | `tanggal` (optional) |
| **GET** | `/history_kelas.php` | Get daftar semua kelas | - |
| **GET** | `/history_absensi.php` | Get history absensi dengan filter | `tanggal`, `id_kelas` (optional) |
| **GET** | `/history_absensi.php?izin_list=1` | Get daftar izin yang perlu disetujui (Guru) | `izin_list=1` |
| **GET** | `/izin_anak.php` | Get daftar izin anak (Orang Tua) | `orang_tua_id` |
| **POST** | `/konfirmasi_izin.php` | Konfirmasi izin anak oleh orang tua | `absensi_id` |

### Notes
- Semua response menggunakan format JSON dengan struktur `{ "success": boolean, "message": string, "data": object/array }`
- Date format: `YYYY-MM-DD`
- Timestamp format: `YYYY-MM-DD HH:MM:SS`
- Jenis absensi: `masuk`, `pulang`, `izin`, `sakit`, `pulang_awal`, `alpha`
- File upload menggunakan `multipart/form-data`

---

## Kontak

**Developer:** Given  
**Email:** grdgiven4@gmail.com  
**GitHub:** [@MGT06](https://github.com/MGT06)

---

## License

This project is for educational purposes.
