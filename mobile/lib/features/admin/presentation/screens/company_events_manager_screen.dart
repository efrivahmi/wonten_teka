import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class CompanyEventsManagerScreen extends StatelessWidget {
  const CompanyEventsManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Kelola Event Perusahaan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, backgroundColor: AppColors.primaryContainer, icon: const Icon(Icons.add, color: AppColors.onPrimary), label: Text('Buat Event', style: TextStyle(color: AppColors.onPrimary))),
      body: ListView.separated(padding: EdgeInsets.all(16.w), itemCount: 3, separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, i) => InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Townhall Q3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            Row(children: [IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {}), IconButton(icon: const Icon(Icons.delete, size: 20, color: AppColors.errorCrimson), onPressed: () {})]),
          ]),
          SizedBox(height: 8.h),
          Row(children: [Icon(Icons.calendar_today, size: 14.w, color: AppColors.onSurfaceVariant), SizedBox(width: 8.w), Text('15 Jul 2025, 14:00', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp))]),
          SizedBox(height: 4.h),
          Row(children: [Icon(Icons.location_on, size: 14.w, color: AppColors.onSurfaceVariant), SizedBox(width: 8.w), Text('Ruang Utama Lt. 3', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp))]),
        ]))),
    );
  }
}
