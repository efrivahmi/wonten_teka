import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

class AttendanceReportAdminScreen extends StatelessWidget {
  const AttendanceReportAdminScreen({super.key});

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
                      Expanded(child: Text('Log Absensi Karyawan', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                
                // Date filter & export button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: AppColors.errorCrimson, size: 20.w),
                              SizedBox(width: 8.w),
                              Text('Hari Ini, 14 Jul', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.download, color: AppColors.errorCrimson),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    itemCount: 10,
                    separatorBuilder: (_, __) => SizedBox(height: 16.h),
                    itemBuilder: (context, i) {
                      final isLate = i % 4 == 0;
                      final isAbsent = i % 7 == 0;
                      
                      Color statusColor = AppColors.successEmerald;
                      String statusText = 'Tepat Waktu';
                      
                      if (isAbsent) {
                        statusColor = AppColors.errorCrimson;
                        statusText = 'Alpa';
                      } else if (isLate) {
                        statusColor = AppColors.warningAmber;
                        statusText = 'Terlambat';
                      }
                      
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          border: Border(left: BorderSide(color: statusColor, width: 4.w)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                              child: Icon(Icons.person, color: AppColors.primary, size: 24.w),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Karyawan ${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.onSurface)),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Icons.login, size: 14.w, color: Colors.grey[500]),
                                      SizedBox(width: 4.w),
                                      Text(isAbsent ? '-' : '07:45', style: TextStyle(color: Colors.grey[700], fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 12.w),
                                      Icon(Icons.logout, size: 14.w, color: Colors.grey[500]),
                                      SizedBox(width: 4.w),
                                      Text(isAbsent ? '-' : '17:10', style: TextStyle(color: Colors.grey[700], fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(color: statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
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
