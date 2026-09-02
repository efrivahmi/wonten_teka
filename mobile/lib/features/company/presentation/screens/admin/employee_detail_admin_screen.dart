import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/info_card.dart';
import '../../../../../core/api/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmployeeDetailAdminScreen extends StatelessWidget {
  final Map<String, dynamic> employee;

  const EmployeeDetailAdminScreen({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final name = employee['full_name'] ?? employee['name'] ?? 'Karyawan';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final department = employee['department'] ?? '-';
    final position = employee['position'] ?? '-';
    final email = employee['email'] ?? employee['user']?['email'] ?? '-';
    final phone = employee['phone'] ?? '-';
    final joinDate = employee['join_date'] != null
        ? DateFormat('d MMM yyyy').format(DateTime.parse(employee['join_date']))
        : '-';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail Karyawan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              final result =
                  await context.push('/admin/employees/edit', extra: employee);
              if (result == true) {
                // Return true to EmployeeManagementScreen so it reloads
                if (context.mounted) {
                  context.pop(true);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48.r,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 32.sp,
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              position,
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            InfoCard(
              child: Column(
                children: [
                  _Row(label: 'Departemen', value: department),
                  Divider(
                      height: 20.h,
                      color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  _Row(label: 'Email', value: email),
                  Divider(
                      height: 20.h,
                      color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  _Row(label: 'Telepon', value: phone),
                  Divider(
                      height: 20.h,
                      color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  _Row(label: 'Tanggal Bergabung', value: joinDate),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.calendar_month,
                    label: 'Jadwal',
                    onTap: () {},
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.receipt_long,
                    label: 'Slip Gaji',
                    onTap: () {},
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionBtn(
                    icon: Icons.analytics,
                    label: 'Laporan',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            if (employee['is_active'] == true || employee['is_active'] == 1)
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => _confirmDeactivate(context, employee['id']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Nonaktifkan Karyawan',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                ),
              ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, int empId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nonaktifkan Karyawan?'),
        content: const Text(
            'Karyawan ini tidak akan bisa login lagi ke aplikasi. Anda yakin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Ya, Nonaktifkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (!context.mounted) return;
        final api = context.read<ApiClient>();
        await api.delete('/admin/employees/$empId');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Karyawan berhasil dinonaktifkan'),
              backgroundColor: AppColors.successEmerald,
            ),
          );
          // Pop and tell previous screen to reload
          context.pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menonaktifkan: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
          Text(value,
              style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp)),
        ],
      );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
}

