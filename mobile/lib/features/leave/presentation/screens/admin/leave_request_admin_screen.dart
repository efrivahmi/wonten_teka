import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

class LeaveRequestAdminScreen extends StatelessWidget {
  const LeaveRequestAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            height: 240.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.errorCrimson.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32.r), bottomRight: Radius.circular(32.r)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
                      Expanded(child: Text('Persetujuan Cuti', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    itemCount: 8,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (context, i) {
                      final isPending = i % 3 != 0;
                      return Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                                  child: Icon(Icons.person, color: AppColors.primary, size: 20.w),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Karyawan ${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppColors.onSurface)),
                                      Text('Staff Operasional', style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: isPending ? AppColors.warningAmber.withValues(alpha: 0.1) : AppColors.successEmerald.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    isPending ? 'Pending' : 'Disetujui',
                                    style: TextStyle(color: isPending ? AppColors.warningAmber : AppColors.successEmerald, fontSize: 10.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Icon(Icons.beach_access, size: 16.w, color: Colors.grey[500]),
                                SizedBox(width: 8.w),
                                Text('Cuti Tahunan (3 Hari)', style: TextStyle(color: Colors.grey[800], fontSize: 13.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16.w, color: Colors.grey[500]),
                                SizedBox(width: 8.w),
                                Text('14 Jul - 16 Jul 2025', style: TextStyle(color: Colors.grey[700], fontSize: 13.sp)),
                              ],
                            ),
                            if (isPending) ...[
                              SizedBox(height: 16.h),
                              Divider(color: Colors.grey[200]),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.errorCrimson,
                                        side: const BorderSide(color: AppColors.errorCrimson),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                      ),
                                      child: const Text('Tolak'),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.successEmerald,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                      ),
                                      child: const Text('Setujui'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
