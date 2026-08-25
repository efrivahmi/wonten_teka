import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_badge.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime _selectedMonth = DateTime.now();

  // Mock data
  final List<Map<String, dynamic>> _attendanceData = [
    {
      'date': 'Senin, 7 Jul',
      'checkIn': '07:58',
      'checkOut': '17:02',
      'status': 'on_time'
    },
    {
      'date': 'Selasa, 8 Jul',
      'checkIn': '08:15',
      'checkOut': '17:05',
      'status': 'late'
    },
    {
      'date': 'Rabu, 9 Jul',
      'checkIn': '07:55',
      'checkOut': '17:00',
      'status': 'on_time'
    },
    {
      'date': 'Kamis, 10 Jul',
      'checkIn': '--:--',
      'checkOut': '--:--',
      'status': 'absent'
    },
    {
      'date': 'Jumat, 11 Jul',
      'checkIn': '08:00',
      'checkOut': '17:30',
      'status': 'on_time'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Riwayat Absensi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Stats Row
            Row(
              children: [
                const _StatCard(
                    label: 'HADIR',
                    value: '18',
                    color: AppColors.successEmerald),
                SizedBox(width: 8.w),
                const _StatCard(
                    label: 'TERLAMBAT',
                    value: '3',
                    color: AppColors.warningAmber),
                SizedBox(width: 8.w),
                const _StatCard(
                    label: 'TIDAK HADIR',
                    value: '1',
                    color: AppColors.errorCrimson),
              ],
            ),
            SizedBox(height: 24.h),

            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: AppColors.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                          _selectedMonth.year, _selectedMonth.month - 1);
                    });
                  },
                ),
                Text(
                  _formatMonth(_selectedMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: AppColors.onSurfaceVariant),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                          _selectedMonth.year, _selectedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Daily Records
            ...(_attendanceData.map((record) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: InfoCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record['date'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  _TimeChip(
                                      label: 'Masuk', time: record['checkIn']),
                                  SizedBox(width: 16.w),
                                  _TimeChip(
                                      label: 'Keluar',
                                      time: record['checkOut']),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(record['status']),
                      ],
                    ),
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'on_time':
        return StatusBadge.onTime();
      case 'late':
        return StatusBadge.late();
      case 'absent':
        return StatusBadge.absent();
      default:
        return StatusBadge.onTime();
    }
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InfoCard(
        borderLeftColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;

  const _TimeChip({required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          time,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
