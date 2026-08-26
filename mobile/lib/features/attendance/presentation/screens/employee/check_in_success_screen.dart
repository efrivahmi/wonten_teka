import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/attendance_log_model.dart';

class CheckInSuccessScreen extends StatelessWidget {
  final AttendanceLogModel log;
  final bool isCheckOut;
  
  const CheckInSuccessScreen({
    super.key, 
    required this.log,
    this.isCheckOut = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFlagged = log.status == 'flagged';
    final primaryColor = isFlagged ? Colors.amber[600]! : Colors.green[500]!;
    final iconData = isFlagged ? Icons.warning_rounded : Icons.check_circle_rounded;
    
    final relevantTime = isCheckOut ? (log.checkOutAt ?? DateTime.now()) : log.checkInAt;
    final timeStr = DateFormat('HH:mm').format(relevantTime);
    final dateStr = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(relevantTime);

    String locationText = 'Lokasi GPS Tersimpan';
    if (log.flags != null && log.flags!.containsKey('address')) {
       locationText = log.flags!['address'] as String;
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
                      ),
                      child: Icon(iconData, color: primaryColor, size: 80.w),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      isCheckOut ? 'Check-out Berhasil' : 'Check-in Berhasil',
                      style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold),
                    ),
                    if (isFlagged)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          'Catatan: Menunggu Tinjauan Admin',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.sp),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Bottom White Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(timeStr, style: TextStyle(color: AppColors.primary, fontSize: 56.sp, fontWeight: FontWeight.bold, letterSpacing: -2)),
                  ),
                  Center(
                    child: Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 16.sp)),
                  ),
                  SizedBox(height: 32.h),
                  
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey[200]!)),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[400], size: 24.w),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(locationText, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () => context.go('/app/dashboard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                      ),
                      child: Text('Kembali ke Dashboard', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 16.h), // Bottom padding for safe area
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
