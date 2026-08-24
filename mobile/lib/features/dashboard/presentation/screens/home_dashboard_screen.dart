import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../attendance/bloc/attendance_cubit.dart';
import '../../../company/bloc/company_cubit.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceCubit>().loadHistory();
      context.read<CompanyCubit>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: AppColors.primary, size: 28.w),
            SizedBox(width: 8.w),
            Text(
              'Wonten Teka',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final userName = state is AuthAuthenticated ? state.user.name : 'User';
                return InfoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.waving_hand, color: AppColors.primary, size: 28.w),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $userName!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Siap untuk hari yang baru?',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
            SizedBox(height: 16.h),

            // Primary Action: Absensi
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () => context.push('/app/attendance/check-in'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryContainer.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face, size: 20.w),
                    SizedBox(width: 8.w),
                    Text(
                      'Absensi Sekarang',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 14.w, color: AppColors.successEmerald),
                SizedBox(width: 4.w),
                Text(
                  'Di dalam area kantor (Geofence Aktif)',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Quick Stats Bento Grid
            BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, state) {
                String checkInAt = '--:--';
                String checkOutAt = '--:--';
                
                if (state is AttendanceLoaded && state.logs.isNotEmpty) {
                  final todayLog = state.logs.first;
                  checkInAt = DateFormat('HH:mm').format(todayLog.checkInAt);
                  checkOutAt = todayLog.checkOutAt != null ? DateFormat('HH:mm').format(todayLog.checkOutAt!) : '--:--';
                }
                
                return Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        borderLeftColor: AppColors.successEmerald,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHECK-IN',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              checkInAt,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: InfoCard(
                        borderLeftColor: AppColors.surfaceVariant,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CHECK-OUT',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              checkOutAt,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16.h),

            // Working Hours Card
            InfoCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JAM KERJA',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '4j 30m',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryContainer, width: 4.w),
                    ),
                    child: Icon(Icons.schedule, color: AppColors.primaryContainer, size: 20.w),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Announcements
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                'Pengumuman Penting',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            BlocBuilder<CompanyCubit, CompanyState>(
              builder: (context, state) {
                if (state is CompanyLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CompanyLoaded && state.announcements.isNotEmpty) {
                  final announcement = state.announcements.first;
                  return InfoCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.warningAmber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.campaign, color: AppColors.warningAmber, size: 24.w),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                announcement.body,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return InfoCard(
                    child: Center(
                      child: Text('Tidak ada pengumuman hari ini.', style: Theme.of(context).textTheme.bodySmall),
                    ),
                  );
                }
              },
            ),
          ].animate(interval: 50.ms).fade(duration: 300.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }
}
