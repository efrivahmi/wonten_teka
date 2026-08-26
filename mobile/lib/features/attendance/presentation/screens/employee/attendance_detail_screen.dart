import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

import '../../../../../core/models/attendance_log_model.dart';
import 'package:intl/intl.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final AttendanceLogModel log;
  const AttendanceDetailScreen({super.key, required this.log});

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
        title: Text('Detail Absensi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & Status
            InfoCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEEE, d MMM yyyy', 'id_ID').format(log.checkInAt),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text(log.flags?['shift_name'] ?? 'Shift Regular',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                      ]),
                  _buildStatusBadge(log.status),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Check-in / Check-out Times
            Row(children: [
              Expanded(
                  child: InfoCard(
                borderLeftColor: AppColors.successEmerald,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHECK-IN',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      SizedBox(height: 4.h),
                      Text(DateFormat('HH:mm').format(log.checkInAt),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold)),
                    ]),
              )),
              SizedBox(width: 12.w),
              Expanded(
                  child: InfoCard(
                borderLeftColor: AppColors.infoCerulean,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHECK-OUT',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      SizedBox(height: 4.h),
                      Text(log.checkOutAt != null ? DateFormat('HH:mm').format(log.checkOutAt!) : '--:--',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold)),
                    ]),
              )),
            ]),
            SizedBox(height: 16.h),

            // Working Hours
            InfoCard(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL JAM KERJA',
                              style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                          SizedBox(height: 4.h),
                          Text(_formatDuration(log.workDuration),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: AppColors.successEmerald,
                                      fontWeight: FontWeight.bold)),
                        ]),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                          color:
                              AppColors.successEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Text('Normal',
                          style: TextStyle(
                              color: AppColors.successEmerald,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp)),
                    ),
                  ]),
            ),
            SizedBox(height: 24.h),

            // Location Map Placeholder
            Text('Lokasi Check-in',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Container(
              height: 180.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Stack(children: [
                Center(
                    child: Icon(Icons.map,
                        size: 48.w,
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.3))),
                Positioned(
                  bottom: 12.h,
                  left: 12.w,
                  right: 12.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Row(children: [
                      Icon(Icons.location_on,
                          color: AppColors.primaryContainer, size: 16.w),
                      SizedBox(width: 8.w),
                      Expanded(
                          child: Text(
                              'Kantor Pusat, Jl. Sudirman No. 52, Jakarta',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.onSurface))),
                    ]),
                  ),
                ),
              ]),
            ),
            SizedBox(height: 24.h),

            // Face Verification
            Text('Foto & Verifikasi Wajah',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    child: Column(
                      children: [
                        Text('Masuk', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        if (log.checkInPhotoUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network('http://www.great-symbols-begin-freely.st.a.dcdg.xyz/storage/${log.checkInPhotoUrl}', height: 100.h, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                          )
                        else
                          Icon(Icons.face, color: AppColors.onSurfaceVariant, size: 48.w),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InfoCard(
                    child: Column(
                      children: [
                        Text('Keluar', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        if (log.checkOutPhotoUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network('http://www.great-symbols-begin-freely.st.a.dcdg.xyz/storage/${log.checkOutPhotoUrl}', height: 100.h, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                          )
                        else
                          Icon(Icons.face, color: AppColors.onSurfaceVariant, size: 48.w),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Dispute Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/app/attendance/dispute'),
                icon: const Icon(Icons.report_problem_outlined),
                label: const Text('Ajukan Dispute'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warningAmber,
                  side: const BorderSide(color: AppColors.warningAmber),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}j ${minutes}m';
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'on_time':
      case 'present':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.successEmerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 14.w, color: AppColors.successEmerald),
              SizedBox(width: 4.w),
              Text('Tepat Waktu', style: TextStyle(color: AppColors.successEmerald, fontSize: 11.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case 'late':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_filled, size: 14.w, color: AppColors.error),
              SizedBox(width: 4.w),
              Text('Terlambat', style: TextStyle(color: AppColors.error, fontSize: 11.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case 'early_leave':
      case 'half_day':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.warningAmber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 14.w, color: AppColors.warningAmber),
              SizedBox(width: 4.w),
              Text('Setengah Hari', style: TextStyle(color: AppColors.warningAmber, fontSize: 11.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

