import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_badge.dart';

class ClaimDetailScreen extends StatelessWidget {
  const ClaimDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Detail Klaim', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Klaim Transport', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            StatusBadge.approved(),
          ]),
          SizedBox(height: 16.h),
          _Row(label: 'Kategori', value: 'Transport'),
          SizedBox(height: 8.h),
          _Row(label: 'Jumlah', value: 'Rp 150.000'),
          SizedBox(height: 8.h),
          _Row(label: 'Tanggal', value: '15 Jul 2025'),
        ])),
        SizedBox(height: 16.h),

        Text('Deskripsi', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        InfoCard(child: Text('Biaya transportasi online untuk meeting klien di Senayan City.', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, height: 1.5))),
        SizedBox(height: 16.h),

        Text('Bukti Pengeluaran', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Container(height: 200.h, width: double.infinity, decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.receipt_long, size: 48.w, color: AppColors.onSurfaceVariant.withOpacity(0.3)),
            SizedBox(height: 8.h), Text('Foto Struk', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
          ]))),
        SizedBox(height: 16.h),

        Text('Riwayat Persetujuan', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        InfoCard(child: Row(children: [
          Container(width: 40.w, height: 40.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.successEmerald.withOpacity(0.1)),
            child: Icon(Icons.check_circle, color: AppColors.successEmerald, size: 20.w)),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Supervisor - Andi Wijaya', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
            Text('Disetujui • 16 Jul, 10:30', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
          ])),
        ])),
      ])),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
    Text(value, style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w600, fontSize: 14.sp)),
  ]);
}
