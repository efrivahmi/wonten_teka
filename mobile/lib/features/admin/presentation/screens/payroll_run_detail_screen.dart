import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';

class PayrollRunDetailScreen extends StatelessWidget {
  const PayrollRunDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Detail Run Payroll', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Juli 2025', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h), decoration: BoxDecoration(color: AppColors.successEmerald.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Text('Selesai', style: TextStyle(color: AppColors.successEmerald, fontSize: 10.sp, fontWeight: FontWeight.bold))),
          ]),
          SizedBox(height: 16.h),
          _Row(label: 'Total Karyawan', value: '156'), SizedBox(height: 8.h),
          _Row(label: 'Total Gaji Pokok', value: 'Rp 1.560.000.000'), SizedBox(height: 8.h),
          _Row(label: 'Total Tunjangan', value: 'Rp 250.000.000'), SizedBox(height: 8.h),
          _Row(label: 'Total Potongan', value: '- Rp 150.000.000'), Divider(height: 24.h),
          _Row(label: 'Total Bersih', value: 'Rp 1.660.000.000', isBold: true),
        ])),
        SizedBox(height: 24.h),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Export Bank'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary))),
          SizedBox(width: 12.w),
          Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.send), label: const Text('Kirim Slip'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryContainer, side: const BorderSide(color: AppColors.primaryContainer)))),
        ]),
      ])),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value; final bool isBold;
  const _Row({required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
    Text(value, style: TextStyle(color: AppColors.onSurface, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: 14.sp)),
  ]);
}
