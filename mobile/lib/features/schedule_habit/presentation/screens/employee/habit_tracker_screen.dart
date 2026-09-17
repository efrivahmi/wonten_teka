import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../schedule/bloc/task_cubit.dart';
import '../../../../../core/models/task_device_models.dart';
import 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';
import 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';

class HabitTrackerScreen extends StatefulWidget {
  final bool isHabit;
  const HabitTrackerScreen({super.key, this.isHabit = true});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskCubit>().loadTasks(habitsOnly: widget.isHabit);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrandPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
          title: AppBrandTitle(section: widget.isHabit ? 'Habit Tracker' : 'Daily Task'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Tugas Hari Ini'),
              Tab(text: 'Laporan Bulan Ini'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(widget.isHabit ? '/app/habits/new' : '/app/tasks/new'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add),
        ),
        body: BlocConsumer<TaskCubit, TaskState>(
          listener: (context, state) {
            if (state is TaskActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.successEmerald, behavior: SnackBarBehavior.floating),
              );
            } else if (state is TaskError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
              );
            }
          },
          builder: (context, state) {
            if (state is TaskLoading && context.read<TaskCubit>().state is! TaskLoaded) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is TaskLoaded) {
              final activeTasks = state.tasks.where((t) => t.isActive).toList();
              final completedTasks = state.tasks.where((t) => !t.isActive).toList();
              final trackingData = state.trackingData;

              return TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Tugas Hari Ini
                  RefreshIndicator(
                    onRefresh: () => context.read<TaskCubit>().loadTasks(habitsOnly: widget.isHabit),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _taskController,
                                    decoration: InputDecoration(
                                      hintText: widget.isHabit ? 'Tambahkan habit baru' : 'Tambahkan tugas baru',
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: state is TaskLoading ? null : () {
                                    if (_taskController.text.isNotEmpty) {
                                      if (widget.isHabit) {
                                        context.read<TaskCubit>().createTask(
                                          title: _taskController.text,
                                          description: '',
                                          recurrenceRule: 'daily',
                                          reminderTime: '07:00:00',
                                        );
                                      } else {
                                        context.read<TaskCubit>().addTask(
                                          _taskController.text,
                                          null,
                                          DateTime.now().toIso8601String().split('T').first,
                                          '07:00',
                                        );
                                      }
                                      _taskController.clear();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                  ),
                                  child: state is TaskLoading 
                                      ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          if (activeTasks.isNotEmpty) ...[
                            Text('Belum Selesai (${activeTasks.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(height: 12.h),
                            ...activeTasks.map((t) => _buildTaskCard(t, context, false)),
                            SizedBox(height: 24.h),
                          ] else if (completedTasks.isEmpty) ...[
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.w),
                                child: const Text('Belum ada tugas hari ini', style: TextStyle(color: AppColors.onSurfaceVariant)),
                              ),
                            ),
                          ],
                          
                          if (completedTasks.isNotEmpty) ...[
                            Text('Selesai Hari Ini (${completedTasks.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.successEmerald)),
                            SizedBox(height: 12.h),
                            ...completedTasks.map((t) => _buildTaskCard(t, context, true)),
                          ]
                        ],
                      ).animate().fade().slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic, duration: 400.ms),
                    ),
                  ),

                  // Tab 2: Laporan Bulan Ini
                  RefreshIndicator(
                    onRefresh: () => context.read<TaskCubit>().loadTasks(habitsOnly: widget.isHabit),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      child: trackingData == null
                          ? const Center(child: Text('Gagal memuat laporan bulanan'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isHabit ? 'Riwayat Habit Bulan Ini' : 'Tugas Diselesaikan Bulan Ini',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 16.h),
                                      if (widget.isHabit) ...[
                                        if ((trackingData['completed_habits'] as List?)?.isEmpty ?? true)
                                          const Text('Belum ada riwayat habit bulan ini.', style: TextStyle(color: AppColors.onSurfaceVariant))
                                        else
                                          ...(trackingData['completed_habits'] as List).map((record) => _buildTrackingItem(
                                                title: record['personal_task']?['title'] ?? 'Habit',
                                                date: record['completed_date'],
                                                badge: 'Streak: ${record['personal_task']?['streak_count'] ?? 1}',
                                                badgeColor: AppColors.warningAmber,
                                              )),
                                      ] else ...[
                                        if ((trackingData['completed_tasks'] as List?)?.isEmpty ?? true)
                                          const Text('Belum ada tugas biasa yang diselesaikan.', style: TextStyle(color: AppColors.onSurfaceVariant))
                                        else
                                          ...(trackingData['completed_tasks'] as List).map((task) => _buildTrackingItem(
                                                title: task['title'] ?? 'Tugas',
                                                date: task['last_completed_at'],
                                                badge: 'Selesai',
                                                badgeColor: AppColors.successEmerald,
                                              )),
                                      ]
                                    ],
                                  ),
                                )
                              ],
                            ).animate().fade(),
                    ),
                  )
                ],
              );
            }
            return const Center(child: Text('Gagal memuat data'));
          },
        ),
      ),
    );
  }

  Widget _buildTrackingItem({required String title, required String date, required String badge, required Color badgeColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date.substring(0, 10), style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
            ),
            child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildTaskCard(PersonalTaskModel task, BuildContext context, bool isCompleted) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.surfaceContainerHigh.withValues(alpha: 0.5) : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isCompleted ? Colors.transparent : AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: InkWell(
          onTap: () {
            if (widget.isHabit && !isCompleted) {
              context.read<TaskCubit>().completeTask(task.id);
            } else {
              context.read<TaskCubit>().toggleTask(task.id, !isCompleted, DateTime.now().toIso8601String().split('T').first);
            }
          },
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isCompleted ? AppColors.successEmerald : AppColors.outline, width: 2),
              color: isCompleted ? AppColors.successEmerald : Colors.transparent,
            ),
            child: Icon(Icons.check, size: 20.w, color: isCompleted ? Colors.white : Colors.transparent),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
          ),
        ),
        subtitle: task.description != null
            ? Text(
                task.description!,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: AppColors.onSurfaceVariant,
                ),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Hapus Tugas'),
                content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<TaskCubit>().deleteTask(task.id, DateTime.now().toIso8601String().split('T').first);
                    },
                    child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
