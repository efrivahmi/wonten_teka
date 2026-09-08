# Audit Wonten Teka

## Alur aplikasi

Laravel menyediakan API Sanctum dan panel admin, React menyediakan portal web karyawan/admin, dan Flutter menyediakan aplikasi mobile. Setelah login, karyawan melengkapi profil, mendaftarkan perangkat untuk persetujuan admin, mendaftarkan biometrik, lalu menggunakan absensi, jadwal, cuti, lembur, klaim, tugas, pengumuman, dan slip gaji. Admin mengelola karyawan, perangkat, shift, kalender, payroll, dan review absensi.

Alur absensi yang sekarang diterapkan: token aktif -> profil karyawan -> perangkat aktif -> data wajah -> lokasi dan geofence server -> shift milik karyawan -> pencegahan check-in ganda -> penyimpanan log. Web mengirim deskriptor wajah agar backend menghitung ulang kecocokan. Mobile masih menghitung kecocokan di perangkat.

## Perbaikan pada audit ini

- Memisahkan embedding face-api.js web dari format biometrik mobile dan mengenkripsi keduanya.
- Menghapus penyimpanan foto mentah enrollment web.
- Menyamakan ambang verifikasi web serta menghitung ulang jarak deskriptor di server.
- Memvalidasi perangkat aktif dan kepemilikan shift sebelum absensi.
- Melindungi seluruh endpoint admin dan perubahan konfigurasi perusahaan dengan pemeriksaan peran server.
- Menghapus rute `/tasks` yang ganda dan mempertahankan kontrak CRUD yang dipakai mobile.
- Menyamakan pagination riwayat absensi dengan model respons Flutter.
- Memperbaiki propagasi error Dio, konfigurasi URL API melalui `--dart-define`, dan mematikan log sensitif secara default.
- Menghapus token FCM, kalender hari libur, indikator kehadiran, dan embedding fallback yang bersifat dummy.
- Mengganti download slip gaji localhost/mock dengan download terautentikasi dari API aktif.
- Menambahkan dasar visual coral/sunrise, fokus keyboard, reduced motion, dan latar responsif global.

## Risiko yang masih harus diselesaikan

1. Mobile memakai landmark ML Kit sebagai vektor pembanding. ML Kit Face Detection bukan model pengenalan identitas. Produksi memerlukan model embedding TFLite yang tetap (misalnya keluarga MobileFaceNet), crop/alignment yang konsisten, kalibrasi threshold pada perangkat target, dan liveness challenge.
2. Endpoint sinkronisasi biometrik mobile mengirim embedding ke klien. Untuk fraud control yang kuat, verifikasi sebaiknya dilakukan pada server atau di hardware-backed secure enclave dengan attestation.
3. Aturan arsitektur menyatakan SaaS multi-tenant, tetapi banyak tabel dan query belum memakai `company_id` serta global scope. Ini berisiko kebocoran lintas perusahaan dan perlu migrasi data terencana.
4. Root/jailbreak detection dan device attestation belum diterapkan. `isMocked` dari GPS hanya satu sinyal dan tidak boleh menjadi satu-satunya kontrol.
5. Tes lama hanya contoh dasar. Modul otorisasi, geofence, shift lintas pengguna, approval, payroll, dan idempotensi absensi perlu feature test dengan database.
6. Bundle web masih besar karena face-api.js berada pada jalur utama. Pisahkan halaman biometrik menjadi lazy-loaded route dan host model weights pada origin sendiri dengan cache versioning.
7. Beberapa controller mengembalikan bentuk respons yang berbeda. Standarkan envelope, kode error stabil, pagination, API versioning, request IDs, rate limiting login/biometrik, dan dokumentasi OpenAPI.
