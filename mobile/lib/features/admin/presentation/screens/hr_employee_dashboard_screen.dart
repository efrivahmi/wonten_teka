import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class HREmployeeDashboardScreen extends StatelessWidget {
  const HREmployeeDashboardScreen({super.key});

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
          title: Text('HR Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Status Karyawan',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: 16.h),
                  Row(children: [
                    const Expanded(
                        child: _StatBox(
                            title: 'Aktif',
                            count: '156',
                            color: AppColors.successEmerald)),
                    SizedBox(width: 8.w),
                    const Expanded(
                        child: _StatBox(
                            title: 'Cuti',
                            count: '12',
                            color: AppColors.infoCerulean)),
                    SizedBox(width: 8.w),
                    const Expanded(
                        child: _StatBox(
                            title: 'Onboarding',
                            count: '3',
                            color: AppColors.warningAmber)),
                  ]),
                ])),
            SizedBox(height: 24.h),
            Text('Aksi Cepat',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            ListTile(
                leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.person_add, color: AppColors.onPrimary)),
                title: const Text('Onboarding Karyawan Baru'),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                tileColor: AppColors.surface,
                onTap: () => context.push('/admin/employees/onboarding')),
            SizedBox(height: 8.h),
            ListTile(
                leading: const CircleAvatar(
                    backgroundColor: AppColors.warningAmber,
                    child: Icon(Icons.edit_document, color: Colors.white)),
                title: const Text('Review Data Kontrak'),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                tileColor: AppColors.surface,
                onTap: () {}),
          ])),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title, count;
  final Color color;
  const _StatBox(
      {required this.title, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(children: [
          Text(count,
              style: TextStyle(
                  fontSize: 24.sp, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 4.h),
          Text(title,
              style:
                  TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant))
        ]),
      );
}
