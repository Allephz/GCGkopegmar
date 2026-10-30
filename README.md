# GCG Akor Kopegmar - Flutter Edition

Aplikasi mobile Flutter untuk **GCG Akor (Clodios) ERP** - Sistem manajemen koperasi **Kopegmar** (Koperasi Pegawai Garuda Mas).

## 📱 Deskripsi

Aplikasi ini adalah konversi dari **Kotlin Android** ke **Flutter** dengan desain UI baru **DESIGN_MUDAH** yang lebih sederhana dan user-friendly.

**Fitur Utama:**
- ✅ Login dengan validasi
- ✅ Dashboard dengan greeting & loan info
- ✅ Manajemen Pinjaman (Ajukan, Lihat Riwayat, Detail)
- ✅ Manajemen Simpanan (Tarik, Lihat Riwayat)
- ✅ Profil & Edit Data
- ✅ Riwayat Transaksi
- ✅ Bottom Navigation (4 menu utama)

## 🎨 DESIGN_MUDAH - Panduan Visual

### Color Palette
- **Primary Blue**: `#2563EB` - Buttons, Links, Headers
- **Success Green**: `#10B981` - Success, Savings
- **Warning Orange**: `#F59E0B` - Warning, Alerts
- **Error Red**: `#EF4444` - Errors, Dangerous Actions
- **Background Gray**: `#F3F4F6` - Background, Subtle Elements

### Typography
- **Font**: Roboto
- **Large (Title)**: 24px, Bold
- **Medium (Body)**: 16px, Regular
- **Small (Label)**: 14px, Regular

### Dimensions
- **Button Height**: 48px
- **Card Padding**: 16dp
- **Border Radius**: 8dp (Normal), 20dp (Badge)
- **Spacing**: 16dp Between Elements

## 🚀 Persiapan Lingkungan

### Prerequisite
- Flutter SDK 3.2+
- Dart SDK 3.2+
- Android SDK 24+ (Min API Level)
- Android Studio / VS Code

### Install Flutter
```bash
# Windows (via PowerShell)
# Download: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0-stable.zip
# Extract ke C:\src\flutter
# Tambahkan ke PATH: C:\src\flutter\bin

flutter doctor
```

### Setup Project
```bash
# 1. Cek dependencies
flutter pub get

# 2. Build & Run
flutter run -d <emulator-id>
```

## 📁 Struktur Project

```
lib/
├── main.dart                 # Entry point dengan theme DESIGN_MUDAH
├── screens/
│   ├── splash_screen.dart   # 3-second splash dengan loader
│   ├── login_screen.dart    # Login dengan eye icon & checkbox
│   ├── home_screen.dart     # Dashboard, greeting, loan card, 4 buttons
│   ├── loan_list_screen.dart    # List pinjaman (Aktif/Riwayat/Ditolak)
│   ├── loan_detail_screen.dart  # Detail pinjaman & installments
│   ├── apply_loan_screen.dart   # 3-step wizard pengajuan
│   ├── savings_screen.dart      # Manajemen simpanan
│   ├── withdrawal_screen.dart   # Form penarikan simpanan
│   ├── withdrawal_result_screen.dart  # Result screen
│   ├── profile_screen.dart      # Avatar, sections, logout
│   ├── edit_profile_screen.dart # Form edit data
│   ├── personal_data_screen.dart # Detail data diri
│   └── transaction_history_screen.dart # Timeline transaksi
├── services/
│   └── api_service.dart     # Dio HTTP Client, 20+ endpoints
├── models/
│   └── responses.dart       # Dart models untuk API responses
├── widgets/
│   └── (custom widgets)
└── utils/
    └── (helper functions)

android/
├── app/
│   ├── build.gradle.kts
│   └── src/main/AndroidManifest.xml
└── build.gradle.kts

pubspec.yaml               # Dependencies & assets
README.md                  # Dokumentasi ini
```

## 🔌 API Integration

### Endpoints (20+)
Semua endpoint menggunakan base URL: `https://kopegmar.com/`

| No | Endpoint | Method | Fungsi |
|----|----------|--------|--------|
| 1 | `/preodm?fnc=auth` | POST | Login |
| 2 | `/txn?rc=...` | GET | Get Personal Data |
| 3 | `/txn?rc=...` | GET | Get Nominal Simpanan |
| 4 | `/txn?rc=...` | POST | Tarik Simpanan |
| 5 | `/txn?rc=...` | GET | Get Tenor List |
| 6 | `/txn?rc=...` | POST | Hitung Cicilan Pinjaman |
| 7 | `/txn?rc=...` | POST | Ajukan Pinjaman |
| 8 | `/txn?rc=...` | GET | Get Loan History |
| ... | ... | ... | ... |

**API Key**: `iJRj9e2v1xIL1ib2xkM4A`
**Workspace ID**: `YPNRO`

### Authentication
```dart
final response = await apiService.login(
  username: 'CANDRA',
  password: 'password123',
);
// Returns: { s: SESSION_ID, srt: TOKEN, pid: PROFILE_ID, e: null }
```

## 🛠️ Development

### Hot Reload
```bash
flutter run
# Press 'r' untuk hot reload
# Press 'R' untuk hot restart
```

### Build APK
```bash
flutter build apk --release
```

### Build AAB (Google Play)
```bash
flutter build appbundle --release
```

## 13 Screens Overview

1. **SPLASH** - Logo + Spinner (3s delay)
2. **LOGIN** - Username, Password, Remember me, Eye icon
3. **HOME** - Greeting, Loan Card, 4 Buttons, Transactions, Bottom Nav
4. **PINJAMAN LIST** - Tabs (Aktif/Riwayat/Ditolak), Cards, FAB
5. **LOAN DETAILS** - Amount, Status, Progress, Installments
6. **APPLY LOAN** - 3-step Wizard (Type/Amount/Review)
7. **TARIK SIMPANAN** - Select Type, Checkbox, Button
8. **TARIK NOMINAL** - Amount Input, Fee Info, Checkbox
9. **WITHDRAWAL RESULT** - Icon, Card, 3 Buttons
10. **PROFILE** - Avatar, Sections, Logout
11. **EDIT PROFILE** - Form Fields, Warning, Save/Cancel
12. **PERSONAL DATA** - Multiple Sections (Education, Job, Address, Bank)
13. **TRANSACTION HISTORY** - Timeline, Load More

## ⚠️ Catatan Penting

- **No Backend Changes**: Semua API endpoints menggunakan dari Kotlin version
- **UI Only**: Hanya UI yang dirubah, API/Features/Data tetap sama
- **DESIGN_MUDAH**: Semua screens menggunakan color palette & typography yang konsisten
- **Keep It Simple**: Minimal design, fokus pada functionality

## 📝 License

Proprietary - Koperasi Pegawai Garuda Mas (Kopegmar)

## 👨‍💻 Support

Hubungi admin koperasi untuk bantuan teknis.
