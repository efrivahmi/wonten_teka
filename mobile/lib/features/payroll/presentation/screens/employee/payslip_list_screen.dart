import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/payslip_cubit.dart';

class PayslipListScreen extends StatefulWidget {
  const PayslipListScreen({super.key});

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
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            height: 240.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32.r), bottomRight: Radius.circular(32.r)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
                      Expanded(child: Text('Slip Gaji', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: BlocBuilder<PayslipCubit, PayslipState>(
                    builder: (context, state) {
                      if (state is PayslipLoading) {
                        return ListView.separated(
                          padding: EdgeInsets.all(24.w),
                          itemCount: 5,
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (_, __) => Container(height: 120.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r))),
                        );
                      } else if (state is PayslipLoaded) {
                        final payslips = state.payslips;
                        if (payslips.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(24.w),
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
                                  child: Icon(Icons.receipt, size: 64.w, color: AppColors.primary),
                                ),
                                SizedBox(height: 24.h),
                                Text('Belum ada slip gaji', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                SizedBox(height: 8.h),
                                Text('Data payroll Anda akan tampil di sini.', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () => context.read<PayslipCubit>().loadHistory(),
                          color: AppColors.primary,
                          child: ListView.separated(
                            padding: EdgeInsets.all(24.w),
                            itemCount: payslips.length,
                            separatorBuilder: (_, __) => SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final item = payslips[index];
                              final netSalaryStr = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(item.netSalary);
                              return GestureDetector(
                                onTap: () => context.push('/app/payslip/detail', extra: item),
                                child: Container(
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                        child: Icon(Icons.request_quote_rounded, color: AppColors.primary, size: 28.w),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.periodLabel,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.onSurface),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(netSalaryStr, style: TextStyle(color: Colors.grey[800], fontSize: 15.sp, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (state is PayslipError) {
                        return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
