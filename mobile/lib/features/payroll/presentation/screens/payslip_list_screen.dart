import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../bloc/payslip_cubit.dart';

class PayslipListScreen extends StatefulWidget {
  const PayslipListScreen({Key? key}) : super(key: key);

  @override
  State<PayslipListScreen> createState() => _PayslipListScreenState();
}

class _PayslipListScreenState extends State<PayslipListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayslipCubit>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface, 
        elevation: 0,
        title: Text('Slip Gaji', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)), 
        centerTitle: true,
      ),
      body: BlocBuilder<PayslipCubit, PayslipState>(
        builder: (context, state) {
          if (state is PayslipLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PayslipError) {
            return Center(child: Text(state.message, style: TextStyle(color: AppColors.error)));
          } else if (state is PayslipLoaded) {
            if (state.payslips.isEmpty) {
              return const Center(child: Text('Belum ada slip gaji'));
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w), 
              itemCount: state.payslips.length, 
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) { 
                final s = state.payslips[i]; 
                return InfoCard(
                  onTap: () => context.push('/app/payslip/detail'), 
                  child: Row(children: [
                    Container(
                      width: 48.w, 
                      height: 48.w, 
                      decoration: BoxDecoration(color: AppColors.tertiaryFixed, borderRadius: BorderRadius.circular(12.r)),
                      child: Icon(Icons.receipt_long, color: AppColors.tertiary, size: 24.w)
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Periode ${s.periodLabel}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text('Diterbitkan: ${s.createdAt != null ? DateFormat('dd MMM y').format(s.createdAt!) : '-'}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Text(currencyFormatter.format(s.netSalary), style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ])
                ); 
              }
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
