import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    Key? key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  }) : super(key: key);

  // Factory constructors for common statuses
  factory StatusBadge.approved() => const StatusBadge(
    label: 'Disetujui',
    backgroundColor: Color(0x1A10B981),
    textColor: AppColors.successEmerald,
    icon: Icons.check_circle_outline,
  );

  factory StatusBadge.pending() => const StatusBadge(
    label: 'Menunggu',
    backgroundColor: Color(0x1AF59E0B),
    textColor: AppColors.warningAmber,
    icon: Icons.schedule,
  );

  factory StatusBadge.rejected() => const StatusBadge(
    label: 'Ditolak',
    backgroundColor: Color(0x1ADC2626),
    textColor: AppColors.errorCrimson,
    icon: Icons.cancel_outlined,
  );

  factory StatusBadge.onTime() => const StatusBadge(
    label: 'Tepat Waktu',
    backgroundColor: Color(0x1A10B981),
    textColor: AppColors.successEmerald,
  );

  factory StatusBadge.late() => const StatusBadge(
    label: 'Terlambat',
    backgroundColor: Color(0x1AF59E0B),
    textColor: AppColors.warningAmber,
  );

  factory StatusBadge.absent() => const StatusBadge(
    label: 'Tidak Hadir',
    backgroundColor: Color(0x1ADC2626),
    textColor: AppColors.errorCrimson,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.w, color: textColor),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
