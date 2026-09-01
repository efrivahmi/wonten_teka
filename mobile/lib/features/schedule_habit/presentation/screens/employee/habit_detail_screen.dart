import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Olahraga Pagi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.edit, color: AppColors.primary), onPressed: () {})]),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Streak Banner
        InfoCard(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('STREAK SAAT INI', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              SizedBox(height: 4.h),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('12', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.warningAmber, fontWeight: FontWeight.bold)),
                SizedBox(width: 4.w),
                Padding(padding: EdgeInsets.only(bottom: 6.h), child: Text('hari', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp))),
              ]),
            ]),
            Icon(Icons.local_fire_department, color: AppColors.warningAmber, size: 48.w),
          ]),
        ),
        SizedBox(height: 16.h),

        // Weekly Calendar
        InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Minggu Ini', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            for (final d in [{'day': 'S', 'done': true}, {'day': 'S', 'done': true}, {'day': 'R', 'done': true}, {'day': 'K', 'done': true},
                             {'day': 'J', 'done': true}, {'day': 'S', 'done': false}, {'day': 'M', 'done': false}])
              Column(children: [
                Text(d['day'] as String, style: TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant)),
                SizedBox(height: 4.h),
                Container(width: 32.w, height: 32.w, decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (d['done'] as bool) ? AppColors.successEmerald : AppColors.surfaceContainerHigh),
                  child: (d['done'] as bool) ? Icon(Icons.check, color: Colors.white, size: 16.w) : null),
              ]),
          ]),
        ])),
        SizedBox(height: 16.h),

        // Stats
        Row(children: [
          Expanded(child: InfoCard(child: Column(children: [
            Text('30', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.successEmerald, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('Total Selesai', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
          ]))),
          SizedBox(width: 12.w),
          Expanded(child: InfoCard(child: Column(children: [
            Text('85%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.infoCerulean, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('Konsistensi', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
          ]))),
        ]),
        SizedBox(height: 16.h),

        // Details
        InfoCard(child: Column(children: [
          const _DetailRow(label: 'Frekuensi', value: 'Setiap Hari'),
          Divider(height: 20.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _DetailRow(label: 'Pengingat', value: '06:00'),
          Divider(height: 20.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _DetailRow(label: 'Dibuat', value: '25 Jun 2025'),
        ])),
      ])),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
    Text(value, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
  ]);
}

