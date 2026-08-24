import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_badge.dart';

class ApprovalInboxScreen extends StatelessWidget {
  const ApprovalInboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requests = [
      {'name': 'Dewi Lestari', 'type': 'Cuti Tahunan', 'date': '20-22 Jul', 'status': 'pending', 'dept': 'Marketing'},
      {'name': 'Rudi Hartono', 'type': 'Klaim Transport', 'date': '15 Jul', 'status': 'pending', 'dept': 'Engineering'},
      {'name': 'Siti Aminah', 'type': 'Cuti Sakit', 'date': '18 Jul', 'status': 'pending', 'dept': 'Finance'},
      {'name': 'Budi Pratama', 'type': 'Lembur', 'date': '12 Jul', 'status': 'approved', 'dept': 'Engineering'},
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        title: Text('Approval Inbox', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true,
        actions: [
          Container(margin: EdgeInsets.only(right: 16.w), padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: AppColors.warningAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Center(child: Text('3 pending', style: TextStyle(color: AppColors.warningAmber, fontWeight: FontWeight.bold, fontSize: 12.sp)))),
        ]),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w), itemCount: requests.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final r = requests[index];
          return InfoCard(
            onTap: () => context.push('/app/leave/approval-detail'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  CircleAvatar(radius: 18.r, backgroundColor: AppColors.surfaceContainerHigh, child: Text((r['name'] as String).substring(0, 1), style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold))),
                  SizedBox(width: 12.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['name'] as String, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                    Text(r['dept'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                  ]),
                ]),
                r['status'] == 'pending' ? StatusBadge.pending() : StatusBadge.approved(),
              ]),
              SizedBox(height: 12.h),
              Row(children: [
                Icon(Icons.description, size: 14.w, color: AppColors.onSurfaceVariant), SizedBox(width: 6.w),
                Text(r['type'] as String, style: TextStyle(color: AppColors.onSurface, fontSize: 13.sp)),
                SizedBox(width: 16.w),
                Icon(Icons.calendar_today, size: 14.w, color: AppColors.onSurfaceVariant), SizedBox(width: 6.w),
                Text(r['date'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.sp)),
              ]),
              if (r['status'] == 'pending') ...[
                SizedBox(height: 12.h),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorCrimson, side: const BorderSide(color: AppColors.errorCrimson), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))), child: const Text('Tolak'))),
                  SizedBox(width: 12.w),
                  Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.successEmerald, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))), child: const Text('Setujui'))),
                ]),
              ],
            ]),
          );
        },
      ),
    );
  }
}
