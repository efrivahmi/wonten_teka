import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../attendance/bloc/attendance_cubit.dart';
import '../../../../company/bloc/company_cubit.dart';
import '../../../../schedule/bloc/shift_cubit.dart';
import '../../../../../core/models/attendance_log_model.dart';
import '../../../../../core/models/shift_models.dart';
import '../../../../../core/widgets/main_sidebar_drawer.dart';
import '../../widgets/dashboard_calendar.dart';
import '../../widgets/dashboard_carousel.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

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
      context.read<ShiftCubit>().loadUpcoming();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      drawer: const MainSidebarDrawer(),
      body: Stack(
        children: [
          // Background Header
          Container(
            height: 260.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
          
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              displacement: 20.0,
              onRefresh: () async {
                context.read<AttendanceCubit>().loadHistory();
                context.read<CompanyCubit>().loadAll();
                context.read<ShiftCubit>().loadUpcoming();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // App Bar Area
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Builder(
                                builder: (context) => IconButton(
                                  icon: const Icon(Icons.menu, color: Colors.white),
                                  onPressed: () => Scaffold.of(context).openDrawer(),
                                ),
                              ),
                              Text(
                                'Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is AuthAuthenticated && state.user.isAdmin) {
                                    return IconButton(
                                      icon: Icon(Icons.admin_panel_settings, color: Colors.white, size: 24.w),
                                      onPressed: () => context.push('/admin/dashboard'),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.notifications_none, color: Colors.white, size: 24.w),
                                onPressed: () => context.push('/app/notifications'),
                              ),
                              SizedBox(width: 4.w),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final userName = state is AuthAuthenticated
                                      ? (state.user.employee?.fullName ?? state.user.name)
                                      : 'U';
                                  return CircleAvatar(
                                    radius: 16.w,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    child: Text(
                                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                      style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Area
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DashboardCarousel(),
                          SizedBox(height: 16.h),
                          // 1. Floating Contextual Attendance Card
                          BlocBuilder<AttendanceCubit, AttendanceState>(
                            builder: (context, state) {
                              bool hasCheckedIn = false;
                              bool hasCheckedOut = false;
                              DateTime? checkInTime;
                              DateTime? checkOutTime;
                              AttendanceLogModel? todayLog;
                              
                              if (state is AttendanceLoaded && state.logs.isNotEmpty) {
                                todayLog = state.logs.first;
                              } else if (state is CheckInSuccess) {
                                todayLog = state.log;
                              } else if (state is CheckOutSuccess) {
                                todayLog = state.log;
                              }

                              if (todayLog != null) {
                                final now = DateTime.now();
                                if (todayLog.checkInAt.year == now.year &&
                                    todayLog.checkInAt.month == now.month &&
                                    todayLog.checkInAt.day == now.day) {
                                  hasCheckedIn = true;
                                  checkInTime = todayLog.checkInAt;
                                  hasCheckedOut = todayLog.checkOutAt != null;
                                  checkOutTime = todayLog.checkOutAt;
                                }
                              }

                              String titleText = 'Status Kehadiran';
                              String bigText = '--:--';
                              String stat1Val = '--:--';
                              String stat2Val = '--:--';
                              String stat3Val = 'Belum';
                              Widget actionButton = const SizedBox.shrink();

                              if (!hasCheckedIn) {
                                titleText = 'Absen Hari Ini';
                                bigText = 'Belum Absen';
                                actionButton = Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 48.h,
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.push('/app/attendance/check-in'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.fingerprint),
                                      label: const Text('Absen Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              } else if (hasCheckedIn && !hasCheckedOut) {
                                titleText = 'Waktu Masuk';
                                bigText = DateFormat('HH:mm').format(checkInTime!);
                                stat1Val = bigText;
                                stat3Val = 'Bekerja';
                                actionButton = Padding(
                                  padding: EdgeInsets.only(top: 20.h),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 48.h,
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.push('/app/attendance/check-out'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.exit_to_app),
                                      label: const Text('Absen Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              } else {
                                titleText = 'Total Jam Kerja';
                                final duration = checkOutTime!.difference(checkInTime!);
                                final hours = duration.inHours;
                                final minutes = duration.inMinutes % 60;
                                bigText = '${hours}h ${minutes}m';
                                stat1Val = DateFormat('HH:mm').format(checkInTime);
                                stat2Val = DateFormat('HH:mm').format(checkOutTime);
                                stat3Val = 'Selesai';
                              }

                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(24.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      titleText,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13.sp, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      bigText,
                                      style: TextStyle(color: AppColors.primary, fontSize: 36.sp, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                                    ),
                                    SizedBox(height: 24.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatColumn('Masuk', stat1Val),
                                        _buildStatColumn('Keluar', stat2Val),
                                        _buildStatColumn('Status', stat3Val),
                                      ],
                                    ),
                                    actionButton,
                                  ],
                                ),
                              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
                            },
                          ),
                          
                          SizedBox(height: 24.h),
                          
                          // 2. Second Card (e.g. Live Queries in design -> We can put "Jadwal & Info" or a chart here)
                          // For now, let's make a beautiful solid primary-container card representing 'Shift Hari Ini'
                          BlocBuilder<ShiftCubit, ShiftState>(
                            builder: (context, state) {
                              ShiftAssignmentModel? todayShift;
                              if (state is ShiftLoaded) {
                                final now = DateTime.now();
                                try {
                                  todayShift = state.shifts.firstWhere((s) =>
                                      s.date.year == now.year &&
                                      s.date.month == now.month &&
                                      s.date.day == now.day);
                                } catch (_) {}
                              }
                              
                              String timeText = '--:-- - --:--';
                              String shiftName = 'Memuat jadwal...';
                              
                              if (state is ShiftLoaded) {
                                if (todayShift != null) {
                                  shiftName = todayShift.shiftTemplate?.name ?? 'Libur';
                                  if (todayShift.shiftTemplate?.startTime != null && todayShift.shiftTemplate?.endTime != null) {
                                    final startF = DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(todayShift.shiftTemplate!.startTime!));
                                    final endF = DateFormat('HH:mm').format(DateFormat('HH:mm:ss').parse(todayShift.shiftTemplate!.endTime!));
                                    timeText = '$startF - $endF';
                                  } else {
                                    timeText = 'Libur';
                                  }
                                } else {
                                  shiftName = 'Tidak ada shift';
                                  timeText = 'Libur';
                                }
                              } else if (state is ShiftError) {
                                shiftName = 'Gagal memuat';
                                timeText = 'Error';
                              }

                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Jadwal Shift', style: TextStyle(color: Colors.white70, fontSize: 13.sp)),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8.r)),
                                          child: Text('HARI INI', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      timeText,
                                      style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      shiftName,
                                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.white70, size: 16.w),
                                        SizedBox(width: 4.w),
                                        Text('Geofence Aktif', style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                                        SizedBox(width: 16.w),
                                        Icon(Icons.verified_user, color: Colors.white70, size: 16.w),
                                        SizedBox(width: 4.w),
                                        Text('Perangkat Valid', style: TextStyle(color: Colors.white, fontSize: 11.sp)),
                                      ],
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
                            },
                          ),
                          
                          SizedBox(height: 24.h),

                          // 3. Kalender (Dashboard Calendar)
                          BlocBuilder<CompanyCubit, CompanyState>(
                            builder: (context, state) {
                              if (state is CompanyLoaded) {
                                return DashboardCalendar(
                                  workingDays: state.workingDays,
                                  events: state.calendarEvents,
                                  onDateSelected: (date) {
                                    // Buka modal/dialog untuk event list jika ada
                                  },
                                ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          
                          SizedBox(height: 24.h),

                          // 4. Menu Utama (Grid) - matching the 'Statistics' white card area
                          Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Menu Utama',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                SizedBox(height: 16.h),
                                GridView.count(
                                  crossAxisCount: 4,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 16.h,
                                  crossAxisSpacing: 16.w,
                                  childAspectRatio: 0.85,
                                  children: [
                                    _GridMenuIcon(
                                      icon: Icons.beach_access_rounded,
                                      label: 'Cuti',
                                      color: AppColors.primary,
                                      onTap: () => context.push('/app/leave'),
                                    ),
                                    _GridMenuIcon(
                                      icon: Icons.access_time_filled,
                                      label: 'Lembur',
                                      color: AppColors.primary,
                                      onTap: () => context.push('/app/overtime'),
                                    ),
                                    _GridMenuIcon(
                                      icon: Icons.receipt_long_rounded,
                                      label: 'Klaim',
                                      color: AppColors.primary,
                                      onTap: () => context.push('/app/claims'),
                                    ),
                                    _GridMenuIcon(
                                      icon: Icons.payment_rounded,
                                      label: 'Slip Gaji',
                                      color: AppColors.primary,
                                      onTap: () => context.push('/app/payslip'),
                                    ),
                                    _GridMenuIcon(
                                      icon: Icons.calendar_month_rounded,
                                      label: 'Jadwal',
                                      color: AppColors.primary,
                                      onTap: () => context.push('/app/schedule/shifts'),
                                    ),
                                    _GridMenuIcon(
                                      icon: Icons.business_rounded,
                                      label: 'Karyawan',
                                      color: AppColors.primary,
                                      onTap: () => context.push('/app/directory'),
                                    ),
                                    _GridMenuIcon(
                                      icon: Icons.fact_check_rounded,
                                      label: 'Approval',
                                      color: AppColors.primary,
                                      onTap: () => context.push('/admin/approvals'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0),
                          
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GridMenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GridMenuIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.w),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
