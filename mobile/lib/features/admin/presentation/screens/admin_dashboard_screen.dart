import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../auth/bloc/auth_bloc.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final userName = user?.name ?? 'Admin';

        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLow,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            title: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.admin_panel_settings,
                      color: AppColors.errorCrimson, size: 20.w),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Halo, $userName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.onSurface),
                onPressed: () => context.push('/app/notifications'),
              ),
              IconButton(
                icon:
                    const Icon(Icons.home_outlined, color: AppColors.onSurface),
                onPressed: () => context.go('/app/home'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats
                InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Hari Ini',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          const _StatMetric(
                              value: '-',
                              label: 'Hadir',
                              color: AppColors.successEmerald),
                          SizedBox(width: 8.w),
                          const _StatMetric(
                              value: '-',
                              label: 'Cuti',
                              color: AppColors.infoCerulean),
                          SizedBox(width: 8.w),
                          const _StatMetric(
                              value: '-',
                              label: 'Alpha',
                              color: AppColors.errorCrimson),
                          SizedBox(width: 8.w),
                          const _StatMetric(
                              value: '-',
                              label: 'Total',
                              color: AppColors.primary),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Data akan terisi setelah karyawan terdaftar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Human Resources Section
                const _SectionTitle(title: 'Sumber Daya Manusia'),
                SizedBox(height: 12.h),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  children: [
                    _MenuGridItem(
                      icon: Icons.people,
                      label: 'Karyawan',
                      color: AppColors.primary,
                      onTap: () => context.push('/admin/employees'),
                    ),
                    _MenuGridItem(
                      icon: Icons.person_add,
                      label: 'Tambah Karyawan',
                      color: AppColors.successEmerald,
                      onTap: () => context.push('/admin/employees/onboarding'),
                    ),
                    _MenuGridItem(
                      icon: Icons.badge,
                      label: 'HR Dashboard',
                      color: AppColors.infoCerulean,
                      onTap: () => context.push('/admin/hr-dashboard'),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Attendance & Schedule Section
                const _SectionTitle(title: 'Absensi & Jadwal'),
                SizedBox(height: 12.h),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  children: [
                    _MenuGridItem(
                      icon: Icons.fact_check,
                      label: 'Laporan Absensi',
                      color: AppColors.primary,
                      onTap: () => context.push('/admin/reports'),
                    ),
                    _MenuGridItem(
                      icon: Icons.flag,
                      label: 'Review Flag',
                      color: AppColors.warningAmber,
                      onTap: () => context.push('/admin/attendance-flags'),
                    ),
                    _MenuGridItem(
                      icon: Icons.calendar_month,
                      label: 'Shift Template',
                      color: AppColors.tertiary,
                      onTap: () => context.push('/admin/shifts'),
                    ),
                    _MenuGridItem(
                      icon: Icons.grid_view,
                      label: 'Jadwal Shift',
                      color: AppColors.secondary,
                      onTap: () => context.push('/admin/shift-assignments'),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Approval & Finance Section
                const _SectionTitle(title: 'Persetujuan & Keuangan'),
                SizedBox(height: 12.h),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  children: [
                    _MenuGridItem(
                      icon: Icons.assignment,
                      label: 'Approval Cuti',
                      color: AppColors.infoCerulean,
                      onTap: () => context.push('/admin/approvals'),
                    ),
                    _MenuGridItem(
                      icon: Icons.receipt_long,
                      label: 'Klaim',
                      color: AppColors.warningAmber,
                      onTap: () => context.push('/admin/claims'),
                    ),
                    _MenuGridItem(
                      icon: Icons.payments,
                      label: 'Payroll',
                      color: AppColors.successEmerald,
                      onTap: () => context.push('/admin/payroll'),
                    ),
                    _MenuGridItem(
                      icon: Icons.settings_applications,
                      label: 'Config Payroll',
                      color: AppColors.tertiary,
                      onTap: () => context.push('/admin/payroll-config'),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Organization Section
                const _SectionTitle(title: 'Organisasi & Sistem'),
                SizedBox(height: 12.h),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  children: [
                    _MenuGridItem(
                      icon: Icons.campaign,
                      label: 'Pengumuman',
                      color: AppColors.warningAmber,
                      onTap: () => context.push('/admin/announcements/new'),
                    ),
                    _MenuGridItem(
                      icon: Icons.event,
                      label: 'Event',
                      color: AppColors.infoCerulean,
                      onTap: () => context.push('/admin/events'),
                    ),
                    _MenuGridItem(
                      icon: Icons.location_on,
                      label: 'Geofence',
                      color: AppColors.errorCrimson,
                      onTap: () => context.push('/admin/org-settings'),
                    ),
                    _MenuGridItem(
                      icon: Icons.analytics,
                      label: 'Analitik',
                      color: AppColors.primary,
                      onTap: () => context.push('/admin/department-analytics'),
                    ),
                    _MenuGridItem(
                      icon: Icons.download,
                      label: 'Export',
                      color: AppColors.tertiary,
                      onTap: () => context.push('/admin/export'),
                    ),
                    _MenuGridItem(
                      icon: Icons.history,
                      label: 'Audit Log',
                      color: AppColors.onSurfaceVariant,
                      onTap: () => context.push('/admin/audit-logs'),
                    ),
                    _MenuGridItem(
                      icon: Icons.settings,
                      label: 'Pengaturan',
                      color: AppColors.onSurfaceVariant,
                      onTap: () => context.push('/admin/settings'),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ]
                  .animate(interval: 50.ms)
                  .fade(duration: 300.ms)
                  .slideY(begin: 0.05, curve: Curves.easeOutQuad),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
    );
  }
}

class _StatMetric extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatMetric(
      {required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h),
              Text(label,
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 11.sp)),
            ],
          ),
        ),
      );
}

class _MenuGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuGridItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 24.w),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
}
