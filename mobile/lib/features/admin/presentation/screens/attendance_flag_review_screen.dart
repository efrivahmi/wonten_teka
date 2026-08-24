import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class AttendanceFlagReviewScreen extends StatelessWidget {
  const AttendanceFlagReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Review Anomali', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: ListView.separated(padding: EdgeInsets.all(16.w), itemCount: 5, separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, i) => InfoCard(
          borderLeftColor: AppColors.warningAmber,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Budi Santoso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: AppColors.warningAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Text('Lokasi Tidak Valid', style: TextStyle(color: AppColors.warningAmber, fontSize: 10.sp, fontWeight: FontWeight.bold))),
            ]),
            SizedBox(height: 8.h),
            Text('Waktu: 08:15 WIB', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
            Text('Lokasi: 2.5 km dari kantor', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorCrimson, side: const BorderSide(color: AppColors.errorCrimson)), child: const Text('Tolak'))),
              SizedBox(width: 12.w),
              Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.successEmerald, foregroundColor: Colors.white), child: const Text('Terima'))),
            ]),
          ]),
        )),
    );
  }
}
