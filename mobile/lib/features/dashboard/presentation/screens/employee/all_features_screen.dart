import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';

class AllFeaturesScreen extends StatelessWidget {
  const AllFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        title: Text(
          'Semua fitur',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;
          
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection(
                  context,
                  title: 'Presensi',
                  features: [
                    _FeatureItem(icon: Icons.login, label: 'Absen Masuk', color: AppColors.successEmerald, route: '/app/attendance/check-in'),
                    _FeatureItem(icon: Icons.logout, label: 'Absen Keluar', color: AppColors.error, route: '/app/attendance/check-out'),
                    _FeatureItem(icon: Icons.history, label: 'Riwayat', color: AppColors.primaryFixedDim, route: '/app/attendance'),
                    _FeatureItem(icon: Icons.edit_calendar, label: 'Lupa Absen', color: AppColors.tertiaryContainer, route: '/app/attendance/adjustment-form'),
                    _FeatureItem(icon: Icons.flight_takeoff, label: 'Dinas Luar', color: AppColors.secondaryContainer, route: '/app/attendance/business-trip-form'),
                    _FeatureItem(icon: Icons.schedule, label: 'Jadwal Shift', color: AppColors.tertiaryContainer, route: '/app/schedule/shifts'),
                  ],
                ),
                _buildDivider(),
                _buildCategorySection(
                  context,
                  title: 'Pengajuan',
                  features: [
                    _FeatureItem(icon: Icons.event_busy, label: 'Cuti', color: AppColors.primaryContainer, route: '/app/leave'),
                    _FeatureItem(icon: Icons.more_time, label: 'Lembur', color: AppColors.secondaryContainer, route: '/app/overtime'),
                    _FeatureItem(icon: Icons.receipt_long, label: 'Klaim', color: AppColors.secondaryContainer, route: '/app/claims'),
                  ],
                ),
                _buildDivider(),
                _buildCategorySection(
                  context,
                  title: 'Keuangan',
                  features: [
                    _FeatureItem(icon: Icons.payments, label: 'Slip Gaji', color: AppColors.primaryContainer, route: '/app/payslip'),
                  ],
                ),
                _buildDivider(),
                _buildCategorySection(
                  context,
                  title: 'Lainnya',
                  features: [
                    _FeatureItem(icon: Icons.calendar_month, label: 'Kalender', color: AppColors.tertiaryContainer, route: '/app/calendar'),
                    _FeatureItem(icon: Icons.track_changes, label: 'Habit Tracker', color: AppColors.primaryFixedDim, route: '/app/habits'),
                    _FeatureItem(icon: Icons.task_alt, label: 'Tasks', color: AppColors.primaryContainer, route: '/app/tasks'),
                  ],
                ),
                if (isAdmin) ...[
                  _buildDivider(),
                  _buildCategorySection(
                    context,
                    title: 'Persetujuan',
                    features: [
                      _FeatureItem(icon: Icons.inbox, label: 'Approval Inbox', color: AppColors.primaryContainer, route: '/admin/approvals'),
                      if (isAdmin) _FeatureItem(icon: Icons.phonelink_setup, label: 'Device Approval', color: AppColors.secondaryContainer, route: '/admin/devices'),
                      if (isAdmin) _FeatureItem(icon: Icons.flag, label: 'Attendance Flags', color: AppColors.error, route: '/admin/attendance-flags'),
                    ],
                  ),
                ],
                if (isAdmin) ...[
                  _buildDivider(),
                  _buildCategorySection(
                    context,
                    title: 'Kelola (Admin)',
                    features: [
                      _FeatureItem(icon: Icons.dashboard, label: 'Dashboard Admin', color: AppColors.tertiaryContainer, route: '/admin/dashboard'),
                      _FeatureItem(icon: Icons.people, label: 'Pegawai', color: AppColors.primaryFixedDim, route: '/admin/employees'),
                      _FeatureItem(icon: Icons.settings_suggest, label: 'Shift Templates', color: AppColors.primaryContainer, route: '/admin/shifts'),
                      _FeatureItem(icon: Icons.date_range, label: 'Leave Types', color: AppColors.secondaryContainer, route: '/admin/leave-types'),
                      _FeatureItem(icon: Icons.analytics, label: 'Analytics', color: AppColors.primaryFixedDim, route: '/admin/department-analytics'),
                      _FeatureItem(icon: Icons.settings, label: 'Settings', color: AppColors.tertiaryContainer, route: '/admin/org-settings'),
                    ],
                  ),
                ],
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, {required String title, required List<_FeatureItem> features}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 24.w,
          runSpacing: 24.h,
          children: features.map((item) {
            return GestureDetector(
              onTap: item.route != null ? () => context.push(item.route!) : null,
              child: SizedBox(
                width: 72.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 28.w,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: const Divider(color: AppColors.surfaceContainerHigh, thickness: 1),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;

  _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    this.route,
  });
}
