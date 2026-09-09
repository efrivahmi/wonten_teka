import 'package:dio/dio.dart';

/// Service untuk mengambil data hari libur nasional Indonesia
/// secara otomatis dari Nager.Date Public Holiday API.
///
/// API ini gratis, tidak memerlukan API key, dan mencakup
/// data hari libur resmi lebih dari 100 negara.
/// Dokumentasi: https://date.nager.at/Api
class HolidayService {
  HolidayService._();

  static final HolidayService instance = HolidayService._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://date.nager.at/api/v3',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Cache hasil fetch per tahun agar tidak berulang kali memanggil API.
  final Map<int, Set<DateTime>> _cache = {};

  /// Mengambil daftar hari libur nasional Indonesia untuk [year] tertentu.
  /// Mengembalikan [Set<DateTime>] (tanpa waktu) untuk efisiensi pengecekan.
  /// Hasil di-cache, sehingga API hanya dipanggil sekali per tahun.
  Future<Set<DateTime>> fetchHolidays(int year) async {
    if (_cache.containsKey(year)) {
      return _cache[year]!;
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/PublicHolidays/$year/ID',
      );

      final holidays = <DateTime>{};
      if (response.data != null) {
        for (final item in response.data!) {
          if (item is Map<String, dynamic> && item['date'] != null) {
            final parsed = DateTime.tryParse(item['date'] as String);
            if (parsed != null) {
              // Simpan hanya date tanpa time component
              holidays.add(DateTime(parsed.year, parsed.month, parsed.day));
            }
          }
        }
      }

      _cache[year] = holidays;
      return holidays;
    } on DioException catch (_) {
      // Jika gagal (offline / timeout), kembalikan set kosong
      // agar kalender tetap bisa berfungsi tanpa crash.
      return {};
    }
  }

  /// Memeriksa apakah [date] merupakan hari libur nasional.
  /// Pastikan [fetchHolidays] sudah dipanggil untuk tahun yang bersangkutan.
  bool isHoliday(DateTime date, Set<DateTime> holidays) {
    return holidays.contains(DateTime(date.year, date.month, date.day));
  }

  /// Membersihkan cache (opsional, jika diperlukan).
  void clearCache() => _cache.clear();
}
