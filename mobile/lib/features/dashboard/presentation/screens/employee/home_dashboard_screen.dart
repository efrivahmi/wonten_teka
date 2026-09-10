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

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _todayInfo;

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
    try {
      final info = await context.read<AttendanceRepository>().getTodayInfo();
      if (mounted) setState(() => _todayInfo = info);
    } catch (_) {}
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
                  title: const Text('Ruang kerja'),
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
                      _buildGreeting(),
                      SizedBox(height: 24.h),
                      ViewEntrance(child: _buildHeroCard(context)),
                      SizedBox(height: 32.h),
                      _buildFeaturesGrid(context),
                      SizedBox(height: 32.h),
                      _buildPromoSection(),
                      SizedBox(height: 32.h),
                      _buildTasksSection(context),
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

  Widget _buildGreeting() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state is AuthAuthenticated
            ? state.user.name.split(' ').first
            : 'Karyawan';
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
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return BrandPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kehadiran Hari Ini',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          if (_todayInfo != null) ...[
            SizedBox(height: 8.h),
            Text(
              _getTodayStatusText(),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.sp),
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceButton(
                  context,
                  title: 'Absen Masuk',
                  icon: Icons.login,
                  color: _canCheckIn() ? AppColors.successEmerald : Colors.grey,
                  onTap: _canCheckIn() ? () => context.push('/app/attendance/check-in').then((_) => _loadTodayInfo()) : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildAttendanceButton(
                  context,
                  title: 'Absen Keluar',
                  icon: Icons.logout,
                  color: _canCheckOut() ? AppColors.error : Colors.grey,
                  onTap: _canCheckOut() ? () => context.push('/app/attendance/check-out').then((_) => _loadTodayInfo()) : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildAttendanceButton(
                  context,
                  title: 'Lembur',
                  icon: Icons.more_time,
                  color: AppColors.primary,
                  onTap: () => context.push('/app/overtime/new'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTodayStatusText() {
    final shifts = _todayInfo?['shifts'] as List? ?? [];
    if (shifts.isEmpty) return 'Tidak ada jadwal shift hari ini.';
    final attendance = shifts.first['attendance'] as Map?;
    if (attendance == null) return 'Belum absen masuk.';
    if (attendance['check_out_time'] == null) {
      return 'Sudah masuk pkl ${DateFormat('HH:mm').format(DateTime.parse(attendance['check_in_time']).toLocal())}';
    }
    return 'Absensi selesai hari ini.';
  }

  bool _canCheckIn() {
    if (_todayInfo == null) return false;
    final shifts = _todayInfo!['shifts'] as List? ?? [];
    return shifts.any((s) => s['attendance'] == null);
  }

  bool _canCheckOut() {
    if (_todayInfo == null) return false;
    final shifts = _todayInfo!['shifts'] as List? ?? [];
    return shifts.any((s) => s['attendance'] != null && s['attendance']['check_out_time'] == null);
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
              'Fitur pilihan kamu',
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
              'Info buat kamu',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
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
        BlocBuilder<CompanyCubit, CompanyState>(
          builder: (context, state) {
            if (state is CompanyLoaded && state.announcements.isNotEmpty) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: state.announcements.take(5).map((announcement) {
                    return Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: _buildPromoCard(
                        title: announcement.title,
                        subtitle: DateFormat('dd MMM yyyy').format(announcement.createdAt ?? DateTime.now()),
                        color: announcement.priority == 'high' ? AppColors.errorContainer : AppColors.primaryFixedDim,
                        icon: Icons.campaign,
                        onTap: () => context.push('/app/announcements/detail', extra: announcement),
                      ),
                    );
                  }).toList(),
                ),
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
                    style:
                        TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
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
    ));
  }

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
      child: BlocBuilder<CompanyCubit, CompanyState>(
        builder: (context, state) {
          final logs = state is CompanyLoaded ? state.attendanceLogs : <Map<String, dynamic>>[];
          
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
                        color: isSelected ? AppColors.primary : (hasAttended ? AppColors.successEmerald : Colors.grey[300]!)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date).substring(0, 3),
                        style: TextStyle(
                          color: isSelected ? Colors.white : (hasAttended ? AppColors.successEmerald : Colors.grey[600]),
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
        }
      ),
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
