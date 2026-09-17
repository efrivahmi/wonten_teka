import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/models/leave_models.dart';
import '../../../../../core/widgets/app_brand_title.dart';
import '../../../../../core/widgets/brand_panel.dart';
import '../../../../../core/widgets/success_submission_screen.dart';
import '../../../bloc/leave_cubit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  File? _attachment;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFile() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _attachment = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

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
      final currentState = context.read<LeaveCubit>().state;
      final requestedDays =
          _dateRange!.end.difference(_dateRange!.start).inDays + 1;
      if (_dateRange!.start.year != _dateRange!.end.year ||
          _dateRange!.start.month != _dateRange!.end.month) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Pengajuan tidak boleh melewati pergantian bulan. Buat pengajuan terpisah untuk setiap bulan.'),
          backgroundColor: AppColors.error,
        ));
        return;
      }
      if (currentState is LeaveLoaded) {
        final matching = currentState.balances.where((item) =>
            item.leaveTypeId == _selectedTypeId &&
            item.year == _dateRange!.start.year &&
            item.month == _dateRange!.start.month);
        if (matching.isNotEmpty &&
            requestedDays > matching.first.remainingDays) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Pengajuan $requestedDays hari melebihi sisa kuota ${matching.first.remainingDays} hari.'),
            backgroundColor: AppColors.error,
          ));
          return;
        }
      }
      final df = DateFormat('yyyy-MM-dd');
      context.read<LeaveCubit>().submitRequest(
            leaveTypeId: _selectedTypeId!,
            startDate: df.format(_dateRange!.start),
            endDate: df.format(_dateRange!.end),
            reason: _reasonController.text,
            attachment: _attachment,
          );
    } else if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih rentang tanggal cuti terlebih dahulu.'),
            backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const AppBrandTitle(section: 'Pengajuan Cuti'),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BrandPageBackground(
        child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: BlocConsumer<LeaveCubit, LeaveState>(
                    listener: (context, state) {
                      if (state is LeaveError) {
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
                      if (state is LeaveSubmitted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuccessSubmissionScreen(
                                title: 'Cuti Berhasil Diajukan!',
                                message: 'Pengajuan cuti Anda telah dicatat dalam sistem dan saat ini sedang menunggu persetujuan dari atasan atau HRD.',
                              ),
                            ),
                          );
                        });
                        return const Center(child: CircularProgressIndicator());
                      }

                      bool isLoading = state is LeaveLoading;
                      List<LeaveTypeModel> types = [];
                      List<LeaveBalanceModel> balances = [];
                      if (state is LeaveLoaded) {
                        types = state.types;
                        balances = state.balances;
                      } else if (context.read<LeaveCubit>().state is LeaveLoaded) {
                        final loadedState = context.read<LeaveCubit>().state as LeaveLoaded;
                        types = loadedState.types;
                        balances = loadedState.balances;
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10))
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Jenis Cuti',
                                    style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.h),
                                DropdownButtonFormField<int>(
                                  initialValue: _selectedTypeId,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!)),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 16.h),
                                  ),
                                  hint: const Text('Pilih Jenis Cuti'),
                                  items: types.map((t) {
                                    final matches = balances
                                        .where((b) => b.leaveTypeId == t.id);
                                    final remaining = matches.isEmpty
                                        ? t.quotaPerMonth ?? 0
                                        : matches.first.remainingDays;
                                    return DropdownMenuItem(
                                        value: t.id,
                                        child: Text(
                                            '${t.name} · sisa $remaining hari'));
                                  }).toList(),
                                  onChanged: isLoading
                                      ? null
                                      : (v) =>
                                          setState(() => _selectedTypeId = v),
                                  validator: (v) =>
                                      v == null ? 'Pilih jenis cuti' : null,
                                ),
                                SizedBox(height: 24.h),
                                Text('Rentang Tanggal',
                                    style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.h),
                                InkWell(
                                  onTap: isLoading ? null : _selectDateRange,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 16.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16.r),
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_month,
                                            color: AppColors.primary,
                                            size: 20.w),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            _dateRange == null
                                                ? 'Pilih tanggal mulai & akhir'
                                                : '${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange!.end)}',
                                            style: TextStyle(
                                                color: _dateRange == null
                                                    ? Colors.grey[600]
                                                    : Colors.black87,
                                                fontSize: 14.sp),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Text('Alasan Cuti',
                                    style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: _reasonController,
                                  maxLines: 4,
                                  enabled: !isLoading,
                                  decoration: InputDecoration(
                                    hintText: 'Jelaskan alasan cuti Anda',
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        borderSide: BorderSide(
                                            color: Colors.grey[200]!)),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 16.h),
                                  ),
                                  validator: (v) =>
                                      v?.isEmpty ?? true ? 'Wajib diisi' : null,
                                ),
                                SizedBox(height: 24.h),
                                Text('Lampiran Bukti (Opsional / Sakit)',
                                    style: TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 8.h),
                                InkWell(
                                  onTap: isLoading ? null : _pickFile,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 24.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3),
                                          style: BorderStyle.solid),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(Icons.cloud_upload_outlined,
                                            size: 32.w,
                                            color: AppColors.primary),
                                        SizedBox(height: 8.h),
                                        Text(
                                            _attachment == null
                                                ? 'Upload Foto Surat Keterangan'
                                                : 'File dipilih: ${_attachment!.path.split('/').last.split('\\').last}',
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
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
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.r)),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 24.w,
                                            height: 24.w,
                                            child:
                                                const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2))
                                        : Text('Kirim Pengajuan',
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
