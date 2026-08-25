import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

/// A reusable card matching the Stitch design pattern:
/// rounded corners, subtle shadow, surfaceContainerLowest background, outline border.
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderLeftColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.child,
    this.padding,
    this.borderLeftColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: padding ?? EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: borderLeftColor != null
                ? Border(left: BorderSide(color: borderLeftColor!, width: 4.w))
                : Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
