import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class PayslipDetailScreen extends StatelessWidget {
  const PayslipDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Slip Juli 2025', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.download, color: AppColors.primary), onPressed: () {})]),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Net Pay Header
        InfoCard(child: Column(children: [
          Text('GAJI BERSIH', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          SizedBox(height: 4.h),
          Text('Rp 12.450.000', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h), Text('Periode: 1 - 31 Juli 2025', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
        ])),
        SizedBox(height: 24.h),

        // Pendapatan
        Text('Pendapatan', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.successEmerald)),
        SizedBox(height: 8.h),
        InfoCard(borderLeftColor: AppColors.successEmerald, child: Column(children: [
          const _Row(label: 'Gaji Pokok', value: 'Rp 10.000.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'Tunjangan Makan', value: 'Rp 1.500.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'Tunjangan Transport', value: 'Rp 1.000.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'Lembur', value: 'Rp 750.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'Reimbursement', value: 'Rp 150.000', isBold: false),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'Total Pendapatan', value: 'Rp 13.400.000', isBold: true),
        ])),
        SizedBox(height: 24.h),

        // Potongan
        Text('Potongan', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.errorCrimson)),
        SizedBox(height: 8.h),
        InfoCard(borderLeftColor: AppColors.errorCrimson, child: Column(children: [
          const _Row(label: 'PPh 21 (TER)', value: '- Rp 450.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'BPJS Kesehatan (1%)', value: '- Rp 100.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'BPJS JHT (2%)', value: '- Rp 200.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'BPJS JP (1%)', value: '- Rp 100.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'Tapera (2.5%)', value: '- Rp 100.000'),
          Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          const _Row(label: 'Total Potongan', value: '- Rp 950.000', isBold: true),
        ])),
      ])),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value; final bool isBold;
  const _Row({required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: isBold ? AppColors.onSurface : AppColors.onSurfaceVariant, fontSize: 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    Text(value, style: TextStyle(color: AppColors.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: 14.sp)),
  ]);
}
