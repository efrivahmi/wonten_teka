import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/bloc/auth_bloc.dart';
import '../../../../attendance/bloc/attendance_cubit.dart';
import '../../../../company/bloc/company_cubit.dart';
import '../../../../schedule/bloc/shift_cubit.dart';
import '../../../../schedule/bloc/task_cubit.dart';
import 'package:intl/intl.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/repositories/attendance_repository.dart';
import '../../../../../core/widgets/app_brand_title.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _todayInfo;
  bool _loadingTodayInfo = true;
  String? _todayInfoError;

  @override
  void initState() {
    super.initState();
    _loadTodayInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AttendanceCubit>().loadHistory();
      context.read<CompanyCubit>().loadAll();
      context.read<ShiftCubit>().loadUpcoming();
      context
          .read<TaskCubit>()
          .loadTasksByDate(DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
  }

  Future<void> _loadTodayInfo() async {
    if (mounted) {
      setState(() {
        _loadingTodayInfo = true;
        _todayInfoError = null;
      });
    }
    try {
      final info = await context.read<AttendanceRepository>().getTodayInfo();
      if (mounted) setState(() => _todayInfo = info);
    } catch (_) {
      if (mounted) {
        setState(() => _todayInfoError = 'Jadwal belum dapat dimuat.');
      }
    } finally {
      if (mounted) setState(() => _loadingTodayInfo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            context.read<AttendanceCubit>().loadHistory();
            context.read<CompanyCubit>().loadAll();
            context.read<ShiftCubit>().loadUpcoming();
            context.read<TaskCubit>().loadTasksByDate(
                DateFormat('yyyy-MM-dd').format(_selectedDate));
            await _loadTodayInfo();
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                  pinned: true,
                  title: const AppBrandTitle(section: 'Ruang kerja karyawan'),
                  actions: [
                    IconButton(
                        tooltip: 'Notifikasi',
                        onPressed: () => context.push('/app/notifications'),
                        icon: const Icon(Icons.notifications_none_rounded))
                  ]),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ViewEntrance(child: _buildHeroCard(context)),
                      SizedBox(height: 24.h),
                      ViewEntrance(
                        delay: const Duration(milliseconds: 90),
                        child: _buildPromoSection(),
                      ),
                      SizedBox(height: 24.h),
                      ViewEntrance(
                        delay: const Duration(milliseconds: 140),
                        child: _buildTodayAttendanceSection(context),
                      ),
                      if (_hasAdditionalSchedule) ...[
                        SizedBox(height: 24.h),
                        ViewEntrance(
                          delay: const Duration(milliseconds: 170),
                          child: _buildAdditionalScheduleSection(),
                        ),
                      ],
                      SizedBox(height: 24.h),
                      ViewEntrance(
                        delay: const Duration(milliseconds: 190),
                        child: _buildWorkScheduleSection(context),
                      ),
                      SizedBox(height: 24.h),
                      ViewEntrance(
                        delay: const Duration(milliseconds: 240),
                        child: _buildMonthlyStatsSection(),
                      ),
                      SizedBox(height: 24.h),
                      ViewEntrance(
                        delay: const Duration(milliseconds: 290),
                        child: _buildFeaturesGrid(context),
                      ),
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

  bool get _hasAdditionalSchedule {
    final shifts = _todayInfo?['shifts'] as List? ?? const [];
    final overtime = _todayInfo?['overtime_today'] as List? ?? const [];
    return (_todayInfo?['has_double_shift'] == true || shifts.length > 1) ||
        overtime.isNotEmpty;
  }

  Widget _buildAdditionalScheduleSection() {
    final shifts = (_todayInfo?['shifts'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final overtime = (_todayInfo?['overtime_today'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    final hasDoubleShift =
        _todayInfo?['has_double_shift'] == true || shifts.length > 1;

    Widget notice({
      required Color color,
      required IconData icon,
      required String eyebrow,
      required String title,
      required String detail,
    }) =>
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withValues(alpha: .25)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(14.r)),
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eyebrow,
                        style: TextStyle(
                            color: color,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1)),
                    SizedBox(height: 3.h),
                    Text(title,
                        style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 5.h),
                    Text(detail,
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11.sp)),
                  ]),
            ),
          ]),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Jadwal Tambahan Hari Ini',
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface)),
      SizedBox(height: 4.h),
      Text('Penugasan khusus dari admin sebelum Anda melakukan absensi.',
          style: TextStyle(fontSize: 11.sp, color: AppColors.onSurfaceVariant)),
      SizedBox(height: 14.h),
      if (hasDoubleShift)
        notice(
          color: Colors.deepPurple,
          icon: Icons.layers_rounded,
          eyebrow: 'SHIFT GANDA',
          title: '${shifts.length} shift hari ini',
          detail: shifts
              .map((shift) =>
                  '${shift['name']} ${shift['start_time']}–${shift['end_time']}')
              .join(' • '),
        ),
      for (final item in overtime)
        notice(
          color: Colors.deepOrange,
          icon: Icons.more_time_rounded,
          eyebrow: 'LEMBUR DISETUJUI',
          title:
              '${item['start_time']?.toString().substring(0, 5) ?? '--:--'}–${item['end_time']?.toString().substring(0, 5) ?? '--:--'}',
          detail:
              '${item['overtime_type'] ?? 'Lembur'}${item['reason'] == null || item['reason'].toString().isEmpty ? '' : ' • ${item['reason']}'}',
        ),
    ]);
  }

  Widget _buildWorkScheduleSection(BuildContext context) {
    final shifts = (_todayInfo?['shifts'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: .045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jadwal Kerja',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface)),
                    Text('Shift default dan penugasan hari ini',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/app/schedule/shifts'),
                child: const Text('Semua'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            child: _loadingTodayInfo
                ? _buildScheduleLoading()
                : _todayInfoError != null
                    ? _buildScheduleMessage(
                        icon: Icons.cloud_off_rounded,
                        message: _todayInfoError!,
                        action: 'Muat ulang',
                        onTap: _loadTodayInfo,
                      )
                    : shifts.isEmpty
                        ? _buildScheduleMessage(
                            icon: Icons.event_busy_rounded,
                            message: 'Tidak ada shift yang terdaftar hari ini.',
                          )
                        : Column(
                            key: ValueKey(shifts.length),
                            children: [
                              for (var index = 0;
                                  index < shifts.length;
                                  index++)
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: index == shifts.length - 1
                                          ? 0
                                          : 12.h),
                                  child: ViewEntrance(
                                    delay: Duration(milliseconds: 70 * index),
                                    offset: 8,
                                    child: _buildShiftCard(shifts[index]),
                                  ),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleLoading() => Container(
        key: const ValueKey('schedule-loading'),
        height: 104.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget _buildScheduleMessage({
    required IconData icon,
    required String message,
    String? action,
    VoidCallback? onTap,
  }) =>
      Container(
        key: ValueKey(message),
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant),
            SizedBox(height: 8.h),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
            if (action != null) ...[
              SizedBox(height: 6.h),
              TextButton(onPressed: onTap, child: Text(action)),
            ],
          ],
        ),
      );

  Widget _buildShiftCard(Map<String, dynamic> shift) {
    final isDefault =
        shift['is_default_schedule'] == true || shift['is_default'] == true;
    final isRecurring = shift['is_recurring_schedule'] == true;
    final assignmentId = shift['assignment_id'];
    final badge = isDefault
        ? 'SHIFT DEFAULT'
        : isRecurring
            ? 'JADWAL BERULANG'
            : assignmentId != null
                ? 'PENUGASAN'
                : 'SHIFT LAINNYA';
    final start = _shortTime(shift['start_time']);
    final end = _shortTime(shift['end_time']);
    final attendance = shift['attendance'] is Map
        ? Map<String, dynamic>.from(shift['attendance'] as Map)
        : null;
    final status = _attendanceLabel(attendance, shift['time_status_label']);
    final statusColor = _attendanceColor(attendance, shift['time_status']);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDefault
              ? AppColors.primary.withValues(alpha: .25)
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isDefault ? AppColors.primary : AppColors.onSurface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Icon(Icons.schedule_rounded, color: Colors.white),
          ),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(shift['name']?.toString() ?? 'Jadwal kerja',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface)),
                    _scheduleBadge(badge,
                        isDefault ? AppColors.primary : AppColors.secondary),
                  ],
                ),
                SizedBox(height: 7.h),
                Text('$start — $end  •  ${_shiftDuration(start, end)}',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant)),
                SizedBox(height: 9.h),
                Row(
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                          color: statusColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Text(status,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700)),
                    ),
                    if (shift['category'] != null)
                      Text(shift['category'].toString().toUpperCase(),
                          style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .6)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleBadge(String label, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 8.sp, fontWeight: FontWeight.w800, color: color)),
      );

  String _shortTime(dynamic value) {
    final text = value?.toString() ?? '--:--';
    return text.length >= 5 ? text.substring(0, 5) : text;
  }

  String _shiftDuration(String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    if (startParts.length < 2 || endParts.length < 2) return 'Durasi -';
    final startMinutes = (int.tryParse(startParts[0]) ?? 0) * 60 +
        (int.tryParse(startParts[1]) ?? 0);
    var endMinutes = (int.tryParse(endParts[0]) ?? 0) * 60 +
        (int.tryParse(endParts[1]) ?? 0);
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    final minutes = endMinutes - startMinutes;
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours jam' : '$hours jam $rest menit';
  }

  String _attendanceLabel(Map<String, dynamic>? attendance, dynamic fallback) {
    if (attendance == null) return fallback?.toString() ?? 'Belum absen';
    if (_isAbsentAttendance(attendance)) return 'Tidak hadir / Alpha';
    if (attendance['check_out_time'] != null) return 'Absensi selesai';
    if (attendance['check_in_time'] != null) return 'Sudah absen masuk';
    return fallback?.toString() ?? 'Belum absen';
  }

  Color _attendanceColor(Map<String, dynamic>? attendance, dynamic timeStatus) {
    if (_isAbsentAttendance(attendance)) return AppColors.errorCrimson;
    final status = attendance?['status']?.toString().toLowerCase();
    if (status == 'late' || status == 'terlambat') {
      return AppColors.warningAmber;
    }
    if (attendance?['check_in_time'] != null) return AppColors.successEmerald;
    if (timeStatus?.toString() == 'active') return AppColors.primary;
    return AppColors.onSurfaceVariant;
  }

  Widget _buildHeroCard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      final user = state is AuthAuthenticated ? state.user : null;
      final employee = user?.employee;
      return BrandPanel(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee?.fullName ?? user?.name ?? 'Karyawan',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 5.h),
                  Text(
                    '${employee?.position ?? 'Posisi belum diatur'} • ${employee?.department ?? 'Unit belum diatur'}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: .86),
                        fontSize: 12.sp),
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: () => context.push('/app/profile'),
                    child: Text('Lihat profil lengkap  →',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTodayAttendanceSection(BuildContext context) {
    final shifts = _todayInfo?['shifts'] as List? ?? const [];
    final attendance = shifts
        .map((shift) => shift['attendance'])
        .whereType<Map>()
        .cast<Map<dynamic, dynamic>>()
        .firstOrNull;
    final status = _isAbsentAttendance(attendance)
        ? 'absent'
        : attendance?['status']?.toString() ?? 'not_started';
    final checkIn = _formatAttendanceTime(attendance?['check_in_time'], status);
    final checkOut =
        _formatAttendanceTime(attendance?['check_out_time'], status);
    final duration = _workDuration(attendance);
    final statusColor = _attendanceColor(attendance?.cast<String, dynamic>(),
        shifts.firstOrNull?['time_status']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Pencatatan Absensi Hari Ini',
            'Status dan durasi kerja diperbarui dari data absensi.'),
        SizedBox(height: 14.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.65,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          children: [
            _summaryTile('Status', _statusLabel(status), Icons.verified_rounded,
                statusColor),
            _summaryTile('Durasi kerja', duration, Icons.timelapse_rounded,
                AppColors.infoCerulean),
            _summaryTile(
                'Jam masuk', checkIn, Icons.login_rounded, AppColors.primary),
            _summaryTile('Jam keluar', checkOut, Icons.logout_rounded,
                AppColors.errorCrimson),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildAttendanceButton(
                context,
                title: 'Absen Masuk',
                icon: Icons.login,
                color: _canCheckIn() ? AppColors.successEmerald : Colors.grey,
                onTap: _canCheckIn()
                    ? () => context
                        .push('/app/attendance/check-in')
                        .then((_) => _loadTodayInfo())
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildAttendanceButton(
                context,
                title: 'Absen Keluar',
                icon: Icons.logout,
                color: _canCheckOut() ? AppColors.errorCrimson : Colors.grey,
                onTap: _canCheckOut()
                    ? () => context
                        .push('/app/attendance/check-out')
                        .then((_) => _loadTodayInfo())
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyStatsSection() {
    final stats = _todayInfo?['monthly_stats'] as Map? ?? const {};
    final present = (stats['present_days'] as num?)?.toInt() ??
        ((stats['on_time'] as num? ?? 0).toInt() +
            (stats['grace_period'] as num? ?? 0).toInt() +
            (stats['late'] as num? ?? 0).toInt());
    final daysInMonth = stats['days_in_month'] ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
            'Statistik Kehadiran ${stats['month_label'] ?? 'Bulan Ini'}',
            'Dihitung ulang dari nol setiap awal bulan. Bulan ini memiliki $daysInMonth hari kalender.'),
        SizedBox(height: 14.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.55,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          children: [
            _summaryTile(
                'Kehadiran bulan ini',
                '$present dari $daysInMonth hari',
                Icons.calendar_month_rounded,
                AppColors.primary),
            _summaryTile('Tepat waktu', '${stats['on_time'] ?? 0} hari',
                Icons.check_circle_rounded, AppColors.successEmerald),
            _summaryTile('Terlambat', '${stats['late'] ?? 0} hari',
                Icons.schedule_rounded, AppColors.warningAmber),
            _summaryTile('Alpha', '${stats['absent'] ?? 0} hari',
                Icons.cancel_rounded, AppColors.errorCrimson),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface)),
          SizedBox(height: 3.h),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 11.sp, color: AppColors.onSurfaceVariant)),
        ],
      );

  Widget _summaryTile(String label, String value, IconData icon, Color color) =>
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22.sp),
            Text(value,
                style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 10.sp)),
          ],
        ),
      );

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'on_time':
      case 'present':
        return 'Tepat waktu';
      case 'late':
        return 'Terlambat';
      case 'absent':
      case 'alpha':
        return 'Alpha';
      default:
        return 'Belum absen';
    }
  }

  String _formatAttendanceTime(dynamic value, String status) {
    if (value == null ||
        status.toLowerCase() == 'absent' ||
        status.toLowerCase() == 'alpha') {
      return '--:--';
    }
    return DateFormat('HH:mm')
        .format(DateTime.parse(value.toString()).toLocal());
  }

  String _workDuration(Map<dynamic, dynamic>? attendance) {
    if (attendance == null || _isAbsentAttendance(attendance)) return '0j 0m';
    final startValue = attendance['check_in_time'];
    if (startValue == null) return '0j 0m';
    final start = DateTime.parse(startValue.toString()).toLocal();
    final endValue = attendance['check_out_time'];
    final end = endValue == null
        ? DateTime.now()
        : DateTime.parse(endValue.toString()).toLocal();
    final minutes = end.difference(start).inMinutes.clamp(0, 24 * 60);
    return '${minutes ~/ 60}j ${minutes % 60}m';
  }

  bool _canCheckIn() {
    if (_todayInfo == null) return false;
    final shifts = _todayInfo!['shifts'] as List? ?? [];
    return shifts
        .any((s) => s['attendance'] == null && s['time_status'] != 'ended');
  }

  bool _canCheckOut() {
    if (_todayInfo == null) return false;
    final shifts = _todayInfo!['shifts'] as List? ?? [];
    return shifts.any((shift) {
      final rawAttendance = shift['attendance'];
      if (rawAttendance is! Map) return false;
      final attendance = Map<String, dynamic>.from(rawAttendance);
      return !_isAbsentAttendance(attendance) &&
          attendance['check_in_time'] != null &&
          shift['time_status'] == 'ended' &&
          attendance['check_out_time'] == null;
    });
  }

  bool _isAbsentAttendance(Map<dynamic, dynamic>? attendance) {
    if (attendance == null) return false;
    final status = attendance['status']?.toString().toLowerCase();
    return status == 'absent' ||
        status == 'alpha' ||
        attendance['is_auto_absent'] == true ||
        (attendance['flags'] is Map &&
            attendance['flags']['auto_absent'] == true);
  }

  Widget _buildAttendanceButton(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
              'Akses Cepat',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/app/all-features'),
              child: const Text(
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
            _buildFeatureItem(context,
                icon: Icons.event_busy,
                label: 'Cuti',
                color: AppColors.primaryContainer,
                route: '/app/leave'),
            _buildFeatureItem(context,
                icon: Icons.flight_takeoff,
                label: 'Dinas Luar',
                color: AppColors.secondaryContainer,
                route: '/app/attendance/business-trip-form'),
            _buildFeatureItem(context,
                icon: Icons.edit_calendar,
                label: 'Lupa Absen',
                color: AppColors.tertiaryContainer,
                route: '/app/attendance/adjustment-form'),
            _buildFeatureItem(context,
                icon: Icons.history,
                label: 'Riwayat',
                color: AppColors.primaryFixedDim,
                route: '/app/attendance'),
            _buildFeatureItem(context,
                icon: Icons.receipt_long,
                label: 'Klaim',
                color: AppColors.secondaryContainer,
                route: '/app/claims'),
            _buildFeatureItem(context,
                icon: Icons.payments,
                label: 'Slip\nGaji',
                color: AppColors.primaryContainer,
                route: '/app/payslip'),
            _buildFeatureItem(context,
                icon: Icons.schedule,
                label: 'Jadwal',
                color: AppColors.tertiaryContainer,
                route: '/app/schedule/shifts'),
            _buildFeatureItem(context,
                icon: Icons.track_changes_rounded,
                label: 'Habit',
                color: AppColors.secondaryContainer,
                route: '/app/habits'),
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

  Widget _buildFeatureItem(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required String route}) {
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
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 26.w,
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
              'Pengumuman Terbaru',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        BlocBuilder<CompanyCubit, CompanyState>(
          builder: (context, state) {
            if (state is CompanyLoaded && state.announcements.isNotEmpty) {
              return Column(
                children: state.announcements.take(3).map((announcement) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildPromoCard(
                      title: announcement.title,
                      subtitle: DateFormat('dd MMM yyyy')
                          .format(announcement.createdAt ?? DateTime.now()),
                      color: announcement.priority == 'high'
                          ? AppColors.errorContainer
                          : AppColors.primaryFixedDim,
                      icon: Icons.campaign,
                    ),
                  );
                }).toList(),
              );
            }
            return Center(
              child: Text(
                'Belum ada pengumuman.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPromoCard(
      {required String title,
      required String subtitle,
      required Color color,
      required IconData icon,
      VoidCallback? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 132.h),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: 10.sp, fontWeight: FontWeight.bold),
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
              Icon(icon,
                  size: 48.sp, color: Colors.black.withValues(alpha: 0.2)),
            ],
          ),
        ));
  }

  // Kept for the dedicated task feature; intentionally omitted from dashboard.
  // ignore: unused_element
  Widget _buildTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tugas Saya',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => _showAddTaskDialog(context),
              child: const Text(
                'Catat Tugas Baru',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildWeeklyCalendar(),
        SizedBox(height: 16.h),
        BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              if (state.tasks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: const Text('Tidak ada tugas di hari ini.',
                        style: TextStyle(color: Colors.grey)),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    color: AppColors.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: !task.isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          context.read<TaskCubit>().toggleTask(
                              task.id,
                              !task.isActive,
                              DateFormat('yyyy-MM-dd').format(_selectedDate));
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: !task.isActive
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: task.reminderTime != null
                          ? Text('Jam: ${task.reminderTime!.substring(0, 5)}')
                          : null,
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          context.read<TaskCubit>().deleteTask(task.id,
                              DateFormat('yyyy-MM-dd').format(_selectedDate));
                        },
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return SizedBox(
      height: 70.h,
      child: BlocBuilder<CompanyCubit, CompanyState>(builder: (context, state) {
        final logs = state is CompanyLoaded
            ? state.attendanceLogs
            : <Map<String, dynamic>>[];

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 14,
          itemBuilder: (context, index) {
            final date = firstDayOfWeek.add(Duration(days: index));
            final isSelected = date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;

            // Check if attended on this date
            final dateString = DateFormat('yyyy-MM-dd').format(date);
            final hasAttended = logs.any((log) {
              if (log['check_in_time'] == null) return false;
              return log['check_in_time'].toString().startsWith(dateString);
            });

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                context.read<TaskCubit>().loadTasksByDate(dateString);
              },
              child: Container(
                width: 50.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (hasAttended
                              ? AppColors.successEmerald
                              : Colors.grey[300]!)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date).substring(0, 3),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (hasAttended
                                ? AppColors.successEmerald
                                : Colors.grey[600]),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                top: 24.h,
                left: 24.w,
                right: 24.w,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catat Tugas Baru',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul Tugas / Kegiatan',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Keterangan (Opsional)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(selectedTime == null
                        ? 'Pilih Jam Pengingat (Opsional)'
                        : 'Pengingat: ${selectedTime!.format(context)}'),
                    trailing: const Icon(Icons.alarm),
                    onTap: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: () {
                        if (titleController.text.isEmpty) return;
                        final reminderStr = selectedTime != null
                            ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                            : null;

                        context.read<TaskCubit>().addTask(
                              titleController.text,
                              descController.text,
                              DateFormat('yyyy-MM-dd').format(_selectedDate),
                              reminderStr,
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Simpan Tugas',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
