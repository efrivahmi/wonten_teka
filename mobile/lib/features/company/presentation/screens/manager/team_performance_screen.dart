import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';

class TeamPerformanceScreen extends StatelessWidget {
  const TeamPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
              onPressed: () => context.pop()),
          title: Text('Performa Tim',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoCard(
                child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Produktivitas (Bulan Ini)',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Icon(Icons.more_vert),
              ]),
              SizedBox(height: 16.h),
              const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCircle(
                        value: '95%',
                        label: 'Kehadiran',
                        color: AppColors.successEmerald),
                    _StatCircle(
                        value: '88%',
                        label: 'Ketepatan Waktu',
                        color: AppColors.infoCerulean),
                    _StatCircle(
                        value: '12j',
                        label: 'Rata Lembur',
                        color: AppColors.warningAmber),
                  ]),
            ])),
            SizedBox(height: 24.h),
            Text('Anggota Tim',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            ...List.generate(
                4,
                (i) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: InfoCard(
                        child: Row(children: [
                      CircleAvatar(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Text('${i + 1}')),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('Anggota ${i + 1}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            Text('Kehadiran: 9$i%, Terlambat: ${i}x',
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12.sp)),
                          ])),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                              color: AppColors.successEmerald
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r)),
                          child: Text('Baik',
                              style: TextStyle(
                                  color: AppColors.successEmerald,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold))),
                    ])))),
          ])),
    );
  }
}

class _StatCircle extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCircle(
      {required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 4.w)),
            child: Center(
                child: Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp)))),
        SizedBox(height: 8.h),
        Text(label,
            style:
                TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
      ]);
}

