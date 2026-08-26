import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../schedule/bloc/task_cubit.dart';
import '../../../../../core/models/task_device_models.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskCubit>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Habit Tracker',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/app/habits/new'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.successEmerald,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading && context.read<TaskCubit>().state is! TaskLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 100.h, width: double.infinity, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16.r))),
                  SizedBox(height: 24.h),
                  Container(height: 16.h, width: 100.w, color: AppColors.surfaceContainerHigh),
                  SizedBox(height: 12.h),
                  ...List.generate(4, (index) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Container(height: 80.h, width: double.infinity, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16.r))),
                  )),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: AppColors.surface.withValues(alpha: 0.5));
          } else if (state is TaskError && (context.read<TaskCubit>().state is! TaskLoaded)) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 100.h),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 64.w, color: AppColors.error.withValues(alpha: 0.7)),
                        SizedBox(height: 16.h),
                        Text('Gagal Memuat Data', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () => context.read<TaskCubit>().loadTasks(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          List<PersonalTaskModel> tasks = [];
          if (state is TaskLoaded) {
            tasks = state.tasks;
          } else if (context.read<TaskCubit>().state is TaskLoaded) {
            tasks = (context.read<TaskCubit>().state as TaskLoaded).tasks;
          }

          final completedCount = tasks.where((t) => t.isCompletedToday).length;
          final totalCount = tasks.length;
          final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<TaskCubit>().loadTasks();
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Progress
                  InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hari Ini',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        SizedBox(height: 12.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.successEmerald),
                            minHeight: 8.h,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text('$completedCount dari $totalCount habit selesai',
                            style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text('Habit Saya',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  SizedBox(height: 12.h),
                  
                  if (tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.self_improvement,
                                  size: 48.w,
                                  color: AppColors.onSurfaceVariant
                                      .withValues(alpha: 0.5)),
                            ),
                            SizedBox(height: 16.h),
                            Text('Belum ada habit',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.bold)),
                            SizedBox(height: 8.h),
                            Text(
                                'Tap tombol + untuk memulai rutinitas baru Anda hari ini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...tasks.map((h) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: InfoCard(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                      color: h.isCompletedToday
                                          ? AppColors.successEmerald.withValues(alpha: 0.1)
                                          : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(12.r)),
                                  child: Icon(Icons.star_outline,
                                      color: h.isCompletedToday
                                          ? AppColors.successEmerald
                                          : AppColors.onSurfaceVariant,
                                      size: 24.w),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(h.title,
                                          style: TextStyle(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.sp)),
                                      SizedBox(height: 2.h),
                                      Row(
                                        children: [
                                          Icon(Icons.local_fire_department,
                                              size: 14.w,
                                              color: AppColors.warningAmber),
                                          SizedBox(width: 4.w),
                                          Text('${h.streakCount} hari streak',
                                              style: TextStyle(
                                                  color: AppColors.onSurfaceVariant,
                                                  fontSize: 12.sp)),
                                          SizedBox(width: 12.w),
                                          Icon(Icons.schedule,
                                              size: 14.w,
                                              color: AppColors.onSurfaceVariant),
                                          SizedBox(width: 4.w),
                                          Text(h.reminderTime != null ? h.reminderTime!.substring(0, 5) : '-',
                                              style: TextStyle(
                                                  color: AppColors.onSurfaceVariant,
                                                  fontSize: 12.sp)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: h.isCompletedToday,
                                  onChanged: h.isCompletedToday ? null : (_) {
                                    context.read<TaskCubit>().completeTask(h.id);
                                  },
                                  activeColor: AppColors.successEmerald,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r)),
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

