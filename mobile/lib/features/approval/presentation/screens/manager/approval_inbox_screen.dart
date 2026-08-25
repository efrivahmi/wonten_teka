import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isApprove ? 'Setujui Permintaan?' : 'Tolak Permintaan?'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            hintText: 'Tambahkan catatan (opsional)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (isApprove) {
                context.read<ApprovalCubit>().approve(request.id, comment: commentController.text);
              } else {
                context.read<ApprovalCubit>().reject(request.id, comment: commentController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppColors.successEmerald : AppColors.errorCrimson,
            ),
            child: Text(isApprove ? 'Setujui' : 'Tolak'),
          ),
        ],
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is ApprovalLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ApprovalLoaded) {
            final requests = state.pending;
            
            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64.w, color: AppColors.successEmerald),
                    SizedBox(height: 16.h),
                    Text(
                      'Semua bersih!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Tidak ada permintaan yang menunggu.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
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
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

