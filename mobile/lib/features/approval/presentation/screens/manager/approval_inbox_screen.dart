import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/error_state_widget.dart';
import '../../../bloc/approval_cubit.dart';
import '../../../../../core/models/approval_instance_model.dart';

class ApprovalInboxScreen extends StatefulWidget {
  const ApprovalInboxScreen({super.key});

  @override
  State<ApprovalInboxScreen> createState() => _ApprovalInboxScreenState();
}

class _ApprovalInboxScreenState extends State<ApprovalInboxScreen> {
  String _selectedFilter = 'Semua';

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
                hintText: 'Tambahkan catatan (opsional)...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
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
          List<ApprovalInstanceModel> requests = [];
          if (state is ApprovalLoaded) {
            requests = state.pending;
          } else if (context.read<ApprovalCubit>().state is ApprovalLoaded) {
            requests = (context.read<ApprovalCubit>().state as ApprovalLoaded).pending;
          }

          if (_selectedFilter != 'Semua') {
            if (_selectedFilter == 'Cuti / Dinas') {
              requests = requests.where((r) => r.requestType == 'Cuti' || r.requestType == 'Dinas Luar').toList();
            } else if (_selectedFilter == 'Lainnya') {
              requests = requests.where((r) => r.requestType != 'Cuti' && r.requestType != 'Dinas Luar' && r.requestType != 'Lembur' && r.requestType != 'Lupa Absen').toList();
            } else {
              requests = requests.where((r) => r.requestType == _selectedFilter).toList();
            }
          }

          Widget content;
          if (state is ApprovalLoading && context.read<ApprovalCubit>().state is! ApprovalLoaded) {
            content = ListView.separated(
              padding: EdgeInsets.all(16.w),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return Container(height: 160.h, width: double.infinity, decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16.r)));
              },
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: AppColors.surface.withValues(alpha: 0.5));
          } else if (state is ApprovalError && context.read<ApprovalCubit>().state is! ApprovalLoaded) {
            content = ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<ApprovalCubit>().loadPending(),
            );
          } else if (requests.isEmpty) {
            content = RefreshIndicator(
              onRefresh: () async => context.read<ApprovalCubit>().loadPending(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100.h),
                  const EmptyStateWidget(
                    title: 'Semua bersih!',
                    message: 'Tidak ada permintaan yang menunggu persetujuan Anda saat ini.',
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            );
          } else {
            content = RefreshIndicator(
              onRefresh: () async => context.read<ApprovalCubit>().loadPending(),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final req = requests[index];
                  
                  return InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8.r)),
                              child: Text(req.requestType, style: TextStyle(color: AppColors.primary, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                            ),
                            Text(
                              req.createdAt != null ? DateFormat('dd MMM yyyy').format(req.createdAt!) : '',
                              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.person, color: AppColors.primary, size: 20.w),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    req.approvable?['employee']?['full_name'] ?? 'Karyawan',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "Posisi: ${req.approvable?['employee']?['position'] ?? '-'}",
                                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (req.approvable?['reason'] != null) ...[
                                Text('Alasan:', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                SizedBox(height: 4.h),
                                Text(req.approvable!['reason'].toString(), style: TextStyle(color: AppColors.onSurface, fontSize: 13.sp)),
                              ],
                              if (req.requestType == 'Cuti') ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14.w, color: AppColors.primary),
                                    SizedBox(width: 6.w),
                                    Text("${req.approvable?['start_date']} - ${req.approvable?['end_date']}", style: TextStyle(color: AppColors.onSurface, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                              if (req.requestType == 'Lembur') ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14.w, color: AppColors.primary),
                                    SizedBox(width: 6.w),
                                    Text("${req.approvable?['date']} (${req.approvable?['start_time']} - ${req.approvable?['end_time']})", style: TextStyle(color: AppColors.onSurface, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                              if (req.requestType == 'Tukar Shift') ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.swap_horiz, size: 14.w, color: AppColors.primary),
                                    SizedBox(width: 6.w),
                                    Text("${req.approvable?['original_date']} \u2192 ${req.approvable?['proposed_date']}", style: TextStyle(color: AppColors.onSurface, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                              if (req.requestType == 'Lupa Absen') ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.history_toggle_off, size: 14.w, color: AppColors.primary),
                                    SizedBox(width: 6.w),
                                    Text("${req.approvable?['date']} (${req.approvable?['check_in']} - ${req.approvable?['check_out']})", style: TextStyle(color: AppColors.onSurface, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                              if (req.requestType == 'Dinas Luar') ...[
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.card_travel, size: 14.w, color: AppColors.primary),
                                    SizedBox(width: 6.w),
                                    Text("${req.approvable?['start_date']} - ${req.approvable?['end_date']} di ${req.approvable?['location']}", style: TextStyle(color: AppColors.onSurface, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showActionDialog(context, req, false),
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorCrimson, side: const BorderSide(color: AppColors.errorCrimson), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                                child: const Text('Tolak'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => _showActionDialog(context, req, true),
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                                child: const Text('Setujui'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.05, end: 0);
                },
              ),
            );
          }

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: ['Semua', 'Cuti / Dinas', 'Lembur', 'Lupa Absen', 'Lainnya'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: AppColors.primaryContainer,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.outlineVariant),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}
