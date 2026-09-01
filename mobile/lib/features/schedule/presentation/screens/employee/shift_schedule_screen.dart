import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/shift_cubit.dart';

class ShiftScheduleScreen extends StatefulWidget {
  const ShiftScheduleScreen({super.key});

  @override
  State<ShiftScheduleScreen> createState() => _ShiftScheduleScreenState();
}

class _ShiftScheduleScreenState extends State<ShiftScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShiftCubit>().loadUpcoming();
    });
  }

  Color _getShiftColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('libur') || lower.contains('off')) {
      return AppColors.onSurfaceVariant;
    }
    if (lower.contains('siang') || lower.contains('malam')) {
      return AppColors.warningAmber;
    }
    return AppColors.successEmerald;
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            height: 280.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop()),
                      Expanded(
                          child: Text('Jadwal Shift',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      context.read<ShiftCubit>().loadUpcoming();
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: BlocBuilder<ShiftCubit, ShiftState>(
                      builder: (context, state) {
                        if (state is ShiftLoading) {
                          return ListView(
                            padding: EdgeInsets.all(24.w),
                            children: [
                              Container(
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius:
                                          BorderRadius.circular(24.r))),
                              SizedBox(height: 24.h),
                              ...List.generate(
                                  3,
                                  (index) => Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: Container(
                                            height: 80.h,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        16.r))),
                                      )),
                            ],
                          ).animate(onPlay: (c) => c.repeat()).shimmer(
                              duration: 1200.ms,
                              color: Colors.white.withValues(alpha: 0.5));
                        } else if (state is ShiftError) {
                          return ListView(
                            padding: EdgeInsets.all(24.w),
                            children: [
                              SizedBox(height: 60.h),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(32.w),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24.r),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10))
                                      ]),
                                  child: Column(
                                    children: [
                                      Icon(Icons.wifi_off,
                                          size: 64.w, color: AppColors.error),
                                      SizedBox(height: 16.h),
                                      Text('Gagal Memuat Data',
                                          style: TextStyle(
                                              color: AppColors.onSurface,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 8.h),
                                      Text(state.message,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14.sp)),
                                      SizedBox(height: 24.h),
                                      ElevatedButton.icon(
                                        onPressed: () => context
                                            .read<ShiftCubit>()
                                            .loadUpcoming(),
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Coba Lagi'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryContainer,
                                            foregroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        16.r))),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (state is ShiftLoaded) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 16.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Weekly Overview Card
                                Container(
                                  padding: EdgeInsets.all(24.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24.r),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10))
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                              icon: const Icon(
                                                  Icons.chevron_left),
                                              onPressed: () {}),
                                          Text('Jadwal Aktif',
                                              style: TextStyle(
                                                  color: AppColors.onSurface,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
                                          IconButton(
                                              icon: const Icon(
                                                  Icons.chevron_right),
                                              onPressed: () {}),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: List.generate(7, (index) {
                                          final now = DateTime.now();
                                          final isToday =
                                              index == now.weekday - 1;
                                          final startOfWeek = now.subtract(
                                              Duration(days: now.weekday - 1));
                                          final date = startOfWeek
                                              .add(Duration(days: index));

                                          return Column(
                                            children: [
                                              Text(days[index],
                                                  style: TextStyle(
                                                      color: isToday
                                                          ? AppColors.primary
                                                          : Colors.grey[500],
                                                      fontSize: 12.sp,
                                                      fontWeight: isToday
                                                          ? FontWeight.bold
                                                          : FontWeight.normal)),
                                              SizedBox(height: 8.h),
                                              Container(
                                                width: 32.w,
                                                height: 32.w,
                                                decoration: BoxDecoration(
                                                  color: isToday
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${date.day}',
                                                    style: TextStyle(
                                                        color: isToday
                                                            ? Colors.white
                                                            : Colors.black87,
                                                        fontSize: 12.sp,
                                                        fontWeight: isToday
                                                            ? FontWeight.bold
                                                            : FontWeight
                                                                .normal),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.h),
                                Text('Shift Mendatang',
                                    style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 16.h),

                                if (state.shifts.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.w),
                                      child: Column(
                                        children: [
                                          Icon(Icons.calendar_today_outlined,
                                              size: 48.w,
                                              color: Colors.grey[400]),
                                          SizedBox(height: 16.h),
                                          Text(
                                              'Belum ada jadwal shift untuk minggu ini.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14.sp)),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  ...state.shifts.map((assignment) {
                                    final dateStr =
                                        DateFormat('EEEE, d MMM', 'id_ID')
                                            .format(assignment.date);
                                    final shiftName =
                                        assignment.shiftTemplate?.name ??
                                            'Libur';
                                    final color = _getShiftColor(shiftName);
                                    final isOff = shiftName
                                            .toLowerCase()
                                            .contains('libur') ||
                                        shiftName.toLowerCase().contains('off');
                                    final startTime =
                                        assignment.shiftTemplate?.startTime !=
                                                null
                                            ? DateFormat('HH:mm').format(
                                                DateFormat('HH:mm:ss').parse(
                                                    assignment.shiftTemplate!
                                                        .startTime!))
                                            : '-';
                                    final endTime =
                                        assignment.shiftTemplate?.endTime !=
                                                null
                                            ? DateFormat('HH:mm').format(
                                                DateFormat('HH:mm:ss').parse(
                                                    assignment.shiftTemplate!
                                                        .endTime!))
                                            : '-';

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 16.h),
                                      padding: EdgeInsets.all(20.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4))
                                        ],
                                        border: Border(
                                            left: BorderSide(
                                                color: color, width: 4.w)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(dateStr,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.sp,
                                                      color:
                                                          AppColors.onSurface)),
                                              SizedBox(height: 4.h),
                                              Text(
                                                  isOff
                                                      ? 'Tidak ada shift'
                                                      : '$startTime - $endTime',
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14.sp)),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 6.h),
                                            decoration: BoxDecoration(
                                                color: color.withValues(
                                                    alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.r)),
                                            child: Text(shiftName,
                                                style: TextStyle(
                                                    color: color,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
