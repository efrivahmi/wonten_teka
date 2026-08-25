import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/widgets/status_badge.dart';
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

  IconData _getIconForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('transport')) return Icons.directions_car;
    if (lower.contains('makan')) return Icons.restaurant;
    if (lower.contains('medis') || lower.contains('kesehatan')) {
      return Icons.local_hospital;
    }
    return Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Riwayat Klaim',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/claims/new'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Klaim'),
      ),
      body: BlocBuilder<ClaimCubit, ClaimState>(
        builder: (context, state) {
          if (state is ClaimLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClaimError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppColors.error)));
          } else if (state is ClaimLoaded) {
            if (state.history.isEmpty) {
              return const Center(child: Text('Belum ada riwayat klaim'));
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.history.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) {
                final claim = state.history[i];
                return InfoCard(
                  onTap: () =>
                      context.push('/app/claims/detail'), // Should pass ID
                  child: Row(children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12.r)),
                      child: Icon(
                          _getIconForCategory(claim.claimCategory?.name ?? ''),
                          color: AppColors.primary,
                          size: 24.w),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(claim.claimCategory?.name ?? 'Klaim',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4.h),
                          Text(
                              DateFormat('dd MMM yyyy')
                                  .format(claim.expenseDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currencyFormatter.format(claim.amount),
                            style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp)),
                        SizedBox(height: 4.h),
                        claim.status.toLowerCase() == 'approved'
                            ? StatusBadge.approved()
                            : claim.status.toLowerCase() == 'pending'
                                ? StatusBadge.pending()
                                : StatusBadge.rejected(),
                      ],
                    ),
                  ]),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
