import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key});
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
          title: Text('Pengumuman',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                          color: AppColors.errorCrimson.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Text('PENTING',
                          style: TextStyle(
                              color: AppColors.errorCrimson,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                              letterSpacing: 0.5))),
                  SizedBox(height: 12.h),
                  Text('Townhall Q3',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Row(children: [
                    Icon(Icons.person,
                        size: 14.w, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Text('HR Department',
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12.sp)),
                    SizedBox(width: 16.w),
                    Icon(Icons.schedule,
                        size: 14.w, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Text('2 jam lalu',
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 12.sp))
                  ]),
                ])),
            SizedBox(height: 16.h),
            InfoCard(
                child: Text(
                    'Kepada seluruh karyawan,\n\nDengan ini kami mengundang seluruh karyawan untuk hadir di acara Townhall Q3 yang akan diadakan:\n\n'
                    'ðŸ“… Selasa, 15 Juli 2025\nâ° 14:00 - 16:00 WIB\nðŸ“ Ruang Utama Lt. 3\n\n'
                    'Agenda:\n1. Opening & Welcome\n2. Q2 Performance Review\n3. Q3 Strategy & Targets\n4. Q&A Session\n\n'
                    'Kehadiran seluruh karyawan sangat diharapkan. Bagi yang WFH, harap hadir ke kantor pada hari tersebut.\n\nTerima kasih,\nHR Department',
                    style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14.sp,
                        height: 1.6))),
            SizedBox(height: 24.h),
            SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Tandai Sudah Dibaca'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r))),
                )),
          ])),
    );
  }
}

