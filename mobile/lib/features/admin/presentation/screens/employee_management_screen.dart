import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class EmployeeManagementScreen extends StatelessWidget {
  const EmployeeManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Karyawan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/admin/employees/new'), backgroundColor: AppColors.primaryContainer, child: const Icon(Icons.person_add, color: AppColors.onPrimary)),
      body: Column(children: [
        Container(color: AppColors.surface, padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h), child: TextField(
          decoration: InputDecoration(hintText: 'Cari karyawan...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: AppColors.surfaceContainerHigh,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none)),
        )),
        Expanded(child: ListView.separated(padding: EdgeInsets.all(16.w), itemCount: 5, separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) => InfoCard(onTap: () => context.push('/admin/employees/detail'), child: Row(children: [
            CircleAvatar(radius: 20.r, backgroundColor: AppColors.surfaceContainerHigh, child: const Icon(Icons.person, color: AppColors.onSurfaceVariant)),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Karyawan ${i + 1}', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14.sp)),
              Text('IT Department', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
            ])),
            Icon(Icons.chevron_right, color: AppColors.outline),
          ])))),
      ]),
    );
  }
}
