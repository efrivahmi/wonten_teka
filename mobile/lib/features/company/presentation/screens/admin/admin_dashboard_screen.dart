import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Dashboard Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Pengguna & Karyawan'),
              _buildAdminCard(
                icon: Icons.people,
                title: 'Kelola Karyawan',
                subtitle: 'Data & Role Karyawan',
                onTap: () => context.push('/admin/employees'),
              ),
              _buildAdminCard(
                icon: Icons.phonelink_setup,
                title: 'Persetujuan Perangkat',
                subtitle: 'Persetujuan Device Binding',
                onTap: () => context.push('/admin/devices'),
              ),
              SizedBox(height: 24.h),
              
              _buildSectionTitle('Pengaturan Absensi'),
              _buildAdminCard(
                icon: Icons.map,
                title: 'Lokasi & Geofence',
                subtitle: 'Atur koordinat pusat absensi',
                onTap: () => context.push('/admin/geofence-settings'),
              ),
              _buildAdminCard(
                icon: Icons.schedule,
                title: 'Shift Kerja & Lembur',
                subtitle: 'Pengaturan jam shift karyawan',
                onTap: () => context.push('/admin/shifts'),
              ),
              SizedBox(height: 24.h),

              _buildSectionTitle('Persetujuan & Laporan'),
              _buildAdminCard(
                icon: Icons.how_to_reg,
                title: 'Konfirmasi Cuti & Izin',
                subtitle: 'Kotak masuk persetujuan',
                onTap: () => context.push('/admin/approvals'),
              ),
              _buildAdminCard(
                icon: Icons.analytics,
                title: 'Laporan Absensi',
                subtitle: 'Laporan kehadiran harian',
                onTap: () => context.push('/admin/attendance-daily'),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAdminCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
