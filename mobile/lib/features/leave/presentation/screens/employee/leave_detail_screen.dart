import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/widgets/status_badge.dart';

class LeaveDetailScreen extends StatelessWidget {
  const LeaveDetailScreen({super.key});

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
          title: Text('Detail Cuti',
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cuti Tahunan',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        StatusBadge.approved(),
                      ]),
                  SizedBox(height: 16.h),
                  const _Row(label: 'Tanggal', value: '14 Jul - 16 Jul 2025'),
                  SizedBox(height: 8.h),
                  const _Row(label: 'Durasi', value: '3 hari'),
                  SizedBox(height: 8.h),
                  const _Row(label: 'Alasan', value: 'Acara keluarga'),
                ])),
            SizedBox(height: 16.h),
            Text('Riwayat Persetujuan',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            const _ApprovalStep(
                name: 'Supervisor - Andi Wijaya',
                status: 'Disetujui',
                time: '10 Jul, 14:30',
                isApproved: true),
            const _ApprovalStep(
                name: 'HR Manager - Sari Dewi',
                status: 'Disetujui',
                time: '10 Jul, 16:00',
                isApproved: true),
          ])),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style:
                TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
        Text(value,
            style: TextStyle(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp)),
      ]);
}

class _ApprovalStep extends StatelessWidget {
  final String name, status, time;
  final bool isApproved;
  const _ApprovalStep(
      {required this.name,
      required this.status,
      required this.time,
      required this.isApproved});
  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InfoCard(
          child: Row(children: [
        Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isApproved
                    ? AppColors.successEmerald.withValues(alpha: 0.1)
                    : AppColors.warningAmber.withValues(alpha: 0.1)),
            child: Icon(isApproved ? Icons.check_circle : Icons.schedule,
                color: isApproved
                    ? AppColors.successEmerald
                    : AppColors.warningAmber,
                size: 20.w)),
        SizedBox(width: 12.w),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
              style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp)),
          Text('$status • $time',
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
        ])),
      ])));
}

