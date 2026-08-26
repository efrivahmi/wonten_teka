import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';

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
              // Hero Background - Darker/Reddish tint for Admin Mode
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
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                            ),
                            child: Icon(Icons.admin_panel_settings, color: AppColors.errorCrimson, size: 28.w),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Panel',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.sp),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: Colors.white),
                            onPressed: () => context.push('/app/notifications'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () => context.go('/app/home'), // Back to employee view or logout
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick Stats Floating Card
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.analytics, color: AppColors.primary, size: 20.w),
                                      SizedBox(width: 8.w),
                                      Text('Ringkasan Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.onSurface)),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  Row(
                                    children: [
                                      Expanded(child: _buildStatItem('Hadir', '-', AppColors.successEmerald)),
                                      Container(width: 1.w, height: 40.h, color: Colors.grey[200]),
                                      Expanded(child: _buildStatItem('Cuti', '-', AppColors.infoCerulean)),
                                      Container(width: 1.w, height: 40.h, color: Colors.grey[200]),
                                      Expanded(child: _buildStatItem('Sakit', '-', AppColors.warningAmber)),
                                      Container(width: 1.w, height: 40.h, color: Colors.grey[200]),
                                      Expanded(child: _buildStatItem('Alpa', '-', AppColors.errorCrimson)),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                            
                            SizedBox(height: 32.h),
                            Text('Operasional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppColors.onSurface)),
                            SizedBox(height: 16.h),
                            
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,
                              mainAxisSpacing: 24.h,
                              crossAxisSpacing: 16.w,
                              childAspectRatio: 0.8,
                              children: [
                                _buildGridItem(context, 'Persetujuan', Icons.fact_check, AppColors.primary, () => context.push('/app/admin/approvals')),
                                _buildGridItem(context, 'Karyawan', Icons.people, AppColors.infoCerulean, () => context.push('/app/admin/employees')),
                                _buildGridItem(context, 'Shift', Icons.calendar_month, AppColors.warningAmber, () => context.push('/app/admin/shifts')),
                                _buildGridItem(context, 'Log Absen', Icons.history, AppColors.successEmerald, () => context.push('/app/admin/attendance')),
                              ],
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                            
                            SizedBox(height: 32.h),
                            Text('Pengaturan & Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppColors.onSurface)),
                            SizedBox(height: 16.h),
                            
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 4,
                              mainAxisSpacing: 24.h,
                              crossAxisSpacing: 16.w,
                              childAspectRatio: 0.8,
                              children: [
                                _buildGridItem(context, 'Payroll', Icons.request_quote, AppColors.errorCrimson, () => context.push('/app/admin/payroll')),
                                _buildGridItem(context, 'Master Data', Icons.storage, AppColors.primary, () => context.push('/app/admin/master')),
                                _buildGridItem(context, 'Laporan', Icons.insert_chart, AppColors.infoCerulean, () => context.push('/app/admin/reports')),
                                _buildGridItem(context, 'Settings', Icons.settings, Colors.grey[700]!, () => context.push('/app/admin/settings')),
                              ],
                            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                            
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28.w),
          ),
          SizedBox(height: 8.h),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
