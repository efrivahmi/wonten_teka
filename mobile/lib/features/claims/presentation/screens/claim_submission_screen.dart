import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ClaimSubmissionScreen extends StatefulWidget {
  const ClaimSubmissionScreen({super.key});
  @override
  State<ClaimSubmissionScreen> createState() => _ClaimSubmissionScreenState();
}

class _ClaimSubmissionScreenState extends State<ClaimSubmissionScreen> {
  String _category = 'Transport';
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _categories = [
    'Transport',
    'Makan',
    'Medis',
    'Parkir',
    'Internet',
    'Lainnya'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
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
      body: SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('KATEGORI'),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                        initialValue: _category,
                        items: _categories
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _category = v);
                        },
                        decoration: _deco('Pilih kategori')),
                    SizedBox(height: 24.h),
                    _label('JUMLAH (Rp)'),
                    SizedBox(height: 8.h),
                    TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: _deco('e.g. 150000')),
                    SizedBox(height: 24.h),
                    _label('DESKRIPSI'),
                    SizedBox(height: 8.h),
                    TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: _deco('Jelaskan detail klaim...')),
                    SizedBox(height: 24.h),
                    _label('TANGGAL PENGELUARAN'),
                    SizedBox(height: 8.h),
                    InkWell(
                        onTap: () {},
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
                            Text('Pilih tanggal',
                                style: TextStyle(
                                    color: AppColors.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                    fontSize: 14.sp))
                          ]),
                        )),
                    SizedBox(height: 24.h),
                    _label('BUKTI STRUK/NOTA'),
                    SizedBox(height: 8.h),
                    InkWell(
                        onTap: () {},
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Klaim berhasil dikirim!')));
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r))),
                          child: Text('Kirim Klaim',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp)),
                        )),
                  ]))),
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
