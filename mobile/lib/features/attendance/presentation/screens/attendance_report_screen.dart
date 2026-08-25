import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => context.pop()),
        title: Text('Laporan Absensi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.download, color: AppColors.primary),
              onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Period Selector
          InfoCard(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text('Juli 2025',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Row(children: [
                  const _PeriodChip(label: 'Minggu', isActive: false),
                  SizedBox(width: 8.w),
                  const _PeriodChip(label: 'Bulan', isActive: true),
                ]),
              ])),
          SizedBox(height: 16.h),

          // Summary Cards
          Row(children: [
            const _SummaryCard(
                value: '22', label: 'Hari Kerja', color: AppColors.onSurface),
            SizedBox(width: 8.w),
            const _SummaryCard(
                value: '18', label: 'Hadir', color: AppColors.successEmerald),
          ]),
          SizedBox(height: 8.h),
          Row(children: [
            const _SummaryCard(
                value: '3', label: 'Terlambat', color: AppColors.warningAmber),
            SizedBox(width: 8.w),
            const _SummaryCard(
                value: '1',
                label: 'Tidak Hadir',
                color: AppColors.errorCrimson),
          ]),
          SizedBox(height: 24.h),

          // Chart placeholder
          Text('Tren Kehadiran',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5))),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final item in [
                      {'label': 'Sen', 'height': 0.9},
                      {'label': 'Sel', 'height': 0.7},
                      {'label': 'Rab', 'height': 1.0},
                      {'label': 'Kam', 'height': 0.0},
                      {'label': 'Jum', 'height': 0.85},
                    ])
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 32.w,
                              height: (140.h * (item['height'] as double)),
                              decoration: BoxDecoration(
                                color: (item['height'] as double) == 0
                                    ? AppColors.errorCrimson
                                        .withValues(alpha: 0.3)
                                    : AppColors.primaryContainer
                                        .withValues(alpha: 0.7),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(6.r)),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(item['label'] as String,
                                style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.onSurfaceVariant)),
                          ]),
                  ]),
            ),
          ),
          SizedBox(height: 24.h),

          // Average Stats
          Text('Rata-rata',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          InfoCard(
              child: Column(children: [
            const _StatRow(label: 'Jam Masuk Rata-rata', value: '08:05'),
            Divider(
                height: 20.h,
                color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            const _StatRow(label: 'Jam Pulang Rata-rata', value: '17:12'),
            Divider(
                height: 20.h,
                color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            const _StatRow(label: 'Total Jam Kerja', value: '162j 30m'),
          ])),
        ]),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _PeriodChip({required this.label, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label,
          style: TextStyle(
              color:
                  isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _SummaryCard(
      {required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: InfoCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold)),
      SizedBox(height: 4.h),
      Text(label,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
    ])));
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  const _StatRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
      Text(value,
          style: TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp)),
    ]);
  }
}
