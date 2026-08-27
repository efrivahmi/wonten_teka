import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/attendance_log_model.dart';

class DailyAttendanceTableScreen extends StatefulWidget {
  const DailyAttendanceTableScreen({super.key});

  @override
  State<DailyAttendanceTableScreen> createState() => _DailyAttendanceTableScreenState();
}

class _DailyAttendanceTableScreenState extends State<DailyAttendanceTableScreen> {
  late final ApiClient _api;
  bool _isLoading = true;
  List<AttendanceLogModel> _logs = [];

  @override
  void initState() {
    super.initState();
    _api = context.read<ApiClient>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('/admin/attendance');
      if (mounted) {
        final List<dynamic> rawData = response.data['data'];
        setState(() {
          _logs = rawData.map((json) {
            // Need to mock the 'employee' relation inside AttendanceLogModel if needed, 
            // but we can extract it into the flags or manually parse it for the table.
            final log = AttendanceLogModel.fromJson(json as Map<String, dynamic>);
            // Temporary hack to attach employee name if returned by backend:
            if (json['employee'] != null && json['employee']['full_name'] != null) {
              log.flags ??= {};
              log.flags!['employee_name'] = json['employee']['full_name'];
            }
            return log;
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tabel Absensi Harian',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengekspor Laporan (Mock)...')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('Belum ada data absensi.'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
                      columns: const [
                        DataColumn(label: Text('Nama Karyawan')),
                        DataColumn(label: Text('Masuk')),
                        DataColumn(label: Text('Keluar')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Catatan/Pelanggaran')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: _logs.map((log) {
                        final empName = log.flags?['employee_name'] ?? 'Unknown';
                        final checkInStr = DateFormat('HH:mm').format(log.checkInAt);
                        final checkOutStr = log.checkOutAt != null
                            ? DateFormat('HH:mm').format(log.checkOutAt!)
                            : '--:--';
                            
                        return DataRow(
                          cells: [
                            DataCell(Text(empName, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(checkInStr)),
                            DataCell(Text(checkOutStr)),
                            DataCell(_buildStatusChip(log.status)),
                            DataCell(_buildViolations(log)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye, color: AppColors.primary, size: 20),
                                onPressed: () {
                                  context.push('/app/attendance/detail', extra: log);
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'on_time':
      case 'present':
        color = AppColors.successEmerald;
        label = 'Tepat Waktu';
        break;
      case 'late':
        color = AppColors.errorCrimson;
        label = 'Terlambat';
        break;
      case 'flagged':
        color = AppColors.warningAmber;
        label = 'Ditinjau';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildViolations(AttendanceLogModel log) {
    List<String> violations = [];
    if (log.flags != null) {
      if (log.flags!['is_mock_location'] == true) {
        violations.add('Lokasi Palsu (Fake GPS)');
      }
      if (log.flags!['low_face_match_score'] == true) {
        violations.add('Wajah Tidak Cocok (<80%)');
      }
      if (log.flags!['early_leave'] == true) {
        violations.add('Pulang Lebih Awal');
      }
    }
    
    if (violations.isEmpty) {
      return const Text('-');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: violations.map((v) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: AppColors.errorCrimson, size: 14),
          SizedBox(width: 4.w),
          Text(v, style: TextStyle(color: AppColors.errorCrimson, fontSize: 11.sp)),
        ],
      )).toList(),
    );
  }
}
