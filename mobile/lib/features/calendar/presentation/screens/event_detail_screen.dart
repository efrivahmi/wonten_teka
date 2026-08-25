import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});
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
          title: Text('Detail Event',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InfoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                          color: AppColors.infoCerulean.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Text('Meeting',
                          style: TextStyle(
                              color: AppColors.infoCerulean,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp))),
                  SizedBox(height: 12.h),
                  Text('Townhall Q3',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  const _Row(
                      icon: Icons.calendar_today, text: 'Selasa, 15 Juli 2025'),
                  SizedBox(height: 8.h),
                  const _Row(icon: Icons.schedule, text: '14:00 - 16:00 WIB'),
                  SizedBox(height: 8.h),
                  const _Row(
                      icon: Icons.location_on, text: 'Ruang Utama Lt. 3'),
                  SizedBox(height: 8.h),
                  const _Row(icon: Icons.people, text: 'Seluruh Karyawan'),
                ])),
            SizedBox(height: 16.h),
            Text('Deskripsi',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            InfoCard(
                child: Text(
                    'Pembahasan pencapaian Q2 dan target Q3 2025. CEO akan menyampaikan update strategi perusahaan.',
                    style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14.sp,
                        height: 1.5))),
            SizedBox(height: 16.h),
            Text('Agenda',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            const InfoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  _AgendaItem(time: '14:00', title: 'Opening & Welcome'),
                  _AgendaItem(time: '14:15', title: 'Q2 Performance Review'),
                  _AgendaItem(time: '14:45', title: 'Q3 Strategy & Targets'),
                  _AgendaItem(time: '15:30', title: 'Q&A Session'),
                  _AgendaItem(time: '16:00', title: 'Closing'),
                ])),
          ])),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 16.w, color: AppColors.onSurfaceVariant),
        SizedBox(width: 8.w),
        Text(text,
            style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp)),
      ]);
}

class _AgendaItem extends StatelessWidget {
  final String time, title;
  const _AgendaItem({required this.time, required this.title});
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(children: [
        SizedBox(
            width: 48.w,
            child: Text(time,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600))),
        Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primaryContainer)),
        SizedBox(width: 12.w),
        Text(title,
            style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp)),
      ]));
}
