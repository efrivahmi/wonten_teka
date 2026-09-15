import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class AttendanceFlagReviewScreen extends StatefulWidget {
  const AttendanceFlagReviewScreen({super.key});

  @override
  State<AttendanceFlagReviewScreen> createState() =>
      _AttendanceFlagReviewScreenState();
}

class _AttendanceFlagReviewScreenState
    extends State<AttendanceFlagReviewScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/admin/attendance-security-events');
      if (!mounted) return;
      setState(() {
        _events = (response.data['data'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data deteksi gagal dimuat: $error')),
      );
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm:ss')
        .format(DateTime.parse(value.toString()).toLocal());
  }

  void _showDetails(Map<String, dynamic> event) {
    final employee = event['employee'] as Map<String, dynamic>? ?? {};
    final device = event['device'] as Map<String, dynamic>? ?? {};
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detail Deteksi Fake GPS',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.errorCrimson,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              _detail('Nama', employee['full_name']),
              _detail('Nomor pegawai', employee['employee_number']),
              _detail('Bagian / jabatan',
                  '${employee['department'] ?? '-'} / ${employee['position'] ?? '-'}'),
              _detail('Perangkat', device['device_name']),
              _detail('Model', device['device_model']),
              _detail('Sistem operasi', device['os_version']),
              _detail('Versi aplikasi', device['app_version']),
              _detail(
                  'ID perangkat',
                  device['device_fingerprint'] ??
                      event['metadata']?['device_fingerprint']),
              _detail(
                  'Percobaan',
                  event['attempted_action'] == 'check_out'
                      ? 'Check Out'
                      : 'Check In'),
              _detail('Waktu terdeteksi', _formatDate(event['detected_at'])),
              _detail(
                  'Koordinat', '${event['latitude']}, ${event['longitude']}'),
              _detail('Alamat', event['address']),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, dynamic value) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120.w,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: Text(value?.toString().isNotEmpty == true
                  ? value.toString()
                  : '-'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Deteksi Fake GPS'),
        actions: [
          IconButton(onPressed: _loadEvents, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('Belum ada percobaan Fake GPS.'))
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final event = _events[index] as Map<String, dynamic>;
                    final employee =
                        event['employee'] as Map<String, dynamic>? ?? {};
                    final device =
                        event['device'] as Map<String, dynamic>? ?? {};
                    return InkWell(
                      onTap: () => _showDetails(event),
                      child: InfoCard(
                        borderLeftColor: AppColors.errorCrimson,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                employee['full_name'] ??
                                    'Karyawan tidak diketahui',
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 6.h),
                            Text(
                              '${device['device_name'] ?? 'Perangkat tidak dikenal'} • ${device['device_model'] ?? 'Model tidak diketahui'}',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12.sp),
                            ),
                            SizedBox(height: 6.h),
                            Text(_formatDate(event['detected_at']),
                                style: TextStyle(fontSize: 12.sp)),
                            SizedBox(height: 8.h),
                            const Text('Absensi langsung ditolak',
                                style: TextStyle(
                                    color: AppColors.errorCrimson,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
