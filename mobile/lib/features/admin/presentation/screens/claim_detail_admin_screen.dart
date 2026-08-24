import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class ClaimDetailAdminScreen extends StatelessWidget {
  const ClaimDetailAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Detail Klaim (Admin)', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Karyawan 1', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: AppColors.warningAmber.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Text('Pending', style: TextStyle(color: AppColors.warningAmber, fontSize: 10.sp, fontWeight: FontWeight.bold))),
          ]),
          SizedBox(height: 16.h),
          _Row(label: 'Kategori', value: 'Medis'), SizedBox(height: 8.h),
          _Row(label: 'Jumlah', value: 'Rp 500.000'), SizedBox(height: 8.h),
          _Row(label: 'Tanggal', value: '15 Jul 2025'),
        ])),
        SizedBox(height: 16.h),
        Text('Bukti Struk', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Container(height: 200.h, width: double.infinity, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12.r)), child: Center(child: Icon(Icons.image, size: 48.w, color: AppColors.onSurfaceVariant))),
        SizedBox(height: 24.h),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorCrimson, side: const BorderSide(color: AppColors.errorCrimson)), child: const Text('Tolak'))),
          SizedBox(width: 12.w),
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.successEmerald, foregroundColor: Colors.white), child: const Text('Bayar/Setujui'))),
        ]),
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
