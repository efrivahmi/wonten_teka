import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class OvertimeDetailScreen extends StatelessWidget {
  const OvertimeDetailScreen({super.key});

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
          'Detail Lembur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCard(
              borderLeftColor: AppColors.successEmerald,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status Pengajuan',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 14.sp)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color:
                              AppColors.successEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Disetujui',
                          style: TextStyle(
                              color: AppColors.successEmerald,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text('Tanggal',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                  Text('12 Oktober 2026',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Mulai',
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12.sp)),
                            Text('18:00',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Selesai',
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12.sp)),
                            Text('21:00 (3 Jam)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text('Pekerjaan',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                  Text(
                      'Menyelesaikan deployment server Wonten Teka untuk rilis fase 3.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text('Jejak Persetujuan',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            const _TimelineItem(
              title: 'Disetujui oleh Budi (Manager)',
              date: '13 Okt 2026, 09:00',
              isLast: false,
              isActive: true,
            ),
            const _TimelineItem(
              title: 'Pengajuan Dibuat',
              date: '12 Okt 2026, 21:05',
              isLast: true,
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String date;
  final bool isLast;
  final bool isActive;

  const _TimelineItem({
    required this.title,
    required this.date,
    required this.isLast,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.outline,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: isActive ? AppColors.primary : AppColors.outline,
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              Text(date,
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
              if (!isLast) SizedBox(height: 24.h),
            ],
          ),
        ),
      ],
    );
  }
}
