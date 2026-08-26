import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/models/payslip_model.dart';

class PayslipDetailScreen extends StatelessWidget {
  final PayslipModel payslip;
  const PayslipDetailScreen({super.key, required this.payslip});
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface, 
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.onSurface), onPressed: () => context.pop()),
        title: Text('Slip ${payslip.periodLabel}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), 
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary), 
            onPressed: () {
              // TODO: implement download
            }
          )
        ]
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // Net Pay Header
            InfoCard(child: Column(children: [
              Text('GAJI BERSIH', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              SizedBox(height: 4.h),
              Text(currencyFormatter.format(payslip.netSalary), style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h), 
              Text('Periode: ${payslip.periodLabel}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
            ])),
            SizedBox(height: 24.h),
    
            // Pendapatan
            Text('Pendapatan', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.successEmerald)),
            SizedBox(height: 8.h),
            InfoCard(borderLeftColor: AppColors.successEmerald, child: Column(children: [
              if (payslip.earningsBreakdown != null && payslip.earningsBreakdown!.isNotEmpty)
                ...payslip.earningsBreakdown!.entries.map((e) {
                  return Column(
                    children: [
                      _Row(label: e.key, value: currencyFormatter.format(num.tryParse(e.value.toString()) ?? 0)),
                      Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ],
                  );
                }),
              _Row(label: 'Total Pendapatan', value: currencyFormatter.format(payslip.grossSalary), isBold: true),
            ])),
            SizedBox(height: 24.h),
    
            // Potongan
            Text('Potongan', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.errorCrimson)),
            SizedBox(height: 8.h),
            InfoCard(borderLeftColor: AppColors.errorCrimson, child: Column(children: [
              if (payslip.deductionsBreakdown != null && payslip.deductionsBreakdown!.isNotEmpty)
                ...payslip.deductionsBreakdown!.entries.map((e) {
                  return Column(
                    children: [
                      _Row(label: e.key, value: '- ${currencyFormatter.format(num.tryParse(e.value.toString()) ?? 0)}'),
                      Divider(height: 16.h, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ],
                  );
                }),
              _Row(label: 'Total Potongan', value: '- ${currencyFormatter.format(payslip.totalDeductions)}', isBold: true),
            ])),
          ]
        )
      ),
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

