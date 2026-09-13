# Wonten Teka — prototipe desain ulang

Jalankan dari akar proyek: `node design-preview/server.cjs`, lalu buka http://127.0.0.1:4174.
File `index.html` juga bisa dibuka langsung di browser. Google Fonts memerlukan koneksi internet; sans-serif menjadi fallback bila tidak tersedia.

## Hasil lokal

38 tampilan yang dapat dinavigasikan: akses/onboarding, portal karyawan, administrasi HR, profil, pengajuan cuti, detail pengajuan, detail slip gaji, bantuan, dan 404. Pendaftaran wajah karyawan memakai tampilan pendaftaran wajah yang sama.

Warna hijau hutan, aksen lime, Plus Jakarta Sans, sidebar desktop, navigasi bawah ponsel, kartu dan formulir responsif. Pencarian, filter, modal, kondisi loading/kosong/gagal, dan beberapa alur tindakan tersedia sebagai simulasi. Data contoh tidak dikirim ke backend. Perubahan simulasi tidak persisten.

Ini prototipe desain, bukan pengganti frontend produksi. Integrasi React/Laravel, semua detail aturan fitur, aksesibilitas menyeluruh, serta pengujian API belum dilakukan. Pola kartu daftar pada sejumlah halaman merupakan rancangan awal yang masih perlu pematangan sebelum implementasi.

## Figma

File: https://www.figma.com/design/5Rxy70IroM38rg4G5qBxCH

Tim: blabla. Kit Simple Design System ditemukan dan komponen Button, Input Field, Navigation Pill telah diimpor melalui tool. File berisi tiga halaman, fondasi warna/tipografi, serta kerangka dashboard pada lebar 390 dan 1440. Konten utama dashboard dan halaman lainnya belum dibuat atau diperiksa visual di Figma karena kuota MCP Starter habis. Prototipe HTML memakai implementasi lokal yang disesuaikan; bukan ekspor lengkap kit Figma.

`figma-state.json` menyimpan hasil tool dan ID yang sudah dibuat. `screens.json` menyimpan spesifikasi 38 tampilan. Skrip Figma disimpan di folder ini sebagai bahan melanjutkan pekerjaan; jangan menjalankannya tanpa membaca state dan memeriksa isi file agar tidak membuat duplikasi.

## Pemeriksaan yang sudah dijalankan

- Sintaks JavaScript valid.
- Semua 38 rute prototipe merender judul halaman yang sesuai.
- Dashboard tidak menimbulkan overflow horizontal pada 360, 390, 768, 1024, 1440, dan 1920 px.
- Pemeriksaan visual dashboard pada desktop dan ponsel; perbaikan sidebar dan keterbacaan teks sekunder.
- Simulasi absensi berhasil, validasi alasan cuti, pengiriman contoh cuti ke halaman detail, pencarian tanpa hasil, serta kondisi gagal dan coba lagi diperiksa melalui browser.

Pemeriksaan ini tidak membuktikan kesetaraan fitur dengan aplikasi produksi dan tidak mencakup semua interaksi di setiap halaman.
