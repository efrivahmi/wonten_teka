import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class LeaveRequestAdminScreen extends StatelessWidget {
  const LeaveRequestAdminScreen({super.key});

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
          title: Text('Data Cuti',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: 8,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) => InfoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Karyawan ${i + 1}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            Text(i % 2 == 0 ? 'Disetujui' : 'Pending',
                                style: TextStyle(
                                    color: i % 2 == 0
                                        ? AppColors.successEmerald
                                        : AppColors.warningAmber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp)),
                          ]),
                      SizedBox(height: 4.h),
                      Text('Cuti Tahunan (3 Hari)',
                          style: TextStyle(
                              color: AppColors.onSurface, fontSize: 14.sp)),
                      Text('14 Jul - 16 Jul 2025',
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12.sp)),
                    ]),
              )),
    );
  }
}

