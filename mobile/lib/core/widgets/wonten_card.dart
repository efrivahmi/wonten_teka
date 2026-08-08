import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WontenCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const WontenCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(
            24.0), // Large containers have higher roundness
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: 0.04), // Level 2: active cards soft diffused shadow
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
