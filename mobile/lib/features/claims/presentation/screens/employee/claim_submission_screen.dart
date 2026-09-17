import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:wonten_teka_mobile/core/widgets/success_submission_screen.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/claim_models.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../bloc/claim_cubit.dart';

class ClaimSubmissionScreen extends StatefulWidget {
  const ClaimSubmissionScreen({super.key});
  @override
  State<ClaimSubmissionScreen> createState() => _ClaimSubmissionScreenState();
}

class _ClaimSubmissionScreenState extends State<ClaimSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Cached categories to prevent dropdown crash on state changes
  List<ClaimCategoryModel> _categories = [];
  
  int? _selectedCategoryId;
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _expenseDate;
  File? _attachment;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fetch categories if they are loaded in the current state
    final currentState = context.read<ClaimCubit>().state;
    if (currentState is ClaimLoaded) {
      _categories = currentState.categories;
    }
  }

  Future<void> _pickFile() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _attachment = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

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
            receiptPath: _attachment?.path,
          );
    } else if (_expenseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih tanggal pengeluaran terlebih dahulu.'),
            backgroundColor: AppColors.errorCrimson),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const AppBrandTitle(section: 'Pengajuan Klaim'),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BrandPageBackground(
        child: BlocConsumer<ClaimCubit, ClaimState>(
          listener: (context, state) {
            if (state is ClaimError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 8.w),
                      Expanded(child: Text(state.message, style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                  backgroundColor: AppColors.errorCrimson,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              );
            }
          },
          builder: (context, state) {
            // Success Full Page
            if (state is ClaimSubmitted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SuccessSubmissionScreen(
                      title: 'Klaim Berhasil Dikirim!',
                      message: 'Pengajuan klaim Anda telah dicatat dalam sistem dan saat ini sedang menunggu persetujuan dari atasan atau HRD.',
                    ),
                  ),
                );
              });
              return const Center(child: CircularProgressIndicator());
            }

            // Sync categories if loaded successfully to prevent dropdown crash
            if (state is ClaimLoaded && state.categories.isNotEmpty) {
              _categories = state.categories;
            }

            bool isLoading = state is ClaimLoading;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jenis Klaim', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCategoryId,
                        decoration: InputDecoration(
                          filled: true, fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          helperText: 'Pilih jenis klaim yang sesuai dengan bukti',
                        ),
                        hint: const Text('Pilih Jenis Klaim'),
                        items: _categories.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                        onChanged: isLoading ? null : (v) => setState(() => _selectedCategoryId = v),
                        validator: (v) => v == null ? 'Pilih jenis klaim' : null,
                      ),
                      SizedBox(height: 24.h),
                      
                      Text('Tanggal Kejadian / Pembelian', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: isLoading ? null : _selectDate,
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[50], borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, color: AppColors.primary, size: 20.w),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(_expenseDate == null ? 'Pilih Tanggal' : DateFormat('dd MMM yyyy', 'id_ID').format(_expenseDate!), style: TextStyle(color: _expenseDate == null ? Colors.grey[500] : AppColors.onSurface, fontSize: 14.sp)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, left: 16.w),
                        child: Text('Tanggal yang tertera pada nota', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                      ),
                      SizedBox(height: 24.h),
                      
                      Text('Nominal (Rp)', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Contoh: 150000',
                          filled: true, fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          prefixText: 'Rp ',
                          helperText: 'Masukkan total nominal pengeluaran',
                        ),
                        validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? 'Masukkan nominal valid' : null,
                      ),
                      SizedBox(height: 24.h),
                      
                      Text('Keterangan', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Jelaskan keperluan klaim secara detail...',
                          filled: true, fillColor: Colors.grey[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide(color: Colors.grey[200]!)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          helperText: 'Wajib diisi agar pengajuan lebih cepat diproses',
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
                      ),
                      SizedBox(height: 24.h),
                      
                      Text('Lampiran Bukti (Opsional)', style: TextStyle(color: AppColors.onSurface, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: isLoading ? null : _pickFile,
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 32.w, color: AppColors.primary),
                              SizedBox(height: 8.h),
                              Text(_attachment == null ? 'Upload Foto / Bukti Transaksi' : 'File dipilih:\n${_attachment!.path.split('/').last.split('\\').last}', 
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.h, left: 16.w),
                        child: Text('Pastikan tulisan pada nota terbaca jelas', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
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
    );
  }
}
