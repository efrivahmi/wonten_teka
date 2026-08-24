import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class DepartmentAnalyticsScreen extends StatelessWidget {
  const DepartmentAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Analitik Departemen', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InfoCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('IT Department', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Icon(Icons.arrow_drop_down),
        ])),
        SizedBox(height: 24.h),
        Text('Tingkat Kehadiran', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        InfoCard(child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 120.w, height: 120.w, child: CircularProgressIndicator(value: 0.92, strokeWidth: 12.w, backgroundColor: AppColors.surfaceContainerHigh, color: AppColors.successEmerald)),
          ]),
          SizedBox(height: 16.h),
          Text('92%', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.successEmerald)),
          Text('Rata-rata bulan ini', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
        ])),
        SizedBox(height: 24.h),
        Text('Statistik Lainnya', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        Row(children: [
          Expanded(child: InfoCard(child: Column(children: [Text('15j', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)), SizedBox(height: 4.h), Text('Lembur', style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant))]))),
          SizedBox(width: 12.w),
          Expanded(child: InfoCard(child: Column(children: [Text('5', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.warningAmber)), SizedBox(height: 4.h), Text('Cuti', style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant))]))),
        ]),
      ])),
    );
  }
}
