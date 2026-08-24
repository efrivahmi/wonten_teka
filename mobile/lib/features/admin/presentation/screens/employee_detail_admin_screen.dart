import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class EmployeeDetailAdminScreen extends StatelessWidget {
  const EmployeeDetailAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Detail Karyawan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () {})]),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        CircleAvatar(radius: 48.r, backgroundColor: AppColors.primaryContainer, child: Text('K1', style: TextStyle(fontSize: 32.sp, color: AppColors.onPrimary, fontWeight: FontWeight.bold))),
        SizedBox(height: 16.h),
        Text('Karyawan 1', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text('Senior Software Engineer', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
        SizedBox(height: 24.h),
        InfoCard(child: Column(children: [
          _Row(label: 'Departemen', value: 'IT Department'), Divider(height: 20.h, color: AppColors.outlineVariant.withOpacity(0.3)),
          _Row(label: 'Email', value: 'karyawan1@company.com'), Divider(height: 20.h, color: AppColors.outlineVariant.withOpacity(0.3)),
          _Row(label: 'Telepon', value: '+62 812-3456-7890'), Divider(height: 20.h, color: AppColors.outlineVariant.withOpacity(0.3)),
          _Row(label: 'Tanggal Bergabung', value: '1 Jan 2023'),
        ])),
        SizedBox(height: 24.h),
        Row(children: [
          Expanded(child: _ActionBtn(icon: Icons.calendar_month, label: 'Jadwal', onTap: () {})), SizedBox(width: 12.w),
          Expanded(child: _ActionBtn(icon: Icons.receipt_long, label: 'Slip Gaji', onTap: () {})), SizedBox(width: 12.w),
          Expanded(child: _ActionBtn(icon: Icons.analytics, label: 'Laporan', onTap: () {})),
        ]),
      ])),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
    Text(value, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
  ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12.r), child: Container(
    padding: EdgeInsets.symmetric(vertical: 16.h), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
    child: Column(children: [Icon(icon, color: AppColors.primaryContainer), SizedBox(height: 8.h), Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold))]),
  ));
}
