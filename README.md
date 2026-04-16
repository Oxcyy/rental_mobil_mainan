# 🚗 FARZATOYS RENTAL — Aplikasi Manajemen Penyewaan Mobil Mainan

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-FF6F00?style=for-the-badge&logo=flutter&logoColor=white)

---

## 📋 Deskripsi Aplikasi

**FARZATOYS RENTAL** adalah aplikasi mobile berbasis **Flutter** yang dikembangkan sebagai **Proyek Akhir** dari pengembangan Pra-Proyek Akhir. Aplikasi ini dirancang khusus untuk membantu mitra usaha penyewaan mobil mainan dalam mengelola armada kendaraan, data penyewa, serta transaksi sewa secara efisien.

Backend aplikasi menggunakan **Supabase** yang mencakup autentikasi pengguna, penyimpanan database cloud, dan upload gambar via Supabase Storage.

---

## ✨ Fitur Aplikasi

| No | Fitur | Deskripsi |
|----|-------|-----------|
| 1 | 🔐 **Login** | Autentikasi pengguna dengan email & password menggunakan Supabase Auth |
| 2 | 🚘 **CRUD Unit Mobil** | Tambah, lihat detail, edit, dan hapus data unit mobil mainan |
| 3 | 📋 **CRUD Data Penyewaan** | Tambah transaksi sewa baru, perbarui status, dan hapus data penyewaan |
| 4 | 🧮 **Kalkulasi Biaya Otomatis** | Total biaya dihitung otomatis: `(durasi menit ÷ 15) × Rp 20.000` per sesi |
| 5 | 🔔 **Notifikasi Pengingat Waktu** | Notifikasi terjadwal otomatis saat durasi sewa habis via `flutter_local_notifications` |
| 6 | 🌗 **Dark / Light Mode** | Tampilan dapat beralih antara tema gelap dan terang secara langsung |
| 7 | 🖼️ **Upload Foto Mobil** | Foto unit mobil diambil dari kamera/galeri dan disimpan ke Supabase Storage |
| 8 | 📊 **Dashboard Ringkasan** | Statistik harian: total mobil, unit tersedia, sewa aktif, dan pendapatan hari ini |

---

## 📚 Materi yang Diimplementasikan

### 🧩 Widget

Aplikasi menggunakan berbagai widget Flutter Material, antara lain:

- **`Scaffold`** — Struktur dasar tiap halaman dengan AppBar dan Body
- **`StreamBuilder`** — Memantau perubahan sesi autentikasi Supabase di `AuthWrapper`
- **`ListView.builder`** — Menampilkan daftar unit mobil dan riwayat penyewaan secara dinamis
- **`TextField`** — Input form untuk login, data mobil, dan data penyewa
- **`SingleChildScrollView`** — Layout scrollable pada form dan dashboard
- **`InkWell`** + **`Container`** — Tombol custom bergaya neobrutalism
- **`CircularProgressIndicator`** — Indikator loading saat proses data berlangsung
- **`SnackBar`** (custom) — Notifikasi feedback dengan tombol OK bergaya neobrutalism
- **`Row`** + **`Expanded`** — Layout kartu statistik berdampingan di dashboard

---

### ⚙️ State Management

Aplikasi menggunakan **Provider** sebagai solusi state management:

- **`ChangeNotifier`** — Digunakan oleh `AppStore` (data mobil & rental) dan `ThemeProvider` (dark/light mode)
- **`ChangeNotifierProvider`** — Mendistribusikan state ke seluruh widget tree via `MultiProvider`
- **`context.watch<T>()`** — Memicu rebuild otomatis saat state berubah (DashboardScreen, CarsScreen, dll)
- **`context.read<T>()`** — Mengakses state tanpa rebuild (untuk aksi seperti toggle tema)

```dart
// Inisialisasi di main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppStore()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: const MyApp(),
)
```

---

### 🗺️ Navigation

Navigasi menggunakan sistem **Navigator** bawaan Flutter dengan `MaterialPageRoute`:

```dart
// Berpindah ke halaman baru
Navigator.push(context, MaterialPageRoute(builder: (_) => CarFormScreen()));

// Kembali ke halaman sebelumnya
Navigator.pop(context);
```

Alur navigasi utama aplikasi:

```
LoginScreen
    └── HomeScreen (BottomNavigationBar)
          ├── DashboardScreen            → Ringkasan statistik harian
          ├── CarsScreen
          │     ├── CarDetailScreen
          │     └── CarFormScreen        → Tambah / Edit unit mobil + upload foto
          └── RentalsScreen
                ├── RentalDetailScreen
                └── RentalFormScreen     → Tambah / Edit data penyewaan
```

---

### 🗄️ Supabase

**Supabase** digunakan sebagai backend lengkap aplikasi:

| Layanan Supabase | Fungsi dalam Aplikasi |
|------------------|-----------------------|
| **Authentication** | Login email & password; session dipantau via `onAuthStateChange` stream |
| **PostgreSQL Database** | Tabel `cars` (unit mobil) dan `rentals` (data penyewaan) |
| **Storage** | Upload dan akses foto unit mobil di bucket `car_images` |

Semua operasi dipusatkan di `lib/services/supabase_service.dart`:

```dart
// Contoh: Upload gambar unit mobil ke Supabase Storage
static Future<String> uploadCarImage(File imageFile) async {
  final fileName = 'car_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _client.storage.from('car_images').upload(fileName, imageFile);
  return _client.storage.from('car_images').getPublicUrl(fileName);
}
```

---

### 🔒 Konfigurasi `.env`

Aplikasi menggunakan **`flutter_dotenv`** untuk menyimpan kredensial API secara aman. File `.env` **tidak di-push ke GitHub** (sudah masuk `.gitignore`).

**Isi file `.env`:**

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Pemuatan di `main.dart`:**

```dart
await dotenv.load(fileName: '.env');
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

File `.env` juga didaftarkan sebagai **asset** di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

> ⚠️ **Jangan** commit file `.env` ke GitHub. Buat file `.env.example` sebagai template untuk kolaborator.

---

### 📦 Package Tambahan (Nilai Tambah)

Selain `supabase_flutter` dan `flutter_dotenv`, aplikasi menggunakan:

| Package | Versi | Fungsi dalam Aplikasi |
|---------|-------|-----------------------|
| **`provider`** | ^6.1.1 | State management untuk `AppStore` dan `ThemeProvider` (dark/light mode) |
| **`intl`** | ^0.18.1 | Format mata uang Rupiah (`NumberFormat.currency`) dan format tanggal lokal `id_ID` |
| **`flutter_local_notifications`** | ^21.0.0 | Notifikasi terjadwal sebagai pengingat akhir durasi sewa |
| **`timezone`** | ^0.11.0 | Penjadwalan notifikasi berbasis zona waktu `Asia/Makassar` (WITA) |
| **`image_picker`** | ^1.2.1 | Mengambil foto unit mobil dari kamera atau galeri untuk diunggah ke Supabase Storage |

---

## 🚀 Cara Instalasi

### Prasyarat
- Flutter SDK `>=3.0.0 <4.0.0`
- Android Studio / VS Code
- Akun Supabase aktif

---

### Langkah 1 — Clone Repositori

```bash
git clone https://github.com/username/rental_mobil_mainan.git
cd rental_mobil_mainan
```

---

### Langkah 2 — Buat File `.env`

```bash
cp .env.example .env
```

Isi dengan kredensial Supabase Anda:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

> 💡 URL dan Anon Key tersedia di **Supabase Dashboard → Project Settings → API**

---

### Langkah 3 — Install Dependencies

```bash
flutter pub get
```

---

### Langkah 4 — Jalankan Aplikasi

```bash
flutter run
```

Untuk memilih perangkat tertentu:

```bash
flutter devices              # Lihat daftar perangkat
flutter run -d <device_id>   # Jalankan di perangkat tertentu
```

---

## 🗂️ Struktur Proyek

```
lib/
├── app_store.dart              # AppStore — state global (Provider)
├── main.dart                   # Entry point, inisialisasi Supabase & Provider
├── notification_service.dart   # Layanan notifikasi terjadwal (WITA)
├── models/
│   ├── car.dart                # Model data unit mobil
│   ├── rental.dart             # Model penyewaan + kalkulasi harga otomatis
│   └── queue_item.dart         # Model antrian
├── providers/
│   └── theme_provider.dart     # ThemeProvider — dark/light mode
├── screens/
│   ├── login_screen.dart       # Halaman login
│   ├── home_screen.dart        # Halaman utama (BottomNavigationBar)
│   ├── dashboard_screen.dart   # Dashboard statistik harian
│   ├── cars_screen.dart        # Daftar unit mobil
│   ├── car_detail_screen.dart  # Detail unit mobil
│   ├── car_form_screen.dart    # Form tambah/edit + upload foto
│   ├── rentals_screen.dart     # Daftar penyewaan
│   ├── rental_detail_screen.dart
│   └── rental_form_screen.dart # Form tambah/edit penyewaan
├── services/
│   └── supabase_service.dart   # Semua operasi CRUD & Auth ke Supabase
└── widgets/
    └── custom_app_bar.dart     # AppBar custom bergaya neobrutalism
```

---

## 💡 Cara Kerja Kalkulasi Biaya

Biaya sewa dihitung otomatis di model `Rental`:

```
Total Biaya = (Durasi Menit ÷ 15) × Rp 20.000
```

Contoh: sewa **30 menit** → `(30 ÷ 15) × Rp 20.000 = **Rp 40.000**`

---

## 🤝 Kontribusi

1. **Fork** repositori ini
2. Buat branch: `git checkout -b fitur/nama-fitur`
3. Commit: `git commit -m 'feat: deskripsi fitur'`
4. Push: `git push origin fitur/nama-fitur`
5. Buat **Pull Request**

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah lisensi **MIT**. Lihat file [LICENSE](LICENSE) untuk informasi lebih lanjut.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/) — Framework UI lintas platform
- [Supabase](https://supabase.com/) — Backend as a Service (Auth + Database + Storage)
- [Provider](https://pub.dev/packages/provider) — State management sederhana dan efisien

---

<p align="center">Dikembangkan sebagai <strong>Proyek Akhir Mobile</strong> — FARZATOYS RENTAL 🚗</p>
