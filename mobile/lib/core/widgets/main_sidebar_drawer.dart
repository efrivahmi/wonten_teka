import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';

class MainSidebarDrawer extends StatelessWidget {
  const MainSidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isAdmin = false;
        bool isManager = false;
        String userName = 'Pengguna';
        String roleName = 'Karyawan';
        
        if (state is AuthAuthenticated) {
          isAdmin = state.user.isAdmin;
          isManager = state.user.isManager;
          userName = state.user.employee?.fullName ?? state.user.name;
          if (isAdmin) roleName = 'Administrator';
          else if (isManager) roleName = 'Manager';
        }

        return Drawer(
          backgroundColor: AppColors.surface,
          child: Column(
            children: [
              _buildHeader(context, userName, roleName),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildListTile(context, 'Beranda', Icons.home, '/app/home'),
                    
                    if (isAdmin || isManager) ...[
                      const Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Text('MANAJEMEN', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                      ),
                      if (isAdmin) _buildListTile(context, 'Admin Dashboard', Icons.admin_panel_settings, '/admin/dashboard', color: AppColors.errorCrimson),
                      _buildListTile(context, 'Persetujuan', Icons.fact_check, '/admin/approvals'),
                      _buildListTile(context, 'Tim Saya', Icons.groups, '/admin/employees'), // For both admin and manager
                    ],

                    if (isAdmin) ...[
                      const Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Text('MASTER DATA', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.storage, color: AppColors.primary),
                        title: const Text('Data Utama', style: TextStyle(fontWeight: FontWeight.w600)),
                        childrenPadding: EdgeInsets.only(left: 16.w),
                        children: [
                          _buildListTile(context, 'Karyawan', Icons.people_outline, '/admin/employees'),
                          _buildListTile(context, 'Kategori Shift', Icons.calendar_month, '/admin/shifts'),
                          _buildListTile(context, 'Jadwal Shift', Icons.assignment_ind, '/admin/shift-assignments'),
                          _buildListTile(context, 'Konfigurasi Payroll', Icons.settings_suggest, '/admin/payroll-config'),
                        ],
                      ),
                      ExpansionTile(
                        leading: Icon(Icons.insert_chart, color: AppColors.infoCerulean),
                        title: const Text('Laporan & Analitik', style: TextStyle(fontWeight: FontWeight.w600)),
                        childrenPadding: EdgeInsets.only(left: 16.w),
                        children: [
                          _buildListTile(context, 'Laporan Absensi', Icons.history, '/admin/reports'),
                          _buildListTile(context, 'Tinjauan Flag Absen', Icons.flag, '/admin/attendance-flags'),
                          _buildListTile(context, 'Analitik Departemen', Icons.pie_chart, '/admin/department-analytics'),
                        ],
                      ),
                      _buildListTile(context, 'Pengumuman / Event', Icons.campaign, '/admin/events'),
                      _buildListTile(context, 'Pengaturan Perusahaan', Icons.business, '/admin/org-settings'),
                      _buildListTile(context, 'Pengaturan Sistem', Icons.settings, '/admin/settings'),
                    ],

                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Text('PERSONAL', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                    ),
                    _buildListTile(context, 'Riwayat Absensi', Icons.fingerprint, '/app/attendance'),
                    _buildListTile(context, 'Jadwal Shift Saya', Icons.schedule, '/app/shift-schedule'),
                    _buildListTile(context, 'Riwayat Cuti', Icons.event_busy, '/app/leave'),
                    _buildListTile(context, 'Klaim / Reimburse', Icons.receipt_long, '/app/claims'),
                    _buildListTile(context, 'Slip Gaji', Icons.request_quote, '/app/payroll'),
                    _buildListTile(context, 'Profil', Icons.person, '/app/profile'),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildListTile(context, 'Keluar', Icons.logout, null, color: AppColors.errorCrimson, onTap: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                context.go('/login');
              }),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String userName, String roleName) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24.h, bottom: 24.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: Colors.white,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: TextStyle(color: AppColors.primary, fontSize: 28.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            userName,
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              roleName,
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, String? route, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.onSurfaceVariant),
      title: Text(title, style: TextStyle(color: color ?? AppColors.onSurface, fontWeight: FontWeight.w500)),
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (route != null) {
          Navigator.pop(context); // Close drawer
          context.push(route);
        }
      },
    );
  }
}
