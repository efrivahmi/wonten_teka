import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../../core/widgets/main_sidebar_drawer.dart';
import '../../widgets/admin_dashboard_calendar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final userName = user?.name ?? 'Admin';

        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLowest,
          body: Stack(
            children: [
              // Hero Background
              Container(
                height: 280.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.errorCrimson.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32.r),
                    bottomRight: Radius.circular(32.r),
                  ),
                ),
              ),
              
              SafeArea(
                child: Column(
                  children: [
                    // Header with Drawer Toggle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Monitoring Pusat',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.sp),
                                ),
                                Text(
                                  'Halo, $userName',
                                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: Colors.white),
                            onPressed: () => context.push('/app/notifications'),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickStats(context),
                            SizedBox(height: 24.h),
                            
                            // 2. Admin Features Grid
                            // 2. Admin Features Grids (Categorized)
                            _buildSectionHeader('Kepegawaian'),
                            SizedBox(height: 12.h),
                            _buildKepegawaianGrid(context),
                            SizedBox(height: 24.h),

                            _buildSectionHeader('Kehadiran & Jadwal'),
                            SizedBox(height: 12.h),
                            _buildKehadiranGrid(context),
                            SizedBox(height: 24.h),

                            _buildSectionHeader('Pengaturan Perusahaan'),
                            SizedBox(height: 12.h),
                            _buildPengaturanGrid(context),
                            SizedBox(height: 24.h),

                            // 2. Attendance Bar Chart
                            Text(
                              'Tren Kehadiran (7 Hari)',
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                            SizedBox(height: 16.h),
                            _buildChartContainer(),
                            SizedBox(height: 24.h),

                            // 3. Admin Calendar Monitoring
                            Text(
                              'Kalender Kehadiran & Libur',
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                            SizedBox(height: 16.h),
                            const AdminDashboardCalendar(),
                            SizedBox(height: 60.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Hadir', '142', AppColors.successEmerald, Icons.how_to_reg),
              _buildStatItem('Alpha', '5', AppColors.errorCrimson, Icons.person_off),
              _buildStatItem('Cuti/Sakit', '12', AppColors.warningAmber, Icons.sick),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/admin/attendance-daily');
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Buka Tabel Absensi Harian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          )
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28.w),
        ),
        SizedBox(height: 8.h),
        Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4.r)),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildKepegawaianGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildActionCard(context, 'Data Karyawan', Icons.people, () => context.push('/admin/employees')),
        _buildActionCard(context, 'Persetujuan Cuti', Icons.fact_check, () => context.push('/admin/approvals')),
      ],
    );
  }

  Widget _buildKehadiranGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildActionCard(context, 'Laporan Kehadiran', Icons.event_note, () => context.push('/admin/attendance-daily')),
        _buildActionCard(context, 'Anomali Absen', Icons.warning_amber, () => context.push('/admin/attendance-flags')),
        _buildActionCard(context, 'Device Karyawan', Icons.devices, () => context.push('/admin/devices')),
        _buildActionCard(context, 'Jadwal Shift', Icons.event_available, () => context.push('/admin/shifts')),
      ],
    );
  }

  Widget _buildPengaturanGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildActionCard(context, 'Tipe Cuti', Icons.flight_takeoff, () => context.push('/admin/leave-types')),
        _buildActionCard(context, 'Konfigurasi Payroll', Icons.request_quote, () => context.push('/admin/payroll-config')),
        _buildActionCard(context, 'Pengaturan Sistem', Icons.settings, () => context.push('/admin/org-settings')),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.errorCrimson.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.errorCrimson, size: 26.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer() {
    return Container(
      height: 220.h,
      padding: EdgeInsets.only(top: 24.h, bottom: 16.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 160,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(days[value.toInt() % 7], style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10.sp)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 145, 12, 3),
            _makeGroupData(1, 150, 8, 2),
            _makeGroupData(2, 148, 10, 2),
            _makeGroupData(3, 142, 12, 5),
            _makeGroupData(4, 155, 5, 0),
            _makeGroupData(5, 50, 0, 110), // Saturday
            _makeGroupData(6, 0, 0, 160),  // Sunday
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  BarChartGroupData _makeGroupData(int x, double present, double leave, double absent) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: present + leave + absent,
          width: 16.w,
          borderRadius: BorderRadius.circular(4.r),
          rodStackItems: [
            BarChartRodStackItem(0, present, AppColors.successEmerald),
            BarChartRodStackItem(present, present + leave, AppColors.warningAmber),
            BarChartRodStackItem(present + leave, present + leave + absent, AppColors.errorCrimson),
          ],
        ),
      ],
    );
  }
}
