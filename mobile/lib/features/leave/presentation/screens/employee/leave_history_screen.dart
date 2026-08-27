import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/error_state_widget.dart';
import '../../../bloc/leave_cubit.dart';

class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaveCubit>().loadAll();
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.all(24.w),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      title: 'Belum ada riwayat cuti',
      message: 'Ajukan cuti untuk beristirahat.',
      icon: Icons.beach_access,
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = AppColors.successEmerald.withValues(alpha: 0.1);
        textColor = AppColors.successEmerald;
        text = 'Disetujui';
        break;
      case 'rejected':
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        text = 'Ditolak';
        break;
      default:
        bgColor = Colors.amber.withValues(alpha: 0.1);
        textColor = Colors.amber[800]!;
        text = 'Menunggu';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/leave/new').then((_) => context.read<LeaveCubit>().loadAll()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajukan Cuti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      Expanded(child: Text('Riwayat Cuti', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: BlocBuilder<LeaveCubit, LeaveState>(
                    builder: (context, state) {
                      if (state is LeaveLoading) {
                        return _buildShimmer();
                      } else if (state is LeaveLoaded) {
                        final history = state.history;
                        if (history.isEmpty) return _buildEmptyState();

                        return RefreshIndicator(
                          onRefresh: () => context.read<LeaveCubit>().loadAll(),
                          color: AppColors.primary,
                          child: ListView.separated(
                            padding: EdgeInsets.all(24.w),
                            itemCount: history.length,
                            separatorBuilder: (_, __) => SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              final startDate = DateFormat('d MMM yyyy').format(item.startDate);
                              final endDate = DateFormat('d MMM yyyy').format(item.endDate);

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
                                            item.leaveType?.name ?? 'Cuti',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.onSurface),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                        Text('$startDate - $endDate', style: TextStyle(color: Colors.grey[700], fontSize: 13.sp)),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(Icons.note_alt_outlined, size: 16.w, color: Colors.grey[500]),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            item.reason,
                                            style: TextStyle(color: Colors.grey[700], fontSize: 13.sp),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      } else if (state is LeaveError) {
                        return ErrorStateWidget(
                          message: state.message,
                          onRetry: () => context.read<LeaveCubit>().loadAll(),
                        );
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
