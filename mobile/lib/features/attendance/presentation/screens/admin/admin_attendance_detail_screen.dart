import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class AdminAttendanceDetailScreen extends StatefulWidget {
  final int attendanceId;

  const AdminAttendanceDetailScreen({
    super.key,
    required this.attendanceId,
  });

  @override
  State<AdminAttendanceDetailScreen> createState() =>
      _AdminAttendanceDetailScreenState();
}

class _AdminAttendanceDetailScreenState
    extends State<AdminAttendanceDetailScreen> {
  Map<String, dynamic>? _log;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await context
          .read<ApiClient>()
          .get('/admin/attendance/${widget.attendanceId}');
      final body = response.data;
      final raw = body is Map ? body['data'] : null;
      if (raw is! Map) throw const FormatException();
      if (mounted) {
        setState(() {
          _log = Map<String, dynamic>.from(raw);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Detail absensi belum dapat dimuat.';
        });
      }
    }
  }

  DateTime? _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '')?.toLocal();

  String _time(dynamic value, {bool absent = false}) {
    if (absent) return '--:--';
    final parsed = _date(value);
    return parsed == null ? '--:--' : DateFormat('HH:mm').format(parsed);
  }

  String _statusLabel(String status) => switch (status.toLowerCase()) {
        'on_time' || 'present' => 'Tepat waktu',
        'late' => 'Terlambat',
        'absent' || 'alpha' => 'Alpha / Tidak masuk',
        'early_leave' => 'Pulang lebih awal',
        'on_leave' => 'Cuti / Izin',
        _ => status.replaceAll('_', ' '),
      };

  Color _statusColor(String status) => switch (status.toLowerCase()) {
        'absent' || 'alpha' => AppColors.errorCrimson,
        'late' || 'early_leave' => AppColors.warningAmber,
        'on_time' || 'present' => AppColors.successEmerald,
        _ => AppColors.infoCerulean,
      };

  String _duration(Map<String, dynamic> log, bool absent) {
    if (absent) return '0 jam 0 menit';
    final stored = int.tryParse(log['work_duration_minutes']?.toString() ?? '');
    final start = _date(log['check_in_at']);
    final end = _date(log['check_out_at']);
    final minutes = stored ??
        (start != null && end != null ? end.difference(start).inMinutes : 0);
    return '${minutes ~/ 60} jam ${minutes % 60} menit';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          title: const Text('Detail Absensi Karyawan'),
          leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.errorCrimson, size: 48),
                      SizedBox(height: 12.h),
                      Text(_error!),
                      TextButton(
                          onPressed: _load, child: const Text('Coba lagi')),
                    ]),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _content(_log!),
                  ),
      );

  Widget _content(Map<String, dynamic> log) {
    final employee = Map<String, dynamic>.from(log['employee'] as Map? ?? {});
    final device = Map<String, dynamic>.from(log['device'] as Map? ?? {});
    final flags = Map<String, dynamic>.from(log['flags'] as Map? ?? {});
    final assignment =
        Map<String, dynamic>.from(log['shift_assignment'] as Map? ?? {});
    final template =
        Map<String, dynamic>.from(assignment['shift_template'] as Map? ?? {});
    final status = log['status']?.toString() ?? 'present';
    final absent = status == 'absent' || status == 'alpha';
    final checkIn = _date(log['check_in_at']);
    final flagLabels = <String>[
      if (flags['is_mock_location'] == true) 'Fake GPS terdeteksi',
      if (flags['low_face_match_score'] == true) 'Kemiripan wajah rendah',
      if (flags['early_leave'] == true) 'Pulang lebih awal',
      if (flags['auto_absent'] == true) 'Alpha dibuat otomatis',
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      children: [
        InfoCard(
          borderLeftColor: _statusColor(status),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                    (employee['full_name']?.toString().isNotEmpty == true)
                        ? employee['full_name'].toString()[0].toUpperCase()
                        : '?'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(employee['full_name']?.toString() ?? 'Karyawan',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                        '${employee['employee_number'] ?? 'Tanpa nomor'} • ${employee['department'] ?? 'Tanpa departemen'}',
                        style:
                            const TextStyle(color: AppColors.onSurfaceVariant)),
                  ])),
            ]),
            SizedBox(height: 14.h),
            Wrap(spacing: 8.w, runSpacing: 8.h, children: [
              _chip(_statusLabel(status), _statusColor(status)),
              if ((template['name'] ?? flags['shift_name']) != null)
                _chip((template['name'] ?? flags['shift_name']).toString(),
                    AppColors.primary),
            ]),
          ]),
        ),
        SizedBox(height: 12.h),
        InfoCard(
          child: Column(children: [
            _row(
                Icons.calendar_today,
                'Tanggal',
                checkIn == null
                    ? '-'
                    : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(checkIn)),
            _row(Icons.login, 'Jam masuk',
                _time(log['check_in_at'], absent: absent)),
            _row(Icons.logout, 'Jam keluar', _time(log['check_out_at'])),
            _row(Icons.timelapse, 'Durasi kerja', _duration(log, absent)),
          ]),
        ),
        SizedBox(height: 12.h),
        InfoCard(
          child: Column(children: [
            _row(
                Icons.location_on_outlined,
                'Lokasi masuk',
                absent
                    ? 'Tidak ada check-in'
                    : (log['check_in_address']?.toString() ??
                        'Tidak tersedia')),
            _row(Icons.location_off_outlined, 'Lokasi keluar',
                log['check_out_address']?.toString() ?? 'Tidak tersedia'),
            _row(Icons.face_outlined, 'Skor wajah masuk',
                _score(log['check_in_face_score'], absent)),
            _row(Icons.face_retouching_natural, 'Skor wajah keluar',
                _score(log['check_out_face_score'], false)),
          ]),
        ),
        SizedBox(height: 12.h),
        InfoCard(
          child: Column(children: [
            _row(Icons.phone_android, 'Perangkat',
                device['device_name']?.toString() ?? 'Tidak tersedia'),
            _row(Icons.devices, 'Model / OS',
                '${device['device_model'] ?? '-'} • ${device['os_version'] ?? '-'}'),
            _row(
                Icons.notes,
                'Catatan',
                log['notes']?.toString() ??
                    log['admin_notes']?.toString() ??
                    '-'),
          ]),
        ),
        if (flagLabels.isNotEmpty) ...[
          SizedBox(height: 12.h),
          InfoCard(
            borderLeftColor: AppColors.warningAmber,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('INDIKATOR & PELANGGARAN',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 10.h),
              ...flagLabels.map((label) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(children: [
                      const Icon(Icons.warning_amber,
                          color: AppColors.warningAmber, size: 18),
                      SizedBox(width: 8.w),
                      Expanded(child: Text(label)),
                    ]),
                  )),
            ]),
          ),
        ],
      ],
    );
  }

  String _score(dynamic value, bool absent) {
    if (absent || value == null) return '-';
    final score = double.tryParse(value.toString());
    if (score == null) return '-';
    return '${(score <= 1 ? score * 100 : score).toStringAsFixed(1)}%';
  }

  Widget _chip(String label, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(99)),
        child: Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      );

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: 10.w),
          SizedBox(
              width: 105.w,
              child: Text(label,
                  style: const TextStyle(color: AppColors.onSurfaceVariant))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );
}
