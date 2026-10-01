import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WontenCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const WontenCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withValues(alpha: .82),
            border: Border.all(color: Colors.white.withValues(alpha: .86)),
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
