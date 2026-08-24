import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            // Avatar
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Icon(Icons.person, color: AppColors.primary, size: 20.w),
            ),
            SizedBox(width: 8.w),
            Text(
              'Wonten Teka',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Profile Header Card
            InfoCard(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 96.w,
                    height: 96.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainer,
                      border: Border.all(
                        color: AppColors.surfaceContainerLowest,
                        width: 4.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface.withOpacity(0.1),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 48.w),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Budi Santoso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Senior Developer',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.infoCerulean.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.badge, size: 14.w, color: AppColors.infoCerulean),
                        SizedBox(width: 4.w),
                        Text(
                          'Karyawan Tetap',
                          style: TextStyle(
                            color: AppColors.infoCerulean,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Menu Items
            _ProfileMenuItem(
              icon: Icons.person,
              iconBgColor: AppColors.primaryFixed,
              iconColor: AppColors.primary,
              title: 'Informasi Pribadi',
              subtitle: 'Data diri, kontak, alamat',
              onTap: () {},
            ),
            SizedBox(height: 12.h),
            _ProfileMenuItem(
              icon: Icons.calendar_month,
              iconBgColor: AppColors.secondaryFixed,
              iconColor: AppColors.secondary,
              title: 'Jadwal Kerja',
              subtitle: 'Shift reguler, jam kantor',
              onTap: () {},
            ),
            SizedBox(height: 12.h),
            _ProfileMenuItem(
              icon: Icons.payments,
              iconBgColor: AppColors.tertiaryFixed,
              iconColor: AppColors.tertiary,
              title: 'Slip Gaji',
              subtitle: 'Riwayat penggajian, potongan, tunjangan',
              trailing: _NewBadge(),
              onTap: () {},
            ),
            SizedBox(height: 12.h),
            _ProfileMenuItem(
              icon: Icons.settings,
              iconBgColor: AppColors.surfaceContainerHigh,
              iconColor: AppColors.onSurfaceVariant,
              title: 'Pengaturan',
              subtitle: 'Kata sandi, notifikasi',
              onTap: () {},
            ),
            SizedBox(height: 12.h),
            _ProfileMenuItem(
              icon: Icons.help,
              iconBgColor: AppColors.surfaceContainerHigh,
              iconColor: AppColors.onSurfaceVariant,
              title: 'Bantuan',
              subtitle: 'FAQ, Hubungi HRD',
              onTap: () {},
            ),
            SizedBox(height: 24.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout),
                    SizedBox(width: 8.w),
                    Text(
                      'Keluar Aplikasi',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            SizedBox(width: 8.w),
          ],
          Icon(Icons.chevron_right, color: AppColors.outline, size: 20.w),
        ],
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        'Baru',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
