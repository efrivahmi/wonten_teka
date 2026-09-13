# Wonten Teka — cakupan desain ulang

## Arah visual

Website HR mobile-first berbahasa Indonesia. Hijau hutan sebagai warna utama, lime untuk aksen, putih hangat untuk kanvas, Plus Jakarta Sans untuk tipografi. Kit Figma akan dipilih setelah pencarian library pada file tujuan; belum ada kit yang diklaim tersedia atau digunakan.

## Inventaris dari router aplikasi

- Publik/onboarding (6): login, awal onboarding, registrasi perangkat, menunggu persetujuan perangkat, pendaftaran wajah, melengkapi profil.
- Karyawan (16): dashboard, absensi, cuti, lembur, klaim, slip gaji, jadwal/shift, kalender, pengumuman, tugas, koreksi absensi, perjalanan dinas, notifikasi, direktori, pendaftaran wajah; rute induk /employee memerlukan perilaku masuk yang jelas.
- Admin (13): dashboard, persetujuan, karyawan, jadwal, laporan, pengaturan, perangkat, kalender/event, payroll, jenis cuti, flag absensi, biometrik; rute induk /admin memerlukan perilaku masuk yang jelas.

Router memuat 35 rute bernama termasuk dua induk, di luar wildcard. Halaman onboarding awal bisa berupa pengarah alur; desain mengikuti perilaku kode.

## Tambahan desain yang diusulkan

- Profil dan keamanan akun, dengan status perangkat terikat dan jalur permintaan penggantian melalui admin.
- Detail pengajuan dan linimasa persetujuan yang dipakai bersama oleh cuti, lembur, klaim, koreksi, dan perjalanan dinas.
- Pusat bantuan absensi: izin kamera/lokasi, wajah tidak cocok, dan lokasi di luar radius.
- Halaman tidak ditemukan dan akses ditolak; kondisi sesi habis.
- Detail karyawan, detail slip gaji, formulir pengajuan, serta konfirmasi tindakan sebagai bagian alur fitur terkait.

## Perilaku responsif

- Mulai dari lebar 360–390 px, lalu 768, 1024, 1440, dan 1920 px.
- Ponsel: satu kolom, navigasi bawah untuk menu utama dan menu lengkap, formulir bertahap, daftar kartu untuk tabel operasional.
- Tablet: dua kolom saat konten cukup lebar; navigasi ringkas.
- Desktop: sidebar, area kerja fleksibel, panel detail kontekstual, tabel yang terbaca.
- Spasi dan heading berskala terbatas; teks isi 14–16 px dan target sentuh minimal 44 px. Hindari membesarkan semua komponen secara linear terhadap layar.
- Batasi panjang baris, pertahankan hierarki, bungkus label panjang, gunakan scroll horizontal hanya pada tabel yang memang perlu perbandingan kolom.

## Kontrak interaksi

Setiap alur mencakup loading, kosong, gagal, berhasil, validasi field, serta disabled/pending. Status selalu menggunakan teks selain warna. Formulir mempunyai label tetap, ringkasan kesalahan, fokus keyboard, dan konfirmasi tindakan sensitif.

Tetap pertahankan satu karyawan satu perangkat, persetujuan admin untuk pergantian perangkat, pemeriksaan lokasi dan biometrik, serta alur persetujuan bersama. Data contoh dalam desain harus diberi konteks sebagai ilustrasi.

## Status

Prototipe lokal 38 tampilan tersedia di design-preview/index.html. File Figma 5Rxy70IroM38rg4G5qBxCH dibuat di tim blabla dengan fondasi dan kerangka dashboard; konten lanjutan terhalang kuota MCP Starter. Kit Simple Design System ditemukan dan tiga jenis komponen diimpor. Baca design-preview/README.md untuk hasil, pemeriksaan, dan batasan. Implementasi frontend produksi belum dilakukan.
