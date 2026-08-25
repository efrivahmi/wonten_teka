import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
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
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.pop()),
          title: Text('Jadwal Shift',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: BlocBuilder<ShiftCubit, ShiftState>(
        builder: (context, state) {
          if (state is ShiftLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ShiftError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppColors.error)));
          } else if (state is ShiftLoaded) {
            return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Week selector
                      InfoCard(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                            IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {}),
                            Text('Jadwal Aktif',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {}),
                          ])),
                      SizedBox(height: 16.h),

                      // Mini calendar row (static display)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                              7,
                              (i) => _DayChip(
                                  label: days[i],
                                  date: '${DateTime.now().day + i}',
                                  isToday: i == 0))),
                      SizedBox(height: 24.h),

                      Text('Jadwal Anda',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 12.h),

                      if (state.shifts.isEmpty)
                        const Center(child: Text('Tidak ada jadwal terdekat'))
                      else
                        ...state.shifts.map((s) {
                          final color =
                              _getShiftColor(s.shiftTemplate?.name ?? 'Shift');
                          return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: InfoCard(
                                borderLeftColor: color,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(DateFormat('dd MMM yyyy').format(s.date),
                                                style: TextStyle(
                                                    color: AppColors.onSurface,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.sp)),
                                            SizedBox(height: 4.h),
                                            Text(
                                                '${s.shiftTemplate?.startTime ?? '-'} - ${s.shiftTemplate?.endTime ?? '-'}',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                    fontSize: 12.sp)),
                                          ]),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8.r)),
                                        child: Text(s.shiftTemplate?.name ?? 'Shift',
                                            style: TextStyle(
                                                color: color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp)),
                                      ),
                                    ]),
                              ));
                        }),
                    ]));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label, date;
  final bool isToday;
  const _DayChip(
      {required this.label, required this.date, required this.isToday});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600)),
      SizedBox(height: 4.h),
      Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? AppColors.primaryContainer : Colors.transparent),
        child: Center(
            child: Text(date,
                style: TextStyle(
                    color: isToday ? AppColors.onPrimary : AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp))),
      ),
    ]);
  }
}

