import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Consistent application identity for primary mobile headers.
class AppBrandTitle extends StatelessWidget {
  final String? section;
  final bool inverse;
  const AppBrandTitle({super.key, this.section, this.inverse = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: .16)),
            ),
            child: Image.asset(
              'assets/images/lemdiklat-logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.verified_user_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('e-Absensi',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: inverse ? Colors.white : AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                if (section != null)
                  Text(section!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: inverse
                              ? Colors.white70
                              : AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
}
