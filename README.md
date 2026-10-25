# SystemPulse

SystemPulse adalah aplikasi menu bar macOS untuk memantau CPU, memori, jaringan, dan baterai secara real-time. Aplikasi berjalan ringan di menu bar tanpa jendela utama atau ikon di Dock.

## Fitur

- Penggunaan CPU real-time.
- Memori terpakai, total memori, dan persentase penggunaan.
- Kecepatan download dan upload jaringan.
- Persentase serta status pengisian baterai.
- Refresh otomatis setiap 1, 2, atau 5 detik.
- Refresh manual dari pop-up menu bar.
- Opsi **Launch at Login** melalui pengaturan macOS.
- Mode menu bar utility: aplikasi tetap aktif tanpa muncul di Dock.

## Kebutuhan

- macOS 14 atau lebih baru.
- Xcode versi terbaru.

## Menjalankan proyek

1. Clone repository ini.
2. Buka `cpu-monit-mac.xcodeproj` di Xcode.
3. Pilih target **cpu-monit-mac** dan run destination **My Mac**.
4. Tekan `⌘R`.
5. Klik ikon SystemPulse di menu bar untuk membuka monitor.

## Struktur proyek

```text
cpu-monit-mac/
├── Models/
│   └── SystemMetrics.swift
├── Services/
│   ├── BatteryService.swift
│   ├── CPUService.swift
│   ├── MemoryService.swift
│   └── NetworkService.swift
├── ViewModels/
│   ├── LoginItemController.swift
│   └── MonitorViewModel.swift
├── Views/
│   ├── MonitorView.swift
│   └── SettingsView.swift
└── MyApp.swift
```

## Build DMG & Release Otomatis (GitHub Actions)

Proyek ini menggunakan GitHub Actions ([`.github/workflows/build-dmg.yml`](.github/workflows/build-dmg.yml)) untuk mem-build `SystemPulse.app` versi Release dan mengemasnya menjadi file `SystemPulse.dmg` secara otomatis:

- **Otomatis Release dari Pesan Commit**: Cukup sertakan versi dengan format `vX.Y.Z` di dalam pesan commit saat push ke `main` (misalnya `git commit -m "v1.0.0"` atau `git commit -m "release v1.0.0"`), maka GitHub Actions akan otomatis membuat tag dan mempublikasikan **GitHub Release** beserta file `SystemPulse.dmg`.
- **Commit Biasa (Tanpa Versi) / Pull Request / Manual Trigger**: Tetap mem-build dan mengunggah artifact `SystemPulse-dmg` di halaman **Actions** tanpa membuat Release baru.

## Distribusi

Untuk distribusi ke pengguna lain tanpa peringatan Gatekeeper macOS, konfigurasi sertifikat **Developer ID Application** dan lakukan notarization melalui Apple.

## Catatan metrik

- CPU dan jaringan dihitung dari perbedaan counter antar-sampel.
- Memori adalah estimasi halaman aktif yang berbeda dari tampilan Activity Monitor karena caching dan memory compression macOS.
- Perhitungan jaringan mengecualikan loopback dan tunnel umum, tetapi penggunaan VPN atau interface virtual tertentu tetap dapat memengaruhi angka yang tampil.

## Lisensi

Tambahkan lisensi pilihanmu sebelum publikasi, misalnya MIT License.
