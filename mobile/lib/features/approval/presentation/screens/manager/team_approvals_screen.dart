import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class TeamApprovalsScreen extends StatelessWidget {
  const TeamApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLow,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.pop()),
          title: Text('Team Approvals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
              labelColor: AppColors.primary,
              indicatorColor: AppColors.primary,
              tabs: [Tab(text: 'Menunggu (5)'), Tab(text: 'Riwayat')]),
        ),
        body: TabBarView(children: [
          ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) =>
                  const _ApprovalItem(isPending: true)),
          ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) =>
                  const _ApprovalItem(isPending: false)),
        ]),
      ),
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final bool isPending;
  const _ApprovalItem({required this.isPending});
  @override
  Widget build(BuildContext context) => InfoCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Andi Wijaya (Marketing)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: (isPending
                            ? AppColors.warningAmber
                            : AppColors.successEmerald)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r)),
                child: Text(isPending ? 'Pending' : 'Disetujui',
                    style: TextStyle(
                        color: isPending
                            ? AppColors.warningAmber
                            : AppColors.successEmerald,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold))),
          ]),
          SizedBox(height: 8.h),
          Text('Cuti Tahunan (3 Hari)',
              style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp)),
          Text('14 Jul - 16 Jul 2025',
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
          if (isPending) ...[
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorCrimson,
                          side:
                              const BorderSide(color: AppColors.errorCrimson)),
                      child: const Text('Tolak'))),
              SizedBox(width: 12.w),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successEmerald,
                          foregroundColor: Colors.white),
                      child: const Text('Setujui'))),
            ]),
          ],
        ]),
      );
}

