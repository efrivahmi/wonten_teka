import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Manager Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Pending Actions
            Text('Tugas Menunggu',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(
                  child: _ActionCard(
                      title: 'Cuti Tim',
                      count: 4,
                      icon: Icons.beach_access,
                      color: AppColors.warningAmber,
                      onTap: () => context.push('/manager/approvals'))),
              SizedBox(width: 12.w),
              Expanded(
                  child: _ActionCard(
                      title: 'Klaim',
                      count: 2,
                      icon: Icons.receipt,
                      color: AppColors.infoCerulean,
                      onTap: () => context.push('/manager/approvals'))),
            ]),
            SizedBox(height: 24.h),

            // Team Overview
            Text('Kehadiran Tim Hari Ini',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            InfoCard(
                child: Column(children: [
              const _TeamStat(
                  label: 'Total Anggota', value: '12', icon: Icons.groups),
              Divider(
                  height: 20.h,
                  color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              const _TeamStat(
                  label: 'Hadir Tepat Waktu',
                  value: '10',
                  icon: Icons.check_circle,
                  color: AppColors.successEmerald),
              Divider(
                  height: 20.h,
                  color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              const _TeamStat(
                  label: 'Terlambat',
                  value: '1',
                  icon: Icons.schedule,
                  color: AppColors.warningAmber),
              Divider(
                  height: 20.h,
                  color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              const _TeamStat(
                  label: 'Cuti/Sakit',
                  value: '1',
                  icon: Icons.healing,
                  color: AppColors.errorCrimson),
            ])),
            SizedBox(height: 24.h),

            SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => context.push('/manager/team-performance'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r))),
                  child: Text('Lihat Performa Tim',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                )),
          ])),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.title,
      required this.count,
      required this.icon,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: color, size: 24.w),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12.r)),
                child: Text('$count',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp))),
          ]),
          SizedBox(height: 12.h),
          Text(title,
              style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp)),
        ]),
      ));
}

class _TeamStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _TeamStat(
      {required this.label,
      required this.value,
      required this.icon,
      this.color = AppColors.onSurfaceVariant});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 20.w),
        SizedBox(width: 12.w),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 14.sp))),
        Text(value,
            style: TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp)),
      ]);
}

