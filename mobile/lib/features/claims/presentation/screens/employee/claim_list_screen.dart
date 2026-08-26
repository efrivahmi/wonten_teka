import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../bloc/claim_cubit.dart';

class ClaimListScreen extends StatefulWidget {
  const ClaimListScreen({super.key});

  @override
  State<ClaimListScreen> createState() => _ClaimListScreenState();
}

class _ClaimListScreenState extends State<ClaimListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimCubit>().loadAll();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/app/claims/new');
          if (!context.mounted) return;
          context.read<ClaimCubit>().loadAll();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajukan Klaim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
                      Expanded(child: Text('Riwayat Klaim', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: BlocBuilder<ClaimCubit, ClaimState>(
                    builder: (context, state) {
                      if (state is ClaimLoading) {
                        return ListView.separated(
                          padding: EdgeInsets.all(24.w),
                          itemCount: 5,
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (_, __) => Container(height: 100.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r))),
                        );
                      } else if (state is ClaimLoaded) {
                        final claims = state.history;
                        if (claims.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(24.w),
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)]),
                                  child: Icon(Icons.receipt_long, size: 64.w, color: AppColors.primary),
                                ),
                                SizedBox(height: 24.h),
                                Text('Belum ada riwayat klaim', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                SizedBox(height: 8.h),
                                Text('Ajukan reimbursement untuk biaya pekerjaan.', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () => context.read<ClaimCubit>().loadAll(),
                          color: AppColors.primary,
                          child: ListView.separated(
                            padding: EdgeInsets.all(24.w),
                            itemCount: claims.length,
                            separatorBuilder: (_, __) => SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final item = claims[index];
                              return Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.claimCategory?.name ?? 'Klaim',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.onSurface),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        _buildStatusChip(item.status),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16.w, color: Colors.grey[500]),
                                        SizedBox(width: 8.w),
                                        Text(DateFormat('dd MMM yyyy').format(item.expenseDate), style: TextStyle(color: Colors.grey[700], fontSize: 13.sp)),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money, size: 16.w, color: Colors.grey[500]),
                                        SizedBox(width: 8.w),
                                        Text(
                                          NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(item.amount),
                                          style: TextStyle(color: Colors.grey[800], fontSize: 14.sp, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      } else if (state is ClaimError) {
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

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
        color = AppColors.successEmerald;
        label = 'Disetujui';
        break;
      case 'rejected':
        color = AppColors.errorCrimson;
        label = 'Ditolak';
        break;
      default:
        color = AppColors.warningAmber;
        label = 'Pending';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}
