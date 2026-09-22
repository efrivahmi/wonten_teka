import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wonten_teka_mobile/core/api/api_client.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/info_card.dart';
import '../../../../../core/theme/app_colors.dart';

class DepartmentAnalyticsScreen extends StatefulWidget {
  const DepartmentAnalyticsScreen({super.key});
  @override
  State<DepartmentAnalyticsScreen> createState() =>
      _DepartmentAnalyticsScreenState();
}

class _DepartmentAnalyticsScreenState extends State<DepartmentAnalyticsScreen> {
  late final ApiClient _api;
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _stats = const {};

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.get('/admin/dashboard');
      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'] is Map ? body['data'] : body;
      if (mounted) {
        setState(() {
          _stats = Map<String, dynamic>.from(data as Map);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat analitik: $e';
          _loading = false;
        });
      }
    }
  }

  double _number(Object? value) => double.tryParse('$value') ?? 0;
  String _format(Object? value) => value == null ? '-' : '$value';

  @override
  Widget build(BuildContext context) {
    final departments = (_stats['department_attendance'] as List? ?? const []);
    final month = _stats['attendance_month'] is Map
        ? Map<String, dynamic>.from(_stats['attendance_month'] as Map)
        : <String, dynamic>{};
    final today = _stats['attendance_today'] is Map
        ? Map<String, dynamic>.from(_stats['attendance_today'] as Map)
        : <String, dynamic>{};
    return BrandPageBackground(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const AppBrandTitle(section: 'Analitik Departemen'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(padding: EdgeInsets.all(16.w), children: [
                    InfoCard(
                        child: Text('Data bulan berjalan dari dashboard API',
                            style: TextStyle(fontSize: 13.sp))),
                    SizedBox(height: 16.h),
                    Text('Ringkasan kehadiran',
                        style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: 8.h),
                    Row(children: [
                      Expanded(
                          child: _MetricCard(
                              label: 'Hadir',
                              value: _format(today['present'] ??
                                  month['present_employee_days']),
                              color: AppColors.successEmerald)),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: _MetricCard(
                              label: 'Terlambat',
                              value: _format(today['late']),
                              color: AppColors.warningAmber)),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: _MetricCard(
                              label: 'Absen',
                              value: _format(today['absent']),
                              color: AppColors.errorCrimson)),
                    ]),
                    SizedBox(height: 20.h),
                    Text('Kehadiran per departemen',
                        style: Theme.of(context).textTheme.titleSmall),
                    SizedBox(height: 8.h),
                    if (departments.isEmpty)
                      const InfoCard(child: Text('Belum ada data departemen.')),
                    ...departments.map((raw) {
                      final item = Map<String, dynamic>.from(raw as Map);
                      final rate = _number(item['attendance_rate'] ??
                          item['rate'] ??
                          item['percentage']);
                      final normalized = rate > 1 ? rate / 100 : rate;
                      return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: InfoCard(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          _format(item['department'] ??
                                              item['name'] ??
                                              'Tanpa departemen'),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          '${(normalized * 100).toStringAsFixed(1)}%'),
                                    ]),
                                SizedBox(height: 8.h),
                                LinearProgressIndicator(
                                    value: normalized.clamp(0, 1),
                                    color: AppColors.successEmerald),
                              ])));
                    }),
                  ])),
    ));
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => InfoCard(
          child: Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 11.sp)),
      ]));
}
