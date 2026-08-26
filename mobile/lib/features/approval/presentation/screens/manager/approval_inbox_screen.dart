import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../bloc/approval_cubit.dart';
import '../../../../../core/models/approval_instance_model.dart';

class ApprovalInboxScreen extends StatefulWidget {
  const ApprovalInboxScreen({super.key});

  @override
  State<ApprovalInboxScreen> createState() => _ApprovalInboxScreenState();
}

class _ApprovalInboxScreenState extends State<ApprovalInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApprovalCubit>().loadPending();
    });
  }

  void _showActionDialog(BuildContext context, ApprovalInstanceModel request, bool isApprove) {
    final commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Text(isApprove ? 'Setujui Permintaan?' : 'Tolak Permintaan?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            SizedBox(height: 16.h),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan (opsional)',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
                    child: const Text('Batal'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (isApprove) {
                        context.read<ApprovalCubit>().approve(request.id, comment: commentController.text);
                      } else {
                        context.read<ApprovalCubit>().reject(request.id, comment: commentController.text);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: isApprove ? AppColors.successEmerald : AppColors.errorCrimson,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text(isApprove ? 'Setujui' : 'Tolak'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  void _showErrorSheet(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 24.h),
            Icon(Icons.error_outline, color: AppColors.error, size: 56.w),
            SizedBox(height: 16.h),
            Text('Gagal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            SizedBox(height: 8.h),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
                child: const Text('Tutup'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Approval Inbox',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ApprovalCubit, ApprovalState>(
        listener: (context, state) {
          if (state is ApprovalActioned) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.successEmerald),
            );
            context.read<ApprovalCubit>().loadPending();
          } else if (state is ApprovalError) {
            _showErrorSheet(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is ApprovalLoading && context.read<ApprovalCubit>().state is! ApprovalLoaded) {
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return Container(height: 160.h, width: double.infinity, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16.r)));
              },
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: AppColors.surface.withValues(alpha: 0.5));
          } else if (state is ApprovalError && context.read<ApprovalCubit>().state is! ApprovalLoaded) {
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
                        Text('Gagal Memuat Data', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () => context.read<ApprovalCubit>().loadPending(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          
          List<ApprovalInstanceModel> requests = [];
          if (state is ApprovalLoaded) {
            requests = state.pending;
          } else if (context.read<ApprovalCubit>().state is ApprovalLoaded) {
            requests = (context.read<ApprovalCubit>().state as ApprovalLoaded).pending;
          }
          
          if (requests.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => context.read<ApprovalCubit>().loadPending(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100.h),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                            child: Icon(Icons.check_circle_outline, size: 48.w, color: AppColors.successEmerald.withValues(alpha: 0.7)),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Semua bersih!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tidak ada permintaan yang menunggu persetujuan Anda saat ini.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
            
            return RefreshIndicator(
              onRefresh: () async => context.read<ApprovalCubit>().loadPending(),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: requests.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  // Asumsi bahwa request.model berisi informasi spesifik cuti/klaim, dan requester_id/name tersedia jika nested model
                  // Karena modelnya polymorphic, kita sesuaikan tampilannya
                  final typeLabel = request.requestType;
                                    
                  return InfoCard(
                    onTap: () {}, // context.push('/app/leave/approval-detail', extra: request),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$typeLabel #${request.approvableId}',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            StatusBadge.pending(),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14.w, color: AppColors.onSurfaceVariant),
                            SizedBox(width: 6.w),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(request.createdAt ?? DateTime.now()),
                              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showActionDialog(context, request, false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.errorCrimson,
                                  side: const BorderSide(color: AppColors.errorCrimson),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                                child: const Text('Tolak'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showActionDialog(context, request, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successEmerald,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                                child: const Text('Setujui'),
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
        },
      ),
    );
  }
}

