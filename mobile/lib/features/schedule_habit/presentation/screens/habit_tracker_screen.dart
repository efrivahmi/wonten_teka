import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class HabitTrackerScreen extends StatelessWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = [
      {'name': 'Olahraga Pagi', 'streak': 12, 'icon': Icons.fitness_center, 'done': true, 'time': '06:00'},
      {'name': 'Baca Buku', 'streak': 5, 'icon': Icons.menu_book, 'done': true, 'time': '07:00'},
      {'name': 'Meditasi', 'streak': 3, 'icon': Icons.self_improvement, 'done': false, 'time': '21:00'},
      {'name': 'Belajar Bahasa', 'streak': 0, 'icon': Icons.translate, 'done': false, 'time': '20:00'},
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        title: Text('Habit Tracker', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/app/habits/new'),
        backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Today's Progress
        InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hari Ini', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          ClipRRect(borderRadius: BorderRadius.circular(4.r), child: LinearProgressIndicator(
            value: 0.5, backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation(AppColors.successEmerald), minHeight: 8.h,
          )),
          SizedBox(height: 8.h),
          Text('2 dari 4 habit selesai', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
        ])),
        SizedBox(height: 24.h),

        Text('Habit Saya', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 12.h),
        ...habits.map((h) => Padding(padding: EdgeInsets.only(bottom: 12.h), child: InfoCard(
          onTap: () => context.push('/app/habits/detail'),
          child: Row(children: [
            Container(
              width: 48.w, height: 48.w,
              decoration: BoxDecoration(
                color: (h['done'] as bool) ? AppColors.successEmerald.withValues(alpha: 0.1) : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.r)),
              child: Icon(h['icon'] as IconData, color: (h['done'] as bool) ? AppColors.successEmerald : AppColors.onSurfaceVariant, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h['name'] as String, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
              SizedBox(height: 2.h),
              Row(children: [
                Icon(Icons.local_fire_department, size: 14.w, color: AppColors.warningAmber),
                SizedBox(width: 4.w),
                Text('${h['streak']} hari streak', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                SizedBox(width: 12.w),
                Icon(Icons.schedule, size: 14.w, color: AppColors.onSurfaceVariant),
                SizedBox(width: 4.w),
                Text(h['time'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
              ]),
            ])),
            Checkbox(
              value: h['done'] as bool, onChanged: (_) {},
              activeColor: AppColors.successEmerald,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
            ),
          ]),
        ))),
      ])),
    );
  }
}
