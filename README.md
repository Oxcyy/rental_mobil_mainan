<div align="center">

# FARZATOYS RENTAL

### Aplikasi Manajemen Penyewaan Mobil Mainan

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Provider](https://img.shields.io/badge/Provider-FF6F00?style=for-the-badge&logo=flutter&logoColor=white)](https://pub.dev/packages/provider)

![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat-square&logo=android)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

*Proyek Akhir Mobile — dikembangkan dari Pra-Proyek Akhir*

</div>

---

## Deskripsi

FARZATOYS RENTAL adalah aplikasi mobile berbasis Flutter untuk membantu mitra usaha penyewaan mobil mainan dalam mengelola armada kendaraan, data penyewa, dan transaksi sewa. Backend menggunakan Supabase yang mencakup autentikasi, database cloud, dan penyimpanan gambar.

---

## Fitur

| Fitur | Deskripsi |
|-------|-----------|
| Login | Autentikasi email dan password via Supabase Auth |
| CRUD Unit Mobil | Tambah, lihat, edit, dan hapus data unit mobil mainan |
| CRUD Penyewaan | Tambah transaksi, perbarui status, dan hapus data sewa |
| Kalkulasi Biaya | Total biaya dihitung otomatis: `(menit ÷ 15) × Rp 20.000` |
| Notifikasi | Pengingat terjadwal saat durasi sewa hampir habis |
| Dark / Light Mode | Tema gelap dan terang yang bisa diubah kapan saja |
| Upload Foto | Foto mobil diambil dari kamera/galeri, disimpan ke Supabase Storage |
| Dashboard | Ringkasan harian: total mobil, tersedia, sewa aktif, dan pendapatan |

---

## Materi yang Diimplementasikan

### Widget

| Widget | Fungsi |
|--------|--------|
| `Scaffold` | Struktur dasar tiap halaman |
| `StreamBuilder` | Memantau perubahan sesi autentikasi Supabase |
| `ListView.builder` | Menampilkan daftar mobil dan penyewaan secara dinamis |
| `TextField` | Input form login, data mobil, dan data penyewa |
| `SingleChildScrollView` | Layout scrollable pada form dan dashboard |
| `InkWell` + `Container` | Tombol custom bergaya neobrutalism |
| `CircularProgressIndicator` | Indikator loading saat proses berlangsung |
| `SnackBar` | Notifikasi feedback dengan tombol OK |
| `Row` + `Expanded` | Layout kartu statistik berdampingan di dashboard |

---

### State Management

Aplikasi menggunakan **Provider** dengan dua `ChangeNotifier`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppStore()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: const MyApp(),
)
```

| Method | Kegunaan |
|--------|----------|
| `context.watch<T>()` | Rebuild otomatis saat state berubah |
| `context.read<T>()` | Akses state tanpa memicu rebuild |
| `notifyListeners()` | Memberitahu listener bahwa state berubah |

---

### Navigation

Navigasi menggunakan Navigator bawaan Flutter dengan `MaterialPageRoute`.

```
LoginScreen
    └── HomeScreen (BottomNavigationBar)
          ├── DashboardScreen
          ├── CarsScreen
          │     ├── CarDetailScreen
          │     └── CarFormScreen
          └── RentalsScreen
                ├── RentalDetailScreen
                └── RentalFormScreen
```

---

### Supabase

| Layanan | Fungsi |
|---------|--------|
| Authentication | Login email & password, pantau session via `onAuthStateChange` |
| PostgreSQL Database | Tabel `cars` dan `rentals` |
| Storage | Upload dan akses foto mobil di bucket `car_images` |

Semua operasi dipusatkan di `lib/services/supabase_service.dart`.

```dart
static Future<String> uploadCarImage(File imageFile) async {
  final fileName = 'car_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _client.storage.from('car_images').upload(fileName, imageFile);
  return _client.storage.from('car_images').getPublicUrl(fileName);
}
```

---

### Konfigurasi .env

Kredensial API disimpan menggunakan `flutter_dotenv` dan tidak di-push ke GitHub.

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

```dart
await dotenv.load(fileName: '.env');
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

File `.env` didaftarkan sebagai asset di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

> Jangan commit file `.env` ke GitHub. Gunakan `.env.example` sebagai template untuk kolaborator.

---

### Package Tambahan

| Package | Versi | Fungsi |
|---------|:-----:|--------|
| `provider` | ^6.1.1 | State management — AppStore dan ThemeProvider |
| `intl` | ^0.18.1 | Format Rupiah dan tanggal lokal `id_ID` |
| `flutter_local_notifications` | ^21.0.0 | Notifikasi terjadwal pengingat durasi sewa |
| `timezone` | ^0.11.0 | Zona waktu `Asia/Makassar` (WITA) untuk notifikasi |
| `image_picker` | ^1.2.1 | Ambil foto dari kamera atau galeri perangkat |

---

## Cara Instalasi

Prasyarat: Flutter SDK `>=3.0.0 <4.0.0`, Android Studio atau VS Code, akun Supabase aktif.

```bash
# 1. Clone repositori
git clone https://github.com/Oxcyy/rental_mobil_mainan.git
cd rental_mobil_mainan

# 2. Buat file .env
cp .env.example .env
# Isi SUPABASE_URL dan SUPABASE_ANON_KEY

# 3. Install dependencies
flutter pub get

# 4. Jalankan aplikasi
flutter run
```

URL dan Anon Key tersedia di **Supabase Dashboard > Project Settings > API**.

---

## Struktur Proyek

```
lib/
├── app_store.dart
├── main.dart
├── notification_service.dart
├── models/
│   ├── car.dart
│   ├── rental.dart
│   └── queue_item.dart
├── providers/
│   └── theme_provider.dart
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
├── services/
│   └── supabase_service.dart
└── widgets/
    └── custom_app_bar.dart
```

---

## Kalkulasi Biaya

Biaya sewa dihitung otomatis di model `Rental`:

```
Total Biaya = (Durasi Menit ÷ 15) × Rp 20.000

Contoh: 30 menit  →  (30 ÷ 15) × Rp 20.000  =  Rp 40.000
```

---

## Lisensi

Didistribusikan di bawah lisensi MIT. Lihat [LICENSE](LICENSE) untuk detail.

---

<div align="center">
FARZATOYS RENTAL · Proyek Akhir Mobile 2026
</div>
