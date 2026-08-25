import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_badge.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});

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
                        Text('Senin, 7 Juli 2025',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text('Shift Pagi (08:00 - 17:00)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                      ]),
                  StatusBadge.onTime(),
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
                      Text('07:58',
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
                      Text('17:02',
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
                          Text('9j 4m',
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
            Text('Verifikasi Wajah',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            InfoCard(
              child: Row(children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Icon(Icons.face,
                      color: AppColors.onSurfaceVariant, size: 32.w),
                ),
                SizedBox(width: 16.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Confidence: 98.5%',
                      style: TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp)),
                  SizedBox(height: 2.h),
                  Text('Liveness: Passed',
                      style: TextStyle(
                          color: AppColors.successEmerald, fontSize: 12.sp)),
                ]),
              ]),
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
}
