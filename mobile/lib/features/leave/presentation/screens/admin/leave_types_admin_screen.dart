import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/leave_models.dart';
import '../../../bloc/leave_cubit.dart';

class LeaveTypesAdminScreen extends StatefulWidget {
  const LeaveTypesAdminScreen({super.key});

  @override
  State<LeaveTypesAdminScreen> createState() => _LeaveTypesAdminScreenState();
}

class _LeaveTypesAdminScreenState extends State<LeaveTypesAdminScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaveCubit>().loadAdminTypes();
  }

  void _confirmDelete(LeaveTypeModel type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tipe Cuti'),
        content: Text('Apakah Anda yakin ingin menghapus tipe cuti "${type.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LeaveCubit>().deleteLeaveType(type.id);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.errorCrimson)),
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
        title: const Text('Tipe Cuti'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/leave-types/form').then((_) => context.read<LeaveCubit>().loadAdminTypes()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<LeaveCubit, LeaveState>(
        listener: (context, state) {
          if (state is LeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.errorCrimson));
          }
        },
        builder: (context, state) {
          if (state is LeaveLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LeaveLoaded) {
            if (state.types.isEmpty) {
              return Center(
                child: Text('Belum ada tipe cuti. Silakan tambah.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.types.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final type = state.types[index];
                return _buildLeaveTypeCard(type);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLeaveTypeCard(LeaveTypeModel type) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.onSurface),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${type.quotaPerYear ?? 0} Hari${type.isPaid ? ' • Dibayar' : ' • Tidak Dibayar'}',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.sp),
                  ),
                  if (!type.isActive)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text('Tidak Aktif', style: TextStyle(color: AppColors.errorCrimson, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () {
                context.push('/admin/leave-types/form', extra: type).then((_) => context.read<LeaveCubit>().loadAdminTypes());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorCrimson),
              onPressed: () => _confirmDelete(type),
            ),
          ],
        ),
      ),
    );
  }
}
