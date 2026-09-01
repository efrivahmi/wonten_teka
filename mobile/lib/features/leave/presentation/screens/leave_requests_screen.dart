import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../bloc/leave_cubit.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key});

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveCubit>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Cuti Saya',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/app/leave/new'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Cuti'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          context.read<LeaveCubit>().loadAll();
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: BlocBuilder<LeaveCubit, LeaveState>(
          builder: (context, state) {
            if (state is LeaveLoading) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(2, (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index == 0 ? 8.w : 0),
                          child: InfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 12.h, width: 60.w, color: AppColors.surfaceContainerHigh),
                                SizedBox(height: 12.h),
                                Container(height: 32.h, width: 80.w, color: AppColors.surfaceContainerHigh),
                                SizedBox(height: 8.h),
                                Container(height: 12.h, width: 100.w, color: AppColors.surfaceContainerHigh),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ),
                    SizedBox(height: 24.h),
                    Container(height: 16.h, width: 150.w, color: AppColors.surfaceContainerHigh),
                    SizedBox(height: 12.h),
                    ...List.generate(4, (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: InfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(height: 16.h, width: 100.w, color: AppColors.surfaceContainerHigh),
                                Container(height: 24.h, width: 60.w, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12.r))),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Container(height: 12.h, width: double.infinity, color: AppColors.surfaceContainerHigh),
                            SizedBox(height: 4.h),
                            Container(height: 12.h, width: 200.w, color: AppColors.surfaceContainerHigh),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: AppColors.surface.withValues(alpha: 0.5));
            } else if (state is LeaveError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100.h),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 64.w, color: AppColors.error.withValues(alpha: 0.7)),
                          SizedBox(height: 16.h),
                          Text(
                            'Gagal Memuat Data',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton.icon(
                            onPressed: () => context.read<LeaveCubit>().loadAll(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is LeaveLoaded) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave Balance Cards
                    if (state.balances.isNotEmpty) ...[
                      Row(
                        children: state.balances.take(2).map((balance) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: _LeaveBalanceCard(
                                label: balance.leaveType?.name ?? 'Cuti',
                                used: balance.usedDays,
                                total: balance.entitledDays,
                                color: AppColors.infoCerulean,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                    ],
  
                    // History Header
                    Text(
                      'Riwayat Pengajuan',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 12.h),
  
                    // Request List
                    if (state.history.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(24.w),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.event_busy,
                                    size: 48.w,
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.5)),
                              ),
                              SizedBox(height: 16.h),
                              Text('Belum ada riwayat cuti',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.bold)),
                              SizedBox(height: 8.h),
                              Text(
                                  'Anda belum pernah mengajukan cuti.\nKlik tombol di bawah untuk mulai.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...state.history.map((request) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _LeaveRequestItem(
                            type: request.leaveType?.name ?? 'Cuti',
                            dateRange:
                                '${DateFormat('dd MMM yyyy').format(request.startDate)} - ${DateFormat('dd MMM yyyy').format(request.endDate)}',
                            reason: request.reason,
                            status: request.status,
                          ),
                        );
                      }),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _LeaveBalanceCard extends StatelessWidget {
  final String label;
  final int used;
  final int total;
  final Color color;

  const _LeaveBalanceCard({
    required this.label,
    required this.used,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = total - used;
    final progress = total > 0 ? used / total : 0.0;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$remaining sisa',
                  style: TextStyle(
                    color: color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$used dari $total hari digunakan',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _LeaveRequestItem extends StatelessWidget {
  final String type;
  final String dateRange;
  final String reason;
  final String status;

  const _LeaveRequestItem({
    required this.type,
    required this.dateRange,
    required this.reason,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              _buildBadge(),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14.w, color: AppColors.onSurfaceVariant),
              SizedBox(width: 6.w),
              Text(
                dateRange,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            reason,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    switch (status.toLowerCase()) {
      case 'approved':
        return StatusBadge.approved();
      case 'pending':
        return StatusBadge.pending();
      case 'rejected':
        return StatusBadge.rejected();
      default:
        return StatusBadge.pending();
    }
  }
}
