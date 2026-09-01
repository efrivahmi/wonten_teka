import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../attendance/bloc/attendance_cubit.dart';
import '../../../../company/bloc/company_cubit.dart';
import '../../../../schedule/bloc/shift_cubit.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedTabIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceCubit>().loadHistory();
      context.read<CompanyCubit>().loadAll();
      context.read<ShiftCubit>().loadUpcoming();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            context.read<AttendanceCubit>().loadHistory();
            context.read<CompanyCubit>().loadAll();
            context.read<ShiftCubit>().loadUpcoming();
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 24.h),
                      _buildTabs(),
                      SizedBox(height: 24.h),
                      _buildHeroCard(),
                      SizedBox(height: 32.h),
                      _buildFeaturesGrid(context),
                      SizedBox(height: 32.h),
                      _buildPromoSection(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: Colors.white, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Poin',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated && state.user.isAdmin) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.errorCrimson,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'ADMIN',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined, color: AppColors.onSurface),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final userName = state is AuthAuthenticated ? state.user.name.split(' ').first : 'Karyawan';
            return Row(
              children: [
                Icon(Icons.account_circle_outlined, size: 28.sp),
                SizedBox(width: 8.w),
                Text(
                  'Hi, $userName!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            children: [
              _buildTabItem(0, 'Personal'),
              _buildTabItem(1, 'Operasional'),
              _buildTabItem(2, 'Performa'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pastelTeal, AppColors.pastelOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart, color: AppColors.onSurface, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Sisa Cuti Tahunan',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Utama',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Kuota Tersedia',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                '12',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                ' Hari',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fitur pilihan kamu',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/app/all-features'),
              child: Text(
                'Atur',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 16.w,
          runSpacing: 24.h,
          alignment: WrapAlignment.start,
          children: [
            _buildFeatureItem(context, icon: Icons.login, label: 'Absen\nMasuk', color: AppColors.pastelTeal, route: '/app/attendance/check-in'),
            _buildFeatureItem(context, icon: Icons.logout, label: 'Absen\nKeluar', color: AppColors.pastelOrange, route: '/app/attendance/check-out'),
            _buildFeatureItem(context, icon: Icons.event_busy, label: 'Cuti', color: AppColors.pastelBlue, route: '/app/leave'),
            _buildFeatureItem(context, icon: Icons.more_time, label: 'Lembur', color: AppColors.pastelPink, route: '/app/overtime'),
            _buildFeatureItem(context, icon: Icons.history, label: 'Riwayat\nAbsen', color: AppColors.pastelGreen, route: '/app/attendance/history'),
            _buildFeatureItem(context, icon: Icons.receipt_long, label: 'Klaim', color: AppColors.pastelPurple, route: '/app/claims'),
            _buildFeatureItem(context, icon: Icons.payments, label: 'Slip\nGaji', color: AppColors.pastelOrange, route: '/app/payroll/payslips'),
            GestureDetector(
              onTap: () => context.push('/app/all-features'),
              child: SizedBox(
                width: 72.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.grid_view,
                        color: AppColors.onSurface,
                        size: 28.w,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Lihat\nSemua',
                      textAlign: TextAlign.center,
                      maxLines: 2,
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, {required IconData icon, required String label, required Color color, required String route}) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: SizedBox(
        width: 72.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                icon,
                color: AppColors.onSurface,
                size: 28.w,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
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
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Info buat kamu',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPromoCard(
                title: 'Townhall Meeting',
                subtitle: '25 Agustus - 26 Agustus',
                color: AppColors.pastelPurple,
                icon: Icons.campaign,
              ),
              SizedBox(width: 16.w),
              _buildPromoCard(
                title: 'Klaim Medis Baru',
                subtitle: 'Mulai 1 September',
                color: AppColors.pastelTeal,
                icon: Icons.health_and_safety,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard({required String title, required String subtitle, required Color color, required IconData icon}) {
    return Container(
      width: 260.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 48.sp, color: Colors.black.withValues(alpha: 0.2)),
        ],
      ),
    );
  }
}
