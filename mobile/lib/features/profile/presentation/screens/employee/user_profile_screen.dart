import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../auth/bloc/auth_bloc.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final employeeName = user?.employee?.fullName ?? user?.name ?? 'User';
        final position = user?.employee?.position ?? '-';
        final department = user?.employee?.department ?? '-';
        final employeeNumber = user?.employee?.employeeNumber ?? '-';
        final roleBadge = user?.isAdmin == true
            ? 'Administrator'
            : 'Karyawan';
        final roleBadgeColor = user?.isAdmin == true
            ? AppColors.errorCrimson
            : AppColors.infoCerulean;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            title: Row(
              children: [
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
                  'Profil Saya',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
                onPressed: () => context.push('/app/notifications'),
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
                              color: AppColors.onSurface.withValues(alpha: 0.1),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        employeeName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$position • $department',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'NIP: $employeeNumber',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Role Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: roleBadgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, size: 14.w, color: roleBadgeColor),
                            SizedBox(width: 4.w),
                            Text(
                              roleBadge,
                              style: TextStyle(
                                color: roleBadgeColor,
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
                  onTap: () => context.push('/app/profile/edit'),
                ),
                SizedBox(height: 12.h),
                _ProfileMenuItem(
                  icon: Icons.calendar_month,
                  iconBgColor: AppColors.secondaryFixed,
                  iconColor: AppColors.secondary,
                  title: 'Jadwal Kerja',
                  subtitle: 'Shift reguler, jam kantor',
                  onTap: () => context.push('/app/schedule/shifts'),
                ),
                SizedBox(height: 12.h),
                _ProfileMenuItem(
                  icon: Icons.payments,
                  iconBgColor: AppColors.tertiaryFixed,
                  iconColor: AppColors.tertiary,
                  title: 'Slip Gaji',
                  subtitle: 'Riwayat penggajian, potongan, tunjangan',
                  onTap: () => context.push('/app/payslip'),
                ),
                SizedBox(height: 12.h),
                _ProfileMenuItem(
                  icon: Icons.face_retouching_natural,
                  iconBgColor: AppColors.primaryFixed,
                  iconColor: AppColors.primary,
                  title: 'Update Data Wajah',
                  subtitle: 'Perbarui data biometrik wajah',
                  onTap: () => context.push('/app/profile/face-update'),
                ),
                SizedBox(height: 12.h),
                _ProfileMenuItem(
                  icon: Icons.people,
                  iconBgColor: AppColors.secondaryFixed,
                  iconColor: AppColors.secondary,
                  title: 'Direktori Perusahaan',
                  subtitle: 'Cari rekan kerja',
                  onTap: () => context.push('/app/directory'),
                ),
                SizedBox(height: 12.h),
                _ProfileMenuItem(
                  icon: Icons.settings,
                  iconBgColor: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Pengaturan',
                  subtitle: 'Kata sandi, notifikasi',
                  onTap: () => context.push('/app/settings'),
                ),
                SizedBox(height: 12.h),
                _ProfileMenuItem(
                  icon: Icons.help,
                  iconBgColor: AppColors.surfaceContainerHigh,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Bantuan',
                  subtitle: 'FAQ, Hubungi HRD',
                  onTap: () => context.push('/app/help'),
                ),

                // Admin-only section
                if (user?.isAdmin == true) ...[
                  SizedBox(height: 24.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        'Admin Panel',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.errorCrimson,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _ProfileMenuItem(
                    icon: Icons.admin_panel_settings,
                    iconBgColor: AppColors.errorContainer,
                    iconColor: AppColors.errorCrimson,
                    title: 'Dashboard Admin',
                    subtitle: 'Kelola karyawan, absensi, payroll',
                    onTap: () => context.push('/admin/dashboard'),
                  ),
                ],

                SizedBox(height: 24.h),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Keluar Aplikasi'),
                          content: const Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<AuthBloc>().add(AuthLogoutRequested());
                              },
                              child: const Text(
                                'Keluar',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
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
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
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
    required this.onTap,
  }) : trailing = null;

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

