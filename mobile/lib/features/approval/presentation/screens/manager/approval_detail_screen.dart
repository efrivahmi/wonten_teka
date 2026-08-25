import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/widgets/status_badge.dart';

class ApprovalDetailScreen extends StatelessWidget {
  const ApprovalDetailScreen({super.key});

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
          title: Text('Detail Pengajuan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: Column(children: [
        Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Requester Info
                      InfoCard(
                          child: Row(children: [
                        CircleAvatar(
                            radius: 24.r,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            child: Text('DL',
                                style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp))),
                        SizedBox(width: 16.w),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Dewi Lestari',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              Text('Marketing â€¢ Staff',
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 13.sp)),
                            ])),
                        StatusBadge.pending(),
                      ])),
                      SizedBox(height: 16.h),

                      // Request Details
                      InfoCard(
                          child: Column(children: [
                        const _Row(label: 'Jenis', value: 'Cuti Tahunan'),
                        Divider(
                            height: 20.h,
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.3)),
                        const _Row(label: 'Tanggal', value: '20 - 22 Jul 2025'),
                        Divider(
                            height: 20.h,
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.3)),
                        const _Row(label: 'Durasi', value: '3 hari'),
                        Divider(
                            height: 20.h,
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.3)),
                        const _Row(label: 'Sisa Cuti', value: '7 hari'),
                      ])),
                      SizedBox(height: 16.h),

                      Text('Alasan',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 8.h),
                      InfoCard(
                          child: Text(
                              'Menghadiri pernikahan saudara di Surabaya. Sudah koordinasi dengan tim untuk delegasi pekerjaan.',
                              style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 14.sp,
                                  height: 1.5))),
                      SizedBox(height: 16.h),

                      // Comment Field
                      Text('Catatan Approver',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: 8.h),
                      TextFormField(
                          maxLines: 3,
                          decoration: InputDecoration(
                              hintText: 'Tambahkan catatan (opsional)',
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.5))),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                      color: AppColors.outlineVariant
                                          .withValues(alpha: 0.5))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryContainer)))),
                    ]))),

        // Bottom Action Buttons
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                  top: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.5)))),
          child: SafeArea(
              child: Row(children: [
            Expanded(
                child: SizedBox(
                    height: 52.h,
                    child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.errorCrimson,
                            side:
                                const BorderSide(color: AppColors.errorCrimson),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r))),
                        child: const Text('Tolak',
                            style: TextStyle(fontWeight: FontWeight.bold))))),
            SizedBox(width: 16.w),
            Expanded(
                child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Pengajuan disetujui!')));
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successEmerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r))),
                        child: const Text('Setujui',
                            style: TextStyle(fontWeight: FontWeight.bold))))),
          ])),
        ),
      ]),
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

