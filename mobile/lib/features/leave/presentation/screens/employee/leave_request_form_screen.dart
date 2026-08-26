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

  void _showErrorSheet(String message) {
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
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 24.h),
            Icon(Icons.error_outline, color: AppColors.error, size: 56.w),
            SizedBox(height: 16.h),
            Text('Pengajuan Gagal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            SizedBox(height: 8.h),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onError, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
                child: const Text('Tutup & Coba Lagi'),
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
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            height: 240.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          'Pengajuan Cuti',
                          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                
                Expanded(
                  child: BlocConsumer<LeaveCubit, LeaveState>(
                    listener: (context, state) {
                      if (state is LeaveSubmitted) {
                        _showSuccessDialog();
                      } else if (state is LeaveError) {
                        _showErrorSheet(state.message);
                      }
                    },
                    builder: (context, state) {
                      bool isLoading = state is LeaveLoading;
                      List<LeaveTypeModel> types = [];
                      if (state is LeaveLoaded) types = state.types;
                      
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Jenis Cuti', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.h),
                                DropdownButtonFormField<int>(
                                  initialValue: _selectedTypeId,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                  ),
                                  hint: const Text('Pilih Jenis Cuti'),
                                  items: types.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                                  onChanged: isLoading ? null : (v) => setState(() => _selectedTypeId = v),
                                  validator: (v) => v == null ? 'Pilih jenis cuti' : null,
                                ),
                                SizedBox(height: 24.h),
                                
                                Text('Rentang Tanggal', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.h),
                                InkWell(
                                  onTap: isLoading ? null : _selectDateRange,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_month, color: AppColors.primary, size: 20.w),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            _dateRange == null
                                                ? 'Pilih tanggal mulai & akhir'
                                                : '${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                                            style: TextStyle(color: _dateRange == null ? Colors.grey[600] : Colors.black87, fontSize: 14.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                
                                Text('Alasan Cuti', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: _reasonController,
                                  maxLines: 4,
                                  enabled: !isLoading,
                                  decoration: InputDecoration(
                                    hintText: 'Jelaskan alasan cuti Anda',
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                  ),
                                  validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                                ),
                                
                                SizedBox(height: 32.h),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52.h,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? SizedBox(width: 24.w, height: 24.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text('Kirim Pengajuan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
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
