import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/leave_models.dart';
import '../../../bloc/leave_cubit.dart';

class LeaveRequestFormScreen extends StatefulWidget {
  const LeaveRequestFormScreen({super.key});

  @override
  State<LeaveRequestFormScreen> createState() => _LeaveRequestFormScreenState();
}

class _LeaveRequestFormScreenState extends State<LeaveRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedTypeId;
  DateTimeRange? _dateRange;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _dateRange != null &&
        _selectedTypeId != null) {
      final df = DateFormat('yyyy-MM-dd');
      context.read<LeaveCubit>().submitRequest(
            leaveTypeId: _selectedTypeId!,
            startDate: df.format(_dateRange!.start),
            endDate: df.format(_dateRange!.end),
            reason: _reasonController.text,
          );
    } else if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih rentang tanggal cuti terlebih dahulu.'),
            backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.successEmerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline,
                  color: AppColors.successEmerald, size: 48.w),
            ),
            SizedBox(height: 16.h),
            Text('Berhasil!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            SizedBox(height: 8.h),
            Text('Pengajuan cuti Anda telah dikirim dan menunggu persetujuan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // close dialog
                  context.pop(); // pop form screen
                  context.read<LeaveCubit>().loadAll(); // reload history
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r))),
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ajukan Cuti',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<LeaveCubit, LeaveState>(
        listener: (context, state) {
          if (state is LeaveSubmitted) {
            _showSuccessDialog();
          } else if (state is LeaveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LeaveLoading;

          List<LeaveTypeModel> types = [];
          if (state is LeaveLoaded) {
            types = state.types;
          } else if (context.read<LeaveCubit>().state is LeaveLoaded)
            types = (context.read<LeaveCubit>().state as LeaveLoaded).types;

          if (types.isNotEmpty && _selectedTypeId == null) {
            _selectedTypeId = types.first.id;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Leave Type
                    Text(
                      'JENIS CUTI',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedTypeId,
                      items: types
                          .map((type) => DropdownMenuItem<int>(
                              value: type.id, child: Text(type.name)))
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null)
                                setState(() => _selectedTypeId = value);
                            },
                      decoration: _inputDecoration('Pilih jenis cuti'),
                      validator: (v) => v == null ? 'Pilih jenis cuti' : null,
                    ),
                    SizedBox(height: 24.h),

                    // Date Range
                    Text(
                      'TANGGAL',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: isLoading ? null : _selectDateRange,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: AppColors.outlineVariant
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range,
                                color: AppColors.onSurfaceVariant, size: 20.w),
                            SizedBox(width: 12.w),
                            Text(
                              _dateRange != null
                                  ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                                  : 'Pilih tanggal cuti',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: _dateRange != null
                                        ? AppColors.onSurface
                                        : AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Reason
                    Text(
                      'ALASAN',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration:
                          _inputDecoration('Jelaskan alasan pengajuan cuti'),
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Wajib diisi' : null,
                      enabled: !isLoading,
                    ),
                    SizedBox(height: 24.h),

                    // Attachment
                    Text(
                      'LAMPIRAN (OPSIONAL)',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: isLoading ? null : () {},
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color:
                                AppColors.outlineVariant.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                color: AppColors.onSurfaceVariant, size: 32.w),
                            SizedBox(height: 8.h),
                            Text(
                              'Tap untuk upload file',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Submit Button
                    SizedBox(
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                    color: AppColors.onPrimary, strokeWidth: 2))
                            : Text(
                                'Kirim Pengajuan',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:
            BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:
            BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primaryContainer),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
