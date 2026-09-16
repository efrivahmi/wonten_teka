import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../widgets/admin_dashboard_calendar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<dynamic> _stats;
  @override
  void initState() {
    super.initState();
    _stats = context.read<ApiClient>().get('/admin/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final userName = user?.name ?? 'Admin';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerScrolled) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260.h,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                title: innerScrolled
                    ? const AppBrandTitle(section: 'Panel admin', inverse: true)
                    : null,
                actions: [
                  IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () => context.push('/app/notifications')),
                  IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () =>
                          context.read<AuthBloc>().add(AuthLogoutRequested())),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 88, 16, 16),
                    child: BrandPanel(
                        child: Align(
                      alignment: Alignment.bottomLeft,
                      child: ViewEntrance(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('PUSAT KENDALI',
                                style: TextStyle(
                                    color: AppColors.primaryFixed,
                                    fontSize: 11.sp,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text('Halo, $userName',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            const Text('Tim terhubung. Kehadiran terpantau.',
                                style: TextStyle(color: Colors.white)),
                          ])),
                    )),
                  ),
                ),
              ),
            ],
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ViewEntrance(child: _buildQuickStats(context)),
                  SizedBox(height: 24.h),

                  // 2. Admin Features Grid
                  // 2. Admin Features Grids (Categorized)
                  _buildSectionHeader('Kepegawaian'),
                  SizedBox(height: 12.h),
                  ViewEntrance(
                      delay: const Duration(milliseconds: 80),
                      child: _buildKepegawaianGrid(context)),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Kehadiran & Jadwal'),
                  SizedBox(height: 12.h),
                  ViewEntrance(
                      delay: const Duration(milliseconds: 140),
                      child: _buildKehadiranGrid(context)),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Penggajian'),
                  SizedBox(height: 12.h),
                  ViewEntrance(
                      delay: const Duration(milliseconds: 200),
                      child: _buildPayrollGrid(context)),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Komunikasi & Informasi'),
                  SizedBox(height: 12.h),
                  ViewEntrance(
                      delay: const Duration(milliseconds: 260),
                      child: _buildKomunikasiGrid(context)),
                  SizedBox(height: 24.h),

                  _buildSectionHeader('Sistem & Data'),
                  SizedBox(height: 12.h),
                  ViewEntrance(
                      delay: const Duration(milliseconds: 320),
                      child: _buildSistemGrid(context)),
                  SizedBox(height: 24.h),

                  // 3. Admin Calendar Monitoring
                  Text(
                    'Kalender Kehadiran & Libur',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface),
                  ),
                  SizedBox(height: 16.h),
                  const ViewEntrance(
                      delay: Duration(milliseconds: 380),
                      child: AdminDashboardCalendar()),
                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _stats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            color: AppColors.surface,
            child: Column(children: [
              const Text('Ringkasan belum dapat dimuat.'),
              TextButton(
                  onPressed: () => setState(() {
                        _stats =
                            context.read<ApiClient>().get('/admin/dashboard');
                      }),
                  child: const Text('Coba lagi'))
            ]),
          );
        }
        final payload = snapshot.data!.data as Map<String, dynamic>;
        return _buildQuickStatsContent(
          context,
          payload['data'] as Map<String, dynamic>? ?? const {},
        );
      },
    );
  }

  Widget _buildQuickStatsContent(
      BuildContext context, Map<String, dynamic> stats) {
    final attendance =
        stats['attendance_today'] as Map<String, dynamic>? ?? const {};
    final departments = (stats['department_attendance'] as List? ?? const [])
        .whereType<Map>()
        .toList();
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ringkasan Hari Ini',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                      color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
            ],
          ),
          if (departments.isNotEmpty) ...[
            SizedBox(height: 24.h),
            const Divider(),
            SizedBox(height: 12.h),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Kehadiran per departemen',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14.sp))),
            SizedBox(height: 14.h),
            ...departments.map((item) {
              final rate = ((item['attendance_rate'] as num?) ?? 0).toDouble();
              return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                          child: Text(
                              item['department']?.toString() ??
                                  'Tanpa departemen',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600))),
                      Text('${rate.toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800))
                    ]),
                    SizedBox(height: 6.h),
                    TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: rate / 100),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => LinearProgressIndicator(
                            value: value.clamp(0, 1),
                            minHeight: 9.h,
                            borderRadius: BorderRadius.circular(8.r),
                            backgroundColor: AppColors.surfaceContainerHigh,
                            color: AppColors.primary)),
                  ]));
            }),
          ],
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Hadir', '${attendance['present'] ?? 0}',
                  AppColors.successEmerald, Icons.how_to_reg),
              _buildStatItem('Alpha', '${attendance['absent'] ?? 0}',
                  AppColors.errorCrimson, Icons.person_off),
              _buildStatItem('Cuti/Sakit', '${attendance['on_leave'] ?? 0}',
                  AppColors.warningAmber, Icons.sick),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28.w),
        ),
        SizedBox(height: 8.h),
        Text(value,
            style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface)),
        Text(label,
            style:
                TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4.r)),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface),
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
        _buildActionCard(context, 'Data Karyawan', Icons.people,
            () => context.push('/admin/employees')),
        _buildActionCard(context, 'Persetujuan', Icons.fact_check,
            () => context.push('/admin/approvals')),
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
        _buildActionCard(context, 'Laporan Harian', Icons.event_note,
            () => context.push('/admin/attendance-daily')),
        _buildActionCard(context, 'Rekap Absen', Icons.summarize,
            () => context.push('/admin/reports')),
        _buildActionCard(context, 'Deteksi Fake GPS', Icons.gps_off,
            () => context.push('/admin/attendance-security-events')),
        _buildActionCard(context, 'Template Shift', Icons.event_available,
            () => context.push('/admin/shifts')),
        _buildActionCard(context, 'Penugasan Shift', Icons.assignment_ind,
            () => context.push('/admin/shift-assignments')),
      ],
    );
  }

  Widget _buildPayrollGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildActionCard(context, 'Konfigurasi', Icons.request_quote,
            () => context.push('/admin/payroll-config')),
        _buildActionCard(context, 'Proses Penggajian', Icons.point_of_sale,
            () => context.push('/admin/payroll')),
      ],
    );
  }

  Widget _buildKomunikasiGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildActionCard(context, 'Kalender Acara', Icons.event,
            () => context.push('/admin/events')),
        _buildActionCard(context, 'Buat Pengumuman', Icons.campaign,
            () => context.push('/admin/announcements/new')),
      ],
    );
  }

  Widget _buildSistemGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildActionCard(context, 'Tipe Cuti', Icons.flight_takeoff,
            () => context.push('/admin/leave-types')),
        _buildActionCard(context, 'Sistem Organisasi', Icons.settings,
            () => context.push('/admin/org-settings')),
        _buildActionCard(context, 'Export Data', Icons.download,
            () => context.push('/admin/export')),
        _buildActionCard(context, 'Audit Logs', Icons.history,
            () => context.push('/admin/audit-logs')),
        _buildActionCard(context, 'Perangkat', Icons.phonelink_lock,
            () => context.push('/admin/devices')),
        _buildActionCard(context, 'Pengaturan Admin', Icons.manage_accounts,
            () => context.push('/admin/settings')),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
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
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 26.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
