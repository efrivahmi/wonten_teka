import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface, elevation: 0,
        title: Text('Admin Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.notifications_none, color: AppColors.onSurface), onPressed: () {})],
      ),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Statistik Hari Ini', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 16.h),
          Row(children: [
            _StatMetric(value: '145', label: 'Hadir', color: AppColors.successEmerald),
            SizedBox(width: 8.w),
            _StatMetric(value: '12', label: 'Cuti', color: AppColors.infoCerulean),
            SizedBox(width: 8.w),
            _StatMetric(value: '3', label: 'Absen', color: AppColors.errorCrimson),
          ]),
        ])),
        SizedBox(height: 24.h),

        Text('Menu Utama', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h, crossAxisSpacing: 12.w,
          children: [
            _MenuGridItem(icon: Icons.people, label: 'Karyawan', color: AppColors.primary, onTap: () => context.push('/admin/employees')),
            _MenuGridItem(icon: Icons.calendar_month, label: 'Jadwal Shift', color: AppColors.warningAmber, onTap: () => context.push('/admin/shifts')),
            _MenuGridItem(icon: Icons.receipt_long, label: 'Payroll', color: AppColors.tertiary, onTap: () => context.push('/admin/payroll')),
            _MenuGridItem(icon: Icons.assignment, label: 'Approval', color: AppColors.infoCerulean, onTap: () => context.push('/admin/approvals')),
            _MenuGridItem(icon: Icons.analytics, label: 'Laporan', color: AppColors.successEmerald, onTap: () => context.push('/admin/reports')),
            _MenuGridItem(icon: Icons.settings, label: 'Pengaturan', color: AppColors.onSurfaceVariant, onTap: () => context.push('/admin/settings')),
          ],
        ),
      ])),
    );
  }
}

class _StatMetric extends StatelessWidget {
  final String value, label; final Color color;
  const _StatMetric({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 24.sp, fontWeight: FontWeight.bold)),
      SizedBox(height: 4.h),
      Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
    ]),
  ));
}

class _MenuGridItem extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _MenuGridItem({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12.r), child: Container(
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 28.w), SizedBox(height: 8.h),
      Text(label, textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurface, fontSize: 12.sp, fontWeight: FontWeight.w600)),
    ]),
  ));
}
