import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Townhall Q3',
        'body': 'Jangan lupa hadir besok pukul 14:00.',
        'time': '2 jam lalu',
        'priority': 'high',
        'icon': Icons.campaign
      },
      {
        'title': 'Update Kebijakan WFH',
        'body': 'Mulai Agustus, WFH max 2 hari per minggu.',
        'time': '1 hari lalu',
        'priority': 'medium',
        'icon': Icons.policy
      },
      {
        'title': 'Server Maintenance',
        'body': 'Maintenance terjadwal Sabtu 19 Jul.',
        'time': '3 hari lalu',
        'priority': 'low',
        'icon': Icons.build
      },
    ];
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Pengumuman',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, i) {
            final a = items[i];
            return InfoCard(
                borderLeftColor: a['priority'] == 'high'
                    ? AppColors.errorCrimson
                    : a['priority'] == 'medium'
                        ? AppColors.warningAmber
                        : AppColors.infoCerulean,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                              color: (a['priority'] == 'high'
                                      ? AppColors.errorCrimson
                                      : a['priority'] == 'medium'
                                          ? AppColors.warningAmber
                                          : AppColors.infoCerulean)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r)),
                          child: Icon(a['icon'] as IconData,
                              color: a['priority'] == 'high'
                                  ? AppColors.errorCrimson
                                  : a['priority'] == 'medium'
                                      ? AppColors.warningAmber
                                      : AppColors.infoCerulean,
                              size: 20.w)),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(a['title'] as String,
                                          style: TextStyle(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14.sp))),
                                  Text(a['time'] as String,
                                      style: TextStyle(
                                          color: AppColors.onSurfaceVariant,
                                          fontSize: 11.sp)),
                                ]),
                            SizedBox(height: 4.h),
                            Text(a['body'] as String,
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 13.sp)),
                          ])),
                    ]));
          }),
    );
  }
}
