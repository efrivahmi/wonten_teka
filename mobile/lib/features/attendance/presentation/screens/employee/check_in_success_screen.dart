import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

class CheckInSuccessScreen extends StatelessWidget {
  const CheckInSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              const Spacer(),
              // Success Animation Area
              Container(
                width: 160.w,
                height: 160.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successEmerald.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.successEmerald,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 64.w),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Check-in Berhasil!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Absensi tercatat pada',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: 16.h),
              Text(
                timeStr,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
              ),
              SizedBox(height: 32.h),
              // Info Cards
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const _InfoRow(
                        icon: Icons.location_on,
                        label: 'Lokasi',
                        value: 'Kantor Pusat Jakarta'),
                    Divider(
                        height: 24.h,
                        color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    const _InfoRow(
                        icon: Icons.face,
                        label: 'Verifikasi',
                        value: 'Wajah Terdeteksi âœ“'),
                    Divider(
                        height: 24.h,
                        color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    const _InfoRow(
                        icon: Icons.smartphone,
                        label: 'Perangkat',
                        value: 'Terikat âœ“'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => context.go('/app/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Kembali ke Dashboard',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 20.w),
        SizedBox(width: 12.w),
        Text(label,
            style:
                TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp)),
      ],
    );
  }
}

