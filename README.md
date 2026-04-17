<div align="center">

```
███████╗ █████╗ ██████╗ ███████╗ █████╗ ████████╗ ██████╗ ██╗   ██╗███████╗
██╔════╝██╔══██╗██╔══██╗╚════██║██╔══██╗╚══██╔══╝██╔═══██╗╚██╗ ██╔╝██╔════╝
█████╗  ███████║██████╔╝    ██╔╝███████║   ██║   ██║   ██║ ╚████╔╝ ███████╗
██╔══╝  ██╔══██║██╔══██╗   ██╔╝ ██╔══██║   ██║   ██║   ██║  ╚██╔╝  ╚════██║
██║     ██║  ██║██║  ██║   ██║  ██║  ██║   ██║   ╚██████╔╝   ██║   ███████║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝    ╚═╝   ╚══════╝
                        🚗  R E N T A L  🚗
```

### Aplikasi Manajemen Penyewaan Mobil Mainan

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Provider](https://img.shields.io/badge/Provider-FF6F00?style=for-the-badge&logo=flutter&logoColor=white)](https://pub.dev/packages/provider)

<br/>

![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat-square&logo=android)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)

<br/>

> 🎓 **Proyek Akhir Mobile** · Dikembangkan dari Pra-Proyek Akhir

</div>

---

## 📖 Tentang Aplikasi

**FARZATOYS RENTAL** adalah aplikasi mobile berbasis **Flutter** untuk membantu mitra usaha penyewaan mobil mainan mengelola armada kendaraan, data penyewa, dan transaksi sewa secara efisien menggunakan **Supabase** sebagai backend cloud.

<br/>

<div align="center">

| 🔐 Auth | 🚘 Kelola Mobil | 📋 Kelola Sewa | 📊 Dashboard |
|:---:|:---:|:---:|:---:|
| Login via Supabase | CRUD unit mobil | CRUD transaksi | Statistik harian |

</div>

---

## ✨ Fitur Lengkap

<table>
  <tr>
    <td width="50%">
      <h3>🔐 Autentikasi</h3>
      <p>Login aman dengan email & password via <strong>Supabase Auth</strong>. Session otomatis dipantau menggunakan <code>StreamBuilder</code>.</p>
    </td>
    <td width="50%">
      <h3>🚘 Manajemen Unit Mobil</h3>
      <p>CRUD lengkap: tambah, lihat detail, edit data, dan hapus unit mobil mainan beserta foto.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🧮 Kalkulasi Biaya Otomatis</h3>
      <p>Biaya dihitung real-time berdasarkan durasi:<br/>
      <code>(menit ÷ 15) × Rp 20.000</code></p>
    </td>
    <td width="50%">
      <h3>🔔 Notifikasi Pengingat</h3>
      <p>Notifikasi terjadwal otomatis saat waktu sewa hampir habis, berbasis zona waktu <strong>WITA</strong>.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🌗 Dark / Light Mode</h3>
      <p>Tema gelap dan terang yang bisa diubah kapan saja via <strong>ThemeProvider</strong>.</p>
    </td>
    <td width="50%">
      <h3>🖼️ Upload Foto Mobil</h3>
      <p>Ambil foto dari kamera/galeri lalu simpan otomatis ke <strong>Supabase Storage</strong>.</p>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>📊 Dashboard Real-time</h3>
      <p>Ringkasan statistik harian: total mobil, unit tersedia, sewa aktif, dan total pendapatan.</p>
    </td>
    <td width="50%">
      <h3>📋 Manajemen Penyewaan</h3>
      <p>CRUD data penyewaan lengkap dengan info penyewa, durasi, status, dan histori transaksi.</p>
    </td>
  </tr>
</table>

---

## 🛠️ Tech Stack & Implementasi

### 🧩 Widget yang Digunakan

```
┌─────────────────────────────────────────────────────────────┐
│  Scaffold           →  Struktur dasar tiap halaman          │
│  StreamBuilder      →  Pantau sesi auth Supabase            │
│  ListView.builder   →  Daftar mobil & penyewaan dinamis     │
│  TextField          →  Form input login, mobil, penyewa     │
│  InkWell+Container  →  Tombol custom neobrutalism           │
│  CircularProgress   →  Indikator loading                    │
│  SnackBar (custom)  →  Notifikasi feedback + tombol OK      │
│  Row + Expanded     →  Layout kartu statistik dashboard     │
└─────────────────────────────────────────────────────────────┘
```

---

### ⚙️ State Management — Provider

Aplikasi menggunakan **Provider** dengan dua `ChangeNotifier` utama:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppStore()),      // data mobil & rental
    ChangeNotifierProvider(create: (_) => ThemeProvider()), // dark/light mode
  ],
  child: const MyApp(),
)
```

| Method | Kegunaan |
|--------|----------|
| `context.watch<T>()` | Rebuild otomatis saat state berubah |
| `context.read<T>()` | Akses state tanpa rebuild |
| `notifyListeners()` | Trigger update ke semua listener |

---

### 🗺️ Alur Navigasi

```
🔐 LoginScreen
      │
      └──▶ 🏠 HomeScreen  (BottomNavigationBar)
                │
                ├──▶ 📊 DashboardScreen
                │
                ├──▶ 🚘 CarsScreen
                │         ├──▶ CarDetailScreen
                │         └──▶ CarFormScreen  (Tambah/Edit + Upload Foto)
                │
                └──▶ 📋 RentalsScreen
                          ├──▶ RentalDetailScreen
                          └──▶ RentalFormScreen  (Tambah/Edit)
```

---

### 🗄️ Supabase Integration

<div align="center">

| Layanan | Fungsi |
|:-------:|--------|
| 🔑 **Auth** | Login email & password, pantau session via stream |
| 🗃️ **Database** | Tabel `cars` dan `rentals` di PostgreSQL |
| 📦 **Storage** | Upload & akses foto mobil di bucket `car_images` |

</div>

```dart
// Semua operasi dipusatkan di SupabaseService
static Future<String> uploadCarImage(File imageFile) async {
  final fileName = 'car_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await _client.storage.from('car_images').upload(fileName, imageFile);
  return _client.storage.from('car_images').getPublicUrl(fileName);
}
```

---

### 🔒 Konfigurasi `.env`

Kredensial API disimpan aman menggunakan **`flutter_dotenv`** — **tidak di-push ke GitHub**.

```env
# .env  (jangan di-commit!)
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

> ⚠️ Salin `.env.example` → `.env` dan isi dengan kredensial milik Anda sendiri.

---

### 📦 Package Tambahan

<div align="center">

| Package | Versi | Fungsi |
|---------|:-----:|--------|
| `provider` | ^6.1.1 | State management (AppStore + ThemeProvider) |
| `intl` | ^0.18.1 | Format Rupiah & tanggal lokal `id_ID` |
| `flutter_local_notifications` | ^21.0.0 | Notifikasi terjadwal pengingat durasi sewa |
| `timezone` | ^0.11.0 | Zona waktu `Asia/Makassar` (WITA) |
| `image_picker` | ^1.2.1 | Ambil foto dari kamera/galeri |

</div>

---

## 💡 Rumus Kalkulasi Biaya

<div align="center">

```
╔══════════════════════════════════════════╗
║                                          ║
║   Total = (Durasi menit ÷ 15) × 20.000  ║
║                                          ║
║   Contoh: 30 menit                       ║
║   → (30 ÷ 15) × Rp 20.000 = Rp 40.000  ║
║                                          ║
╚══════════════════════════════════════════╝
```

</div>

---

## 🚀 Cara Instalasi

### Prasyarat

- Flutter SDK `>=3.0.0 <4.0.0`
- Android Studio / VS Code
- Akun Supabase aktif

### Langkah-langkah

```bash
# 1. Clone repositori
git clone https://github.com/Oxcyy/rental_mobil_mainan.git
cd rental_mobil_mainan

# 2. Buat file .env
cp .env.example .env
# → Edit .env dan isi SUPABASE_URL & SUPABASE_ANON_KEY

# 3. Install dependencies
flutter pub get

# 4. Jalankan aplikasi
flutter run
```

> 💡 Dapatkan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di **Supabase Dashboard → Project Settings → API**

---

## 🗂️ Struktur Proyek

```
📁 lib/
├── 📄 app_store.dart              ← State global (Provider)
├── 📄 main.dart                   ← Entry point & inisialisasi
├── 📄 notification_service.dart   ← Notifikasi terjadwal WITA
│
├── 📁 models/
│   ├── 🚘 car.dart               ← Model unit mobil
│   ├── 📋 rental.dart            ← Model penyewaan + kalkulasi harga
│   └── 🔢 queue_item.dart        ← Model antrian
│
├── 📁 providers/
│   └── 🌗 theme_provider.dart    ← Dark/Light mode
│
├── 📁 screens/
│   ├── 🔐 login_screen.dart
│   ├── 🏠 home_screen.dart
│   ├── 📊 dashboard_screen.dart
│   ├── 🚘 cars_screen.dart
│   ├── 🔍 car_detail_screen.dart
│   ├── ✏️  car_form_screen.dart
│   ├── 📋 rentals_screen.dart
│   ├── 🔍 rental_detail_screen.dart
│   └── ✏️  rental_form_screen.dart
│
├── 📁 services/
│   └── ☁️  supabase_service.dart  ← CRUD & Auth ke Supabase
│
└── 📁 widgets/
    └── 🎨 custom_app_bar.dart     ← AppBar neobrutalism
```

---

## 🤝 Kontribusi

```bash
# Fork → Clone → Branch → Push → PR
git checkout -b fitur/nama-fitur
git commit -m "feat: deskripsi fitur"
git push origin fitur/nama-fitur
```

---

## 📄 Lisensi

Didistribusikan di bawah lisensi **MIT**. Lihat [`LICENSE`](LICENSE) untuk detail.

---

<div align="center">

**🙏 Dibuat dengan ❤️ menggunakan**

[![Flutter](https://img.shields.io/badge/-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/-Supabase-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com)
[![Dart](https://img.shields.io/badge/-Dart-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)

<br/>

⭐ **Jangan lupa kasih bintang kalau proyek ini membantu!** ⭐

<br/>

```
Made with 💜 · FARZATOYS RENTAL · Proyek Akhir Mobile 2026
```

</div>
