import 'package:flutter/material.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class DepartmentAnalyticsScreen extends StatelessWidget {
  const DepartmentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: 'Analitik Departemen'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoCard(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('IT Department',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_drop_down),
                ])),
            SizedBox(height: 24.h),
            Text('Tingkat Kehadiran',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            InfoCard(
                child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: CircularProgressIndicator(
                        value: 0.92,
                        strokeWidth: 12.w,
                        
                        color: AppColors.successEmerald)),
              ]),
              SizedBox(height: 16.h),
              Text('92%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.successEmerald)),
              Text('Rata-rata bulan ini',
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
            ])),
            SizedBox(height: 24.h),
            Text('Statistik Lainnya',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(
                  child: InfoCard(
                      child: Column(children: [
                Text('15j',
                    style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer)),
                SizedBox(height: 4.h),
                Text('Lembur',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.onSurfaceVariant))
              ]))),
              SizedBox(width: 12.w),
              Expanded(
                  child: InfoCard(
                      child: Column(children: [
                Text('5',
                    style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningAmber)),
                SizedBox(height: 4.h),
                Text('Cuti',
                    style: TextStyle(
                        fontSize: 12.sp, color: AppColors.onSurfaceVariant))
              ]))),
            ]),
          ])),
    ));
  }
}

