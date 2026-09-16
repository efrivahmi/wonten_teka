import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../api/api_client.dart';

class MainSidebarDrawer extends StatelessWidget {
  const MainSidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isAdmin = false;
        String userName = 'Pengguna';
        String roleName = 'Karyawan';

        if (state is AuthAuthenticated) {
          isAdmin = state.user.isAdmin;
          userName = state.user.employee?.fullName ?? state.user.name;
          if (isAdmin) {
            roleName = 'Administrator';
          }
        }

        return Drawer(
          backgroundColor: AppColors.surface,
          child: Column(
            children: [
              _buildHeader(context, userName, roleName),
              Expanded(
                child: FutureBuilder<dynamic>(
                  future: context.read<ApiClient>().get('/app-config'),
                  builder: (context, configSnapshot) {
                    final menu = configSnapshot.hasData
                        ? ((configSnapshot.data!.data['data']['employee_menu']
                                    as List? ??
                                const [])
                            .whereType<Map>()
                            .where((item) => item['enabled'] == true)
                            .map((item) => item['key'].toString())
                            .toSet())
                        : <String>{
                            'attendance',
                            'schedule',
                            'leave',
                            'overtime',
                            'claims',
                            'payroll',
                            'calendar',
                            'tasks',
                            'adjustments',
                            'business_trips',
                            'profile'
                          };
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildListTile(
                            context, 'Beranda', Icons.home, '/app/home'),
                        if (isAdmin) ...[
                          const Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            child: Text('ADMINISTRATOR',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 1.2)),
                          ),
                          _buildListTile(context, 'Dasbor Admin',
                              Icons.admin_panel_settings, '/admin/dashboard'),
                        ],
                        if (isAdmin) ...[
                          const Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            child: Text('MASTER DATA',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurfaceVariant)),
                          ),
                          ExpansionTile(
                            leading: const Icon(Icons.storage,
                                color: AppColors.primary),
                            title: const Text('Data Utama',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            childrenPadding: EdgeInsets.only(left: 16.w),
                            children: [
                              _buildListTile(context, 'Karyawan',
                                  Icons.people_outline, '/admin/employees'),
                              _buildListTile(context, 'Kategori Shift',
                                  Icons.calendar_month, '/admin/shifts'),
                              _buildListTile(
                                  context,
                                  'Jadwal Shift',
                                  Icons.assignment_ind,
                                  '/admin/shift-assignments'),
                              _buildListTile(context, 'Tipe Cuti',
                                  Icons.flight_takeoff, '/admin/leave-types'),
                              _buildListTile(
                                  context,
                                  'Konfigurasi Payroll',
                                  Icons.settings_suggest,
                                  '/admin/payroll-config'),
                            ],
                          ),
                          ExpansionTile(
                            leading: const Icon(Icons.insert_chart,
                                color: AppColors.infoCerulean),
                            title: const Text('Laporan & Analitik',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            childrenPadding: EdgeInsets.only(left: 16.w),
                            children: [
                              _buildListTile(context, 'Laporan Absensi',
                                  Icons.history, '/admin/reports'),
                              _buildListTile(
                                  context,
                                  'Deteksi Fake GPS',
                                  Icons.gps_off,
                                  '/admin/attendance-security-events'),
                            ],
                          ),
                          _buildListTile(context, 'Pengumuman / Event',
                              Icons.campaign, '/admin/events'),
                          _buildListTile(context, 'Pengaturan Perusahaan',
                              Icons.business, '/admin/org-settings'),
                          _buildListTile(context, 'Pengaturan Sistem',
                              Icons.settings, '/admin/settings'),
                        ],
                        const Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          child: Text('PERSONAL',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurfaceVariant)),
                        ),
                        if (menu.contains('attendance'))
                          _buildListTile(context, 'Riwayat Absensi',
                              Icons.fingerprint, '/app/attendance'),
                        if (menu.contains('schedule'))
                          _buildListTile(context, 'Jadwal Shift Saya',
                              Icons.schedule, '/app/schedule/shifts'),
                        if (menu.contains('business_trips'))
                          _buildListTile(
                              context,
                              'Perjalanan Dinas',
                              Icons.flight_takeoff,
                              '/app/attendance/business-trip-form'),
                        if (menu.contains('adjustments'))
                          _buildListTile(context, 'Koreksi Absensi', Icons.tune,
                              '/app/attendance/adjustment-form'),
                        if (menu.contains('leave'))
                          _buildListTile(context, 'Riwayat Cuti',
                              Icons.event_busy, '/app/leave'),
                        if (menu.contains('overtime'))
                          _buildListTile(context, 'Lembur', Icons.more_time,
                              '/app/overtime'),
                        if (menu.contains('claims'))
                          _buildListTile(context, 'Klaim / Reimburse',
                              Icons.receipt_long, '/app/claims'),
                        if (menu.contains('payroll'))
                          _buildListTile(context, 'Slip Gaji',
                              Icons.request_quote, '/app/payroll'),
                        if (menu.contains('calendar'))
                          _buildListTile(context, 'Kalender Perusahaan',
                              Icons.calendar_month, '/app/calendar'),
                        if (menu.contains('tasks'))
                          _buildListTile(context, 'Daily Task', Icons.task_alt,
                              '/app/tasks'),
                        if (menu.contains('habits'))
                          _buildListTile(context, 'Habit Tracker',
                              Icons.track_changes, '/app/habits'),
                        _buildListTile(
                            context,
                            'Data Wajah Saya',
                            Icons.face_retouching_natural,
                            '/app/profile/face-update'),
                        if (menu.contains('profile'))
                          _buildListTile(
                              context, 'Profil', Icons.person, '/app/profile'),
                        SizedBox(height: 24.h),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              _buildListTile(context, 'Keluar', Icons.logout, null,
                  color: AppColors.errorCrimson, onTap: () {
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
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 24.h,
          bottom: 24.h,
          left: 16.w,
          right: 16.w),
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
          Row(children: [
            Image.asset('assets/images/lemdiklat-logo.png',
                width: 38.w, height: 38.w),
            SizedBox(width: 10.w),
            Expanded(
                child: Text('e-Absensi Lemdiklat',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800)))
          ]),
          SizedBox(height: 20.h),
          CircleAvatar(
            radius: 32.r,
            backgroundColor: Colors.white,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            userName,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, String title, IconData icon, String? route,
      {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.onSurfaceVariant),
      title: Text(title,
          style: TextStyle(
              color: color ?? AppColors.onSurface,
              fontWeight: FontWeight.w500)),
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
