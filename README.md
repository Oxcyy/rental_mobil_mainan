<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=700&size=28&pause=1000&color=7B1FA2&center=true&vCenter=true&width=500&lines=FARZATOYS+RENTAL+🚗;Aplikasi+Penyewaan+Mobil+Mainan" alt="Typing SVG" />

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Provider](https://img.shields.io/badge/Provider-FF6F00?style=for-the-badge&logo=flutter&logoColor=white)](https://pub.dev/packages/provider)

![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Version](https://img.shields.io/badge/Version-1.0.0-7B1FA2?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-success?style=flat-square)

<br/>

> **Proyek Akhir Mobile** · Flutter + Supabase · 2026

</div>

---

## Daftar Isi

- [Profil Anggota](#profil-anggota)
- [Tentang Aplikasi](#tentang-aplikasi)
- [Fitur](#fitur)
- [Implementasi](#implementasi)
  - [Widget](#widget)
  - [State Management](#state-management--provider)
  - [Navigation](#navigation)
  - [Supabase](#supabase)
  - [Konfigurasi .env](#konfigurasi-env)
  - [Package Tambahan](#package-tambahan)
- [Instalasi](#instalasi)
- [Struktur Proyek](#struktur-proyek)
- [Rumus Kalkulasi Biaya](#rumus-kalkulasi-biaya)
- [Lisensi](#lisensi)

---

## Profil Anggota

**Kelompok :** (isi nomor kelompok)  
**Kelas :** Sistem Informasi  
**Mata Kuliah :** Pemrograman Aplikasi Bergerak

| Nama | NIM | Kelas | GitHub |
|------|-----|-------|--------|
| Yulius Pune' | 2409116110 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Oxcyy-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Oxcyy) |
| Muhammad Fakhri Al-Kautsar | 2409116081 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Oxcyy-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Oxcyy) |
| Yudha Tri Atmaja  | 2409116095 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Oxcyy-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Oxcyy) |
| Elvira Agustin  | 2409116109 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Oxcyy-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Oxcyy) |
| Rizky wahyu dina putri | 2409116111 | Sistem Informasi C '24 | [![GitHub](https://img.shields.io/badge/Oxcyy-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/Oxcyy) |

---

## Tentang Aplikasi

**FARZATOYS RENTAL** adalah aplikasi mobile yang dibangun dengan Flutter untuk membantu mitra usaha penyewaan mobil mainan mengelola armada, data penyewa, dan transaksi secara digital. Seluruh data tersimpan di cloud menggunakan Supabase — real-time, aman, dan mudah diakses.

---

## Fitur

| Fitur | Deskripsi |
|-------|-----------|
| **Login** | Autentikasi email & password via Supabase Auth |
| **Manajemen Unit Mobil** | CRUD lengkap data unit mobil beserta foto |
| **Manajemen Penyewaan** | Tambah, edit, update status, dan hapus transaksi sewa |
| **Kalkulasi Otomatis** | Biaya dihitung real-time: `(menit ÷ 15) × Rp 20.000` |
| **Notifikasi Pengingat** | Alert terjadwal saat waktu sewa hampir habis |
| **Dark / Light Mode** | Tema aplikasi bisa diubah kapan saja |
| **Upload Foto** | Ambil foto dari kamera/galeri, simpan ke Supabase Storage |
| **Dashboard** | Statistik harian: armada, ketersediaan, sewa aktif, pendapatan |

---

## Implementasi

### Widget

| Widget | Penggunaan |
|--------|------------|
| `Scaffold` | Kerangka dasar setiap halaman |
| `StreamBuilder` | Memantau status sesi autentikasi secara reaktif |
| `ListView.builder` | Render daftar mobil dan transaksi secara dinamis |
| `TextField` | Input pada form login, data mobil, dan penyewa |
| `SingleChildScrollView` | Halaman yang bisa di-scroll (form & dashboard) |
| `InkWell` + `Container` | Tombol custom bergaya neobrutalism |
| `CircularProgressIndicator` | Loading state saat proses async berlangsung |
| `SnackBar` | Feedback ke pengguna setelah aksi |
| `Row` + `Expanded` | Layout grid kartu statistik di dashboard |

---

### State Management — Provider

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppStore()),      // data mobil & rental
    ChangeNotifierProvider(create: (_) => ThemeProvider()), // dark/light mode
  ],
  child: const MyApp(),
)
```

| Method | Fungsi |
|--------|--------|
| `context.watch<T>()` | Subscribe state, rebuild otomatis saat berubah |
| `context.read<T>()` | Akses state tanpa trigger rebuild |
| `notifyListeners()` | Broadcast perubahan ke semua listener |

---

### Navigation

Navigasi menggunakan **Navigator** bawaan Flutter dengan `MaterialPageRoute`.

```
LoginScreen
    └── HomeScreen  ←  BottomNavigationBar
          ├── DashboardScreen
          ├── CarsScreen
          │     ├── CarDetailScreen
          │     └── CarFormScreen      ← tambah / edit + upload foto
          └── RentalsScreen
                ├── RentalDetailScreen
                └── RentalFormScreen   ← tambah / edit penyewaan
```

---

### Supabase

| Layanan | Implementasi |
|---------|-------------|
| **Auth** | Login email & password — session dipantau via `onAuthStateChange` stream |
| **Database** | PostgreSQL — tabel `cars` dan `rentals` |
| **Storage** | Bucket `car_images` untuk foto unit mobil |

```dart
// lib/services/supabase_service.dart
static Future<String> uploadCarImage(File imageFile) async {
  final fileName = 'car_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _client.storage.from('car_images').upload(fileName, imageFile);
  return _client.storage.from('car_images').getPublicUrl(fileName);
}
```

---

### Konfigurasi .env

Kredensial API dikelola dengan `flutter_dotenv` — tidak pernah masuk ke repository.

```env
# .env — jangan di-commit
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

```dart
// main.dart
await dotenv.load(fileName: '.env');
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

> Salin `.env.example` → `.env`, lalu isi dengan kredensial proyek Supabase Anda.

---

### Package Tambahan

| Package | Versi | Kegunaan |
|---------|:-----:|----------|
| `provider` | ^6.1.1 | State management global |
| `intl` | ^0.18.1 | Format Rupiah & tanggal lokal `id_ID` |
| `flutter_local_notifications` | ^21.0.0 | Notifikasi terjadwal pengingat akhir sewa |
| `timezone` | ^0.11.0 | Zona waktu `Asia/Makassar` (WITA) |
| `image_picker` | ^1.2.1 | Akses kamera & galeri perangkat |

---

## Instalasi

> Prasyarat: Flutter `>=3.0.0`, Android Studio / VS Code, akun Supabase aktif.

```bash
# Clone
git clone https://github.com/Oxcyy/rental_mobil_mainan.git
cd rental_mobil_mainan

# Setup environment
cp .env.example .env
# → Isi SUPABASE_URL dan SUPABASE_ANON_KEY

# Install & jalankan
flutter pub get
flutter run
```

Dapatkan kredensial di **Supabase Dashboard → Project Settings → API**.

---

## Struktur Proyek

```
lib/
├── app_store.dart               # Global state (Provider)
├── main.dart                    # Entry point & inisialisasi app
├── notification_service.dart    # Notifikasi terjadwal (WITA)
│
├── models/
│   ├── car.dart                 # Model unit mobil
│   ├── rental.dart              # Model penyewaan + kalkulasi harga
│   └── queue_item.dart
│
├── providers/
│   └── theme_provider.dart      # Dark / Light mode
│
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── cars_screen.dart
│   ├── car_detail_screen.dart
│   ├── car_form_screen.dart
│   ├── rentals_screen.dart
│   ├── rental_detail_screen.dart
│   └── rental_form_screen.dart
│
├── services/
│   └── supabase_service.dart    # Semua operasi CRUD & Auth
│
└── widgets/
    └── custom_app_bar.dart
```

---

## Rumus Kalkulasi Biaya

```
Total = (Durasi menit ÷ 15) × Rp 20.000

Contoh:  30 menit  →  (30 ÷ 15) × 20.000  =  Rp 40.000
         60 menit  →  (60 ÷ 15) × 20.000  =  Rp 80.000
```

---

## Lisensi

MIT License — lihat [LICENSE](LICENSE) untuk detail.

---

<div align="center">

Made with Flutter & Supabase · FARZATOYS RENTAL · Proyek Akhir Mobile 2026

</div>
