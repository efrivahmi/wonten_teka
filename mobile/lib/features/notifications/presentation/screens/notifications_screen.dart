import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final notifs = [
      {
        'title': 'Cuti Disetujui',
        'body': 'Pengajuan cuti 14-16 Jul telah disetujui.',
        'time': '10 menit lalu',
        'icon': Icons.check_circle,
        'color': AppColors.successEmerald,
        'read': false
      },
      {
        'title': 'Pengumuman Baru',
        'body': 'Townhall Q3 besok pukul 14:00.',
        'time': '2 jam lalu',
        'icon': Icons.campaign,
        'color': AppColors.warningAmber,
        'read': false
      },
      {
        'title': 'Slip Gaji Tersedia',
        'body': 'Slip gaji Juli 2025 sudah tersedia.',
        'time': '1 hari lalu',
        'icon': Icons.payments,
        'color': AppColors.infoCerulean,
        'read': true
      },
      {
        'title': 'Klaim Diproses',
        'body': 'Klaim transport Rp 150.000 disetujui.',
        'time': '2 hari lalu',
        'icon': Icons.receipt,
        'color': AppColors.tertiary,
        'read': true
      },
      {
        'title': 'Pengingat Shift',
        'body': 'Shift siang besok: 12:00 - 21:00.',
        'time': '3 hari lalu',
        'icon': Icons.schedule,
        'color': AppColors.primaryContainer,
        'read': true
      },
    ];
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Notifikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () {},
                child: Text('Baca Semua',
                    style:
                        TextStyle(color: AppColors.primary, fontSize: 12.sp)))
          ]),
      body: ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: notifs.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, i) {
            final n = notifs[i];
            return InfoCard(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (n['color'] as Color).withValues(alpha: 0.1)),
                      child: Icon(n['icon'] as IconData,
                          color: n['color'] as Color, size: 20.w)),
                  SizedBox(width: 12.w),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          Expanded(
                              child: Text(n['title'] as String,
                                  style: TextStyle(
                                      color: AppColors.onSurface,
                                      fontWeight: (n['read'] as bool)
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 14.sp))),
                          if (!(n['read'] as bool))
                            Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryContainer)),
                        ]),
                        SizedBox(height: 2.h),
                        Text(n['body'] as String,
                            style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13.sp)),
                        SizedBox(height: 4.h),
                        Text(n['time'] as String,
                            style: TextStyle(
                                color: AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                                fontSize: 11.sp)),
                      ])),
                ]));
          }),
    );
  }
}
