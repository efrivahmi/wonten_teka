import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

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
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.analytics_outlined,
                      size: 64.w,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                ),
                SizedBox(height: 24.h),
                Text('Laporan Belum Tersedia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                Text(
                    'Fitur laporan absensi sedang dalam tahap pengembangan dan integrasi dengan sistem backend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 14.sp, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

