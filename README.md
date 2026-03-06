# 2409116029_Mochammad-Rezky-Ramadhan_Tugas5

## Deskripsi Singkat
Aplikasi Flutter untuk pendaftaran event dengan validasi form real-time, penyimpanan data pendaftar menggunakan `Provider`, serta fitur daftar, detail, edit, hapus, dan pencarian data pendaftar.

## Fitur Utama
- Form pendaftaran event dengan berbagai jenis input.
- Validasi real-time (`autovalidateMode: AutovalidateMode.onUserInteraction`).
- Data pendaftar disimpan dan dikelola dengan `Provider`.
- Halaman daftar pendaftar.
- Halaman detail pendaftar.
- Badge jumlah pendaftar di AppBar.
- Hapus data dengan dialog konfirmasi.
- Multi-step form menggunakan `Stepper`.
- Edit data pendaftar.
- Search/filter pendaftar.

## Checklist Kriteria Tugas Praktikum
### Wajib
- [x] Minimal 5 field input berbeda jenis.
- [x] Validasi real-time (`autovalidateMode`).
- [x] Minimal 2 jenis input selain `TextFormField` (Radio, Dropdown, Checkbox, DatePicker).
- [x] Provider untuk menyimpan data pendaftar.
- [x] Halaman list pendaftar.
- [x] Error handling (`try-catch`) minimal 1 kali.
- [x] Reset form setelah submit berhasil.

### Bonus (+20)
- [x] Multi-step form dengan `Stepper` (+10).
- [x] Edit data pendaftar (+5).
- [x] Search/filter pendaftar (+5).

## Teknologi
- Flutter
- Dart
- Provider

## Cara Menjalankan Proyek
1. Pastikan Flutter SDK sudah terpasang.
2. Jalankan perintah berikut di root project:

```bash
flutter pub get
flutter run
```

## Bukti Screenshot yang Harus Dilampirkan
- Form kosong.
- Form terisi.
- Validation error.
- List pendaftar.
