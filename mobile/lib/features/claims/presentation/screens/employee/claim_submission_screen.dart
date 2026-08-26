import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/claim_models.dart';
import '../../../bloc/claim_cubit.dart';

class ClaimSubmissionScreen extends StatefulWidget {
  const ClaimSubmissionScreen({super.key});
  @override
  State<ClaimSubmissionScreen> createState() => _ClaimSubmissionScreenState();
}

class _ClaimSubmissionScreenState extends State<ClaimSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedCategoryId;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _expenseDate;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
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
      setState(() => _expenseDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _expenseDate != null &&
        _selectedCategoryId != null) {
      final df = DateFormat('yyyy-MM-dd');
      context.read<ClaimCubit>().submit(
            categoryId: _selectedCategoryId!,
            amount: double.tryParse(_amountController.text) ?? 0.0,
            expenseDate: df.format(_expenseDate!),
            description: _descController.text,
          );
    } else if (_expenseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih tanggal pengeluaran terlebih dahulu.'),
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
            Text('Klaim Berhasil!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            SizedBox(height: 8.h),
            Text('Pengajuan klaim Anda telah dikirim dan menunggu persetujuan.',
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
                  context.read<ClaimCubit>().loadAll(); // reload history
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
              onPressed: () => context.pop()),
          title: Text('Ajukan Klaim',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.bold)),
          centerTitle: true),
      body: BlocConsumer<ClaimCubit, ClaimState>(
        listener: (context, state) {
          if (state is ClaimSubmitted) {
            _showSuccessDialog();
          } else if (state is ClaimError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ClaimLoading;

          List<ClaimCategoryModel> categories = [];
          if (state is ClaimLoaded) {
            categories = state.categories;
          } else if (context.read<ClaimCubit>().state is ClaimLoaded)
            categories =
                (context.read<ClaimCubit>().state as ClaimLoaded).categories;

          if (categories.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = categories.first.id;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('KATEGORI'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      items: categories
                          .map((c) => DropdownMenuItem<int>(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (v) {
                              if (v != null)
                                setState(() => _selectedCategoryId = v);
                            },
                      decoration: _deco('Pilih kategori'),
                      validator: (v) =>
                          v == null ? 'Wajib pilih kategori' : null,
                    ),
                    SizedBox(height: 24.h),
                    _label('JUMLAH (Rp)'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: _deco('e.g. 150000'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Jumlah wajib diisi' : null,
                      enabled: !isLoading,
                    ),
                    SizedBox(height: 24.h),
                    _label('DESKRIPSI'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: _deco('Jelaskan detail klaim...'),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Deskripsi wajib diisi'
                          : null,
                      enabled: !isLoading,
                    ),
                    SizedBox(height: 24.h),
                    _label('TANGGAL PENGELUARAN'),
                    SizedBox(height: 8.h),
                    InkWell(
                        onTap: isLoading ? null : _selectDate,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.5))),
                          child: Row(children: [
                            Icon(Icons.calendar_today,
                                color: AppColors.onSurfaceVariant, size: 20.w),
                            SizedBox(width: 12.w),
                            Text(
                                _expenseDate != null
                                    ? DateFormat('dd MMM yyyy')
                                        .format(_expenseDate!)
                                    : 'Pilih tanggal',
                                style: TextStyle(
                                    color: _expenseDate != null
                                        ? AppColors.onSurface
                                        : AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                    fontSize: 14.sp))
                          ]),
                        )),
                    SizedBox(height: 24.h),
                    _label('BUKTI STRUK/NOTA (OPSIONAL)'),
                    SizedBox(height: 8.h),
                    InkWell(
                        onTap: isLoading ? null : () {},
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 32.h),
                          decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withValues(alpha: 0.5))),
                          child: Column(children: [
                            Icon(Icons.camera_alt_outlined,
                                color: AppColors.onSurfaceVariant, size: 32.w),
                            SizedBox(height: 8.h),
                            Text('Foto atau upload struk',
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 12.sp))
                          ]),
                        )),
                    SizedBox(height: 32.h),
                    SizedBox(
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r))),
                          child: isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(
                                      color: AppColors.onPrimary,
                                      strokeWidth: 2))
                              : Text('Kirim Klaim',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp)),
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2));
  InputDecoration _deco(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primaryContainer)));
}
