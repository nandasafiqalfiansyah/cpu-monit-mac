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

- macOS 13 atau lebih baru.
- Xcode versi terbaru.

## Menjalankan proyek

1. Clone repository ini.
2. Buka `Untitled Project.xcodeproj` di Xcode.
3. Pilih target **MyApp** dan run destination **My Mac**.
4. Tekan `⌘R`.
5. Klik ikon SystemPulse di menu bar untuk membuka monitor.

## Struktur proyek

```text
MyApp/
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

## Membuat DMG

Skrip berikut membuat `SystemPulse.app` versi Release dan memasukkannya ke DMG dengan shortcut ke folder Applications:

```zsh
./Scripts/create-dmg.sh
```

Hasilnya tersedia di:

```text
build/release/SystemPulse.dmg
```

## Distribusi

DMG untuk penggunaan pribadi dapat dibuat langsung dari skrip di atas. Untuk membagikannya ke pengguna lain, konfigurasi **Developer ID Application** di Xcode, lalu lakukan notarization melalui Apple agar macOS tidak menampilkan peringatan Gatekeeper.

## Catatan metrik

- CPU dan jaringan dihitung dari perbedaan counter antar-sampel.
- Memori adalah estimasi halaman aktif yang berbeda dari tampilan Activity Monitor karena caching dan memory compression macOS.
- Perhitungan jaringan mengecualikan loopback dan tunnel umum, tetapi penggunaan VPN atau interface virtual tertentu tetap dapat memengaruhi angka yang tampil.

## Lisensi

Tambahkan lisensi pilihanmu sebelum publikasi, misalnya MIT License.
